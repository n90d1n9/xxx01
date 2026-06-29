import '../../schema/common/ai_agen_builder_model.dart';
import '../../schema/connection/integration_connector.dart';
import '../../schema/integration/integration_type.dart';
import '../../schema/node/node_type.dart';
import '../../schema/workflow/workflow.dart';
import '../../schema/workflow/workflow_edge.dart';
import '../../schema/workflow/workflow_node.dart';
import '../service/code_generator.dart';

class SpringBootGenerator extends CodeGenerator {
  SpringBootGenerator({
    required super.templateEngine,
    required super.outputDirectory,
  });

  @override
  Future<Map<String, String>> generate(AIAgentBuilderModel model) async {
    final files = <String, String>{};
    final basePackage = 'com.aiagent.${_toSnakeCase(model.project.name)}';
    final basePath = 'src/main/java/${basePackage.replaceAll('.', '/')}';

    // Generate main application
    files['$basePath/Application.java'] = templateEngine
        .render('springboot/application', {
          'package': basePackage,
          'className': '${_toPascalCase(model.project.name)}Application',
          'projectName': model.project.name,
        });

    // Generate configuration
    files['$basePath/config/CamelConfiguration.java'] = templateEngine
        .render('springboot/camel_config', {
          'package': '$basePackage.config',
          'camelContext': model.integrationConfig?.camelContext,
        });

    // Generate route builders for each workflow
    for (final agent in model.agents) {
      if (agent.workflows != null) {
        for (final workflow in agent.workflows!) {
          files['$basePath/routes/${_toPascalCase(workflow.name)}Route.java'] =
              templateEngine.render(
                'springboot/route_builder',
                _buildRouteContext(workflow, basePackage),
              );
        }
      }
    }

    // Generate processors for custom nodes
    final customProcessors = _extractCustomProcessors(model);
    for (final processor in customProcessors) {
      files['$basePath/processors/${processor['className']}.java'] =
          templateEngine.render('springboot/processor', processor);
    }

    // Generate DTOs
    files['$basePath/dto/MessageDTO.java'] = templateEngine.render(
      'springboot/message_dto',
      {'package': '$basePackage.dto'},
    );

    // Generate application.yml
    files['src/main/resources/application.yml'] = templateEngine.render(
      'springboot/application_yml',
      _buildApplicationYmlContext(model),
    );

    // Generate pom.xml
    files['pom.xml'] = templateEngine.render(
      'springboot/pom',
      _buildPomContext(model),
    );

    return files;
  }

  Map<String, dynamic> _buildRouteContext(
    Workflow workflow,
    String basePackage,
  ) {
    return {
      'package': '$basePackage.routes',
      'className': '${_toPascalCase(workflow.name)}Route',
      'routeId': workflow.id,
      'workflow': {
        'name': workflow.name,
        'description': workflow.description,
        'nodes': workflow.nodes.map((node) => _buildNodeContext(node)).toList(),
        'edges':
            workflow.edges?.map((edge) => _buildEdgeContext(edge)).toList() ??
            [],
      },
      'startNode': workflow.nodes.firstWhere(
        (n) => n.type == NodeType.start,
        orElse: () => workflow.nodes.first,
      ),
    };
  }

  Map<String, dynamic> _buildNodeContext(WorkflowNode node) {
    return {
      'id': node.id,
      'name': node.name,
      'type': node.type.name,
      'camelComponent': _mapNodeTypeToCamel(node.type),
      'config': _extractNodeConfigForCamel(node),
      'hasConnector': node.connector != null,
      'connector': node.connector != null
          ? _buildConnectorContext(node.connector!)
          : null,
    };
  }

  Map<String, dynamic> _buildEdgeContext(WorkflowEdge edge) {
    return {
      'source': edge.source,
      'target': edge.target,
      'hasCondition': edge.condition != null,
      'condition': edge.condition?.expression,
      'type': edge.type?.name,
    };
  }

  Map<String, dynamic> _buildConnectorContext(IntegrationConnector connector) {
    return {
      'type': connector.type.name,
      'uri': _buildCamelUriFromConnector(connector),
      'config': connector.connectionConfig != null
          ? {
              'host': connector.connectionConfig!.host,
              'port': connector.connectionConfig!.port,
              'uri': connector.connectionConfig!.uri,
            }
          : {},
    };
  }

  String _buildCamelUriFromConnector(IntegrationConnector connector) {
    switch (connector.type) {
      case IntegrationType.kafka:
        final topic = connector.messagePattern?.config?.topicName ?? 'default';
        return 'kafka:$topic';
      case IntegrationType.http:
      case IntegrationType.rest:
        return connector.connectionConfig?.uri ?? 'http://localhost:8080';
      case IntegrationType.rabbitmq:
        final queue = connector.messagePattern?.config?.queueName ?? 'default';
        return 'rabbitmq:$queue';
      case IntegrationType.database:
        return 'jdbc:dataSource';
      case IntegrationType.file:
        return 'file://${connector.connectionConfig?.uri ?? '/tmp'}';
      default:
        return '${connector.type.name}:default';
    }
  }

  String _mapNodeTypeToCamel(NodeType type) {
    switch (type) {
      case NodeType.splitter:
        return 'split';
      case NodeType.aggregator:
        return 'aggregate';
      case NodeType.enricher:
        return 'enrich';
      case NodeType.filter:
        return 'filter';
      case NodeType.transform:
        return 'setBody';
      case NodeType.router:
      case NodeType.condition:
        return 'choice';
      case NodeType.multicast:
        return 'multicast';
      case NodeType.recipientList:
        return 'recipientList';
      case NodeType.throttler:
        return 'throttle';
      case NodeType.delay:
        return 'delay';
      case NodeType.loop:
        return 'loop';
      default:
        return 'process';
    }
  }

  Map<String, dynamic> _extractNodeConfigForCamel(WorkflowNode node) {
    final config = <String, dynamic>{};

    if (node.config?.splitterConfig != null) {
      config['expression'] =
          node.config!.splitterConfig!.expression ?? 'body()';
      config['streaming'] = node.config!.splitterConfig!.streaming ?? false;
    }

    if (node.config?.aggregatorConfig != null) {
      config['completionSize'] =
          node.config!.aggregatorConfig!.completionSize ?? 100;
      config['completionTimeout'] =
          node.config!.aggregatorConfig!.completionTimeout ?? 5000;
    }

    if (node.config?.condition != null) {
      config['expression'] = node.config!.condition!.expression;
      config['language'] = node.config!.condition!.language ?? 'simple';
    }

    if (node.config?.transformConfig != null) {
      config['script'] = node.config!.transformConfig!.script;
      config['type'] = node.config!.transformConfig!.type;
    }

    return config;
  }

  List<Map<String, dynamic>> _extractCustomProcessors(
    AIAgentBuilderModel model,
  ) {
    final processors = <Map<String, dynamic>>[];

    for (final agent in model.agents) {
      if (agent.workflows != null) {
        for (final workflow in agent.workflows!) {
          for (final node in workflow.nodes) {
            if (node.type == NodeType.codeExecution ||
                node.type == NodeType.llm ||
                node.type == NodeType.tool) {
              processors.add({
                'package':
                    'com.aiagent.${_toSnakeCase(model.project.name)}.processors',
                'className': '${_toPascalCase(node.name)}Processor',
                'nodeName': node.name,
                'nodeType': node.type.name,
              });
            }
          }
        }
      }
    }

    return processors;
  }

  Map<String, dynamic> _buildApplicationYmlContext(AIAgentBuilderModel model) {
    return {
      'serverPort': 8080,
      'camelContext':
          model.integrationConfig?.camelContext?.name ?? 'aiAgentContext',
      'tracing':
          model.integrationConfig?.camelContext?.globalOptions?.tracing ??
          false,
      'streamCaching':
          model.integrationConfig?.camelContext?.globalOptions?.streamCaching ??
          true,
    };
  }

  Map<String, dynamic> _buildPomContext(AIAgentBuilderModel model) {
    return {
      'groupId': 'com.aiagent',
      'artifactId': _toKebabCase(model.project.name),
      'version': model.config?.version ?? '1.0.0',
      'projectName': model.project.name,
      'springBootVersion': '3.2.0',
      'camelVersion': '4.3.0',
      'javaVersion': '17',
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

  String _toSnakeCase(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (m) => '${m.group(1)}_${m.group(2)}',
        )
        .replaceAll(RegExp(r'[\-\s]+'), '_')
        .toLowerCase();
  }
}
