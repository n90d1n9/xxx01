package tech.kayys.contract.resource;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.contract.domain.ContractMilestone;

@Path("/api/milestones")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class MilestoneController {
    
    @GET
    @Path("/contracts/{id}")
    public Response getContractMilestones(@PathParam("id") Long contractId) {
        List<ContractMilestone> milestones = ContractMilestone
            .list("contract.id = ?1 ORDER BY sequenceNumber", contractId);
        return Response.ok(milestones).build();
    }
    
    @POST
    public Response createMilestone(ContractMilestone milestone) {
        milestone.persist();
        return Response.status(201).entity(milestone).build();
    }
    
    @PUT
    @Path("/{id}")
    public Response updateMilestone(@PathParam("id") Long id, ContractMilestone updatedMilestone) {
        ContractMilestone milestone = ContractMilestone.findById(id);
        if (milestone == null) {
            return Response.status(404).build();
        }
        
        milestone.milestoneName = updatedMilestone.milestoneName;
        milestone.milestoneDescription = updatedMilestone.milestoneDescription;
        milestone.plannedStartDate = updatedMilestone.plannedStartDate;
        milestone.plannedEndDate = updatedMilestone.plannedEndDate;
        milestone.actualStartDate = updatedMilestone.actualStartDate;
        milestone.actualEndDate = updatedMilestone.actualEndDate;
        milestone.progressPercentage = updatedMilestone.progressPercentage;
        milestone.status = updatedMilestone.status;
        milestone.milestoneValue = updatedMilestone.milestoneValue;
        
        milestone.persist();
        return Response.ok(milestone).build();
    }
    
    @PUT
    @Path("/{id}/progress")
    public Response updateMilestoneProgress(
            @PathParam("id") Long id, 
            @QueryParam("progress") BigDecimal progressPercentage) {
        
        ContractMilestone milestone = ContractMilestone.findById(id);
        if (milestone == null) {
            return Response.status(404).build();
        }
        
        milestone.progressPercentage = progressPercentage;
        
        // Auto-update status based on progress
        if (progressPercentage.compareTo(BigDecimal.ZERO) == 0) {
            milestone.status = ContractMilestone.MilestoneStatus.NOT_STARTED;
        } else if (progressPercentage.compareTo(BigDecimal.valueOf(100)) == 0) {
            milestone.status = ContractMilestone.MilestoneStatus.COMPLETED;
            milestone.actualEndDate = LocalDate.now();
        } else {
            milestone.status = ContractMilestone.MilestoneStatus.IN_PROGRESS;
            if (milestone.actualStartDate == null) {
                milestone.actualStartDate = LocalDate.now();
            }
        }
        
        milestone.persist();
        return Response.ok(milestone).build();
    }
}
