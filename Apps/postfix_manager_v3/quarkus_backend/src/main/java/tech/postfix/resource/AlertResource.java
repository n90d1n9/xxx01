@Path("/api/alerts")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
class AlertResource {
    @Inject AlertService alertService;

    @GET
    public List<AlertDto> getAll(@QueryParam("unreadOnly") @DefaultValue("false") boolean unreadOnly) {
        return alertService.getAll(unreadOnly);
    }

    @PATCH @Path("/{id}/read")
    public Response markRead(@PathParam("id") String id) {
        alertService.markRead(id); return Response.ok().build();
    }

    @POST @Path("/read-all")
    public Response markAllRead() { alertService.markAllRead(); return Response.ok().build(); }

    @DELETE @Path("/{id}")
    public Response delete(@PathParam("id") String id) {
        alertService.delete(id); return Response.noContent().build();
    }
}