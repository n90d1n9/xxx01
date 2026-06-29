import 'human_approval_status.dart';
import 'human_loop_definition.dart';

class HumanApprovalRequest {
  final String id;
  final HumanInLoopNodeDefinition definition;
  final Map<String, dynamic> inputData;
  final DateTime createdAt;
  final DateTime? expiresAt;
  HumanApprovalStatus status;
  String? selectedOption;
  List<String>? selectedOptions;
  String? textResponse;
  String? comment;
  String? approvedBy;
  DateTime? respondedAt;

  HumanApprovalRequest({
    required this.id,
    required this.definition,
    required this.inputData,
    required this.createdAt,
    this.expiresAt,
    this.status = HumanApprovalStatus.pending,
    this.selectedOption,
    this.selectedOptions,
    this.textResponse,
    this.comment,
    this.approvedBy,
    this.respondedAt,
  });

  bool get isPending => status == HumanApprovalStatus.pending;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isCompleted =>
      status == HumanApprovalStatus.approved ||
      status == HumanApprovalStatus.rejected ||
      status == HumanApprovalStatus.completed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'definition': definition.toJson(),
    'inputData': inputData,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'status': status.name,
    'selectedOption': selectedOption,
    'selectedOptions': selectedOptions,
    'textResponse': textResponse,
    'comment': comment,
    'approvedBy': approvedBy,
    'respondedAt': respondedAt?.toIso8601String(),
  };
}
