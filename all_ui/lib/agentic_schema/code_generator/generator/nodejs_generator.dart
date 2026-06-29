import '../../schema/agent/agent.dart';
import '../../schema/common/ai_agen_builder_model.dart';
import '../../schema/workflow/workflow.dart';
import '../service/code_generator.dart';

class NodeJsGenerator extends CodeGenerator {
  NodeJsGenerator({
    required super.templateEngine,
    required super.outputDirectory,
  });

  @override
  Future<Map<String, String>> generate(AIAgentBuilderModel model) async {
    final files = <String, String>{};

    // Generate package.json
    files['package.json'] = templateEngine.render(
      'nodejs/package_json',
      _buildPackageJsonContext(model),
    );

    // Generate main app
    files['src/index.js'] = templateEngine.render('nodejs/index', {
      'project': model.project,
    });

    // Generate workflow handlers
    for (final agent in model.agents) {
      if (agent.workflows != null) {
        for (final workflow in agent.workflows!) {
          files['src/workflows/${_toKebabCase(workflow.name)}.js'] =
              templateEngine.render(
                'nodejs/workflow',
                _buildWorkflowContext(workflow),
              );
        }
      }
    }

    // Generate agent services
    for (final agent in model.agents) {
      files['src/agents/${_toKebabCase(agent.name)}.js'] = templateEngine
          .render('nodejs/agent', _buildAgentContext(agent));
    }

    // Generate config
    files['src/config/config.js'] = templateEngine.render('nodejs/config', {
      'integrationConfig': model.integrationConfig,
    });

    return files;
  }

  Map<String, dynamic> _buildPackageJsonContext(AIAgentBuilderModel model) {
    return {
      'name': _toKebabCase(model.project.name),
      'version': model.config?.version ?? '1.0.0',
      'description': model.project.description ?? '',
      'dependencies': {
        'express': '^4.18.2',
        'axios': '^1.6.0',
        'kafkajs': '^2.2.4',
        'amqplib': '^0.10.3',
        'openai': '^4.20.0',
      },
    };
  }

  Map<String, dynamic> _buildWorkflowContext(Workflow workflow) {
    return {
      'workflowName': workflow.name,
      'className': _toPascalCase(workflow.name),
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
      'agentName': agent.name,
      'className': _toPascalCase(agent.name),
      'llmProvider': agent.llmConfig.provider.name,
      'llmModel': agent.llmConfig.model,
    };
  }

  String _toKebabCase(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (m) => '${m.group(1)}-${m.group(2)}',
        )
        .replaceAll(RegExp(r'[_\s]+'), '-')
        .toLowerCase();
  }

  String _toPascalCase(String text) {
    return text
        .split(RegExp(r'[_\-\s]+'))
        .map(
          (w) => w.isEmpty
              ? ''
              : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join('');
  }

  String _toCamelCase(String text) {
    return text
        .split(RegExp(r'[_\-\s]+'))
        .asMap()
        .map(
          (i, w) => MapEntry(
            i,
            i == 0
                ? w.toLowerCase()
                : w[0].toUpperCase() + w.substring(1).toLowerCase(),
          ),
        )
        .values
        .join('');
  }
}
