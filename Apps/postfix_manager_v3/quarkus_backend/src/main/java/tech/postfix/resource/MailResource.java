@Path("/api/mail")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
class MailResource {
    private static final Logger LOG = Logger.getLogger(MailResource.class);
    @Inject MailService mailService;

    // Domains
    @GET  @Path("/domains") public List<VirtualDomainDto> getDomains() { return mailService.getDomains(); }

    @POST @Path("/domains")
    public Response createDomain(CreateDomainRequest req) {
        return Response.status(201).entity(mailService.createDomain(req.domain())).build();
    }

    @DELETE @Path("/domains/{domain}")
    public Response deleteDomain(@PathParam("domain") String domain) {
        mailService.deleteDomain(domain); return Response.noContent().build();
    }

    @PATCH @Path("/domains/{domain}")
    public Response toggleDomain(@PathParam("domain") String domain, ToggleDomainRequest req) {
        mailService.toggleDomain(domain, req.isActive()); return Response.ok().build();
    }

    // Mailboxes
    @GET @Path("/mailboxes")
    public List<VirtualMailboxDto> getMailboxes(@QueryParam("domain") String domain) {
        return mailService.getMailboxes(domain);
    }

    @POST @Path("/mailboxes")
    public Response createMailbox(CreateMailboxRequest req) {
        return Response.status(201).entity(
            mailService.createMailbox(req.email(), req.password(), req.quotaMb(), req.forwardTo())
        ).build();
    }

    @DELETE @Path("/mailboxes/{email}")
    public Response deleteMailbox(@PathParam("email") String email) {
        mailService.deleteMailbox(email); return Response.noContent().build();
    }

    @PATCH @Path("/mailboxes/{email}/password")
    public Response updatePassword(@PathParam("email") String email, UpdatePasswordRequest req) {
        mailService.updatePassword(email, req.password()); return Response.ok().build();
    }

    @PATCH @Path("/mailboxes/{email}/quota")
    public Response updateQuota(@PathParam("email") String email, UpdateQuotaRequest req) {
        mailService.updateQuota(email, req.quotaMb()); return Response.ok().build();
    }

    @PATCH @Path("/mailboxes/{email}")
    public Response toggleMailbox(@PathParam("email") String email, ToggleMailboxRequest req) {
        mailService.toggleMailbox(email, req.isActive()); return Response.ok().build();
    }

    // Aliases
    @GET @Path("/aliases")
    public List<MailAliasDto> getAliases(@QueryParam("domain") String domain) {
        return mailService.getAliases(domain);
    }

    @POST @Path("/aliases")
    public Response createAlias(CreateAliasRequest req) {
        return Response.status(201).entity(
            mailService.createAlias(req.source(), req.destination(), req.comment())
        ).build();
    }

    @DELETE @Path("/aliases/{source}")
    public Response deleteAlias(@PathParam("source") String source) {
        mailService.deleteAlias(source); return Response.noContent().build();
    }

    @PATCH @Path("/aliases/{source}")
    public Response toggleAlias(@PathParam("source") String source, ToggleAliasRequest req) {
        mailService.toggleAlias(source, req.isActive()); return Response.ok().build();
    }
}
