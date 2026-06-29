package java.tech.kayyis;

import java.util.List;

class PartitionInfo {
    private int partition;
    private int leader;
    private List<Integer> replicas;
    private List<Integer> isr;

    // Getters and setters
    public int getPartition() { return partition; }
    public void setPartition(int partition) { this.partition = partition; }
    public int getLeader() { return leader; }
    public void setLeader(int leader) { this.leader = leader; }
    public List<Integer> getReplicas() { return replicas; }
    public void setReplicas(List<Integer> replicas) { this.replicas = replicas; }
    public List<Integer> getIsr() { return isr; }
    public void setIsr(List<Integer> isr) { this.isr = isr; }
}
