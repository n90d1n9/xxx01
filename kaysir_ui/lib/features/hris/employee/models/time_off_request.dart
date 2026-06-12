class TimeOffRequest {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status; // Pending, Approved, Rejected

  TimeOffRequest({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
  });

  int get durationDays {
    final value = endDate.difference(startDate).inDays + 1;
    return value < 0 ? 0 : value;
  }

  bool get isApproved => status == 'Approved';

  bool get isPending => status == 'Pending';
}
