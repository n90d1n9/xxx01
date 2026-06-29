package tech.kayys.finance.resource;

import java.util.List;

import io.micrometer.core.ipc.http.HttpSender.Response;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import tech.kayys.finance.dto.CreatePayrollRequest;
import tech.kayys.finance.service.PayrollService;
import tech.kayys.invoice.domain.Payroll;

@Path("/api/payroll")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class PayrollResource {
    
    @Inject
    PayrollService payrollService;
    
    @POST
    @Transactional
    public Response processPayroll(@Valid CreatePayrollRequest request) {
        Payroll payroll = payrollService.processPayroll(request);
        return Response.status(Response.Status.CREATED).entity(payroll).build();
    }
    
    @GET
    @Path("/company/{companyId}")
    public List<Payroll> getPayrollByCompany(@PathParam("companyId") Long companyId,
                                           @QueryParam("year") Integer year,
                                           @QueryParam("month") Integer month) {
        return payrollService.getPayrollByCompanyAndPeriod(companyId, year, month);
    }
}
