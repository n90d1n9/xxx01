import '../../../components/guardrails/model/guardrail_action.dart';
import 'http_request_action.dart';
import 'script_action.dart';
import 'template_action.dart';
import 'tranform_action.dart';
import 'workflow_action.dart';

abstract class ActionDefinition {
  final String type;

  ActionDefinition(this.type);

  Map<String, dynamic> toJson();

  factory ActionDefinition.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == null) throw Exception('Action type is required');

    switch (type) {
      case 'http_request':
        return HttpRequestAction.fromJson(json);
      case 'transform':
        return TransformAction.fromJson(json);
      case 'script':
        return ScriptAction.fromJson(json);
      case 'template':
        return TemplateAction.fromJson(json);
      case 'workflow':
        return WorkflowAction.fromJson(json);
      case 'guardrail': // 👈 Add this
        return GuardrailAction.fromJson(json);
      default:
        throw Exception('Unknown action type: $type');
    }
  }
}
