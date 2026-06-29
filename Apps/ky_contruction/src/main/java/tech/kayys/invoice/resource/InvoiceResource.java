package tech.kayys.invoice.resource;


@Path("/api/invoices")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class InvoiceResource {
    
    @Inject
    InvoiceService invoiceService;
    
    @POST
    @Transactional
    public Response createInvoice(@Valid CreateInvoiceRequest request) {
        Invoice invoice = invoiceService.createInvoice(request);
        return Response.status(Response.Status.CREATED).entity(invoice).build();
    }
    
    @PUT
    @Path("/{id}/send")
    @Transactional
    public Response sendInvoice(@PathParam("id") Long id) {
        Invoice invoice = invoiceService.sendInvoice(id);
        return Response.ok(invoice).build();
    }
    
    @PUT
    @Path("/{id}/pay")
    @Transactional
    public Response markInvoicePaid(@PathParam("id") Long id, 
                                   @QueryParam("amount") BigDecimal amount,
                                   @QueryParam("paidDate") String paidDate) {
        LocalDate date = LocalDate.parse(paidDate);
        Invoice invoice = invoiceService.markInvoicePaid(id, amount, date);
        return Response.ok(invoice).build();
    }
    
    @GET
    @Path("/company/{companyId}")
    public List<Invoice> getInvoicesByCompany(@PathParam("companyId") Long companyId) {
        return Invoice.find("company.id = ?1 ORDER BY invoiceDate DESC", companyId).list();
    }
}