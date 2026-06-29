import 'report_comment.dart';
import 'report_visibility.dart';

class ReportCollaboration {
  final String reportId;
  final Map<String, CollaborationMode> userPermissions;
  final List<String> activeUsers;
  final List<ReportComment> comments;
  final bool allowDownload;
  final bool allowShare;
  final DateTime? expiresAt;

  ReportCollaboration({
    required this.reportId,
    required this.userPermissions,
    this.activeUsers = const [],
    this.comments = const [],
    this.allowDownload = true,
    this.allowShare = true,
    this.expiresAt,
  });
}
