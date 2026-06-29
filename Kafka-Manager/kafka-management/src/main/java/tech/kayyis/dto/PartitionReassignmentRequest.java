package java.tech.kayyis.dto;

import java.util.List;

class PartitionReassignmentRequest {
    private List<PartitionReassignment> reassignments;

    // Getters and setters
    public List<PartitionReassignment> getReassignments() { return reassignments; }
    public void setReassignments(List<PartitionReassignment> reassignments) { this.reassignments = reassignments; }
}
