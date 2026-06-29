package java.tech.kayyis.dto;

import java.util.Map;

class ClusterMetrics {
    private String clusterId;
    private int brokerCount;
    private int topicCount;
    private int partitionCount;
    private int consumerGroupCount;
    private Map<Integer, Integer> partitionsPerBroker;

    // Getters and setters
    public String getClusterId() { return clusterId; }
    public void setClusterId(String clusterId) { this.clusterId = clusterId; }
    public int getBrokerCount() { return brokerCount; }
    public void setBrokerCount(int brokerCount) { this.brokerCount = brokerCount; }
    public int getTopicCount() { return topicCount; }
    public void setTopicCount(int topicCount) { this.topicCount = topicCount; }
    public int getPartitionCount() { return partitionCount; }
    public void setPartitionCount(int partitionCount) { this.partitionCount = partitionCount; }
    public int getConsumerGroupCount() { return consumerGroupCount; }
    public void setConsumerGroupCount(int consumerGroupCount) { this.consumerGroupCount = consumerGroupCount; }
    public Map<Integer, Integer> getPartitionsPerBroker() { return partitionsPerBroker; }
    public void setPartitionsPerBroker(Map<Integer, Integer> partitionsPerBroker) { this.partitionsPerBroker = partitionsPerBroker; }
}
