

import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.*;
import org.jboss.logging.Logger;
import java.util.List;


@Path("/api/auth")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
class AuthResource {
    private static final Logger LOG = Logger.getLogger(AuthResource.class);
    @Inject AuthService authService;

    @POST @Path("/login")
    public Response login(LoginRequest req) {
        try {
            return Response.ok(authService.login(req.username(), req.password())).build();
        } catch (SecurityException e) {
            return Response.status(401).entity(new ErrorResponse(e.getMessage())).build();
        }
    }

    @POST @Path("/refresh")
    public Response refresh(RefreshRequest req) {
        try {
            return Response.ok(authService.refresh(req.refreshToken())).build();
        } catch (SecurityException e) {
            return Response.status(401).entity(new ErrorResponse(e.getMessage())).build();
        }
    }

    @POST @Path("/logout")
    public Response logout(RefreshRequest req) {
        if (req != null) authService.logout(req.refreshToken());
        return Response.ok().build();
    }
}