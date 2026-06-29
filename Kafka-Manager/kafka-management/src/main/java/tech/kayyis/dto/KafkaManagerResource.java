package tech.kayyis.dto;

import java.tech.kayyis.services.KafkaAdminService;

@Path("/api/kafka")
@ApplicationScoped
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class KafkaManagerResource {

    private static final Logger LOG = Logger.getLogger(KafkaManagerResource.class);

    @Inject
    KafkaAdminService kafkaAdminService;

    @GET
    @Path("/health")
    public Response checkHealth() {
        try {
            boolean isHealthy = kafkaAdminService.checkClusterHealth();
            if (isHealthy) {
                return Response.ok(Map.of("status", "UP")).build();
            } else {
                return Response.status(Response.Status.SERVICE_UNAVAILABLE)
                        .entity(Map.of("status", "DOWN"))
                        .build();
            }
        } catch (Exception e) {
            LOG.error("Error checking Kafka health", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", e.getMessage()))
                    .build();
        }
    }

    @GET
    @Path("/topics")
    public Response listTopics() {
        try {
            List<TopicInfo> topics = kafkaAdminService.listTopics();
            return Response.ok(topics).build();
        } catch (Exception e) {
            LOG.error("Error listing topics", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", e.getMessage()))
                    .build();
        }
    }

    @GET
    @Path("/topics/{topicName}")
    public Response getTopicDetails(@PathParam("topicName") String topicName) {
        try {
            TopicDetail details = kafkaAdminService.getTopicDetails(topicName);
            if (details != null) {
                return Response.ok(details).build();
            } else {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity(Map.of("error", "Topic not found: " + topicName))
                        .build();
            }
        } catch (Exception e) {
            LOG.error("Error getting topic details for " + topicName, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", e.getMessage()))
                    .build();
        }
    }

    @POST
    @Path("/topics")
    public Response createTopic(TopicCreationRequest request) {
        try {
            kafkaAdminService.createTopic(request);
            return Response.status(Response.Status.CREATED)
                    .entity(Map.of("message", "Topic created successfully: " + request.getName()))
                    .build();
        } catch (Exception e) {
            LOG.error("Error creating topic " + request.getName(), e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", e.getMessage()))
                    .build();
        }
    }

    @DELETE
    @Path("/topics/{topicName}")
    public Response deleteTopic(@PathParam("topicName") String topicName) {
        try {
            kafkaAdminService.deleteTopic(topicName);
            return Response.ok(Map.of("message", "Topic deleted: " + topicName)).build();
        } catch (Exception e) {
            LOG.error("Error deleting topic " + topicName, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", e.getMessage()))
                    .build();
        }
    }

    @PUT
    @Path("/topics/{topicName}/partitions")
    public Response updatePartitions(@PathParam("topicName") String topicName, PartitionUpdateRequest request) {
        try {
            kafkaAdminService.updatePartitions(topicName, request.getNewPartitionCount());
            return Response.ok(Map.of("message", "Partitions updated for topic: " + topicName)).build();
        } catch (Exception e) {
            LOG.error("Error updating partitions for topic " + topicName, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", e.getMessage()))
                    .build();
        }
    }

    @GET
    @Path("/consumer-groups")
    public Response listConsumerGroups() {
        try {
            List<ConsumerGroupInfo> groups = kafkaAdminService.listConsumerGroups();
            return Response.ok(groups).build();
        } catch (Exception e) {
            LOG.error("Error listing consumer groups", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", e.getMessage()))
                    .build();
        }
    }

    @GET
    @Path("/consumer-groups/{groupId}")
    public Response getConsumerGroupDetails(@PathParam("groupId") String groupId) {
        try {
            ConsumerGroupDetail details = kafkaAdminService.getConsumerGroupDetails(groupId);
            if (details != null) {
                return Response.ok(details).build();
            } else {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity(Map.of("error", "Consumer group not found: " + groupId))
                        .build();
            }
        } catch (Exception e) {
            LOG.error("Error getting consumer group details for " + groupId, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", e.getMessage()))
                    .build();
        }
    }

    @DELETE
    @Path("/consumer-groups/{groupId}")
    public Response deleteConsumerGroup(@PathParam("groupId") String groupId) {
        try {
            kafkaAdminService.deleteConsumerGroup(groupId);
            return Response.ok(Map.of("message", "Consumer group deleted: " + groupId)).build();
        } catch (Exception e) {
            LOG.error("Error deleting consumer group " + groupId, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", e.getMessage()))
                    .build();
        }
    }

    @GET
    @Path("/brokers")
    public Response listBrokers() {
        try {
            List<BrokerInfo> brokers = kafkaAdminService.listBrokers();
            return Response.ok(brokers).build();
        } catch (Exception e) {
            LOG.error("Error listing brokers", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", e.getMessage()))
                    .build();
        }
    }

    @GET
    @Path("/metrics")
    public Response getClusterMetrics() {
        try {
            ClusterMetrics metrics = kafkaAdminService.getClusterMetrics();
            return Response.ok(metrics).build();
        } catch (Exception e) {
            LOG.error("Error getting cluster metrics", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", e.getMessage()))
                    .build();
        }
    }

    @POST
    @Path("/reassign-partitions")
    public Response reassignPartitions(PartitionReassignmentRequest request) {
        try {
            kafkaAdminService.reassignPartitions(request);
            return Response.ok(Map.of("message", "Partition reassignment started")).build();
        } catch (Exception e) {
            LOG.error("Error reassigning partitions", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", e.getMessage()))
                    .build();
        }
    }
}