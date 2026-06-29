package com.postfix.resource;

import com.postfix.service.AuthService;
import jakarta.inject.Inject;
import jakarta.ws.rs.container.*;
import jakarta.ws.rs.core.*;
import jakarta.ws.rs.ext.Provider;
import org.jboss.logging.Logger;

import java.util.Set;

/**
 * JAX-RS request filter that validates JWT Bearer tokens on all /api/* routes
 * except /api/auth/login (the only public endpoint).
 */
@Provider
@PreMatching
public class AuthFilter implements ContainerRequestFilter {

    private static final Logger LOG = Logger.getLogger(AuthFilter.class);

    // Paths that don't require authentication
    private static final Set<String> PUBLIC_PATHS = Set.of(
        "/api/auth/login",
        "/api/auth/logout",
        "/q/health",
        "/q/metrics",
        "/swagger",
        "/swagger-ui"
    );

    @Inject
    AuthService authService;

    @Override
    public void filter(ContainerRequestContext ctx) {
        String path = ctx.getUriInfo().getPath();

        // Allow public paths and WebSocket upgrades
        if (isPublic(path)) return;
        if ("OPTIONS".equalsIgnoreCase(ctx.getMethod())) return; // CORS preflight

        String authHeader = ctx.getHeaderString(HttpHeaders.AUTHORIZATION);
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            ctx.abortWith(Response.status(Response.Status.UNAUTHORIZED)
                .entity("{\"message\":\"Missing or invalid Authorization header\"}")
                .type(MediaType.APPLICATION_JSON).build());
            return;
        }

        String token = authHeader.substring(7);
        try {
            String username = authService.validateAccessToken(token);
            // Attach username as request property for downstream use
            ctx.setProperty("username", username);
        } catch (SecurityException e) {
            LOG.debugf("Auth rejected for %s: %s", path, e.getMessage());
            ctx.abortWith(Response.status(Response.Status.UNAUTHORIZED)
                .entity("{\"message\":\"" + e.getMessage() + "\"}")
                .type(MediaType.APPLICATION_JSON).build());
        }
    }

    private boolean isPublic(String path) {
        return PUBLIC_PATHS.stream().anyMatch(path::startsWith);
    }
}
