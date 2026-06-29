enum HumanApprovalStatus {
  pending,
  approved,
  rejected,
  completed,
  timeout,
  cancelled,
}

enum HumanApprovalType {
  binary, // Approve/Reject
  choice, // Multiple choice
  text, // Text input
  multiChoice, // Multiple selections
}
