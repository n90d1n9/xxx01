import '../models/node_card.dart';
import '../schema/integration_route.dart';
import '../schema/transformation_step.dart';
import '../schema/validation_issue.dart';
import '../schema/validation_result.dart';

class RouteValidator {
  /// Validates an integration route
  static ValidationResult validateRoute(IntegrationRoute route) {
    final issues = <ValidationIssue>[];

    // Validate route structure
    issues.addAll(_validateRouteStructure(route));

    // Validate nodes
    issues.addAll(_validateNodes(route));

    // Validate connections
    issues.addAll(_validateConnections(route));

    // Validate endpoints
    issues.addAll(_validateEndpoints(route));

    // Validate transformations
    issues.addAll(_validateTransformations(route));

    // Validate expressions
    issues.addAll(_validateExpressions(route));

    // Validate error handling
    issues.addAll(_validateErrorHandling(route));

    return ValidationResult(
      isValid: issues.where((i) => i.severity == IssueSeverity.error).isEmpty,
      issues: issues,
    );
  }

  static List<ValidationIssue> _validateRouteStructure(IntegrationRoute route) {
    final issues = <ValidationIssue>[];

    if (route.name.isEmpty) {
      issues.add(
        ValidationIssue(
          severity: IssueSeverity.error,
          category: IssueCategory.structure,
          message: 'Route name is required',
          nodeId: null,
        ),
      );
    }

    if (route.nodes.isEmpty) {
      issues.add(
        ValidationIssue(
          severity: IssueSeverity.error,
          category: IssueCategory.structure,
          message: 'Route must contain at least one node',
          nodeId: null,
        ),
      );
    }

    return issues;
  }

  static List<ValidationIssue> _validateNodes(IntegrationRoute route) {
    final issues = <ValidationIssue>[];

    for (final node in route.nodes) {
      // Check for duplicate IDs
      final duplicates = route.nodes.where((n) => n.id == node.id).length;
      if (duplicates > 1) {
        issues.add(
          ValidationIssue(
            severity: IssueSeverity.error,
            category: IssueCategory.structure,
            message: 'Duplicate node ID: ${node.id}',
            nodeId: node.id,
          ),
        );
      }

      // Validate node configuration
      issues.addAll(_validateNodeConfig(node));
    }

    // Check for source endpoint
    final hasSource = route.nodes.any(
      (n) => n.type.contains('endpoint') && _isConsumer(n),
    );

    if (!hasSource) {
      issues.add(
        ValidationIssue(
          severity: IssueSeverity.warning,
          category: IssueCategory.endpoints,
          message: 'Route should start with a consumer endpoint',
          nodeId: null,
        ),
      );
    }

    // Check for target endpoint
    final hasTarget = route.nodes.any(
      (n) => n.type.contains('endpoint') && _isProducer(n),
    );

    if (!hasTarget) {
      issues.add(
        ValidationIssue(
          severity: IssueSeverity.warning,
          category: IssueCategory.endpoints,
          message: 'Route should end with a producer endpoint',
          nodeId: null,
        ),
      );
    }

    return issues;
  }

  static List<ValidationIssue> _validateNodeConfig(NodeCard node) {
    final issues = <ValidationIssue>[];
    final component = _getComponentDefinition(node.type);

    if (component != null) {
      for (final param in component.parameters) {
        if (param.required && !node.config.containsKey(param.name)) {
          issues.add(
            ValidationIssue(
              severity: IssueSeverity.error,
              category: IssueCategory.configuration,
              message: 'Required parameter "${param.name}" is missing',
              nodeId: node.id,
              field: param.name,
            ),
          );
        }

        // Validate parameter value
        if (node.config.containsKey(param.name)) {
          final value = node.config[param.name];
          issues.addAll(_validateParameterValue(param, value, node.id));
        }
      }
    }

    return issues;
  }

  static List<ValidationIssue> _validateParameterValue(
    ComponentParameter param,
    dynamic value,
    String nodeId,
  ) {
    final issues = <ValidationIssue>[];

    if (value == null || (value is String && value.isEmpty)) {
      return issues;
    }

    switch (param.type) {
      case ParameterType.number:
        if (value is! num && num.tryParse(value.toString()) == null) {
          issues.add(
            ValidationIssue(
              severity: IssueSeverity.error,
              category: IssueCategory.configuration,
              message: 'Parameter "${param.name}" must be a number',
              nodeId: nodeId,
              field: param.name,
            ),
          );
        }
        break;

      case ParameterType.boolean:
        if (value is! bool) {
          issues.add(
            ValidationIssue(
              severity: IssueSeverity.error,
              category: IssueCategory.configuration,
              message: 'Parameter "${param.name}" must be a boolean',
              nodeId: nodeId,
              field: param.name,
            ),
          );
        }
        break;

      case ParameterType.select:
        if (param.options != null && !param.options!.contains(value)) {
          issues.add(
            ValidationIssue(
              severity: IssueSeverity.error,
              category: IssueCategory.configuration,
              message: 'Parameter "${param.name}" has invalid value: $value',
              nodeId: nodeId,
              field: param.name,
            ),
          );
        }
        break;

      default:
        break;
    }

    return issues;
  }

  static List<ValidationIssue> _validateConnections(IntegrationRoute route) {
    final issues = <ValidationIssue>[];
    final nodeIds = route.nodes.map((n) => n.id).toSet();

    for (final connection in route.connections) {
      // Check if source node exists
      if (!nodeIds.contains(connection.sourceNodeId)) {
        issues.add(
          ValidationIssue(
            severity: IssueSeverity.error,
            category: IssueCategory.connections,
            message:
                'Connection source node not found: ${connection.sourceNodeId}',
            nodeId: connection.sourceNodeId,
          ),
        );
      }

      // Check if target node exists
      if (!nodeIds.contains(connection.targetNodeId)) {
        issues.add(
          ValidationIssue(
            severity: IssueSeverity.error,
            category: IssueCategory.connections,
            message:
                'Connection target node not found: ${connection.targetNodeId}',
            nodeId: connection.targetNodeId,
          ),
        );
      }

      // Validate connection compatibility
      final sourceNode = route.nodes.firstWhere(
        (n) => n.id == connection.sourceNodeId,
        orElse: () => null as NodeCard,
      );
      final targetNode = route.nodes.firstWhere(
        (n) => n.id == connection.targetNodeId,
        orElse: () => null as NodeCard,
      );

      if (sourceNode != null && targetNode != null) {
        issues.addAll(_validateConnectionCompatibility(sourceNode, targetNode));
      }
    }

    // Check for orphaned nodes
    final connectedNodes = <String>{};
    for (final connection in route.connections) {
      connectedNodes.add(connection.sourceNodeId!);
      connectedNodes.add(connection.targetNodeId!);
    }

    for (final node in route.nodes) {
      if (!connectedNodes.contains(node.id) && route.nodes.length > 1) {
        issues.add(
          ValidationIssue(
            severity: IssueSeverity.warning,
            category: IssueCategory.connections,
            message: 'Node is not connected: ${node.name}',
            nodeId: node.id,
          ),
        );
      }
    }

    // Check for circular references
    issues.addAll(_detectCircularReferences(route));

    return issues;
  }

  static List<ValidationIssue> _validateConnectionCompatibility(
    NodeCard source,
    NodeCard target,
  ) {
    final issues = <ValidationIssue>[];

    // Add compatibility rules based on component types
    // Example: Can't connect a consumer-only component to a consumer-only component

    return issues;
  }

  static List<ValidationIssue> _detectCircularReferences(
    IntegrationRoute route,
  ) {
    final issues = <ValidationIssue>[];
    final visited = <String>{};
    final recursionStack = <String>{};

    bool hasCycle(String nodeId) {
      visited.add(nodeId);
      recursionStack.add(nodeId);

      final outgoingConnections = route.connections.where(
        (c) => c.sourceNodeId == nodeId,
      );

      for (final connection in outgoingConnections) {
        if (!visited.contains(connection.targetNodeId)) {
          if (hasCycle(connection.targetNodeId!)) {
            return true;
          }
        } else if (recursionStack.contains(connection.targetNodeId)) {
          return true;
        }
      }

      recursionStack.remove(nodeId);
      return false;
    }

    for (final node in route.nodes) {
      if (!visited.contains(node.id)) {
        if (hasCycle(node.id)) {
          issues.add(
            ValidationIssue(
              severity: IssueSeverity.error,
              category: IssueCategory.connections,
              message: 'Circular reference detected in route',
              nodeId: node.id,
            ),
          );
          break;
        }
      }
    }

    return issues;
  }

  static List<ValidationIssue> _validateEndpoints(IntegrationRoute route) {
    final issues = <ValidationIssue>[];

    for (final node in route.nodes) {
      if (node.type.contains('endpoint')) {
        // Validate endpoint URI
        final uri = node.config['uri'] as String?;
        if (uri != null && uri.isNotEmpty) {
          issues.addAll(_validateEndpointUri(uri, node.id));
        }

        // Validate endpoint specification
        if (node.type == 'rest-endpoint') {
          issues.addAll(_validateRestEndpoint(node));
        } else if (node.type == 'soap-endpoint') {
          issues.addAll(_validateSoapEndpoint(node));
        }
      }
    }

    return issues;
  }

  static List<ValidationIssue> _validateEndpointUri(String uri, String nodeId) {
    final issues = <ValidationIssue>[];

    if (!uri.contains(':')) {
      issues.add(
        ValidationIssue(
          severity: IssueSeverity.error,
          category: IssueCategory.endpoints,
          message: 'Invalid endpoint URI format: $uri',
          nodeId: nodeId,
          field: 'uri',
        ),
      );
    }

    return issues;
  }

  static List<ValidationIssue> _validateRestEndpoint(NodeCard node) {
    final issues = <ValidationIssue>[];

    final method = node.config['method'] as String?;
    final path = node.config['path'] as String?;

    if (method == null || method.isEmpty) {
      issues.add(
        ValidationIssue(
          severity: IssueSeverity.error,
          category: IssueCategory.endpoints,
          message: 'HTTP method is required for REST endpoint',
          nodeId: node.id,
          field: 'method',
        ),
      );
    }

    if (path == null || path.isEmpty) {
      issues.add(
        ValidationIssue(
          severity: IssueSeverity.error,
          category: IssueCategory.endpoints,
          message: 'Path is required for REST endpoint',
          nodeId: node.id,
          field: 'path',
        ),
      );
    }

    return issues;
  }

  static List<ValidationIssue> _validateSoapEndpoint(NodeCard node) {
    final issues = <ValidationIssue>[];

    // Add SOAP-specific validation

    return issues;
  }

  static List<ValidationIssue> _validateTransformations(
    IntegrationRoute route,
  ) {
    final issues = <ValidationIssue>[];

    for (final transformation in route.transformations) {
      issues.addAll(_validateTransformation(transformation));
    }

    return issues;
  }

  static List<ValidationIssue> _validateTransformation(
    TransformationStep transformation,
  ) {
    final issues = <ValidationIssue>[];

    if (transformation.type == TransformationType.dataMapper) {
      if (transformation.mappingRules == null ||
          transformation.mappingRules!.isEmpty) {
        issues.add(
          ValidationIssue(
            severity: IssueSeverity.warning,
            category: IssueCategory.transformation,
            message: 'Data mapper has no mapping rules',
            nodeId: transformation.id,
          ),
        );
      }

      // Validate mapping rules
      for (final rule in transformation.mappingRules ?? []) {
        if (rule.sourcePath.isEmpty) {
          issues.add(
            ValidationIssue(
              severity: IssueSeverity.error,
              category: IssueCategory.transformation,
              message: 'Mapping rule source path is empty',
              nodeId: transformation.id,
            ),
          );
        }

        if (rule.targetPath.isEmpty) {
          issues.add(
            ValidationIssue(
              severity: IssueSeverity.error,
              category: IssueCategory.transformation,
              message: 'Mapping rule target path is empty',
              nodeId: transformation.id,
            ),
          );
        }
      }
    }

    return issues;
  }

  static List<ValidationIssue> _validateExpressions(IntegrationRoute route) {
    final issues = <ValidationIssue>[];

    for (final node in route.nodes) {
      final expression = node.config['expression'] as String?;
      if (expression != null && expression.isNotEmpty) {
        final language = node.config['language'] as String? ?? 'simple';
        issues.addAll(_validateExpression(expression, language, node.id));
      }
    }

    return issues;
  }

  static List<ValidationIssue> _validateExpression(
    String expression,
    String language,
    String nodeId,
  ) {
    final issues = <ValidationIssue>[];

    // Simple expression validation
    if (language == 'simple') {
      // Check for balanced brackets
      final openBrackets = expression.split('\${').length - 1;
      final closeBrackets = expression.split('}').length - 1;

      if (openBrackets != closeBrackets) {
        issues.add(
          ValidationIssue(
            severity: IssueSeverity.error,
            category: IssueCategory.expression,
            message: 'Unbalanced brackets in expression',
            nodeId: nodeId,
            field: 'expression',
          ),
        );
      }
    }

    // Add more expression validation based on language

    return issues;
  }

  static List<ValidationIssue> _validateErrorHandling(IntegrationRoute route) {
    final issues = <ValidationIssue>[];

    if (route.errorHandler == null) {
      issues.add(
        ValidationIssue(
          severity: IssueSeverity.info,
          category: IssueCategory.errorHandling,
          message: 'No error handler configured, using default',
          nodeId: null,
        ),
      );
    }

    return issues;
  }

  static bool _isConsumer(NodeCard node) {
    final component = _getComponentDefinition(node.type);
    return component?.consumerSupported ?? false;
  }

  static bool _isProducer(NodeCard node) {
    final component = _getComponentDefinition(node.type);
    return component?.producerSupported ?? false;
  }

  static CamelComponent? _getComponentDefinition(String type) {
    // Get component definition from library
    final allComponents = CamelComponentsLibrary.getAllComponents();
    for (final category in allComponents.values) {
      for (final component in category) {
        if (component.id == type) {
          return component;
        }
      }
    }
    return null;
  }
}

enum ParameterType {
  string,
  number,
  boolean,
  select,
  object,
  array,
  file,
  password,
  expression,
  uri,
  duration,
  enumType,
}

class ComponentParameter {
  final String name;
  final String label;
  final String description;
  final ParameterType type;
  final bool required;
  final dynamic defaultValue;
  final List<String>? options;
  final Map<String, dynamic>? validation;
  final String? group;
  final int? order;
  final bool advanced;

  const ComponentParameter({
    required this.name,
    required this.label,
    required this.description,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.options,
    this.validation,
    this.group,
    this.order,
    this.advanced = false,
  });

  factory ComponentParameter.fromJson(Map<String, dynamic> json) {
    return ComponentParameter(
      name: json['name'] as String,
      label: json['label'] as String,
      description: json['description'] as String,
      type: _parseParameterType(json['type']),
      required: json['required'] as bool? ?? false,
      defaultValue: json['defaultValue'],
      options:
          json['options'] != null
              ? List<String>.from(json['options'] as List)
              : null,
      validation: json['validation'] as Map<String, dynamic>?,
      group: json['group'] as String?,
      order: json['order'] as int?,
      advanced: json['advanced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'description': description,
      'type': type.name,
      'required': required,
      if (defaultValue != null) 'defaultValue': defaultValue,
      if (options != null) 'options': options,
      if (validation != null) 'validation': validation,
      if (group != null) 'group': group,
      if (order != null) 'order': order,
      'advanced': advanced,
    };
  }

  static ParameterType _parseParameterType(dynamic value) {
    if (value is ParameterType) return value;
    final stringValue = value.toString();
    return ParameterType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => ParameterType.string,
    );
  }

  ComponentParameter copyWith({
    String? name,
    String? label,
    String? description,
    ParameterType? type,
    bool? required,
    dynamic defaultValue,
    List<String>? options,
    Map<String, dynamic>? validation,
    String? group,
    int? order,
    bool? advanced,
  }) {
    return ComponentParameter(
      name: name ?? this.name,
      label: label ?? this.label,
      description: description ?? this.description,
      type: type ?? this.type,
      required: required ?? this.required,
      defaultValue: defaultValue ?? this.defaultValue,
      options: options ?? this.options,
      validation: validation ?? this.validation,
      group: group ?? this.group,
      order: order ?? this.order,
      advanced: advanced ?? this.advanced,
    );
  }
}

class CamelComponent {
  final String id;
  final String name;
  final String description;
  final String category;
  final String icon;
  final List<ComponentParameter> parameters;
  final bool consumerSupported;
  final bool producerSupported;
  final List<String> tags;
  final String? documentationUrl;
  final Map<String, dynamic>? metadata;

  const CamelComponent({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.parameters,
    this.consumerSupported = false,
    this.producerSupported = false,
    this.tags = const [],
    this.documentationUrl,
    this.metadata,
  });

  factory CamelComponent.fromJson(Map<String, dynamic> json) {
    return CamelComponent(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      parameters:
          (json['parameters'] as List)
              .map(
                (e) => ComponentParameter.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      consumerSupported: json['consumerSupported'] as bool? ?? false,
      producerSupported: json['producerSupported'] as bool? ?? false,
      tags: List<String>.from(json['tags'] as List? ?? []),
      documentationUrl: json['documentationUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'icon': icon,
      'parameters': parameters.map((e) => e.toJson()).toList(),
      'consumerSupported': consumerSupported,
      'producerSupported': producerSupported,
      'tags': tags,
      if (documentationUrl != null) 'documentationUrl': documentationUrl,
      if (metadata != null) 'metadata': metadata,
    };
  }

  ComponentParameter? getParameter(String name) {
    return parameters.firstWhere(
      (param) => param.name == name,
      orElse: () => throw StateError('Parameter $name not found'),
    );
  }

  List<ComponentParameter> getRequiredParameters() {
    return parameters.where((param) => param.required).toList();
  }

  List<ComponentParameter> getParametersByGroup(String group) {
    return parameters.where((param) => param.group == group).toList();
  }

  CamelComponent copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? icon,
    List<ComponentParameter>? parameters,
    bool? consumerSupported,
    bool? producerSupported,
    List<String>? tags,
    String? documentationUrl,
    Map<String, dynamic>? metadata,
  }) {
    return CamelComponent(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      parameters: parameters ?? this.parameters,
      consumerSupported: consumerSupported ?? this.consumerSupported,
      producerSupported: producerSupported ?? this.producerSupported,
      tags: tags ?? this.tags,
      documentationUrl: documentationUrl ?? this.documentationUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

class CamelComponentsLibrary {
  static final Map<String, List<CamelComponent>> _components = {
    'endpoints': _createEndpointComponents(),
    'routing': _createRoutingComponents(),
    'transformation': _createTransformationComponents(),
    'messaging': _createMessagingComponents(),
    'dataformat': _createDataFormatComponents(),
    'monitoring': _createMonitoringComponents(),
    'utility': _createUtilityComponents(),
  };

  static Map<String, List<CamelComponent>> getAllComponents() {
    return _components;
  }

  static List<CamelComponent> getComponentsByCategory(String category) {
    return _components[category] ?? [];
  }

  static CamelComponent? getComponentById(String id) {
    for (final category in _components.values) {
      for (final component in category) {
        if (component.id == id) {
          return component;
        }
      }
    }
    return null;
  }

  static List<CamelComponent> searchComponents(String query) {
    final results = <CamelComponent>[];
    final lowercaseQuery = query.toLowerCase();

    for (final category in _components.values) {
      for (final component in category) {
        if (component.name.toLowerCase().contains(lowercaseQuery) ||
            component.description.toLowerCase().contains(lowercaseQuery) ||
            component.tags.any(
              (tag) => tag.toLowerCase().contains(lowercaseQuery),
            )) {
          results.add(component);
        }
      }
    }

    return results;
  }

  static List<String> getCategories() {
    return _components.keys.toList();
  }

  // Component creation methods
  static List<CamelComponent> _createEndpointComponents() {
    return [
      CamelComponent(
        id: 'rest-endpoint',
        name: 'REST Endpoint',
        description: 'Expose REST API endpoints',
        category: 'endpoints',
        icon: 'http',
        consumerSupported: true,
        producerSupported: true,
        parameters: [
          ComponentParameter(
            name: 'method',
            label: 'HTTP Method',
            description: 'HTTP method for the endpoint',
            type: ParameterType.select,
            required: true,
            options: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
          ),
          ComponentParameter(
            name: 'path',
            label: 'Path',
            description: 'URL path for the endpoint',
            type: ParameterType.string,
            required: true,
          ),
          ComponentParameter(
            name: 'consumes',
            label: 'Consumes',
            description: 'Content types this endpoint consumes',
            type: ParameterType.string,
            defaultValue: 'application/json',
          ),
          ComponentParameter(
            name: 'produces',
            label: 'Produces',
            description: 'Content types this endpoint produces',
            type: ParameterType.string,
            defaultValue: 'application/json',
          ),
        ],
        tags: ['http', 'rest', 'api'],
      ),
      CamelComponent(
        id: 'file-endpoint',
        name: 'File Endpoint',
        description: 'Read from or write to file system',
        category: 'endpoints',
        icon: 'folder',
        consumerSupported: true,
        producerSupported: true,
        parameters: [
          ComponentParameter(
            name: 'directory',
            label: 'Directory',
            description: 'Directory to read from or write to',
            type: ParameterType.string,
            required: true,
          ),
          ComponentParameter(
            name: 'fileName',
            label: 'File Name',
            description: 'File name pattern',
            type: ParameterType.string,
          ),
        ],
        tags: ['file', 'io'],
      ),
      CamelComponent(
        id: 'kafka-endpoint',
        name: 'Kafka Endpoint',
        description: 'Apache Kafka messaging',
        category: 'endpoints',
        icon: 'message',
        consumerSupported: true,
        producerSupported: true,
        parameters: [
          ComponentParameter(
            name: 'topic',
            label: 'Topic',
            description: 'Kafka topic name',
            type: ParameterType.string,
            required: true,
          ),
          ComponentParameter(
            name: 'brokers',
            label: 'Brokers',
            description: 'Kafka broker addresses',
            type: ParameterType.string,
            required: true,
          ),
        ],
        tags: ['kafka', 'messaging'],
      ),
    ];
  }

  static List<CamelComponent> _createRoutingComponents() {
    return [
      CamelComponent(
        id: 'choice-router',
        name: 'Choice Router',
        description: 'Route messages based on conditions',
        category: 'routing',
        icon: 'fork',
        consumerSupported: false,
        producerSupported: false,
        parameters: [
          ComponentParameter(
            name: 'predicates',
            label: 'Predicates',
            description: 'Routing conditions',
            type: ParameterType.array,
            required: true,
          ),
        ],
        tags: ['routing', 'conditional'],
      ),
      CamelComponent(
        id: 'multicast-router',
        name: 'Multicast Router',
        description: 'Send message to multiple endpoints',
        category: 'routing',
        icon: 'share',
        consumerSupported: false,
        producerSupported: false,
        parameters: [
          ComponentParameter(
            name: 'parallelProcessing',
            label: 'Parallel Processing',
            description: 'Process endpoints in parallel',
            type: ParameterType.boolean,
            defaultValue: false,
          ),
        ],
        tags: ['routing', 'multicast'],
      ),
    ];
  }

  static List<CamelComponent> _createTransformationComponents() {
    return [
      CamelComponent(
        id: 'json-transformer',
        name: 'JSON Transformer',
        description: 'Transform JSON data',
        category: 'transformation',
        icon: 'code',
        consumerSupported: false,
        producerSupported: false,
        parameters: [
          ComponentParameter(
            name: 'schema',
            label: 'Schema',
            description: 'JSON schema for validation',
            type: ParameterType.string,
          ),
        ],
        tags: ['json', 'transformation'],
      ),
      CamelComponent(
        id: 'xslt-transformer',
        name: 'XSLT Transformer',
        description: 'Transform XML using XSLT',
        category: 'transformation',
        icon: 'transform',
        consumerSupported: false,
        producerSupported: false,
        parameters: [
          ComponentParameter(
            name: 'xslt',
            label: 'XSLT',
            description: 'XSLT transformation file',
            type: ParameterType.string,
            required: true,
          ),
        ],
        tags: ['xml', 'xslt', 'transformation'],
      ),
    ];
  }

  static List<CamelComponent> _createMessagingComponents() {
    return [
      CamelComponent(
        id: 'jms-endpoint',
        name: 'JMS Endpoint',
        description: 'Java Message Service integration',
        category: 'messaging',
        icon: 'queue',
        consumerSupported: true,
        producerSupported: true,
        parameters: [
          ComponentParameter(
            name: 'destination',
            label: 'Destination',
            description: 'JMS queue or topic name',
            type: ParameterType.string,
            required: true,
          ),
        ],
        tags: ['jms', 'messaging'],
      ),
    ];
  }

  static List<CamelComponent> _createDataFormatComponents() {
    return [
      CamelComponent(
        id: 'json-dataformat',
        name: 'JSON Data Format',
        description: 'Marshal and unmarshal JSON',
        category: 'dataformat',
        icon: 'data_object',
        consumerSupported: false,
        producerSupported: false,
        parameters: [
          ComponentParameter(
            name: 'prettyPrint',
            label: 'Pretty Print',
            description: 'Format JSON with indentation',
            type: ParameterType.boolean,
            defaultValue: false,
          ),
        ],
        tags: ['json', 'dataformat'],
      ),
    ];
  }

  static List<CamelComponent> _createMonitoringComponents() {
    return [
      CamelComponent(
        id: 'metrics-endpoint',
        name: 'Metrics Endpoint',
        description: 'Collect and expose metrics',
        category: 'monitoring',
        icon: 'analytics',
        consumerSupported: false,
        producerSupported: true,
        parameters: [
          ComponentParameter(
            name: 'metrics',
            label: 'Metrics',
            description: 'Metrics to collect',
            type: ParameterType.array,
          ),
        ],
        tags: ['metrics', 'monitoring'],
      ),
    ];
  }

  static List<CamelComponent> _createUtilityComponents() {
    return [
      CamelComponent(
        id: 'log-processor',
        name: 'Log Processor',
        description: 'Log message content',
        category: 'utility',
        icon: 'description',
        consumerSupported: false,
        producerSupported: false,
        parameters: [
          ComponentParameter(
            name: 'message',
            label: 'Message',
            description: 'Log message pattern',
            type: ParameterType.string,
            defaultValue: '',
          ),
          ComponentParameter(
            name: 'level',
            label: 'Log Level',
            description: 'Logging level',
            type: ParameterType.select,
            options: ['DEBUG', 'INFO', 'WARN', 'ERROR'],
            defaultValue: 'INFO',
          ),
        ],
        tags: ['logging', 'utility'],
      ),
      CamelComponent(
        id: 'validation-processor',
        name: 'Validation Processor',
        description: 'Validate message content',
        category: 'utility',
        icon: 'verified',
        consumerSupported: false,
        producerSupported: false,
        parameters: [
          ComponentParameter(
            name: 'validator',
            label: 'Validator',
            description: 'Validation expression or schema',
            type: ParameterType.string,
            required: true,
          ),
        ],
        tags: ['validation', 'utility'],
      ),
    ];
  }
}
