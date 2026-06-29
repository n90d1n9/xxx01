package tech.kayys.contract.resource;

import java.time.LocalDate;
import java.util.List;

import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.contract.domain.Contract;
import tech.kayys.contract.domain.ContractClaim;
import tech.kayys.finance.domain.ProgressPayment;

@Path("/api/contracts")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ContractController {
    
    @GET
    @Path("/projects/{id}")
    public Response getProjectContracts(@PathParam("id") Long projectId) {
        List<Contract> contracts = Contract.list("project.id", projectId);
        return Response.ok(contracts).build();
    }
    
    @POST
    public Response createContract(Contract contract) {
        // Generate contract number
        contract.contractNumber = generateContractNumber(contract);
        contract.persist();
        return Response.status(201).entity(contract).build();
    }
    
    @GET
    @Path("/{id}/claims")
    public Response getContractClaims(@PathParam("id") Long contractId) {
        List<ContractClaim> claims = ContractClaim
                .list("contract.id = ?1 ORDER BY submittedDate DESC", contractId);
        return Response.ok(claims).build();
    }
    
    @POST
    @Path("/claims")
    public Response createClaim(ContractClaim claim) {
        // Generate claim number
        long count = ContractClaim.count("contract", claim.contract) + 1;
        claim.claimNumber = String.format("CL-%s-%03d", 
                claim.contract.contractNumber, count);
        claim.submittedDate = LocalDate.now();
        claim.responseDueDate = LocalDate.now().plusDays(28); // Standard response time
        
        claim.persist();
        return Response.status(201).entity(claim).build();
    }
    
    @GET
    @Path("/{id}/payments")
    public Response getProgressPayments(@PathParam("id") Long contractId) {
        List<ProgressPayment> payments = ProgressPayment
                .list("contract.id = ?1 ORDER BY paymentNumber", contractId);
        return Response.ok(payments).build();
    }
    
    @POST
    @Path("/payments")
    public Response createProgressPayment(ProgressPayment payment) {
        // Calculate payment number
        Integer lastPaymentNumber = ProgressPayment
                .find("contract = ?1 ORDER BY paymentNumber DESC", payment.contract)
                .project(Integer.class, "paymentNumber")
                .firstResult();
        
        payment.paymentNumber = (lastPaymentNumber != null ? lastPaymentNumber : 0) + 1;
        payment.submittedDate = LocalDate.now();
        
        payment.persist();
        return Response.status(201).entity(payment).build();
    }
    
    private String generateContractNumber(Contract contract) {
        long count = Contract.count("project", contract.project) + 1;
        return String.format("CT-%s-%03d", contract.project.projectCode, count);
    }
}
