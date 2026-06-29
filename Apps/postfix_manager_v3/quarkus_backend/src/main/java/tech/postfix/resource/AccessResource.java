

@Path("/api/postfix/access")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
class AccessResource {
    @Inject AccessService accessService;

    @GET
    public List<AccessRuleDto> getAll(@QueryParam("listType") String listType) {
        return accessService.getAll(listType);
    }

    @POST
    public Response create(AccessRuleDto dto) {
        return Response.status(201).entity(accessService.create(dto)).build();
    }

    @DELETE @Path("/{pattern}")
    public Response delete(@PathParam("pattern") String pattern) {
        accessService.delete(pattern); return Response.noContent().build();
    }

    @PATCH @Path("/{pattern}")
    public Response toggle(@PathParam("pattern") String pattern, ToggleRequest req) {
        accessService.toggle(pattern, req.isActive()); return Response.ok().build();
    }
}
