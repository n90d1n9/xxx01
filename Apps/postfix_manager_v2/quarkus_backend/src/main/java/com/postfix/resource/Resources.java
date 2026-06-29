package com.postfix.resource;

import com.postfix.dto.Dtos.*;
import com.postfix.service.*;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.*;
import org.jboss.logging.Logger;
import java.util.List;

// ─── Auth ──────────────────────────────────────────────────────────────────────
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

    @POST @Path("/logout")
    public Response logout() { return Response.ok().build(); }
}

// ─── Postfix Core ──────────────────────────────────────────────────────────────
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
    public List<MailQueueDto> getQueue(
            @QueryParam("status") String status,
            @QueryParam("search") String search,
            @QueryParam("page")   @DefaultValue("0")  int page,
            @QueryParam("size")   @DefaultValue("50") int size) {
        return postfixService.getQueue(status, search, page, size);
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

// ─── Transport Maps ────────────────────────────────────────────────────────────
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

// ─── Access Control ────────────────────────────────────────────────────────────
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

// ─── TLS / Certificates ────────────────────────────────────────────────────────
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

// ─── DNS Health ────────────────────────────────────────────────────────────────
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

// ─── Alerts ────────────────────────────────────────────────────────────────────
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

// ─── Backups ───────────────────────────────────────────────────────────────────
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

// ─── Mail Management ───────────────────────────────────────────────────────────
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
