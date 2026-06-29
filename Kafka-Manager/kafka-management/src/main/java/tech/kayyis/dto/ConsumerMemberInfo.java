package java.tech.kayyis.dto;

import java.util.List;

class ConsumerMemberInfo {
    private String memberId;
    private String clientId;
    private String host;
    private List<String> assignments;

    // Getters and setters
    public String getMemberId() { return memberId; }
    public void setMemberId(String memberId) { this.memberId = memberId; }
    public String getClientId() { return clientId; }
    public void setClientId(String clientId) { this.clientId = clientId; }
    public String getHost() { return host; }
    public void setHost(String host) { this.host = host; }
    public List<String> getAssignments() { return assignments; }
    public void setAssignments(List<String> assignments) { this.assignments = assignments; }
}
