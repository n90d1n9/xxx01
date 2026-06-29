class Shift {
  final int id;
  final int employeeId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String status; // scheduled, in_progress, completed, missed

  Shift({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.status,
  });
}
