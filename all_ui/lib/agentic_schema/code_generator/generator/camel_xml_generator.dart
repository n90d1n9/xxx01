import '../../schema/common/ai_agen_builder_model.dart';
import '../../schema/config/node_config.dart';
import '../../schema/connection/integration_connector.dart';
import '../../schema/integration/integration_pattern.dart';
import '../../schema/node/node_type.dart';
import '../../schema/workflow/workflow.dart';
import '../../schema/workflow/workflow_edge.dart';
import '../../schema/workflow/workflow_node.dart';
import '../service/code_generator.dart';

class CamelXmlGenerator extends CodeGenerator {
  CamelXmlGenerator({
    required super.templateEngine,
    required super.outputDirectory,
  }) {
    _registerCamelHelpers();
  }

  void _registerCamelHelpers() {
    templateEngine.registerHelper('camelUri', (params, content, context) {
      if (params.isEmpty) return '';
      final connector = context[params[0]];
      if (connector == null) return '';
      return _buildCamelUri(connector);
    });

    templateEngine.registerHelper('nodeType', (params, content, context) {
      if (params.isEmpty) return '';
      final nodeType = params[0];
      return _mapNodeTypeToCamelComponent(nodeType);
    });
  }

  String _buildCamelUri(Map<String, dynamic> connector) {
    final type = connector['type'];
    final config = connector['connectionConfig'] ?? {};

    switch (type) {
      case 'kafka':
        final topic = config['topicName'] ?? 'default';
        return 'kafka:$topic';
      case 'http':
      case 'rest':
        return config['uri'] ?? 'http://localhost';
      case 'file':
        return 'file:${config['path'] ?? '/tmp'}';
      case 'database':
        return 'jdbc:${config['connectionString'] ?? ''}';
      default:
        return '$type:default';
    }
  }

  String _mapNodeTypeToCamelComponent(String nodeType) {
    switch (nodeType) {
      case 'splitter':
        return 'split';
      case 'aggregator':
        return 'aggregate';
      case 'enricher':
        return 'enrich';
      case 'filter':
        return 'filter';
      case 'transform':
        return 'transform';
      case 'router':
        return 'choice';
      default:
        return 'process';
    }
  }

  @override
  Future<Map<String, String>> generate(AIAgentBuilderModel model) async {
    final files = <String, String>{};

    // Generate Spring Boot application
    files['src/main/resources/application.yml'] = templateEngine.render(
      'camel/application',
      _buildApplicationContext(model),
    );

    // Generate routes for each workflow
    for (final agent in model.agents) {
      if (agent.workflows != null) {
        for (final workflow in agent.workflows!) {
          final routeXml = _generateRouteXml(workflow, model);
          files['src/main/resources/camel/${workflow.name}.xml'] = routeXml;
        }
      }
    }

    // Generate pom.xml
    files['pom.xml'] = templateEngine.render(
      'camel/pom',
      _buildPomContext(model),
    );

    // Generate main application class
    files['src/main/java/com/aiagent/Application.java'] = templateEngine.render(
      'camel/application_java',
      _buildJavaContext(model),
    );

    return files;
  }

  String _generateRouteXml(Workflow workflow, AIAgentBuilderModel model) {
    final context = {
      'workflow': _workflowToMap(workflow),
      'nodes': workflow.nodes.map(_nodeToMap).toList(),
      'edges': workflow.edges?.map(_edgeToMap).toList() ?? [],
      'hasStart': workflow.nodes.any((n) => n.type == NodeType.start),
      'hasEnd': workflow.nodes.any((n) => n.type == NodeType.end),
    };

    return templateEngine.render('camel/route', context);
  }

  Map<String, dynamic> _workflowToMap(Workflow workflow) {
    return {
      'id': workflow.id,
      'name': workflow.name,
      'description': workflow.description,
      'type': workflow.type?.name,
    };
  }

  Map<String, dynamic> _nodeToMap(WorkflowNode node) {
    return {
      'id': node.id,
      'name': node.name,
      'type': node.type.name,
      'category': node.category?.name,
      'config': _configToMap(node.config),
      'connector': node.connector != null
          ? _connectorToMap(node.connector!)
          : null,
      'integrationPattern': node.integrationPattern != null
          ? _integrationPatternToMap(node.integrationPattern!)
          : null,
    };
  }

  Map<String, dynamic> _edgeToMap(WorkflowEdge edge) {
    return {
      'id': edge.id,
      'source': edge.source,
      'target': edge.target,
      'type': edge.type?.name,
      'label': edge.label,
      'condition': edge.condition?.expression,
    };
  }

  Map<String, dynamic>? _configToMap(NodeConfig? config) {
    if (config == null) return null;

    return {
      'prompt': config.prompt,
      'condition': config.condition?.expression,
      'splitter': config.splitterConfig != null
          ? {
              'strategy': config.splitterConfig!.strategy,
              'expression': config.splitterConfig!.expression,
            }
          : null,
      'aggregator': config.aggregatorConfig != null
          ? {
              'completionSize': config.aggregatorConfig!.completionSize,
              'timeout': config.aggregatorConfig!.completionTimeout,
              'strategy': config.aggregatorConfig!.aggregationStrategy,
            }
          : null,
      'transform': config.transformConfig != null
          ? {
              'type': config.transformConfig!.type,
              'script': config.transformConfig!.script,
            }
          : null,
    };
  }

  Map<String, dynamic> _connectorToMap(IntegrationConnector connector) {
    return {
      'id': connector.id,
      'name': connector.name,
      'type': connector.type.name,
      'direction': connector.direction.name,
      'uri': _buildCamelUri(_connectorToRawMap(connector)),
      'config': connector.connectionConfig != null
          ? {
              'uri': connector.connectionConfig!.uri,
              'host': connector.connectionConfig!.host,
              'port': connector.connectionConfig!.port,
            }
          : null,
    };
  }

  Map<String, dynamic> _connectorToRawMap(IntegrationConnector connector) {
    return {
      'type': connector.type.name,
      'connectionConfig': connector.connectionConfig != null
          ? {
              'uri': connector.connectionConfig!.uri,
              'topicName': connector.messagePattern?.config?.topicName,
              'path': connector.connectionConfig!.uri,
              'connectionString': connector.connectionConfig!.uri,
            }
          : {},
    };
  }

  Map<String, dynamic> _integrationPatternToMap(IntegrationPattern pattern) {
    return {
      'hasRouting': pattern.routing != null,
      'hasTransformation': pattern.transformation != null,
      'hasEndpoint': pattern.endpoint != null,
      'hasMessage': pattern.message != null,
      'routing': pattern.routing?.pattern.name,
      'transformation': pattern.transformation?.pattern.name,
    };
  }

  Map<String, dynamic> _buildApplicationContext(AIAgentBuilderModel model) {
    return {
      'projectName': model.project.name,
      'camelVersion': '4.0.0',
      'springBootVersion': '3.2.0',
      'integrationConfig': model.integrationConfig != null
          ? {
              'backend': model.integrationConfig!.backend?.type,
              'camelContext': model.integrationConfig!.camelContext?.name,
            }
          : null,
    };
  }

  Map<String, dynamic> _buildPomContext(AIAgentBuilderModel model) {
    return {
      'groupId': 'com.aiagent',
      'artifactId': _toKebabCase(model.project.name),
      'version': '1.0.0',
      'projectName': model.project.name,
      'camelVersion': '4.0.0',
      'springBootVersion': '3.2.0',
    };
  }

  Map<String, dynamic> _buildJavaContext(AIAgentBuilderModel model) {
    return {
      'package': 'com.aiagent',
      'className': _toPascalCase(model.project.name),
      'projectName': model.project.name,
    };
  }

  String _toKebabCase(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match.group(1)}-${match.group(2)}',
        )
        .replaceAll(RegExp(r'[_\s]+'), '-')
        .toLowerCase();
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
}
