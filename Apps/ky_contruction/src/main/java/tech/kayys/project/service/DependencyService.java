package tech.kayys.project.service;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.project.domain.Project;
import tech.kayys.project.domain.ProjectTransaction;
import tech.kayys.project.domain.Task;
import tech.kayys.project.domain.TaskDependency;
import tech.kayys.project.repository.TaskDependencyRepository;
import tech.kayys.project.repository.TaskRepository;
import tech.kayys.project.repository.TransactionRepository;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

import io.quarkus.hibernate.reactive.panache.common.WithTransaction;
import io.smallrye.mutiny.Uni;

@ApplicationScoped
public class DependencyService {

    private final TaskDependencyRepository dependencyRepo;
    private final TaskRepository taskRepo;
    private final TransactionRepository txRepo;

    @Inject
    public DependencyService(TaskDependencyRepository dependencyRepo,
            TaskRepository taskRepo,
            TransactionRepository txRepo) {
        this.dependencyRepo = dependencyRepo;
        this.taskRepo = taskRepo;
        this.txRepo = txRepo;
    }

    /**
     * Create a dependency. If autoAdjust==true, successor will be shifted to
     * satisfy the constraint.
     * Otherwise the method will throw IllegalStateException if constraint not
     * satisfied.
     *
     * This operation is transactional: both dependency and transaction log are
     * persisted atomically.
     */
    @WithTransaction
    public Uni<TaskDependency> createDependency(TaskDependency dep, boolean autoAdjust, String createdBy) {
        Objects.requireNonNull(dep, "dependency required");
        Objects.requireNonNull(dep.predecessor, "predecessor required");
        Objects.requireNonNull(dep.successor, "successor required");

        if (dep.predecessor.id == null || dep.successor.id == null) {
            return Uni.createFrom().failure(
                    new IllegalArgumentException("predecessor and successor must be persisted tasks with ids"));
        }

        // basic project sanity check
        if (dep.predecessor.project == null || dep.successor.project == null ||
                !Objects.equals(dep.predecessor.project.id, dep.successor.project.id)) {
            return Uni.createFrom().failure(
                    new IllegalArgumentException("predecessor and successor must belong to the same project"));
        }

        // detect cycle first
        return dependencyRepo.findByProject(dep.predecessor.project.id)
                .map(deps -> {
                    Map<Long, Set<Long>> adj = new HashMap<>();
                    for (TaskDependency d : deps) {
                        adj.computeIfAbsent(d.predecessor.id, k -> new HashSet<>()).add(d.successor.id);
                    }
                    adj.computeIfAbsent(dep.predecessor.id, k -> new HashSet<>()).add(dep.successor.id);

                    if (detectCycle(adj)) {
                        throw new IllegalStateException("Adding this dependency would create a cycle");
                    }
                    return dep;
                })
                .flatMap(d -> dependencyRepo.persist(d).replaceWith(d))
                .flatMap(d -> adjustSuccessorIfNeeded(d, autoAdjust, createdBy))
                .flatMap(d -> logDependencyTransaction(d, createdBy));
    }

    /**
     * Validate the dependency constraint. If autoAdjust==true, will shift successor
     * dates to satisfy.
     * This method reads up-to-date tasks from repository and persists changes if
     * autoAdjust applies.
     */
    @WithTransaction
    public Uni<Void> validateDependencyConstraints(TaskDependency dep, boolean autoAdjust) {
        Uni<Task> predUni = taskRepo.findById(dep.predecessor.id);
        Uni<Task> succUni = taskRepo.findById(dep.successor.id);

        return Uni.combine().all().unis(predUni, succUni).asTuple()
                .flatMap(tuple -> {
                    Task pred = tuple.getItem1();
                    Task succ = tuple.getItem2();

                    if (pred == null || succ == null) {
                        return Uni.createFrom().failure(new IllegalStateException("Tasks not found"));
                    }
                    if (pred.startDate == null || pred.endDate == null || succ.startDate == null
                            || succ.endDate == null) {
                        return Uni.createFrom()
                                .failure(new IllegalStateException("Tasks must have startDate and endDate set"));
                    }

                    boolean adjusted = false;

                    switch (dep.type) {
                        case FS -> {
                            LocalDate minStart = pred.endDate.plusDays(dep.lag);
                            if (succ.startDate.isBefore(minStart)) {
                                if (autoAdjust) {
                                    long durationDays = Duration.between(
                                            succ.startDate.atStartOfDay(), succ.endDate.atStartOfDay()).toDays();
                                    succ.startDate = minStart;
                                    succ.endDate = succ.startDate.plusDays(Math.max(1, durationDays));
                                    adjusted = true;
                                } else {
                                    return Uni.createFrom().failure(
                                            new IllegalStateException(
                                                    "Successor starts before predecessor finishes (FS)"));
                                }
                            }
                        }
                        case SS -> {
                            LocalDate minStart = pred.startDate.plusDays(dep.lag);
                            if (succ.startDate.isBefore(minStart)) {
                                if (autoAdjust) {
                                    long durationDays = Duration.between(
                                            succ.startDate.atStartOfDay(), succ.endDate.atStartOfDay()).toDays();
                                    succ.startDate = minStart;
                                    succ.endDate = succ.startDate.plusDays(Math.max(1, durationDays));
                                    adjusted = true;
                                } else {
                                    return Uni.createFrom().failure(
                                            new IllegalStateException(
                                                    "Successor starts before predecessor starts (SS)"));
                                }
                            }
                        }
                        case FF -> {
                            LocalDate minEnd = pred.endDate.plusDays(dep.lag);
                            if (succ.endDate.isBefore(minEnd)) {
                                if (autoAdjust) {
                                    long durationDays = Duration.between(
                                            succ.startDate.atStartOfDay(), succ.endDate.atStartOfDay()).toDays();
                                    succ.endDate = minEnd;
                                    succ.startDate = succ.endDate.minusDays(Math.max(1, durationDays));
                                    adjusted = true;
                                } else {
                                    return Uni.createFrom().failure(
                                            new IllegalStateException("Successor ends before predecessor ends (FF)"));
                                }
                            }
                        }
                        case SF -> {
                            LocalDate minEnd = pred.startDate.plusDays(dep.lag);
                            if (succ.endDate.isBefore(minEnd)) {
                                if (autoAdjust) {
                                    long durationDays = Duration.between(
                                            succ.startDate.atStartOfDay(), succ.endDate.atStartOfDay()).toDays();
                                    succ.endDate = minEnd;
                                    succ.startDate = succ.endDate.minusDays(Math.max(1, durationDays));
                                    adjusted = true;
                                } else {
                                    return Uni.createFrom().failure(
                                            new IllegalStateException("Successor ends before predecessor starts (SF)"));
                                }
                            }
                        }
                        default -> {
                            return Uni.createFrom()
                                    .failure(new IllegalArgumentException("Unknown dependency type: " + dep.type));
                        }
                    }

                    if (adjusted) {
                        return taskRepo.persist(succ)
                                .flatMap(ignored -> {
                                    ProjectTransaction t = new ProjectTransaction();
                                    t.project = pred.project;
                                    t.transactionDate = LocalDateTime.now();
                                    t.transactionType = ProjectTransaction.TransactionType.UPDATE;
                                    t.domainType = ProjectTransaction.DomainType.TASK;
                                    t.referenceId = succ.id;
                                    t.description = "Auto-adjusted successor due to " + dep.type + " dependency";
                                    t.createdBy = "system";
                                    return txRepo.persist(t).replaceWithVoid();
                                });
                    } else {
                        return Uni.createFrom().voidItem();
                    }
                });
    }

    private Uni<TaskDependency> adjustSuccessorIfNeeded(TaskDependency dep, boolean autoAdjust, String createdBy) {
        return Uni.combine().all().unis(
                taskRepo.findById(dep.predecessor.id),
                taskRepo.findById(dep.successor.id)).asTuple()
                .flatMap(tuple -> {
                    Task pred = tuple.getItem1();
                    Task succ = tuple.getItem2();

                    if (pred == null || succ == null) {
                        return Uni.createFrom().failure(new IllegalStateException("Tasks not found"));
                    }

                    switch (dep.type) {
                        case FS:
                            LocalDate minStartFS = pred.endDate.plusDays(dep.lag);
                            if (succ.startDate.isBefore(minStartFS)) {
                                if (autoAdjust) {
                                    long duration = Math.max(1,
                                            Duration.between(succ.startDate.atStartOfDay(), succ.endDate.atStartOfDay())
                                                    .toDays());
                                    succ.startDate = minStartFS;
                                    succ.endDate = succ.startDate.plusDays(duration);
                                    return taskRepo.persist(succ)
                                            .replaceWith(dep)
                                            .flatMap(t -> logAutoShiftTransaction(pred.project, succ, "FS", createdBy));
                                } else {
                                    return Uni.createFrom().failure(
                                            new IllegalStateException(
                                                    "Successor starts before predecessor finishes (FS)"));
                                }
                            }
                            break;

                        case SS:
                            LocalDate minStartSS = pred.startDate.plusDays(dep.lag);
                            if (succ.startDate.isBefore(minStartSS)) {
                                if (autoAdjust) {
                                    long duration = Math.max(1,
                                            Duration.between(succ.startDate.atStartOfDay(), succ.endDate.atStartOfDay())
                                                    .toDays());
                                    succ.startDate = minStartSS;
                                    succ.endDate = succ.startDate.plusDays(duration);
                                    return taskRepo.persist(succ)
                                            .replaceWith(dep)
                                            .flatMap(t -> logAutoShiftTransaction(pred.project, succ, "SS", createdBy));
                                } else {
                                    return Uni.createFrom().failure(
                                            new IllegalStateException(
                                                    "Successor starts before predecessor starts (SS)"));
                                }
                            }
                            break;

                        case FF:
                            LocalDate minEndFF = pred.endDate.plusDays(dep.lag);
                            if (succ.endDate.isBefore(minEndFF)) {
                                if (autoAdjust) {
                                    long duration = Math.max(1,
                                            Duration.between(succ.startDate.atStartOfDay(), succ.endDate.atStartOfDay())
                                                    .toDays());
                                    succ.endDate = minEndFF;
                                    succ.startDate = succ.endDate.minusDays(duration);
                                    return taskRepo.persist(succ)
                                            .replaceWith(dep)
                                            .flatMap(t -> logAutoShiftTransaction(pred.project, succ, "FF", createdBy));
                                } else {
                                    return Uni.createFrom().failure(
                                            new IllegalStateException("Successor ends before predecessor ends (FF)"));
                                }
                            }
                            break;

                        case SF:
                            LocalDate minEndSF = pred.startDate.plusDays(dep.lag);
                            if (succ.endDate.isBefore(minEndSF)) {
                                if (autoAdjust) {
                                    long duration = Math.max(1,
                                            Duration.between(succ.startDate.atStartOfDay(), succ.endDate.atStartOfDay())
                                                    .toDays());
                                    succ.endDate = minEndSF;
                                    succ.startDate = succ.endDate.minusDays(duration);
                                    return taskRepo.persist(succ)
                                            .replaceWith(dep)
                                            .flatMap(t -> logAutoShiftTransaction(pred.project, succ, "SF", createdBy));
                                } else {
                                    return Uni.createFrom().failure(
                                            new IllegalStateException("Successor ends before predecessor starts (SF)"));
                                }
                            }
                            break;

                        default:
                            return Uni.createFrom()
                                    .failure(new IllegalArgumentException("Unknown dependency type: " + dep.type));
                    }
                    return Uni.createFrom().item(dep);
                });
    }

    private Uni<TaskDependency> logDependencyTransaction(TaskDependency dep, String createdBy) {
        ProjectTransaction tx = new ProjectTransaction();
        tx.project = dep.predecessor.project;
        tx.transactionDate = LocalDateTime.now();
        tx.transactionType = ProjectTransaction.TransactionType.CREATE;

        try {
            tx.domainType = ProjectTransaction.DomainType.valueOf("DEPENDENCY");
        } catch (IllegalArgumentException e) {
            tx.domainType = ProjectTransaction.DomainType.TASK;
        }

        tx.referenceId = dep.id;
        tx.description = String.format("DEPENDENCY %s pred=%d succ=%d lag=%d",
                dep.type, dep.predecessor.id, dep.successor.id, dep.lag);
        tx.createdBy = createdBy;
        tx.amount = null;

        return txRepo.persist(tx).replaceWith(dep);
    }

    private Uni<TaskDependency> logAutoShiftTransaction(Project project, Task succ, String type, String createdBy) {
        ProjectTransaction tx = new ProjectTransaction();
        tx.project = project;
        tx.transactionDate = LocalDateTime.now();
        tx.transactionType = ProjectTransaction.TransactionType.UPDATE;
        tx.domainType = ProjectTransaction.DomainType.TASK;
        tx.referenceId = succ.id;
        tx.description = "Auto-shifted successor due to " + type + " dependency: newStart=" + succ.startDate
                + ", newEnd=" + succ.endDate;
        tx.createdBy = createdBy;
        tx.amount = null;
        return txRepo.persist(tx).replaceWith(new TaskDependency());
    }

    private boolean dfsCycle(Long node, Map<Long, Set<Long>> adj, Set<Long> visited, Set<Long> stack) {
        if (stack.contains(node))
            return true;
        if (visited.contains(node))
            return false;
        visited.add(node);
        stack.add(node);
        for (Long neigh : adj.getOrDefault(node, Collections.emptySet())) {
            if (dfsCycle(neigh, adj, visited, stack))
                return true;
        }
        stack.remove(node);
        return false;
    }

    /**
     * Detect cycle directly from adjacency map.
     */
    public boolean detectCycle(Map<Long, Set<Long>> adj) {
        Set<Long> visited = new HashSet<>();
        Set<Long> stack = new HashSet<>();

        for (Long node : adj.keySet()) {
            if (dfsCycle(node, adj, visited, stack)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Detect if adding dependency `candidate` would create a cycle in the project's
     * dependency graph.
     */
    /*
     * public boolean detectCycle(TaskDependency candidate) {
     * Long projectId = candidate.predecessor.project.id;
     * List<TaskDependency> deps = dependencyRepo.findByProject(projectId);
     * 
     * // build adjacency map: predecessor -> set of successors
     * Map<Long, Set<Long>> adj = new HashMap<>();
     * for (TaskDependency d : deps) {
     * long predId = d.predecessor.id;
     * long succId = d.successor.id;
     * adj.computeIfAbsent(predId, k -> new HashSet<>()).add(succId);
     * }
     * // add the candidate edge
     * adj.computeIfAbsent(candidate.predecessor.id, k -> new
     * HashSet<>()).add(candidate.successor.id);
     * 
     * // perform DFS-based cycle detection
     * Set<Long> visited = new HashSet<>();
     * Set<Long> stack = new HashSet<>();
     * 
     * for (Long node : adj.keySet()) {
     * if (dfsCycle(node, adj, visited, stack))
     * return true;
     * }
     * return false;
     * }
     */

}
