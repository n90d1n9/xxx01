/// Report versioning and history
class ReportVersion {
  final String id;
  final String reportId;
  final int version;
  final String configJson;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final String? comment;
  final Map<String, dynamic>? changes;

  ReportVersion({
    required this.id,
    required this.reportId,
    required this.version,
    required this.configJson,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.comment,
    this.changes,
  });
}
