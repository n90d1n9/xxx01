package tech.kayys.report.service;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.project.domain.Project;
import tech.kayys.project.domain.ProjectBudgetReport;
import tech.kayys.project.domain.ProjectResourceReport;
import tech.kayys.project.domain.ProjectTaskReport;
import tech.kayys.project.domain.ProjectTransaction;
import tech.kayys.project.domain.Task;
import tech.kayys.project.dto.BudgetBurnDownDTO;
import tech.kayys.project.dto.BudgetBurnDownPoint;
import tech.kayys.project.dto.ProjectHealthDTO;
import tech.kayys.project.dto.ResourceUtilizationDTO;
import tech.kayys.project.dto.ResourceUtilizationPoint;
import tech.kayys.project.dto.RiskTrendDTO;
import tech.kayys.project.dto.RiskTrendPoint;
import tech.kayys.project.dto.TaskProgressDTO;
import tech.kayys.project.repository.BudgetReportRepository;
import tech.kayys.project.repository.ProjectBudgetRepository;
import tech.kayys.project.repository.ResourceReportRepository;
import tech.kayys.project.repository.ResourceRepository;
import tech.kayys.project.repository.RiskReportRepository;
import tech.kayys.project.repository.TaskReportRepository;
import tech.kayys.project.repository.TaskRepository;
import tech.kayys.project.repository.TransactionRepository;
import tech.kayys.project.service.RiskSeverity;
import tech.kayys.risk.domain.ProjectRiskReport;
import tech.kayys.risk.repository.RiskRegisterRepository;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

import io.smallrye.mutiny.Uni;

/**
 * Reactive ReportingService (Mutiny/Uni) - refactored from blocking
 * implementation.
 * All public methods return Uni<T>.
 */
@ApplicationScoped
public class ReportingService {

    private final TransactionRepository txRepo;
    private final BudgetReportRepository budgetReportRepo;
    private final ResourceReportRepository resourceReportRepo;
    private final TaskReportRepository taskReportRepo;
    private final RiskReportRepository riskReportRepo;
    private final TaskRepository taskRepo;
    private final RiskRegisterRepository riskRepo;

    @Inject
    public ReportingService(
            TransactionRepository txRepo,
            BudgetReportRepository budgetReportRepo,
            ResourceReportRepository resourceReportRepo,
            TaskReportRepository taskReportRepo,
            RiskReportRepository riskReportRepo,
            ProjectBudgetRepository projectBudgetRepo,
            TaskRepository taskRepo,
            ResourceRepository resourceRepo,
            RiskRegisterRepository riskRepo) {
        this.txRepo = txRepo;
        this.budgetReportRepo = budgetReportRepo;
        this.resourceReportRepo = resourceReportRepo;
        this.taskReportRepo = taskReportRepo;
        this.riskReportRepo = riskReportRepo;
        this.taskRepo = taskRepo;
        this.riskRepo = riskRepo;
    }

    // ---------------- Reactive helpers ----------------

    // ---------------- Helpers ----------------
    private BigDecimal safe(BigDecimal b) {
        return b == null ? BigDecimal.ZERO : b;
    }

    private String deriveResourceType(ProjectTransaction tx) {
        if (tx.description != null && tx.description.contains("type:")) {
            String rest = tx.description.split("type:")[1].trim();
            String[] parts = rest.split("\\s+");
            return parts.length > 0 ? parts[0] : "UNKNOWN";
        }
        return "UNKNOWN";
    }

    // ---------------- Snapshot Reports (Budget / Resource / Task / Risk)
    // ----------------

    /**
     * Generate budget snapshot report for project (reactive).
     */
    public Uni<ProjectBudgetReport> generateBudgetReport(Long projectId) {
        return txRepo.find("project.id = ?1", projectId).list()
                .map(txs -> {
                    BigDecimal planned = BigDecimal.ZERO;
                    BigDecimal actual = BigDecimal.ZERO;
                    for (ProjectTransaction tx : txs) {
                        if (tx.domainType != ProjectTransaction.DomainType.BUDGET)
                            continue;
                        switch (tx.transactionType) {
                            case CREATE, UPDATE, APPROVE -> planned = planned.add(safe(tx.amount));
                            case ACTUAL, COMMITTED -> actual = actual.add(safe(tx.amount));
                            default -> {
                            }
                        }
                    }
                    ProjectBudgetReport rpt = new ProjectBudgetReport();
                    rpt.project = new Project();
                    rpt.project.id = projectId;
                    rpt.plannedBudget = planned;
                    rpt.actualSpent = actual;
                    rpt.remainingBudget = planned.subtract(actual);
                    rpt.lastUpdated = LocalDateTime.now();
                    return rpt;
                })
                .call(rpt -> budgetReportRepo.persist(rpt))
                .onFailure().recoverWithItem(err -> {
                    ProjectBudgetReport fallback = new ProjectBudgetReport();
                    fallback.project = new Project();
                    fallback.project.id = projectId;
                    fallback.plannedBudget = BigDecimal.ZERO;
                    fallback.actualSpent = BigDecimal.ZERO;
                    fallback.remainingBudget = BigDecimal.ZERO;
                    fallback.lastUpdated = LocalDateTime.now();
                    return fallback;
                });
    }

    /**
     * Generate resource snapshot report for project (reactive).
     */
    public Uni<ProjectResourceReport> generateResourceReport(Long projectId) {
        return txRepo.find("project.id = ?1 order by transactionDate", projectId).list()
                .map(txs -> {
                    int allocated = 0, released = 0;
                    Map<String, Integer> byType = new HashMap<>();
                    for (ProjectTransaction tx : txs) {
                        if (tx.domainType != ProjectTransaction.DomainType.RESOURCE)
                            continue;
                        int qty = tx.quantity == null ? 0 : tx.quantity;
                        String type = deriveResourceType(tx);
                        switch (tx.transactionType) {
                            case ALLOCATE -> {
                                allocated += qty;
                                byType.put(type, byType.getOrDefault(type, 0) + qty);
                            }
                            case RELEASE -> {
                                released += qty;
                                byType.put(type, Math.max(0, byType.getOrDefault(type, 0) - qty));
                            }
                            default -> {
                            }
                        }
                    }
                    ProjectResourceReport rpt = new ProjectResourceReport();
                    rpt.project = new Project();
                    rpt.project.id = projectId;
                    rpt.allocatedQuantity = allocated;
                    rpt.releasedQuantity = released;
                    rpt.inUse = Math.max(0, allocated - released);
                    rpt.utilizationRate = allocated > 0 ? ((double) (allocated - released)) / allocated : 0.0;
                    rpt.lastUpdated = LocalDateTime.now();
                    rpt.snapshotByType = byType;
                    return rpt;
                })
                .call(rpt -> resourceReportRepo.persist(rpt))
                .onFailure().recoverWithItem(err -> {
                    ProjectResourceReport fallback = new ProjectResourceReport();
                    fallback.project = new Project();
                    fallback.project.id = projectId;
                    fallback.allocatedQuantity = 0;
                    fallback.releasedQuantity = 0;
                    fallback.inUse = 0;
                    fallback.utilizationRate = 0.0;
                    fallback.snapshotByType = Collections.emptyMap();
                    fallback.lastUpdated = LocalDateTime.now();
                    return fallback;
                });
    }

    /**
     * Generate task snapshot report (reactive).
     */
    public Uni<ProjectTaskReport> generateTaskReport(Long projectId) {
        Uni<Project> projectUni = Project.<Project>findById(projectId);

        Uni<Long> totalUni = taskRepo.countByProject(projectId);
        Uni<Long> completedUni = taskRepo.countByProjectAndStatus(projectId, Task.TaskStatus.COMPLETED);
        Uni<Long> inProgressUni = taskRepo.countByProjectAndStatus(projectId, Task.TaskStatus.IN_PROGRESS);
        Uni<Long> notStartedUni = taskRepo.countByProjectAndStatus(projectId, Task.TaskStatus.PLANNED);

        return Uni.combine().all().unis(projectUni, totalUni, completedUni, inProgressUni, notStartedUni)
                .asTuple()
                .map(tuple -> {
                    Project project = tuple.getItem1();
                    int total = tuple.getItem2().intValue();
                    int completed = tuple.getItem3().intValue();
                    int inProgress = tuple.getItem4().intValue();
                    int notStarted = tuple.getItem5().intValue();

                    ProjectTaskReport rpt = new ProjectTaskReport();
                    rpt.project = project; // now it's safe
                    rpt.totalTasks = total;
                    rpt.completedTasks = completed;
                    rpt.inProgressTasks = inProgress;
                    rpt.notStartedTasks = notStarted;
                    rpt.completionRate = total > 0 ? ((double) completed) / total : 0.0;
                    rpt.lastUpdated = LocalDateTime.now();

                    return rpt;
                })
                .call(rpt -> taskReportRepo.persist(rpt))
                .onFailure().recoverWithItem(err -> {
                    ProjectTaskReport fallback = new ProjectTaskReport();
                    fallback.project = new Project();
                    fallback.project.id = projectId;
                    fallback.totalTasks = 0;
                    fallback.completedTasks = 0;
                    fallback.inProgressTasks = 0;
                    fallback.notStartedTasks = 0;
                    fallback.completionRate = 0.0;
                    fallback.lastUpdated = LocalDateTime.now();
                    return fallback;
                });
    }

    /**
     * Generate risk snapshot report (reactive).
     */
    public Uni<ProjectRiskReport> generateRiskReport(Long projectId) {
        return txRepo.find("project.id = ?1 and domainType = ?2", projectId, ProjectTransaction.DomainType.RISK).list()
                .map(txs -> {
                    int open = 0, closed = 0, high = 0, medium = 0, low = 0;
                    for (ProjectTransaction tx : txs) {
                        switch (tx.transactionType) {
                            case CREATE -> open++;
                            case DELETE -> closed++;
                            default -> {
                            }
                        }
                        String desc = tx.description == null ? "" : tx.description.toUpperCase();
                        if (desc.contains("HIGH"))
                            high++;
                        else if (desc.contains("MEDIUM"))
                            medium++;
                        else if (desc.contains("LOW"))
                            low++;
                    }
                    ProjectRiskReport rpt = new ProjectRiskReport();
                    rpt.project = new Project();
                    rpt.project.id = projectId;
                    rpt.openRisks = open;
                    rpt.closedRisks = closed;
                    rpt.highRisks = high;
                    rpt.mediumRisks = medium;
                    rpt.lowRisks = low;
                    rpt.lastUpdated = LocalDateTime.now();
                    return rpt;
                })
                .call(rpt -> riskReportRepo.persist(rpt))
                .onFailure().recoverWithItem(err -> {
                    ProjectRiskReport fallback = new ProjectRiskReport();
                    fallback.project = new Project();
                    fallback.project.id = projectId;
                    fallback.openRisks = 0;
                    fallback.closedRisks = 0;
                    fallback.highRisks = 0;
                    fallback.mediumRisks = 0;
                    fallback.lowRisks = 0;
                    fallback.lastUpdated = LocalDateTime.now();
                    return fallback;
                });
    }

    // ---------------- Time-series / Analytical Reports ----------------

    /**
     * Budget burn-down (by day, inclusive window) - reactive.
     */
    public Uni<BudgetBurnDownDTO> generateBudgetBurnDown(Long projectId, LocalDate from, LocalDate to) {
        if (from == null || to == null)
            return Uni.createFrom().failure(new IllegalArgumentException("from/to required"));
        if (to.isBefore(from))
            return Uni.createFrom().failure(new IllegalArgumentException("to must be >= from"));

        return txRepo.find(
                "project.id = ?1 and domainType = ?2 and transactionDate >= ?3 and transactionDate < ?4 order by transactionDate",
                projectId, ProjectTransaction.DomainType.BUDGET, from.atStartOfDay(), to.plusDays(1).atStartOfDay())
                .list()
                .map(txs -> {
                    Map<LocalDate, BigDecimal> plannedByDay = new TreeMap<>();
                    Map<LocalDate, BigDecimal> actualByDay = new TreeMap<>();
                    for (ProjectTransaction tx : txs) {
                        LocalDate d = tx.transactionDate.toLocalDate();
                        BigDecimal amt = safe(tx.amount);
                        switch (tx.transactionType) {
                            case CREATE:
                            case UPDATE:
                            case APPROVE:
                                plannedByDay.put(d, plannedByDay.getOrDefault(d, BigDecimal.ZERO).add(amt));
                                break;
                            case ACTUAL:
                            case COMMITTED:
                                actualByDay.put(d, actualByDay.getOrDefault(d, BigDecimal.ZERO).add(amt));
                                break;
                            case ADJUSTMENT:
                                plannedByDay.put(d, plannedByDay.getOrDefault(d, BigDecimal.ZERO).add(amt));
                                break;
                            default:
                                break;
                        }
                    }

                    BigDecimal runningPlanned = BigDecimal.ZERO;
                    BigDecimal runningActual = BigDecimal.ZERO;
                    List<BudgetBurnDownPoint> points = new ArrayList<>();
                    LocalDate cur = from;
                    while (!cur.isAfter(to)) {
                        runningPlanned = runningPlanned.add(plannedByDay.getOrDefault(cur, BigDecimal.ZERO));
                        runningActual = runningActual.add(actualByDay.getOrDefault(cur, BigDecimal.ZERO));
                        points.add(new BudgetBurnDownPoint(cur, runningPlanned, runningActual));
                        cur = cur.plusDays(1);
                    }
                    return new BudgetBurnDownDTO(projectId, points, runningPlanned, runningActual);
                });
    }

    /**
     * Resource utilization timeline - reactive.
     */
    public Uni<ResourceUtilizationDTO> generateResourceUtilization(Long projectId, LocalDate from, LocalDate to) {
        if (from == null || to == null)
            return Uni.createFrom().failure(new IllegalArgumentException("from/to required"));
        if (to.isBefore(from))
            return Uni.createFrom().failure(new IllegalArgumentException("to must be >= from"));

        return txRepo.find(
                "project.id = ?1 and domainType = ?2 and transactionDate >= ?3 and transactionDate < ?4 order by transactionDate",
                projectId, ProjectTransaction.DomainType.RESOURCE, from.atStartOfDay(), to.plusDays(1).atStartOfDay())
                .list()
                .map(txs -> {
                    Map<String, Integer> running = new HashMap<>();
                    Map<LocalDate, Map<String, Integer>> dailySnapshot = new TreeMap<>();
                    for (ProjectTransaction tx : txs) {
                        LocalDate d = tx.transactionDate.toLocalDate();
                        String rtype = deriveResourceType(tx);
                        int qty = tx.quantity == null ? 0 : tx.quantity;
                        switch (tx.transactionType) {
                            case ALLOCATE:
                                running.put(rtype, running.getOrDefault(rtype, 0) + qty);
                                break;
                            case RELEASE:
                                running.put(rtype, Math.max(0, running.getOrDefault(rtype, 0) - qty));
                                break;
                            default:
                                break;
                        }
                        dailySnapshot.put(d, new HashMap<>(running));
                    }

                    List<ResourceUtilizationPoint> points = new ArrayList<>();
                    LocalDate cur = from;
                    Map<String, Integer> last = new HashMap<>();
                    while (!cur.isAfter(to)) {
                        Map<String, Integer> snap = dailySnapshot.getOrDefault(cur, last);
                        for (Map.Entry<String, Integer> e : snap.entrySet()) {
                            points.add(new ResourceUtilizationPoint(cur, e.getKey(), e.getValue()));
                        }
                        last = snap;
                        cur = cur.plusDays(1);
                    }

                    Map<String, Object> summary = new HashMap<>();
                    summary.put("snapshot", running);
                    return new ResourceUtilizationDTO(projectId, summary, points);
                });
    }

    /**
     * Task progress snapshot - reactive (uses authoritative taskRepo counts).
     */
    public Uni<TaskProgressDTO> generateTaskProgress(Long projectId) {
        return TaskProgressDTO.fromRepoCounts(
                taskRepo.countByProject(projectId),
                taskRepo.countByProjectAndStatus(projectId, Task.TaskStatus.COMPLETED),
                taskRepo.countByProjectAndStatus(projectId, Task.TaskStatus.IN_PROGRESS),
                taskRepo.countByProjectAndStatus(projectId, Task.TaskStatus.PLANNED),
                projectId);
    }

    /**
     * Risk trend timeline - reactive.
     */
    public Uni<RiskTrendDTO> generateRiskTrend(Long projectId, LocalDate from, LocalDate to) {
        if (from == null || to == null)
            return Uni.createFrom().failure(new IllegalArgumentException("from/to required"));
        if (to.isBefore(from))
            return Uni.createFrom().failure(new IllegalArgumentException("to must be >= from"));

        return txRepo.find(
                "project.id = ?1 and domainType = ?2 and transactionDate >= ?3 and transactionDate < ?4 order by transactionDate",
                projectId, ProjectTransaction.DomainType.RISK, from.atStartOfDay(), to.plusDays(1).atStartOfDay())
                .list()
                .flatMap(txs -> {
                    Map<LocalDate, Integer> openByDay = new TreeMap<>();
                    Map<LocalDate, Integer> highByDay = new TreeMap<>();
                    int runningOpen = 0;
                    int runningHigh = 0;
                    for (ProjectTransaction tx : txs) {
                        LocalDate d = tx.transactionDate.toLocalDate();
                        switch (tx.transactionType) {
                            case CREATE:
                                runningOpen++;
                                if (tx.description != null && tx.description.contains("severity:HIGH"))
                                    runningHigh++;
                                break;
                            case DELETE:
                                runningOpen = Math.max(0, runningOpen - 1);
                                break;
                            case UPDATE:
                                if (tx.description != null && tx.description.contains("severity:HIGH"))
                                    runningHigh++;
                                break;
                            default:
                                break;
                        }
                        openByDay.put(d, runningOpen);
                        highByDay.put(d, runningHigh);
                    }

                    List<RiskTrendPoint> points = new ArrayList<>();
                    LocalDate cur = from;
                    while (!cur.isAfter(to)) {
                        points.add(new RiskTrendPoint(cur, openByDay.getOrDefault(cur, 0),
                                highByDay.getOrDefault(cur, 0)));
                        cur = cur.plusDays(1);
                    }

                    return Uni.combine().all()
                            .unis(riskRepo.countByProject(projectId),
                                    riskRepo.countByProjectAndSeverity(projectId, RiskSeverity.HIGH))
                            .asTuple()
                            .map(t -> new RiskTrendDTO(projectId, points, t.getItem1().intValue(),
                                    t.getItem2().intValue()));
                });
    }

    // ---------------- Composite Project Health ----------------

    public Uni<ProjectHealthDTO> generateProjectHealth(Long projectId) {
        Uni<ProjectBudgetReport> brUni = budgetReportRepo.findByProjectId(projectId)
                .onItem().ifNull().continueWith(() -> null)
                .flatMap(br -> br == null ? buildBudgetSnapshotFromTransactions(projectId) : Uni.createFrom().item(br));

        Uni<TaskProgressDTO> tpUni = generateTaskProgress(projectId);
        Uni<Long> highRisksUni = riskRepo.countByProjectAndSeverity(projectId, RiskSeverity.HIGH);

        return Uni.combine().all().unis(brUni, tpUni, highRisksUni).asTuple()
                .map(t -> {
                    ProjectBudgetReport br = t.getItem1();
                    TaskProgressDTO tp = t.getItem2();
                    long highRisks = t.getItem3();

                    double budgetScore = 1.0;
                    if (br != null && br.plannedBudget != null
                            && br.plannedBudget.compareTo(BigDecimal.ZERO) > 0) {
                        BigDecimal ratio = br.actualSpent.divide(br.plannedBudget, 4, RoundingMode.DOWN);
                        budgetScore = Math.max(0.0, 1.0 - ratio.doubleValue());
                    }

                    double scheduleScore = tp == null ? 0.0 : tp.completionRate();
                    double riskScore = Math.max(0.0, 1.0 - Math.min(1.0, ((double) highRisks) / 10.0));
                    double overall = (budgetScore * 0.4) + (scheduleScore * 0.4) + (riskScore * 0.2);
                    return new ProjectHealthDTO(projectId, budgetScore, scheduleScore, riskScore, overall);
                });
    }

    // ---------------- Fallback budget snapshot builder (reactive) ----------------

    private Uni<ProjectBudgetReport> buildBudgetSnapshotFromTransactions(Long projectId) {
        LocalDate today = LocalDate.now();
        LocalDate from = today.minusYears(1);
        LocalDate to = today;

        return generateBudgetBurnDown(projectId, from, to)
                .map(dto -> {
                    ProjectBudgetReport r = new ProjectBudgetReport();
                    r.project = new Project();
                    r.project.id = projectId;
                    r.plannedBudget = dto.plannedTotal();
                    r.actualSpent = dto.actualTotal();
                    r.remainingBudget = dto.plannedTotal().subtract(dto.actualTotal());
                    r.lastUpdated = LocalDateTime.now();
                    return r;
                });
    }

}
