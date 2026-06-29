package tech.kayys.project.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.quarkus.panache.common.Page;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.ws.rs.NotFoundException;
import tech.kayys.contract.domain.Contract;
import tech.kayys.contract.domain.ContractClaim;
import tech.kayys.contract.domain.DocumentControl;
import tech.kayys.project.domain.Project;
import tech.kayys.project.domain.ProjectTransaction;
import tech.kayys.project.dto.ProjectRequest;
import tech.kayys.project.dto.ProjectResponse;
import tech.kayys.project.dto.ProjectSearchCriteria;
import tech.kayys.project.model.ProjectMapper;
import tech.kayys.project.repository.ProjectRepository;
import tech.kayys.risk.dto.TransactionDTO;

@ApplicationScoped
public class ProjectService {

    @Inject
    ProjectRepository projectRepo;
    @Inject
    TransactionService transactionService;
     /** ✅ Create project with transaction logging */
    @Inject ProjectMapper mapper;



    /** ✅ Paginated list */
    public Uni<List<Project>> listAllPaginated(int page, int size) {
        return projectRepo.findAll()
                .page(page, size)
                .list();
    }

    /** ✅ Count projects */
    public Uni<Long> countAll() {
        return Project.count();
    }



    /** ✅ Check existence */
    public Uni<Boolean> existsById(Long id) {
        return projectRepo.findById(id).map(p -> p != null);
    }

   

    /** ✅ Create */
    public Uni<ProjectResponse> create(ProjectRequest dto, String createdBy) {
        return generateProjectCode()
            .flatMap(code -> {
                Project entity = mapper.toEntity(dto);
                entity.projectCode = code;
                entity.createdDate = LocalDateTime.now();
                return projectRepo.persist(entity)
                    .flatMap(p -> transactionService.logTransaction(new TransactionDTO(
                            null, p.id,
                            ProjectTransaction.TransactionType.CREATE,
                            ProjectTransaction.DomainType.PROJECT,
                            null, null,
                            "Project created",
                            createdBy,
                            LocalDateTime.now()))
                        .replaceWith(mapper.toResponse(p)));
            });
    }

    /** ✅ Update */
    public Uni<ProjectResponse> update(Long id, ProjectRequest dto, String updatedBy) {
        return projectRepo.findById(id)
            .onItem().ifNull().failWith(() -> new NotFoundException("Project not found"))
            .flatMap(existing -> {
                mapper.updateEntity(existing, dto);
                existing.updatedDate = LocalDateTime.now();
                return projectRepo.persist(existing)
                    .flatMap(p -> transactionService.logTransaction(new TransactionDTO(
                            null, p.id,
                            ProjectTransaction.TransactionType.UPDATE,
                            ProjectTransaction.DomainType.PROJECT,
                            null, null,
                            "Project updated",
                            updatedBy,
                            LocalDateTime.now()))
                        .replaceWith(mapper.toResponse(p)));
            });
    }

    /** ✅ Find by ID */
    public Uni<ProjectResponse> findById(Long id) {
        return projectRepo.findById(id)
            .onItem().ifNull().failWith(() -> new NotFoundException("Project not found"))
            .map(mapper::toResponse);
    }

    /** ✅ List all */
    public Uni<List<ProjectResponse>> listAll() {
        return projectRepo.listAll()
            .map(list -> list.stream().map(mapper::toResponse).toList());
    }

    /** ✅ Search with criteria and pagination */
    public Uni<List<ProjectResponse>> search(ProjectSearchCriteria criteria) {
        StringBuilder jpql = new StringBuilder("1=1");
        List<Object> params = new ArrayList<>();
        int idx = 1;

        if (criteria.keyword != null && !criteria.keyword.isBlank()) {
            jpql.append(" AND (LOWER(name) LIKE ?").append(idx).append(" OR LOWER(description) LIKE ?").append(idx).append(")");
            params.add("%" + criteria.keyword.toLowerCase() + "%");
            idx++;
        }
        if (criteria.status != null) {
            jpql.append(" AND status = ?").append(idx);
            params.add(criteria.status);
            idx++;
        }
        if (criteria.startDate != null) {
            jpql.append(" AND startDate >= ?").append(idx);
            params.add(criteria.startDate);
            idx++;
        }
        if (criteria.endDate != null) {
            jpql.append(" AND endDate <= ?").append(idx);
            params.add(criteria.endDate);
            idx++;
        }

        return projectRepo.find(jpql.toString(), params.toArray())
            .page(criteria.page, criteria.size)
            .list()
            .map(list -> list.stream().map(mapper::toResponse).toList());
    }

    /** ✅ Generate project code */
    private Uni<String> generateProjectCode() {
        String year = String.valueOf(LocalDate.now().getYear());
        return Project.count()
            .map(count -> String.format("PRJ%s%03d", year, count + 1));
    }

    /** ✅ Aggregated dashboard data (raw) */
    public Uni<Map<String, Object>> getDashboardData(Long projectId) {
        Uni<Long> totalContracts = Contract.count("project.id", projectId);
        Uni<Long> activeContracts = Contract.count("project.id = ?1 AND status = ?2",
                projectId, Contract.ContractStatus.ACTIVE);
        Uni<Long> totalClaims = ContractClaim.count("contract.project.id", projectId);
        Uni<Long> pendingClaims = ContractClaim.count("contract.project.id = ?1 AND status = ?2",
                projectId, ContractClaim.ClaimStatus.SUBMITTED);
        Uni<Long> totalDocuments = DocumentControl.count("project.id", projectId);

        return Uni.combine().all().unis(
                totalContracts,
                activeContracts,
                totalClaims,
                pendingClaims,
                totalDocuments).asTuple()
                .map(tuple -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("totalContracts", tuple.getItem1());
                    data.put("activeContracts", tuple.getItem2());
                    data.put("totalClaims", tuple.getItem3());
                    data.put("pendingClaims", tuple.getItem4());
                    data.put("totalDocuments", tuple.getItem5());
                    return data;
                });
    }

    /** ✅ Dashboard enriched with project details */
    public Uni<Map<String, Object>> getDashboard(Long projectId) {
        return findById(projectId)
                .onItem().ifNull().failWith(() -> new NotFoundException("Project not found"))
                .flatMap(project -> getDashboardData(projectId)
                        .map(data -> {
                            Map<String, Object> dashboard = new HashMap<>(data);
                            dashboard.put("project", project);
                            return dashboard;
                        }));
    }

    /** ✅ Change status with logging */
    public Uni<Void> changeStatus(Long id, Project.ProjectStatus status, String updatedBy) {
        return projectRepo.findById(id)
                .onItem().ifNull().failWith(() -> new NotFoundException("Project not found"))
                .flatMap(p -> {
                    p.status = status;
                    return projectRepo.persist(p)
                            .flatMap(_ignore -> transactionService.logTransaction(new TransactionDTO(
                                    null,
                                    p.id,
                                    ProjectTransaction.TransactionType.UPDATE,
                                    ProjectTransaction.DomainType.PROJECT,
                                    null, null,
                                    "Status changed to " + status,
                                    updatedBy,
                                    LocalDateTime.now())))
                            .replaceWithVoid();
                });
    }

    /** Search with optional filters */
    public Uni<List<Project>> search(String keyword,
            Project.ProjectStatus status,
            LocalDate startDate,
            LocalDate endDate,
            int page,
            int size) {

        StringBuilder query = new StringBuilder("1=1");
        List<Object> params = new ArrayList<>();
        int paramIndex = 1;

        if (keyword != null && !keyword.isBlank()) {
            query.append(" AND (LOWER(projectName) LIKE ?").append(paramIndex).append(" OR LOWER(description) LIKE ?")
                    .append(paramIndex).append(")");
            params.add("%" + keyword.toLowerCase() + "%");
            paramIndex++;
        }

        if (status != null) {
            query.append(" AND status = ?").append(paramIndex);
            params.add(status);
            paramIndex++;
        }

        if (startDate != null) {
            query.append(" AND startDate >= ?").append(paramIndex);
            params.add(startDate);
            paramIndex++;
        }

        if (endDate != null) {
            query.append(" AND endDate <= ?").append(paramIndex);
            params.add(endDate);
            paramIndex++;
        }

        return projectRepo.find(query.toString(), params.toArray())
                .page(Page.of(page, size))
                .list();
    }

}
