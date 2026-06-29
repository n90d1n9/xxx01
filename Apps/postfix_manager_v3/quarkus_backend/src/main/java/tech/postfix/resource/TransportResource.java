


@Path("/api/postfix/transport")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
class TransportResource {
    @Inject TransportService transportService;

    @GET  public List<TransportMapDto> getAll() { return transportService.getAll(); }

    @POST
    public Response create(TransportMapDto dto) {
        return Response.status(201).entity(transportService.create(dto)).build();
    }

    @PUT @Path("/{pattern}")
    public Response update(@PathParam("pattern") String pattern, TransportMapDto dto) {
        transportService.update(pattern, dto); return Response.ok().build();
    }

    @DELETE @Path("/{pattern}")
    public Response delete(@PathParam("pattern") String pattern) {
        transportService.delete(pattern); return Response.noContent().build();
    }

    @POST @Path("/reload")
    public Response reload() { transportService.reload(); return Response.ok().build(); }
}