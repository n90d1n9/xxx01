package tech.kayys.report.resource;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import io.smallrye.mutiny.Uni;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.contract.domain.Contract;
import tech.kayys.finance.domain.ProgressPayment;

@Path("/api/reports")
@Produces(MediaType.APPLICATION_JSON)
public class ReportController {
    
    @GET
    @Path("/contracts/summary")
    public Response getContractSummaryReport(@QueryParam("projectId") Long projectId) {
        String query = projectId != null ? "project.id = ?1" : "1=1";
        Object[] params = projectId != null ? new Object[]{projectId} : new Object[]{};
        
        Uni<List<Contract>> contracts = Contract.list(query, params);
        
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalContracts", contracts.size());
        summary.put("totalValue", contracts.stream()
            .map(c -> c.contractValue != null ? c.contractValue : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add));
        
        Map<String, Long> statusCounts = contracts.stream()
            .collect(Collectors.groupingBy(c -> c.status.getLabel(), Collectors.counting()));
        summary.put("statusCounts", statusCounts);
        
        Map<String, Long> typeCounts = contracts.stream()
            .collect(Collectors.groupingBy(c -> c.contractType.getLabel(), Collectors.counting()));
        summary.put("typeCounts", typeCounts);
        
        return Response.ok(summary).build();
    }
    
    @GET
    @Path("/payments/summary")
    public Response getPaymentSummaryReport(@QueryParam("contractId") Long contractId) {
        Uni<List<ProgressPayment>> payments;
        if (contractId != null) {
            payments = ProgressPayment.list("contract.id", contractId);
        } else {
            payments = ProgressPayment.listAll();
        }
        
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalPayments", payments.size());
        summary.put("totalAmount", payments.stream()
            .filter(p -> p.status == ProgressPayment.PaymentStatus.PAID)
            .map(p -> p.netAmount != null ? p.netAmount : BigDecimal.ZERO)
            .reduce(BigDecimal.ZERO, BigDecimal::add));
        
        Map<String, Long> statusCounts = payments.stream()
            .collect(Collectors.groupingBy(p -> p.status.getLabel(), Collectors.counting()));
        summary.put("statusCounts", statusCounts);
        
        return Response.ok(summary).build();
    }
}
