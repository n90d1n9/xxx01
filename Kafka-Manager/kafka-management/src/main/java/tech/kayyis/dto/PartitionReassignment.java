package java.tech.kayyis.dto;

import java.util.List;

class PartitionReassignment {
    private String topic;
    private int partition;
    private List<Integer> replicas;

    // Getters and setters
    public String getTopic() { return topic; }
    public void setTopic(String topic) { this.topic = topic; }
    public int getPartition() { return partition; }
    public void setPartition(int partition) { this.partition = partition; }
    public List<Integer> getReplicas() { return replicas; }
    public void setReplicas(List<Integer> replicas) { this.replicas = replicas; }
}