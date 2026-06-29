package tech.kayys.project.resource;

import java.time.LocalDate;
import java.time.LocalDateTime;
import io.smallrye.mutiny.Uni;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.construction.service.CPMSchedulingService;
import tech.kayys.finance.domain.ChangeOrder;
import tech.kayys.project.service.EarnedValueService;
import tech.kayys.risk.domain.RiskRegister;

@Path("/api/planning")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class PlanningController {

    @Inject
    CPMSchedulingService cpmService;

    @Inject
    EarnedValueService evService;

    @POST
    @Path("/projects/{id}/critical-path")
    public Response calculateCriticalPath(@PathParam("id") Long projectId) {
        CPMSchedulingService.CriticalPathResult result = cpmService.calculateCriticalPath(projectId);
        return Response.ok(result).build();
    }

    @POST
    @Path("/projects/{id}/earned-value")
    public Uni<Response> calculateEarnedValue(@PathParam("id") Long projectId,
            @QueryParam("statusDate") String statusDateStr) {
        LocalDate statusDate = statusDateStr != null ? LocalDate.parse(statusDateStr) : LocalDate.now();

        return evService.calculateEarnedValue(projectId, statusDate)
                .onItem().ifNull().failWith(() -> new NotFoundException("Project not found"))
                .map(evData -> Response.ok(evData).build());
    }

    @GET
    @Path("/projects/{id}/change-orders")
    public Uni<Response> getChangeOrders(@PathParam("id") Long projectId) {
        return ChangeOrder
                .list("project.id = ?1 ORDER BY requestedDate DESC", projectId)
                .map(changeOrders -> Response.ok(changeOrders).build());
    }

    @POST
    @Path("/change-orders")
    @Transactional
    public Uni<Response> createChangeOrder(ChangeOrder changeOrder) {
        return ChangeOrder.count("project", changeOrder.project)
                .onItem().transform(count -> {
                    changeOrder.changeOrderNumber = String.format("CO-%s-%03d",
                            changeOrder.project.projectCode, count + 1);
                    changeOrder.requestedDate = LocalDateTime.now();
                    return changeOrder;
                })
                .chain(co -> co.persistAndFlush())
                .map(co -> Response.status(201).entity(co).build());
    }

    @PUT
    @Path("/change-orders/{id}/approve")
    @RolesAllowed({ "PROJECT_MANAGER", "ADMIN" })
    public Uni<Response> approveChangeOrder(@PathParam("id") Long id,
            @QueryParam("approver") String approver) {
        return ChangeOrder.<ChangeOrder>findById(id)
                .onItem().ifNull().failWith(() -> new NotFoundException("Change order not found"))
                .onItem().transformToUni(co -> {
                    co.status = ChangeOrder.ChangeOrderStatus.APPROVED;
                    co.approvedBy = approver;
                    co.approvedDate = LocalDateTime.now();
                    return co.persistAndFlush().map(x -> Response.ok(co).build());
                });
    }

    @GET
    @Path("/projects/{id}/risks")
    public Uni<Response> getRiskRegister(@PathParam("id") Long projectId) {
        return RiskRegister
                .list("project.id = ?1 ORDER BY riskScore DESC", projectId)
                .map(risks -> Response.ok(risks).build());
    }

    @POST
    @Path("/risks")
    @Transactional
    public Uni<Response> createRisk(RiskRegister risk) {
        return RiskRegister.count("project", risk.project)
                .onItem().transform(count -> {
                    risk.riskId = String.format("R-%s-%03d", risk.project.projectCode, count + 1);
                    risk.identifiedDate = LocalDate.now();
                    return risk;
                })
                .chain(r -> r.persistAndFlush())
                .map(r -> Response.status(201).entity(r).build());
    }
}
