package tech.kayys.services;


import org.apache.kafka.clients.admin.*;
import org.apache.kafka.common.config.ConfigResource;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

import java.util.*;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@ApplicationScoped
public class KafkaAdminService {

    @Inject
    AdminClient adminClient;

    public List<String> listTopics() throws ExecutionException, InterruptedException {
        return adminClient.listTopics().names().get().stream().collect(Collectors.toList());
    }

    public void createTopic(String topicName, int partitions, short replicationFactor) 
            throws ExecutionException, InterruptedException {
        NewTopic newTopic = new NewTopic(topicName, partitions, replicationFactor);
        adminClient.createTopics(Collections.singletonList(newTopic)).all().get();
    }

    public void deleteTopic(String topicName) throws ExecutionException, InterruptedException {
        adminClient.deleteTopics(Collections.singletonList(topicName)).all().get();
    }

    public Map<String, TopicDescription> describeTopics(List<String> topicNames) 
            throws ExecutionException, InterruptedException {
        return adminClient.describeTopics(topicNames).all().get();
    }

    public Map<ConfigResource, Config> describeConfigs(String topicName) 
            throws ExecutionException, InterruptedException {
        ConfigResource resource = new ConfigResource(ConfigResource.Type.TOPIC, topicName);
        return adminClient.describeConfigs(Collections.singletonList(resource)).all().get();
    }

    public Map<String, String> getTopicConfigs(String topicName) 
            throws ExecutionException, InterruptedException {
        Map<ConfigResource, Config> configs = describeConfigs(topicName);
        return configs.values().stream()
                .flatMap(config -> config.entries().stream())
                .collect(Collectors.toMap(
                        ConfigEntry::name,
                        ConfigEntry::value
                ));
    }

    public List<ConsumerGroupListing> listConsumerGroups() 
            throws ExecutionException, InterruptedException {
        return (List<ConsumerGroupListing>) adminClient.listConsumerGroups().all().get();
    }

    public Map<String, ConsumerGroupDescription> describeConsumerGroups(List<String> groupIds) 
            throws ExecutionException, InterruptedException {
        return adminClient.describeConsumerGroups(groupIds).all().get();
    }
}