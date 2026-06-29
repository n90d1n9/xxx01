package java.tech.kayyis.services;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;

import jakarta.enterprise.context.ApplicationScoped;
import io.quarkus.runtime.Quarkus;
import io.quarkus.runtime.QuarkusApplication;
import io.quarkus.runtime.annotations.QuarkusMain;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.apache.kafka.clients.admin.*;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.TopicPartitionInfo;
import org.apache.kafka.common.config.ConfigResource;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;


import java.tech.kayyis.dto.TopicInfo;
import java.util.*;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@ApplicationScoped
public class KafkaAdminService {

    private static final Logger LOG = Logger.getLogger(KafkaAdminService.class);
    
    @ConfigProperty(name = "kafka.bootstrap.servers", defaultValue = "localhost:9092")
    String bootstrapServers;
    
    private AdminClient createAdminClient() {
        Properties props = new Properties();
        props.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(AdminClientConfig.REQUEST_TIMEOUT_MS_CONFIG, 30000);
        return AdminClient.create(props);
    }
    
    public boolean checkClusterHealth() throws ExecutionException, InterruptedException {
        try (AdminClient adminClient = createAdminClient()) {
            // If we can get cluster nodes, we consider Kafka healthy
            adminClient.describeCluster().nodes().get();
            return true;
        } catch (Exception e) {
            LOG.error("Kafka cluster health check failed", e);
            return false;
        }
    }
    
    public List<TopicInfo> listTopics() throws ExecutionException, InterruptedException {
        List<TopicInfo> result = new ArrayList<>();
        
        try (AdminClient adminClient = createAdminClient()) {
            ListTopicsResult topicsResult = adminClient.listTopics(new ListTopicsOptions().listInternal(true));
            Set<String> topicNames = topicsResult.names().get();
            
            DescribeTopicsResult describeTopicsResult = adminClient.describeTopics(topicNames);
            Map<String, TopicDescription> topicDescriptions = describeTopicsResult.allTopicNames().get();
            
            for (Map.Entry<String, TopicDescription> entry : topicDescriptions.entrySet()) {
                TopicDescription description = entry.getValue();
                TopicInfo topicInfo = new TopicInfo();
                topicInfo.setName(description.name());
                topicInfo.setPartitionCount(description.partitions().size());
                topicInfo.setInternal(description.isInternal());
                result.add(topicInfo);
            }
        }
        
        return result;
    }
    
    public TopicDetail getTopicDetails(String topicName) throws ExecutionException, InterruptedException {
        try (AdminClient adminClient = createAdminClient()) {
            // Check if topic exists
            Set<String> topicNames = adminClient.listTopics().names().get();
            if (!topicNames.contains(topicName)) {
                return null;
            }
            
            // Get topic description
            DescribeTopicsResult describeResult = adminClient.describeTopics(Collections.singleton(topicName));
            TopicDescription description = describeResult.allTopicNames().get().get(topicName);
            
            // Get topic configs
            ConfigResource resource = new ConfigResource(ConfigResource.Type.TOPIC, topicName);
            DescribeConfigsResult configsResult = adminClient.describeConfigs(Collections.singleton(resource));
            Config config = configsResult.all().get().get(resource);
            
            TopicDetail detail = new TopicDetail();
            detail.setName(description.name());
            detail.setPartitionCount(description.partitions().size());
            detail.setInternal(description.isInternal());
            
            // Process partitions
            List<PartitionInfo> partitions = new ArrayList<>();
            for (TopicPartitionInfo partitionInfo : description.partitions()) {
                PartitionInfo partition = new PartitionInfo();
                partition.setPartition(partitionInfo.partition());
                partition.setLeader(partitionInfo.leader().id());
                partition.setReplicas(partitionInfo.replicas().stream()
                        .map(node -> node.id())
                        .collect(Collectors.toList()));
                partition.setIsr(partitionInfo.isr().stream()
                        .map(node -> node.id())
                        .collect(Collectors.toList()));
                partitions.add(partition);
            }
            detail.setPartitions(partitions);
            
            // Process configs
            Map<String, String> configs = new HashMap<>();
            for (ConfigEntry entry : config.entries()) {
                if (!entry.isDefault()) {
                    configs.put(entry.name(), entry.value());
                }
            }
            detail.setConfigs(configs);
            
            return detail;
        } catch (Exception e) {
            LOG.error("Error getting topic details for " + topicName, e);
            throw e;
        }
    }
    
    public void createTopic(TopicCreationRequest request) throws ExecutionException, InterruptedException {
        try (AdminClient adminClient = createAdminClient()) {
            NewTopic newTopic = new NewTopic(
                    request.getName(),
                    request.getPartitions(),
                    request.getReplicationFactor());
            
            if (request.getConfigs() != null) {
                newTopic.configs(request.getConfigs());
            }
            
            adminClient.createTopics(Collections.singleton(newTopic)).all().get();
        }
    }
    
    public void deleteTopic(String topicName) throws ExecutionException, InterruptedException {
        try (AdminClient adminClient = createAdminClient()) {
            adminClient.deleteTopics(Collections.singleton(topicName)).all().get();
        }
    }
    
    public void updatePartitions(String topicName, int newPartitionCount) throws ExecutionException, InterruptedException {
        try (AdminClient adminClient = createAdminClient()) {
            Map<String, NewPartitions> newPartitionsMap = Collections.singletonMap(
                    topicName, NewPartitions.increaseTo(newPartitionCount));
            adminClient.createPartitions(newPartitionsMap).all().get();
        }
    }
    
    public List<ConsumerGroupInfo> listConsumerGroups() throws ExecutionException, InterruptedException {
        List<ConsumerGroupInfo> result = new ArrayList<>();
        
        try (AdminClient adminClient = createAdminClient()) {
            ListConsumerGroupsResult groupsResult = adminClient.listConsumerGroups();
            Collection<ConsumerGroupListing> groups = groupsResult.all().get();
            
            for (ConsumerGroupListing group : groups) {
                ConsumerGroupInfo info = new ConsumerGroupInfo();
                info.setGroupId(group.groupId());
                info.setSimple(group.isSimpleConsumerGroup());
                result.add(info);
            }
        }
        
        return result;
    }
    
    public ConsumerGroupDetail getConsumerGroupDetails(String groupId) throws ExecutionException, InterruptedException {
        try (AdminClient adminClient = createAdminClient()) {
            // Check if consumer group exists
            ListConsumerGroupsResult groupsResult = adminClient.listConsumerGroups();
            Collection<ConsumerGroupListing> groups = groupsResult.all().get();
            boolean groupExists = groups.stream().anyMatch(g -> g.groupId().equals(groupId));
            
            if (!groupExists) {
                return null;
            }
            
            // Get consumer group description
            DescribeConsumerGroupsResult describeResult = adminClient.describeConsumerGroups(
                    Collections.singleton(groupId));
            ConsumerGroupDescription description = describeResult.all().get().get(groupId);
            
            // Get consumer group offsets
            ListConsumerGroupOffsetsResult offsetsResult = adminClient.listConsumerGroupOffsets(groupId);
            Map<TopicPartition, OffsetAndMetadata> offsets = offsetsResult.partitionsToOffsetAndMetadata().get();
            
            ConsumerGroupDetail detail = new ConsumerGroupDetail();
            detail.setGroupId(description.groupId());
            detail.setState(description.state().toString());
            
            // Process members
            List<ConsumerMemberInfo> members = new ArrayList<>();
            for (MemberDescription member : description.members()) {
                ConsumerMemberInfo memberInfo = new ConsumerMemberInfo();
                memberInfo.setMemberId(member.consumerId());
                memberInfo.setClientId(member.clientId());
                memberInfo.setHost(member.host());
                
                if (member.assignment() != null) {
                    memberInfo.setAssignments(member.assignment().topicPartitions().stream()
                            .map(tp -> tp.topic() + "-" + tp.partition())
                            .collect(Collectors.toList()));
                }
                
                members.add(memberInfo);
            }
            detail.setMembers(members);
            
            // Process offsets
            List<PartitionOffsetInfo> partitionOffsets = new ArrayList<>();
            for (Map.Entry<TopicPartition, OffsetAndMetadata> entry : offsets.entrySet()) {
                TopicPartition tp = entry.getKey();
                OffsetAndMetadata offset = entry.getValue();
                
                PartitionOffsetInfo offsetInfo = new PartitionOffsetInfo();
                offsetInfo.setTopic(tp.topic());
                offsetInfo.setPartition(tp.partition());
                offsetInfo.setOffset(offset.offset());
                offsetInfo.setMetadata(offset.metadata());
                
                partitionOffsets.add(offsetInfo);
            }
            detail.setOffsets(partitionOffsets);
            
            return detail;
        } catch (Exception e) {
            LOG.error("Error getting consumer group details for " + groupId, e);
            throw e;
        }
    }
    
    public void deleteConsumerGroup(String groupId) throws ExecutionException, InterruptedException {
        try (AdminClient adminClient = createAdminClient()) {
            adminClient.deleteConsumerGroups(Collections.singleton(groupId)).all().get();
        }
    }
    
    public List<BrokerInfo> listBrokers() throws ExecutionException, InterruptedException {
        List<BrokerInfo> result = new ArrayList<>();
        
        try (AdminClient adminClient = createAdminClient()) {
            DescribeClusterResult clusterResult = adminClient.describeCluster();
            Collection<Node> nodes = clusterResult.nodes().get();
            Node controller = clusterResult.controller().get();
            
            for (Node node : nodes) {
                BrokerInfo broker = new BrokerInfo();
                broker.setId(node.id());
                broker.setHost(node.host());
                broker.setPort(node.port());
                broker.setRack(node.rack());
                broker.setController(node.id() == controller.id());
                result.add(broker);
            }
        }
        
        return result;
    }
    
    public ClusterMetrics getClusterMetrics() throws ExecutionException, InterruptedException {
        ClusterMetrics metrics = new ClusterMetrics();
        
        try (AdminClient adminClient = createAdminClient()) {
            // Get cluster info
            DescribeClusterResult clusterResult = adminClient.describeCluster();
            String clusterId = clusterResult.clusterId().get();
            Collection<Node> nodes = clusterResult.nodes().get();
            
            metrics.setClusterId(clusterId);
            metrics.setBrokerCount(nodes.size());
            
            // Get topics info
            ListTopicsResult topicsResult = adminClient.listTopics();
            Set<String> topicNames = topicsResult.names().get();
            
            metrics.setTopicCount(topicNames.size());
            
            // Get partition info
            DescribeTopicsResult describeTopicsResult = adminClient.describeTopics(topicNames);
            Map<String, TopicDescription> topicDescriptions = describeTopicsResult.allTopicNames().get();
            
            int totalPartitions = 0;
            Map<Integer, Integer> partitionsPerBroker = new HashMap<>();
            
            for (Map.Entry<String, TopicDescription> entry : topicDescriptions.entrySet()) {
                TopicDescription description = entry.getValue();
                totalPartitions += description.partitions().size();
                
                for (TopicPartitionInfo partitionInfo : description.partitions()) {
                    int leaderId = partitionInfo.leader().id();
                    partitionsPerBroker.put(leaderId, partitionsPerBroker.getOrDefault(leaderId, 0) + 1);
                }
            }
            
            metrics.setPartitionCount(totalPartitions);
            metrics.setPartitionsPerBroker(partitionsPerBroker);
            
            // Get consumer groups info
            ListConsumerGroupsResult groupsResult = adminClient.listConsumerGroups();
            Collection<ConsumerGroupListing> groups = groupsResult.all().get();
            
            metrics.setConsumerGroupCount(groups.size());
            
            return metrics;
        }
    }
    
    public void reassignPartitions(PartitionReassignmentRequest request) throws ExecutionException, InterruptedException {
        try (AdminClient adminClient = createAdminClient()) {
            Map<TopicPartition, Optional<NewPartitionReassignment>> reassignments = new HashMap<>();
            
            for (PartitionReassignment reassignment : request.getReassignments()) {
                TopicPartition tp = new TopicPartition(reassignment.getTopic(), reassignment.getPartition());
                NewPartitionReassignment newAssignment = new NewPartitionReassignment(reassignment.getReplicas());
                reassignments.put(tp, Optional.of(newAssignment));
            }
            
            adminClient.alterPartitionReassignments(reassignments).all().get();
        }
    }
}
