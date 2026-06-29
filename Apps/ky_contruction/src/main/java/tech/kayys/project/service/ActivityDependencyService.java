package tech.kayys.project.service;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.project.domain.ActivityDependency;
import tech.kayys.project.domain.ProjectTransaction;
import tech.kayys.project.domain.ScheduleActivity;
import tech.kayys.project.repository.ActivityDependencyRepository;
import tech.kayys.project.repository.ScheduleActivityRepository;
import tech.kayys.project.repository.TransactionRepository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

import io.quarkus.hibernate.reactive.panache.common.WithTransaction;
import io.smallrye.mutiny.Uni;

@ApplicationScoped
public class ActivityDependencyService {

    private final ActivityDependencyRepository depRepo;
    private final ScheduleActivityRepository actRepo;
    private final TransactionRepository txRepo;

    @Inject
    public ActivityDependencyService(ActivityDependencyRepository depRepo,
            ScheduleActivityRepository actRepo,
            TransactionRepository txRepo) {
        this.depRepo = depRepo;
        this.actRepo = actRepo;
        this.txRepo = txRepo;
    }

    @WithTransaction
    public Uni<ActivityDependency> createDependency(ActivityDependency dep, boolean autoAdjust, String createdBy) {
        Objects.requireNonNull(dep.predecessor, "predecessor required");
        Objects.requireNonNull(dep.successor, "successor required");

        if (dep.predecessor.id == null || dep.successor.id == null) {
            return Uni.createFrom().failure(
                    new IllegalArgumentException("predecessor and successor must be persisted activities"));
        }

        // Same project validation
        if (!Objects.equals(
                dep.predecessor.schedule.project.id,
                dep.successor.schedule.project.id)) {
            return Uni.createFrom().failure(
                    new IllegalArgumentException("Predecessor and successor must belong to the same project"));
        }

        return detectCycle(dep.predecessor, dep.successor)
                .flatMap(hasCycle -> {
                    if (hasCycle) {
                        return Uni.createFrom().failure(
                                new IllegalStateException("Adding this dependency would create a cycle"));
                    }
                    return validateConstraint(dep, autoAdjust)
                            .flatMap(updatedSucc -> depRepo.persist(dep).replaceWith(dep))
                            .flatMap(saved -> logTransaction(saved, createdBy).replaceWith(saved));
                });
    }

    private Uni<ScheduleActivity> validateConstraint(ActivityDependency dep, boolean autoAdjust) {
        ScheduleActivity pred = dep.predecessor;
        ScheduleActivity succ = dep.successor;

        LocalDate predStart = pred.actualStart != null ? pred.actualStart : pred.earlyStart;
        LocalDate predFinish = pred.actualFinish != null ? pred.actualFinish : pred.earlyFinish;
        LocalDate succStart = succ.actualStart != null ? succ.actualStart : succ.earlyStart;
        LocalDate succFinish = succ.actualFinish != null ? succ.actualFinish : succ.earlyFinish;

        boolean needsUpdate = false;

        switch (dep.dependencyType) {
            case FINISH_TO_START:
                if (succStart.isBefore(predFinish.plusDays(dep.lagDuration))) {
                    if (autoAdjust) {
                        succ.earlyStart = predFinish.plusDays(dep.lagDuration);
                        needsUpdate = true;
                    } else {
                        return Uni.createFrom().failure(new IllegalStateException("FS constraint violated"));
                    }
                }
                break;

            case START_TO_START:
                if (succStart.isBefore(predStart.plusDays(dep.lagDuration))) {
                    if (autoAdjust) {
                        succ.earlyStart = predStart.plusDays(dep.lagDuration);
                        needsUpdate = true;
                    } else {
                        return Uni.createFrom().failure(new IllegalStateException("SS constraint violated"));
                    }
                }
                break;

            case FINISH_TO_FINISH:
                if (succFinish.isBefore(predFinish.plusDays(dep.lagDuration))) {
                    if (autoAdjust) {
                        succ.earlyFinish = predFinish.plusDays(dep.lagDuration);
                        needsUpdate = true;
                    } else {
                        return Uni.createFrom().failure(new IllegalStateException("FF constraint violated"));
                    }
                }
                break;

            case START_TO_FINISH:
                if (succFinish.isBefore(predStart.plusDays(dep.lagDuration))) {
                    if (autoAdjust) {
                        succ.earlyFinish = predStart.plusDays(dep.lagDuration);
                        needsUpdate = true;
                    } else {
                        return Uni.createFrom().failure(new IllegalStateException("SF constraint violated"));
                    }
                }
                break;
        }

        if (needsUpdate) {
            return actRepo.persist(succ).replaceWith(succ);
        }
        return Uni.createFrom().item(succ);
    }

    private Uni<Boolean> detectCycle(ScheduleActivity predecessor, ScheduleActivity successor) {
        return depRepo.findByProject(predecessor.schedule.project.id)
                .map(deps -> {
                    // Build adjacency
                    Map<Long, Set<Long>> adj = new HashMap<>();
                    for (ActivityDependency d : deps) {
                        adj.computeIfAbsent(d.predecessor.id, k -> new HashSet<>()).add(d.successor.id);
                    }
                    // Add candidate edge
                    adj.computeIfAbsent(predecessor.id, k -> new HashSet<>()).add(successor.id);

                    // DFS cycle detection
                    Set<Long> visited = new HashSet<>();
                    Set<Long> stack = new HashSet<>();
                    for (Long node : adj.keySet()) {
                        if (dfsCycle(node, adj, visited, stack))
                            return true;
                    }
                    return false;
                });
    }

    private boolean dfsCycle(Long node, Map<Long, Set<Long>> adj, Set<Long> visited, Set<Long> stack) {
        if (stack.contains(node))
            return true;
        if (!visited.add(node))
            return false;

        stack.add(node);
        for (Long succ : adj.getOrDefault(node, Set.of())) {
            if (dfsCycle(succ, adj, visited, stack))
                return true;
        }
        stack.remove(node);
        return false;
    }

    private Uni<Void> logTransaction(ActivityDependency dep, String createdBy) {
        ProjectTransaction tx = new ProjectTransaction();
        tx.project = dep.predecessor.schedule.project; // ✅ fixed
        tx.transactionDate = LocalDateTime.now();
        tx.transactionType = ProjectTransaction.TransactionType.CREATE;
        tx.domainType = ProjectTransaction.DomainType.DEPENDENCY;
        tx.referenceId = dep.id;
        tx.description = String.format(
                "Dependency %s between predecessor=%d and successor=%d (lag=%d)",
                dep.dependencyType, dep.predecessor.id, dep.successor.id, dep.lagDuration);
        tx.createdBy = createdBy;
        return txRepo.persist(tx).replaceWithVoid();
    }

}
