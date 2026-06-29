package tech.kayys.tax.resource;

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
import tech.kayys.accounting.domain.TaxRecord;
import tech.kayys.tax.service.TaxService;

@Path("/api/tax")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class TaxResource {
    
    @Inject
    TaxService taxService;
    
    @POST
    @Path("/pph21")
    @Transactional
    public Response calculatePPh21(@Valid PPh21Request request) {
        TaxRecord taxRecord = taxService.calculatePPh21(request.companyId, request.year, 
                                                       request.month, request.grossSalary);
        return Response.ok(taxRecord).build();
    }
    
    @POST
    @Path("/ppn")
    @Transactional
    public Response calculatePPN(@Valid PPNRequest request) {
        TaxRecord taxRecord = taxService.calculatePPN(request.companyId, request.year, request.month);
        return Response.ok(taxRecord).build();
    }
    
    @GET
    @Path("/overdue")
    public List<TaxRecord> getOverdueTaxes() {
        return taxService.getOverdueTaxes();
    }
    
    @PUT
    @Path("/{id}/pay")
    @Transactional
    public Response payTax(@PathParam("id") Long id, @QueryParam("ntpn") String ntpnNumber) {
        TaxRecord taxRecord = taxService.payTax(id, ntpnNumber);
        return Response.ok(taxRecord).build();
    }
}
