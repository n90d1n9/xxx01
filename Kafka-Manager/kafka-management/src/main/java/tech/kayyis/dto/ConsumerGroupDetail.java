package java.tech.kayyis.dto;

import java.util.List;

class ConsumerGroupDetail {
    private String groupId;
    private String state;
    private List<ConsumerMemberInfo> members;
    private List<PartitionOffsetInfo> offsets;

    // Getters and setters
    public String getGroupId() { return groupId; }
    public void setGroupId(String groupId) { this.groupId = groupId; }
    public String getState() { return state; }
    public void setState(String state) { this.state = state; }
    public List<ConsumerMemberInfo> getMembers() { return members; }
    public void setMembers(List<ConsumerMemberInfo> members) { this.members = members; }
    public List<PartitionOffsetInfo> getOffsets() { return offsets; }
    public void setOffsets(List<PartitionOffsetInfo> offsets) { this.offsets = offsets; }
}
