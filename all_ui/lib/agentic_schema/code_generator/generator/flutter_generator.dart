import '../../schema/agent/agent.dart';
import '../../schema/common/ai_agen_builder_model.dart';
import '../../schema/workflow/workflow.dart';
import '../service/code_generator.dart';

class FlutterGenerator extends CodeGenerator {
  FlutterGenerator({
    required super.templateEngine,
    required super.outputDirectory,
  });

  @override
  Future<Map<String, String>> generate(AIAgentBuilderModel model) async {
    final files = <String, String>{};

    // Generate workflow execution service
    for (final agent in model.agents) {
      if (agent.workflows != null) {
        for (final workflow in agent.workflows!) {
          final context = _buildWorkflowContext(workflow);
          files['lib/services/${_toSnakeCase(workflow.name)}_service.dart'] =
              templateEngine.render('flutter/workflow_service', context);
        }
      }
    }

    // Generate agent provider
    for (final agent in model.agents) {
      final context = _buildAgentContext(agent);
      files['lib/providers/${_toSnakeCase(agent.name)}_provider.dart'] =
          templateEngine.render('flutter/agent_provider', context);
    }

    // Generate main app
    files['lib/main.dart'] = templateEngine.render('flutter/main', {
      'project': model.project,
      'agents': model.agents,
    });

    return files;
  }

  Map<String, dynamic> _buildWorkflowContext(Workflow workflow) {
    return {
      'workflow': {
        'name': workflow.name,
        'className': _toPascalCase(workflow.name),
        'description': workflow.description,
      },
      'nodes': workflow.nodes
          .map(
            (node) => {
              'name': node.name,
              'type': node.type.name,
              'methodName': _toCamelCase(node.name),
            },
          )
          .toList(),
    };
  }

  Map<String, dynamic> _buildAgentContext(Agent agent) {
    return {
      'agent': {
        'name': agent.name,
        'className': _toPascalCase(agent.name),
        'type': agent.type.name,
      },
      'llmConfig': {
        'provider': agent.llmConfig.provider.name,
        'model': agent.llmConfig.model,
      },
    };
  }

  String _toCamelCase(String text) {
    return text
        .split(RegExp(r'[_\-\s]+'))
        .asMap()
        .map(
          (i, word) => MapEntry(
            i,
            i == 0
                ? word.toLowerCase()
                : word[0].toUpperCase() + word.substring(1).toLowerCase(),
          ),
        )
        .values
        .join('');
  }

  String _toPascalCase(String text) {
    return text
        .split(RegExp(r'[_\-\s]+'))
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join('');
  }

  String _toSnakeCase(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match.group(1)}_${match.group(2)}',
        )
        .replaceAll(RegExp(r'[\-\s]+'), '_')
        .toLowerCase();
  }
}
