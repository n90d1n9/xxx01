package tech.kayys.report.service;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.project.domain.Project;
import tech.kayys.project.domain.ProjectBudgetReport;
import tech.kayys.project.domain.ProjectResourceReport;
import tech.kayys.project.domain.ProjectTaskReport;
import tech.kayys.project.repository.BudgetReportRepository;
import tech.kayys.project.repository.ProjectRepository;
import tech.kayys.project.repository.ResourceReportRepository;
import tech.kayys.project.repository.RiskReportRepository;
import tech.kayys.project.repository.TaskReportRepository;
import tech.kayys.risk.domain.ProjectRiskReport;

import org.jboss.logging.Logger;
import io.quarkus.scheduler.Scheduled;
import io.smallrye.mutiny.Uni;

import java.time.LocalDate;
import java.time.LocalDateTime;

@ApplicationScoped
public class ReportingAggregator {

    private static final Logger LOG = Logger.getLogger(ReportingAggregator.class);

    private final ReportingService reportingService;
    private final ProjectRepository projectRepo;
    private final BudgetReportRepository budgetReportRepo;
    private final ResourceReportRepository resourceReportRepo;
    private final TaskReportRepository taskReportRepo;
    private final RiskReportRepository riskReportRepo;

    @Inject
    public ReportingAggregator(
            ReportingService reportingService,
            ProjectRepository projectRepo,
            BudgetReportRepository budgetReportRepo,
            ResourceReportRepository resourceReportRepo,
            TaskReportRepository taskReportRepo,
            RiskReportRepository riskReportRepo) {
        this.reportingService = reportingService;
        this.projectRepo = projectRepo;
        this.budgetReportRepo = budgetReportRepo;
        this.resourceReportRepo = resourceReportRepo;
        this.taskReportRepo = taskReportRepo;
        this.riskReportRepo = riskReportRepo;
    }

    /**
     * Run aggregation regularly (reactive, non-blocking).
     */
    @Scheduled(every = "1m")
    void aggregateAll() {
        projectRepo.listAll() // PanacheRepositoryReactive: returns Uni<List<Project>>
                .flatMap(projects -> {
                    LOG.debugf("ReportingAggregator running for %d projects", projects.size());
                    return Uni.combine().all().unis(
                            projects.stream()
                                    .map(this::aggregateProject)
                                    .toList())
                            .discardItems(); // ignore individual results
                })
                .subscribe().with(
                        unused -> LOG.debug("All project reports aggregated successfully"),
                        failure -> LOG.error("Failed aggregating project reports", failure));
    }

   private Uni<Void> aggregateProject(Project p) {
    LocalDate start = p.startDate;
    LocalDate end = p.endDate != null ? p.endDate : start.plusDays(30);

    Uni<ProjectBudgetReport> budgetUni = reportingService.generateBudgetBurnDown(p.id, start, end)
            .map(br -> {
                ProjectBudgetReport projBr = new ProjectBudgetReport();
                projBr.project = p;
                projBr.plannedBudget = br.plannedTotal();
                projBr.actualSpent = br.actualTotal();
                projBr.remainingBudget = br.plannedTotal().subtract(br.actualTotal());
                projBr.lastUpdated = LocalDateTime.now();
                return projBr;
            })
            .flatMap(budgetReportRepo::upsertByProject);

    Uni<ProjectResourceReport> resourceUni = reportingService.generateResourceUtilization(p.id, start, end)
            .map(rrDto -> {
                ProjectResourceReport rr = new ProjectResourceReport();
                rr.project = p;
                rr.lastUpdated = LocalDateTime.now();
                rr.allocatedQuantity = ((Number) rrDto.summary().getOrDefault("allocated", 0)).intValue();
                rr.inUse = ((Number) rrDto.summary().getOrDefault("inUse", 0)).intValue();
                return rr;
            })
            .flatMap(resourceReportRepo::upsertByProject);

    Uni<ProjectTaskReport> taskUni = reportingService.generateTaskProgress(p.id)
            .map(tr -> {
                ProjectTaskReport trp = new ProjectTaskReport();
                trp.project = p;
                trp.totalTasks = tr.totalTasks();
                trp.completedTasks = tr.completed();
                trp.inProgressTasks = tr.inProgress();
                trp.notStartedTasks = tr.notStarted();
                trp.completionRate = tr.completionRate();
                trp.lastUpdated = LocalDateTime.now();
                return trp;
            })
            .flatMap(taskReportRepo::upsertByProject);

    Uni<ProjectRiskReport> riskUni = reportingService.generateRiskTrend(p.id, start, end)
            .map(riskDto -> {
                ProjectRiskReport rrp = new ProjectRiskReport();
                rrp.project = p;
                rrp.openRisks = riskDto.openRisksNow();
                rrp.highRisks = riskDto.highRisksNow();
                rrp.lastUpdated = LocalDateTime.now();
                return rrp;
            })
            .flatMap(riskReportRepo::upsertByProject);

    return Uni.combine().all().unis(budgetUni, resourceUni, taskUni, riskUni)
            .discardItems()
            .onFailure().invoke(ex -> LOG.errorf(ex, "Failed aggregating reports for project %d", p.id));
}


}
