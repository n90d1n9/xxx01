package tech.kayys.controller;

//import tech.kayys.kafkamanager.service.KafkaAdminService;
//import tech.kayys.kafkamanager.service.KafkaMessageService;
import org.apache.kafka.clients.admin.ConsumerGroupDescription;
import org.apache.kafka.clients.admin.ConsumerGroupListing;
import org.apache.kafka.clients.admin.TopicDescription;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.tags.Tag;

import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.DefaultValue;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.services.KafkaAdminService;
import tech.kayys.services.KafkaMessageService;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentMap;

@Path("/api/kafka")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Tag(name = "Kafka Management", description = "Operations for managing Kafka")
public class KafkaResource {

    @Inject
    KafkaAdminService adminService;

    @Inject
    KafkaMessageService messageService;

    @GET
    @Path("/topics")
    @Operation(summary = "List all topics")
    public Response listTopics() {
        try {
            return Response.ok(adminService.listTopics()).build();
        } catch (Exception e) {
            return Response.serverError().entity(e.getMessage()).build();
        }
    }

    @POST
    @Path("/topics/{topicName}")
    @Operation(summary = "Create a new topic")
    public Response createTopic(
            @PathParam("topicName") String topicName,
            @QueryParam("partitions") @DefaultValue("1") int partitions,
            @QueryParam("replicationFactor") @DefaultValue("1") short replicationFactor) {
        try {
            adminService.createTopic(topicName, partitions, replicationFactor);
            return Response.ok().build();
        } catch (Exception e) {
            return Response.serverError().entity(e.getMessage()).build();
        }
    }

    @DELETE
    @Path("/topics/{topicName}")
    @Operation(summary = "Delete a topic")
    public Response deleteTopic(@PathParam("topicName") String topicName) {
        try {
            adminService.deleteTopic(topicName);
            return Response.ok().build();
        } catch (Exception e) {
            return Response.serverError().entity(e.getMessage()).build();
        }
    }

    @GET
    @Path("/topics/{topicName}")
    @Operation(summary = "Get topic details")
    public Response describeTopic(@PathParam("topicName") String topicName) {
        try {
            Map<String, TopicDescription> description = 
                adminService.describeTopics(List.of(topicName));
            return Response.ok(description).build();
        } catch (Exception e) {
            return Response.serverError().entity(e.getMessage()).build();
        }
    }

    @GET
    @Path("/topics/{topicName}/configs")
    @Operation(summary = "Get topic configurations")
    public Response getTopicConfigs(@PathParam("topicName") String topicName) {
        try {
            return Response.ok(adminService.getTopicConfigs(topicName)).build();
        } catch (Exception e) {
            return Response.serverError().entity(e.getMessage()).build();
        }
    }

    @GET
    @Path("/consumer-groups")
    @Operation(summary = "List consumer groups")
    public Response listConsumerGroups() {
        try {
            return Response.ok(adminService.listConsumerGroups()).build();
        } catch (Exception e) {
            return Response.serverError().entity(e.getMessage()).build();
        }
    }

    @GET
    @Path("/consumer-groups/{groupId}")
    @Operation(summary = "Get consumer group details")
    public Response describeConsumerGroup(@PathParam("groupId") String groupId) {
        try {
            Map<String, ConsumerGroupDescription> description = 
                adminService.describeConsumerGroups(List.of(groupId));
            return Response.ok(description).build();
        } catch (Exception e) {
            return Response.serverError().entity(e.getMessage()).build();
        }
    }

    @POST
    @Path("/messages")
    @Operation(summary = "Send a message to the default topic")
    public Response sendMessage(String message) {
        messageService.sendMessage(message);
        return Response.accepted().build();
    }

    @GET
    @Path("/messages")
    @Operation(summary = "Get received messages")
    public Response getMessages() {
        ConcurrentMap<String, String> messages = messageService.getReceivedMessages();
        return Response.ok(messages).build();
    }
}