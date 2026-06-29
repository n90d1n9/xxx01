package tech.kayys.ai.resource;

import java.util.ArrayList;
import java.util.List;

import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.ai.domain.AIRecommendation;
import tech.kayys.ai.domain.AnomalyDetection;
import tech.kayys.ai.service.AIRecommendationEngine;
import tech.kayys.ai.service.AnomalyDetectionService;
import tech.kayys.ai.service.PredictiveAnalyticsService;
import tech.kayys.project.domain.ProjectAnalytics;

@Path("/api/analytics")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class AnalyticsController {
    
    @Inject
    PredictiveAnalyticsService analyticsService;
    
    @Inject
    AnomalyDetectionService anomalyService;
    
    @Inject
    AIRecommendationEngine recommendationEngine;
    
    @POST
    @Path("/projects/{id}/analyze")
    public Response analyzeProject(@PathParam("id") Long projectId) {
        ProjectAnalytics analytics = analyticsService.analyzeProject(projectId);
        if (analytics == null) {
            return Response.status(404).entity("Project not found").build();
        }
        return Response.ok(analytics).build();
    }
    
    @GET
    @Path("/projects/{id}/analytics")
    public Response getProjectAnalytics(@PathParam("id") Long projectId) {
        List<ProjectAnalytics> analytics = ProjectAnalytics
                .list("project.id = ?1 ORDER BY analysisDate DESC", projectId);
        return Response.ok(analytics).build();
    }
    
    @GET
    @Path("/anomalies")
    public Response getAnomalies(@QueryParam("project") Long projectId,
                                @QueryParam("type") String anomalyType,
                                @QueryParam("status") String status) {
        List<AnomalyDetection> anomalies;
        
        StringBuilder query = new StringBuilder("1=1");
        List<Object> params = new ArrayList<>();
        
        if (projectId != null) {
            query.append(" and project.id = ?").append(params.size() + 1);
            params.add(projectId);
        }
        
        if (anomalyType != null) {
            try {
                AnomalyDetection.AnomalyType type = 
                        AnomalyDetection.AnomalyType.valueOf(anomalyType.toUpperCase());
                query.append(" and anomalyType = ?").append(params.size() + 1);
                params.add(type);
            } catch (IllegalArgumentException e) {
                return Response.status(400).entity("Invalid anomaly type: " + anomalyType).build();
            }
        }
        
        if (status != null) {
            try {
                AnomalyDetection.AnomalyStatus anomalyStatus = 
                        AnomalyDetection.AnomalyStatus.valueOf(status.toUpperCase());
                query.append(" and status = ?").append(params.size() + 1);
                params.add(anomalyStatus);
            } catch (IllegalArgumentException e) {
                return Response.status(400).entity("Invalid status: " + status).build();
            }
        }
        
        query.append(" ORDER BY detectionDate DESC");
        
        anomalies = AnomalyDetection.list(query.toString(), params.toArray());
        return Response.ok(anomalies).build();
    }
    
    @PUT
    @Path("/anomalies/{id}/investigate")
    @RolesAllowed({"PROJECT_MANAGER", "SITE_ENGINEER"})
    public Response investigateAnomaly(@PathParam("id") Long id,
                                     @QueryParam("investigator") String investigator,
                                     @QueryParam("notes") String notes,
                                     @QueryParam("status") String status) {
        AnomalyDetection anomaly = AnomalyDetection.findById(id);
        if (anomaly == null) {
            return Response.status(404).build();
        }
        
        try {
            anomaly.status = AnomalyDetection.AnomalyStatus.valueOf(status.toUpperCase());
            anomaly.investigatedBy = investigator;
            anomaly.investigationNotes = notes;
            anomaly.persist();
            
            return Response.ok(anomaly).build();
        } catch (IllegalArgumentException e) {
            return Response.status(400).entity("Invalid status: " + status).build();
        }
    }
    
    @GET
    @Path("/recommendations")
    public Response getRecommendations(@QueryParam("project") Long projectId,
                                      @QueryParam("type") String recommendationType,
                                      @QueryParam("status") String status) {
        List<AIRecommendation> recommendations;
        
        StringBuilder query = new StringBuilder("1=1");
        List<Object> params = new ArrayList<>();
        
        if (projectId != null) {
            query.append(" and project.id = ?").append(params.size() + 1);
            params.add(projectId);
        }
        
        if (recommendationType != null) {
            try {
                AIRecommendation.RecommendationType type = 
                        AIRecommendation.RecommendationType.valueOf(recommendationType.toUpperCase());
                query.append(" and recommendationType = ?").append(params.size() + 1);
                params.add(type);
            } catch (IllegalArgumentException e) {
                return Response.status(400).entity("Invalid recommendation type: " + recommendationType).build();
            }
        }
        
        if (status != null) {
            try {
                AIRecommendation.RecommendationStatus recStatus = 
                        AIRecommendation.RecommendationStatus.valueOf(status.toUpperCase());
                query.append(" and status = ?").append(params.size() + 1);
                params.add(recStatus);
            } catch (IllegalArgumentException e) {
                return Response.status(400).entity("Invalid status: " + status).build();
            }
        }
        
        query.append(" ORDER BY recommendationDate DESC");
        
        recommendations = AIRecommendation.list(query.toString(), params.toArray());
        return Response.ok(recommendations).build();
    }
    
    @PUT
    @Path("/recommendations/{id}/review")
    @RolesAllowed({"PROJECT_MANAGER", "ADMIN"})
    public Response reviewRecommendation(@PathParam("id") Long id,
                                        @QueryParam("reviewer") String reviewer,
                                        @QueryParam("status") String status,
                                        @QueryParam("notes") String notes) {
        AIRecommendation recommendation = AIRecommendation.findById(id);
        if (recommendation == null) {
            return Response.status(404).build();
        }
        
        try {
            recommendation.status = AIRecommendation.RecommendationStatus.valueOf(status.toUpperCase());
            recommendation.reviewedBy = reviewer;
            recommendation.reviewNotes = notes;
            recommendation.persist();
            
            return Response.ok(recommendation).build();
        } catch (IllegalArgumentException e) {
            return Response.status(400).entity("Invalid status: " + status).build();
        }
    }
    
    @POST
    @Path("/anomaly-detection/run")
    @RolesAllowed("ADMIN")
    public Response runAnomalyDetection() {
        try {
            anomalyService.runDailyAnomalyDetection();
            return Response.ok().entity("Anomaly detection completed").build();
        } catch (Exception e) {
            return Response.status(500).entity("Error running anomaly detection: " + e.getMessage()).build();
        }
    }
    
    @POST
    @Path("/recommendations/generate")
    @RolesAllowed("ADMIN")
    public Response generateRecommendations() {
        try {
            recommendationEngine.generateDailyRecommendations();
            return Response.ok().entity("Recommendations generated").build();
        } catch (Exception e) {
            return Response.status(500).entity("Error generating recommendations: " + e.getMessage()).build();
        }
    }
}
