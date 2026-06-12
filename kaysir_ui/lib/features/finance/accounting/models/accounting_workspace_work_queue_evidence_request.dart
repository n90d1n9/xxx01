class AccountingWorkspaceWorkQueueEvidenceRequest {
  AccountingWorkspaceWorkQueueEvidenceRequest({
    required this.recipientLabel,
    required this.subject,
    required this.responseDueLabel,
    required this.statusLabel,
    required this.agingLabel,
    required this.followUpLabel,
    required this.nextTrackingActionLabel,
    required this.requestBody,
    required Iterable<String> requestedItems,
  }) : requestedItems = List<String>.unmodifiable(requestedItems);

  final String recipientLabel;
  final String subject;
  final String responseDueLabel;
  final String statusLabel;
  final String agingLabel;
  final String followUpLabel;
  final String nextTrackingActionLabel;
  final String requestBody;
  final List<String> requestedItems;
}
