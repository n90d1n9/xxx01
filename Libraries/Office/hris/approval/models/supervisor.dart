class SupervisorAction {
  SupervisorAction({
    required String id,
    required String actionType,
    required String requestedBy,
    required DateTime requestedAt,
    String? approvedBy,
    DateTime? approvedAt,
    String? reason,
    Map<String, dynamic>? metadata,
  });
}
