package java.tech.kayyis.dto;

import java.util.List;
import java.util.Map;

class TopicDetail {
    private String name;
    private int partitionCount;
    private boolean internal;
    private List<PartitionInfo> partitions;
    private Map<String, String> configs;

    // Getters and setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public int getPartitionCount() { return partitionCount; }
    public void setPartitionCount(int partitionCount) { this.partitionCount = partitionCount; }
    public boolean isInternal() { return internal; }
    public void setInternal(boolean internal) { this.internal = internal; }
    public List<PartitionInfo> getPartitions() { return partitions; }
    public void setPartitions(List<PartitionInfo> partitions) { this.partitions = partitions; }
    public Map<String, String> getConfigs() { return configs; }
    public void setConfigs(Map<String, String> configs) { this.configs = configs; }
}