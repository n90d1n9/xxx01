

@Path("/api/postfix/tls")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
class TlsResource {
    @Inject TlsService tlsService;

    @GET @Path("/certificates")
    public List<TlsCertificateDto> getCerts() { return tlsService.getAll(); }

    @POST @Path("/certificates")
    public Response uploadCert(CertUploadRequest req) {
        try {
            return Response.status(201).entity(tlsService.upload(req)).build();
        } catch (Exception e) {
            return Response.status(400).entity(new ErrorResponse(e.getMessage())).build();
        }
    }

    @DELETE @Path("/certificates/{domain}")
    public Response deleteCert(@PathParam("domain") String domain) {
        tlsService.delete(domain); return Response.noContent().build();
    }

    @POST @Path("/test")
    public TlsTestResultDto testTls(TlsTestRequest req) {
        return tlsService.testConnection(req.domain());
    }
}