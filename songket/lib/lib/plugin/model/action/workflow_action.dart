import 'action_definition.dart';

class WorkflowAction extends ActionDefinition {
  final String workflowId;
  final Map<String, String> inputMapping;
  final Map<String, String> outputMapping;

  WorkflowAction({
    required this.workflowId,
    this.inputMapping = const {},
    this.outputMapping = const {},
  }) : super('workflow');

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'workflowId': workflowId,
    'inputMapping': inputMapping,
    'outputMapping': outputMapping,
  };

  factory WorkflowAction.fromJson(Map<String, dynamic> json) => WorkflowAction(
    workflowId: json['workflowId'],
    inputMapping: Map<String, String>.from(json['inputMapping'] ?? {}),
    outputMapping: Map<String, String>.from(json['outputMapping'] ?? {}),
  );
}
