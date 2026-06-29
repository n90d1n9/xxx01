import '../../schema/agent/agent.dart';
import '../../schema/common/ai_agen_builder_model.dart';
import '../../schema/workflow/workflow.dart';
import '../service/code_generator.dart';

class PythonGenerator extends CodeGenerator {
  PythonGenerator({
    required super.templateEngine,
    required super.outputDirectory,
  });

  @override
  Future<Map<String, String>> generate(AIAgentBuilderModel model) async {
    final files = <String, String>{};

    // Generate setup.py
    files['setup.py'] = templateEngine.render(
      'python/setup',
      _buildSetupContext(model),
    );

    // Generate requirements.txt
    files['requirements.txt'] = templateEngine.render(
      'python/requirements',
      {},
    );

    // Generate main app
    final packageName = _toSnakeCase(model.project.name);
    files['$packageName/__init__.py'] = '';
    files['$packageName/main.py'] = templateEngine.render('python/main', {
      'project': model.project,
    });

    // Generate workflow modules
    for (final agent in model.agents) {
      if (agent.workflows != null) {
        for (final workflow in agent.workflows!) {
          files['$packageName/workflows/${_toSnakeCase(workflow.name)}.py'] =
              templateEngine.render(
                'python/workflow',
                _buildWorkflowContext(workflow),
              );
        }
      }
    }

    // Generate agent modules
    for (final agent in model.agents) {
      files['$packageName/agents/${_toSnakeCase(agent.name)}.py'] =
          templateEngine.render('python/agent', _buildAgentContext(agent));
    }

    return files;
  }

  Map<String, dynamic> _buildSetupContext(AIAgentBuilderModel model) {
    return {
      'name': _toSnakeCase(model.project.name),
      'version': model.config?.version ?? '1.0.0',
      'description': model.project.description ?? '',
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
              'methodName': _toSnakeCase(node.name),
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

  String _toSnakeCase(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (m) => '${m.group(1)}_${m.group(2)}',
        )
        .replaceAll(RegExp(r'[\-\s]+'), '_')
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
}
