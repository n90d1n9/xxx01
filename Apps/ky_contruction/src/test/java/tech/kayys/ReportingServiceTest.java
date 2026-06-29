package tech.kayys;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentMatchers;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class ReportingServiceTest {

    TransactionRepository txRepo;
    ProjectBudgetRepository budgetRepo;
    TaskRepository taskRepo;
    ResourceRepository resourceRepo;
    RiskRepository riskRepo;
    ProjectRepository projectRepo;
    ProjectBudgetReportRepository budgetReportRepo;
    ProjectResourceReportRepository resourceReportRepo;
    ProjectTaskReportRepository taskReportRepo;
    ProjectRiskReportRepository riskReportRepo;

    ReportingService service;

    @BeforeEach
    void setup() {
        txRepo = mock(TransactionRepository.class);
        budgetRepo = mock(ProjectBudgetRepository.class);
        taskRepo = mock(TaskRepository.class);
        resourceRepo = mock(ResourceRepository.class);
        riskRepo = mock(RiskRepository.class);
        projectRepo = mock(ProjectRepository.class);
        budgetReportRepo = mock(ProjectBudgetReportRepository.class);
        resourceReportRepo = mock(ProjectResourceReportRepository.class);
        taskReportRepo = mock(ProjectTaskReportRepository.class);
        riskReportRepo = mock(ProjectRiskReportRepository.class);

        service = new ReportingService(txRepo, budgetRepo, taskRepo, resourceRepo, riskRepo, projectRepo,
                budgetReportRepo, resourceReportRepo, taskReportRepo, riskReportRepo);
    }

    @Test
    void testGenerateBudgetBurnDown_basic() {
        Long pid = 1L;
        LocalDate from = LocalDate.of(2025, 9, 1);
        LocalDate to = LocalDate.of(2025, 9, 3);

        ProjectTransaction t1 = new ProjectTransaction();
        t1.setTransactionDate(LocalDateTime.of(2025, 9, 1, 10, 0));
        t1.setTransactionType(ProjectTransaction.TransactionType.CREATE);
        t1.setDomainType(ProjectTransaction.DomainType.BUDGET);
        t1.setAmount(new BigDecimal("1000"));

        ProjectTransaction t2 = new ProjectTransaction();
        t2.setTransactionDate(LocalDateTime.of(2025, 9, 2, 12, 0));
        t2.setTransactionType(ProjectTransaction.TransactionType.ACTUAL);
        t2.setDomainType(ProjectTransaction.DomainType.BUDGET);
        t2.setAmount(new BigDecimal("200"));

        when(txRepo.findByProjectAndDomainBetween(eq(pid), eq(ProjectTransaction.DomainType.BUDGET),
                any(), any())).thenReturn(List.of(t1, t2));

        var dto = service.generateBudgetBurnDown(pid, from, to);
        assertEquals(pid, dto.projectId());
        assertEquals(3, dto.points().size()); // 1st, 2nd, 3rd
        // day1 planned 1000, actual 0
        assertEquals(new BigDecimal("1000"), dto.points().get(0).planned());
        assertEquals(new BigDecimal("0"), dto.points().get(0).actual());
        // day2 cumulative planned 1000, actual 200
        assertEquals(new BigDecimal("1000"), dto.points().get(1).planned());
        assertEquals(new BigDecimal("200"), dto.points().get(1).actual());
        assertEquals(new BigDecimal("1000"), dto.plannedTotal());
        assertEquals(new BigDecimal("200"), dto.actualTotal());
    }

    @Test
    void testGenerateTaskProgress_counts() {
        Long pid = 2L;
        when(taskRepo.countByProject(pid)).thenReturn(5L);
        when(taskRepo.countByProjectAndStatus(pid, Task.TaskStatus.COMPLETED)).thenReturn(2L);

        var dto = service.generateTaskProgress(pid);
        assertEquals(5, dto.totalTasks());
        assertEquals(2, dto.completed());
        assertEquals(0.4, dto.completionRate(), 0.0001);
    }
}
