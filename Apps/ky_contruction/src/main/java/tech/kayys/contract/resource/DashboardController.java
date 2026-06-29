package tech.kayys.contract.resource;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.ws.rs.DefaultValue;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.contract.domain.Contract;
import tech.kayys.contract.domain.ContractClaim;
import tech.kayys.contract.domain.DocumentApproval;
import tech.kayys.contract.domain.DocumentControl;
import tech.kayys.finance.domain.ProgressPayment;
import tech.kayys.project.domain.Project;

@Path("/api/dashboard")
@Produces(MediaType.APPLICATION_JSON)
public class DashboardController {
    
    @GET
    @Path("/overview")
    public Response getDashboardOverview() {
        Map<String, Object> overview = new HashMap<>();
        
        // Project Statistics
        overview.put("totalProjects", Project.count());
        overview.put("activeProjects", Project.count("status", Project.ProjectStatus.EXECUTION));
        
        // Contract Statistics
        overview.put("totalContracts", Contract.count());
        overview.put("activeContracts", Contract.count("status", Contract.ContractStatus.ACTIVE));
        overview.put("pendingContracts", Contract.count("status", Contract.ContractStatus.TENDER));
        
        // Claims Statistics
        overview.put("totalClaims", ContractClaim.count());
        overview.put("pendingClaims", ContractClaim.count("status", ContractClaim.ClaimStatus.SUBMITTED));
        overview.put("underReviewClaims", ContractClaim.count("status", ContractClaim.ClaimStatus.UNDER_REVIEW));
        
        // Payment Statistics
        overview.put("totalPayments", ProgressPayment.count());
        overview.put("pendingPayments", ProgressPayment.count("status", ProgressPayment.PaymentStatus.SUBMITTED));
        overview.put("approvedPayments", ProgressPayment.count("status", ProgressPayment.PaymentStatus.APPROVED));
        
        // Document Statistics
        overview.put("totalDocuments", DocumentControl.count());
        overview.put("pendingApprovals", DocumentApproval.count("status", DocumentApproval.ApprovalStatus.PENDING));
        
        return Response.ok(overview).build();
    }
    
    @GET
    @Path("/contract-values")
    public Response getContractValueAnalysis() {
        List<Object[]> results = Contract.getEntityManager()
            .createQuery("SELECT c.contractType, SUM(c.contractValue) FROM Contract c GROUP BY c.contractType", Object[].class)
            .getResultList();
        
        Map<String, BigDecimal> contractValuesByType = new HashMap<>();
        for (Object[] result : results) {
            Contract.ContractType type = (Contract.ContractType) result[0];
            BigDecimal totalValue = (BigDecimal) result[1];
            contractValuesByType.put(type.getLabel(), totalValue != null ? totalValue : BigDecimal.ZERO);
        }
        
        return Response.ok(contractValuesByType).build();
    }
    
    @GET
    @Path("/payment-trends")
    public Response getPaymentTrends(@QueryParam("months") @DefaultValue("12") int months) {
        LocalDate fromDate = LocalDate.now().minusMonths(months);
        
        List<Object[]> results = ProgressPayment.getEntityManager()
            .createQuery("SELECT FUNCTION('YEAR', p.paidDate), FUNCTION('MONTH', p.paidDate), SUM(p.netAmount) " +
                        "FROM ProgressPayment p WHERE p.paidDate >= :fromDate AND p.status = :status " +
                        "GROUP BY FUNCTION('YEAR', p.paidDate), FUNCTION('MONTH', p.paidDate) " +
                        "ORDER BY FUNCTION('YEAR', p.paidDate), FUNCTION('MONTH', p.paidDate)", Object[].class)
            .setParameter("fromDate", fromDate)
            .setParameter("status", ProgressPayment.PaymentStatus.PAID)
            .getResultList();
        
        List<Map<String, Object>> trends = new ArrayList<>();
        for (Object[] result : results) {
            Map<String, Object> monthData = new HashMap<>();
            monthData.put("year", result[0]);
            monthData.put("month", result[1]);
            monthData.put("totalAmount", result[2]);
            trends.add(monthData);
        }
        
        return Response.ok(trends).build();
    }
}