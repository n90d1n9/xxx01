@Path("/api/postfix/backups")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
class BackupResource {
    @Inject BackupService backupService;

    @GET public List<BackupEntryDto> getAll() { return backupService.getAll(); }

    @POST
    public Response create(BackupRequest req) {
        try {
            return Response.status(201).entity(backupService.create(req.includes())).build();
        } catch (Exception e) {
            return Response.status(500).entity(new ErrorResponse(e.getMessage())).build();
        }
    }

    @POST @Path("/{id}/restore")
    public Response restore(@PathParam("id") String id) {
        try {
            backupService.restore(id); return Response.ok().build();
        } catch (Exception e) {
            return Response.status(500).entity(new ErrorResponse(e.getMessage())).build();
        }
    }

    @DELETE @Path("/{id}")
    public Response delete(@PathParam("id") String id) {
        try {
            backupService.delete(id); return Response.noContent().build();
        } catch (Exception e) {
            return Response.status(500).entity(new ErrorResponse(e.getMessage())).build();
        }
    }
}