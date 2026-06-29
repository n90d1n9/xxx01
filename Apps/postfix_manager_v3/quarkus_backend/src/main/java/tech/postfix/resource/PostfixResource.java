

@Path("/api/postfix")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
class PostfixResource {
    private static final Logger LOG = Logger.getLogger(PostfixResource.class);
    @Inject PostfixService postfixService;

    @GET  @Path("/status") public ServerStatusDto  getStatus()                                { return postfixService.getStatus(); }
    @POST @Path("/start")  public Response start()  { postfixService.start();  return Response.ok().build(); }
    @POST @Path("/stop")   public Response stop()   { postfixService.stop();   return Response.ok().build(); }
    @POST @Path("/reload") public Response reload() { postfixService.reload(); return Response.ok().build(); }

    @GET @Path("/stats")
    public PostfixStatsDto getStats(@QueryParam("period") @DefaultValue("24h") String period) {
        return postfixService.getStats(period);
    }

    @GET @Path("/queue")
    public Response getQueue(
            @QueryParam("status") String status,
            @QueryParam("search") String search,
            @QueryParam("sort")   String sort,
            @QueryParam("order")  @DefaultValue("asc") String order,
            @QueryParam("page")   @DefaultValue("0")  int page,
            @QueryParam("size")   @DefaultValue("50") int size) {
        List<MailQueueDto> items = postfixService.getQueue(status, search, page, size);
        long total = postfixService.getQueueTotal(status, search);
        return Response.ok(items)
            .header("X-Total-Count", total)
            .header("Access-Control-Expose-Headers", "X-Total-Count")
            .build();
    }

    @POST @Path("/queue/flush")
    public Response flushQueue() { postfixService.flushQueue(); return Response.ok().build(); }

    @DELETE @Path("/queue/{id}")
    public Response deleteQueueItem(@PathParam("id") String id) {
        postfixService.deleteQueueItem(id); return Response.noContent().build();
    }

    @POST @Path("/queue/{id}/requeue")
    public Response requeueItem(@PathParam("id") String id) {
        postfixService.requeueItem(id); return Response.ok().build();
    }

    @POST @Path("/queue/{id}/hold")
    public Response holdItem(@PathParam("id") String id) {
        postfixService.holdItem(id); return Response.ok().build();
    }

    @POST @Path("/queue/{id}/release")
    public Response releaseItem(@PathParam("id") String id) {
        postfixService.releaseItem(id); return Response.ok().build();
    }

    @POST @Path("/queue/delete-batch")
    public Response deleteBatch(List<String> ids) {
        postfixService.deleteBatch(ids); return Response.ok().build();
    }

    @GET @Path("/logs")
    public List<MailLogDto> getLogs(
            @QueryParam("level")   String level,
            @QueryParam("search")  String search,
            @QueryParam("queueId") String queueId,
            @QueryParam("page")    @DefaultValue("0")   int page,
            @QueryParam("size")    @DefaultValue("100") int size) {
        return postfixService.getLogs(level, search, queueId, page, size);
    }

    @GET @Path("/config")
    public List<PostfixConfigDto> getConfig() { return postfixService.getConfig(); }

    @PUT @Path("/config/{key}")
    public Response updateConfig(@PathParam("key") String key, UpdateConfigRequest req) {
        postfixService.updateConfig(key, req.value()); return Response.ok().build();
    }

    @POST @Path("/config/test")
    public Response testConfig() {
        boolean ok = postfixService.testConfig();
        return ok ? Response.ok().build() : Response.status(400).build();
    }

    @GET @Path("/config/export")
    public Response exportConfig() {
        String content = postfixService.exportConfig();
        return Response.ok(content).type(MediaType.TEXT_PLAIN).build();
    }

    @POST @Path("/config/import")
    public Response importConfig(ImportConfigRequest req) {
        postfixService.importConfig(req.content()); return Response.ok().build();
    }
}
