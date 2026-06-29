


@Path("/api/postfix/dns")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
class DnsResource {
    @Inject DnsService dnsService;

    @GET @Path("/{domain}")
    public DnsHealthDto check(@PathParam("domain") String domain) {
        return dnsService.check(domain);
    }

    @POST @Path("/{domain}/check")
    public DnsHealthDto recheck(@PathParam("domain") String domain) {
        return dnsService.check(domain);
    }
}