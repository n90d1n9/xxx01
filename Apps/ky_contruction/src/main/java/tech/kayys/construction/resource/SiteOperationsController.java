package tech.kayys.construction.resource;

import java.time.LocalDate;
import java.util.List;

import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.finance.domain.DailyLog;

@Path("/api/site-operations")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class SiteOperationsController {
    
    @GET
    @Path("/daily-logs")
    public Response getDailyLogs(@QueryParam("project") Long projectId,
                                @QueryParam("date") String dateStr) {
        List<DailyLog> logs;
        
        if (projectId != null && dateStr != null) {
            LocalDate date = LocalDate.parse(dateStr);
            logs = DailyLog.list("project.id = ?1 and logDate = ?2", projectId, date);
        } else if (projectId != null) {
            logs = DailyLog.list("project.id = ?1 ORDER BY logDate DESC", projectId);
        } else {
            logs = DailyLog.list("ORDER BY logDate DESC");
        }
        
        return Response.ok(logs).build();
    }
    
    @POST
    @Path("/daily-logs")
    public Response createDailyLog(DailyLog dailyLog) {
        dailyLog.persist();
        return Response.status(201).entity(dailyLog).build();
    }
    
    @GET
    @Path("/safety-incidents")
    public Response getSafetyIncidents(@QueryParam("project") Long projectId,
                                      @QueryParam("severity") String severity) {
        List<SafetyIncident> incidents;
        
        if (projectId != null && severity != null) {
            try {
                SafetyIncident.IncidentSeverity sev = 
                        SafetyIncident.IncidentSeverity.valueOf(severity.toUpperCase());
                incidents = SafetyIncident.list("project.id = ?1 and severity = ?2", projectId, sev);
            } catch (IllegalArgumentException e) {
                return Response.status(400).entity("Invalid severity: " + severity).build();
            }
        } else if (projectId != null) {
            incidents = SafetyIncident.list("project.id", projectId);
        } else {
            incidents = SafetyIncident.list("ORDER BY incidentDate DESC");  
