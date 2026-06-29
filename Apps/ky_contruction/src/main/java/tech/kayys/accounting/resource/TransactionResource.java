package tech.kayys.accounting.resource;

import java.time.LocalDate;
import java.util.List;

import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
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
import tech.kayys.accounting.domain.FinancialTransaction;
import tech.kayys.accounting.service.FinancialTransactionService;

@Path("/api/transactions")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class TransactionResource {
    
    @Inject
    FinancialTransactionService transactionService;
    
    @POST
    @Transactional
    public Response createTransaction(@Valid CreateTransactionRequest request) {
        FinancialTransaction transaction = transactionService.createTransaction(request);
        return Response.status(Response.Status.CREATED).entity(transaction).build();
    }
    
    @PUT
    @Path("/{id}/approve")
    @Transactional
    public Response approveTransaction(@PathParam("id") Long id, @QueryParam("approvedBy") String approvedBy) {
        FinancialTransaction transaction = transactionService.approveTransaction(id, approvedBy);
        return Response.ok(transaction).build();
    }
    
    @PUT
    @Path("/{id}/post")
    @Transactional
    public Response postTransaction(@PathParam("id") Long id) {
        FinancialTransaction transaction = transactionService.postTransaction(id);
        return Response.ok(transaction).build();
    }
    
    @GET
    @Path("/company/{companyId}")
    public List<FinancialTransaction> getTransactionsByCompany(
            @PathParam("companyId") Long companyId,
            @QueryParam("startDate") String startDate,
            @QueryParam("endDate") String endDate) {
        
        LocalDate start = LocalDate.parse(startDate);
        LocalDate end = LocalDate.parse(endDate);
        
        return transactionService.getTransactionsByCompany(companyId, start, end);
    }
    
    @GET
    @Path("/company/{companyId}/summary")
    public FinancialSummary getFinancialSummary(
            @PathParam("companyId") Long companyId,
            @QueryParam("startDate") String startDate,
            @QueryParam("endDate") String endDate) {
        
        LocalDate start = LocalDate.parse(startDate);
        LocalDate end = LocalDate.parse(endDate);
        
        return transactionService.getFinancialSummary(companyId, start, end);
    }
}
