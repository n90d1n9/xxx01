import '../../schema/common/ai_agen_builder_model.dart';
import '../../schema/workflow/workflow.dart';
import '../../schema/workflow/workflow_node.dart';
import '../service/code_generator.dart';

class CamelYamlGenerator extends CodeGenerator {
  CamelYamlGenerator({
    required super.templateEngine,
    required super.outputDirectory,
  });

  @override
  Future<Map<String, String>> generate(AIAgentBuilderModel model) async {
    final files = <String, String>{};

    // Generate application.yml
    files['src/main/resources/application.yml'] = templateEngine.render(
      'camel/application_yml',
      _buildContext(model),
    );

    // Generate routes for each workflow
    for (final agent in model.agents) {
      if (agent.workflows != null) {
        for (final workflow in agent.workflows!) {
          final routeYaml = _generateRouteYaml(workflow);
          files['src/main/resources/camel-routes/${workflow.name}.yaml'] =
              routeYaml;
        }
      }
    }

    return files;
  }

  String _generateRouteYaml(Workflow workflow) {
    final context = {
      'workflow': {
        'id': workflow.id,
        'name': workflow.name,
        'description': workflow.description,
      },
      'nodes': workflow.nodes
          .map(
            (node) => {
              'id': node.id,
              'name': node.name,
              'type': node.type.name,
              'config': _extractNodeConfig(node),
            },
          )
          .toList(),
      'edges':
          workflow.edges
              ?.map(
                (edge) => {
                  'source': edge.source,
                  'target': edge.target,
                  'condition': edge.condition?.expression,
                },
              )
              .toList() ??
          [],
    };

    return templateEngine.render('camel/route_yaml', context);
  }

  Map<String, dynamic> _extractNodeConfig(WorkflowNode node) {
    final config = <String, dynamic>{};

    if (node.config?.splitterConfig != null) {
      config['splitter'] = {
        'strategy': node.config!.splitterConfig!.strategy,
        'expression': node.config!.splitterConfig!.expression,
      };
    }

    if (node.config?.aggregatorConfig != null) {
      config['aggregator'] = {
        'completionSize': node.config!.aggregatorConfig!.completionSize,
        'timeout': node.config!.aggregatorConfig!.completionTimeout,
      };
    }

    if (node.connector != null) {
      config['connector'] = {
        'type': node.connector!.type.name,
        'uri': node.connector!.connectionConfig?.uri,
      };
    }

    return config;
  }

  Map<String, dynamic> _buildContext(AIAgentBuilderModel model) {
    return {
      'projectName': model.project.name,
      'port': 8080,
      'camelVersion': '4.0.0',
    };
  }
}
