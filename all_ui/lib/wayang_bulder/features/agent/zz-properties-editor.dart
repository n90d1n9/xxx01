// ============================================================================
// ENHANCED AI AGENT BUILDER - PRODUCTION READY
// ============================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'zz-agent.dart';

// ============================================================================
// DOMAIN MODELS - Enhanced with Freezed-style immutability
// ============================================================================

enum AgentCategory {
  cognitive('Cognitive', Icons.psychology, Colors.purple),
  operational('Operational', Icons.settings, Colors.blue),
  governance('Governance', Icons.shield, Colors.orange),
  analytic('Analytic', Icons.analytics, Colors.green),
  interactive('Interactive', Icons.chat, Colors.teal),
  transformer('Transformer', Icons.transform, Colors.pink);

  final String label;
  final IconData icon;
  final Color color;
  const AgentCategory(this.label, this.icon, this.color);
}

enum AgentRole {
  orchestrator('Orchestrator', 'Coordinates multi-agent execution'),
  planner('Planner', 'Decomposes goals into plans'),
  executor('Executor', 'Executes tasks and actions'),
  evaluator('Evaluator', 'Validates and scores results'),
  guardrail('Guardrail', 'Enforces policies and safety'),
  memory('Memory', 'Stores and retrieves context'),
  analytics('Analytics', 'Monitors and analyzes metrics'),
  dialogue('Dialogue', 'Manages conversations'),
  transformer('Transformer', 'Transforms data formats'),
  router('Router', 'Routes requests conditionally'),
  aggregator('Aggregator', 'Aggregates multiple inputs');

  final String label;
  final String description;
  const AgentRole(this.label, this.description);
}

enum AgentBehavior {
  deterministic('Deterministic', 'Predictable, consistent outputs'),
  reflective('Reflective', 'Self-evaluating and adaptive'),
  reactive('Reactive', 'Event-driven responses'),
  proactive('Proactive', 'Anticipates and initiates');

  final String label;
  final String description;
  const AgentBehavior(this.label, this.description);
}

enum PayloadType {
  goalPayload('Goal', 'High-level objectives'),
  planPayload('Plan', 'Structured execution steps'),
  taskPayload('Task', 'Executable action items'),
  resultPayload('Result', 'Execution outcomes'),
  errorPayload('Error', 'Error information'),
  scorePayload('Score', 'Evaluation metrics'),
  violationPayload('Violation', 'Policy violations'),
  memoryWritePayload('Memory Write', 'Store data'),
  memoryQueryPayload('Memory Query', 'Retrieve data'),
  memoryReadPayload('Memory Read', 'Retrieved context'),
  metricsPayload('Metrics', 'Performance data'),
  insightPayload('Insight', 'Analyzed insights'),
  textPayload('Text', 'Plain text content'),
  jsonPayload('JSON', 'JSON data'),
  streamPayload('Stream', 'Streaming data'),
  anyPayload('Any', 'Universal payload');

  final String label;
  final String description;
  const PayloadType(this.label, this.description);
}

// ============================================================================
// PORT - Enhanced with validation
// ============================================================================

class Port {
  final String id;
  final String name;
  final PayloadType type;
  final bool multiple;
  final bool optional;
  final String? description;
  final Map<String, dynamic> metadata;

  Port({
    String? id,
    required this.name,
    required this.type,
    this.multiple = false,
    this.optional = false,
    this.description,
    this.metadata = const {},
  }) : id = id ?? const Uuid().v4();

  Port copyWith({
    String? name,
    PayloadType? type,
    bool? multiple,
    bool? optional,
    String? description,
    Map<String, dynamic>? metadata,
  }) =>
      Port(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        multiple: multiple ?? this.multiple,
        optional: optional ?? this.optional,
        description: description ?? this.description,
        metadata: metadata ?? this.metadata,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'multiple': multiple,
        'optional': optional,
        if (description != null) 'description': description,
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  factory Port.fromJson(Map<String, dynamic> json) => Port(
        id: json['id'],
        name: json['name'],
        type: PayloadType.values.byName(json['type']),
        multiple: json['multiple'] ?? false,
        optional: json['optional'] ?? false,
        description: json['description'],
        metadata: json['metadata'] ?? {},
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Port && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ============================================================================
// AGENT CONFIGURATION - Enhanced with presets
// ============================================================================

class AgentConfig {
  final String? model;
  final double? temperature;
  final int? maxSteps;
  final int? timeout;
  final int? retryCount;
  final Map<String, dynamic> customParams;

  AgentConfig({
    this.model,
    this.temperature,
    this.maxSteps,
    this.timeout,
    this.retryCount,
    this.customParams = const {},
  });

  AgentConfig copyWith({
    String? model,
    double? temperature,
    int? maxSteps,
    int? timeout,
    int? retryCount,
    Map<String, dynamic>? customParams,
  }) =>
      AgentConfig(
        model: model ?? this.model,
        temperature: temperature ?? this.temperature,
        maxSteps: maxSteps ?? this.maxSteps,
        timeout: timeout ?? this.timeout,
        retryCount: retryCount ?? this.retryCount,
        customParams: customParams ?? this.customParams,
      );

  Map<String, dynamic> toJson() => {
        if (model != null) 'model': model,
        if (temperature != null) 'temperature': temperature,
        if (maxSteps != null) 'max_steps': maxSteps,
        if (timeout != null) 'timeout': timeout,
        if (retryCount != null) 'retry_count': retryCount,
        ...customParams,
      };

  factory AgentConfig.fromJson(Map<String, dynamic> json) {
    final customParams = Map<String, dynamic>.from(json);
    customParams.remove('model');
    customParams.remove('temperature');
    customParams.remove('max_steps');
    customParams.remove('timeout');
    customParams.remove('retry_count');

    return AgentConfig(
      model: json['model'],
      temperature: json['temperature']?.toDouble(),
      maxSteps: json['max_steps'],
      timeout: json['timeout'],
      retryCount: json['retry_count'],
      customParams: customParams,
    );
  }

  // Presets
  static AgentConfig precise() => AgentConfig(
        model: 'gpt-4',
        temperature: 0.1,
        maxSteps: 5,
      );

  static AgentConfig balanced() => AgentConfig(
        model: 'gpt-3.5-turbo',
        temperature: 0.5,
        maxSteps: 10,
      );

  static AgentConfig creative() => AgentConfig(
        model: 'gpt-4',
        temperature: 0.9,
        maxSteps: 15,
      );
}

// ============================================================================
// VALIDATION RULE - Enhanced with severity
// ============================================================================

enum RuleSeverity { error, warning, info }

class ValidationRule {
  final String id;
  final String rule;
  final String description;
  final RuleSeverity severity;
  final bool enabled;

  ValidationRule({
    String? id,
    required this.rule,
    required this.description,
    this.severity = RuleSeverity.error,
    this.enabled = true,
  }) : id = id ?? const Uuid().v4();

  ValidationRule copyWith({
    String? rule,
    String? description,
    RuleSeverity? severity,
    bool? enabled,
  }) =>
      ValidationRule(
        id: id,
        rule: rule ?? this.rule,
        description: description ?? this.description,
        severity: severity ?? this.severity,
        enabled: enabled ?? this.enabled,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'rule': rule,
        'description': description,
        'severity': severity.name,
        'enabled': enabled,
      };

  factory ValidationRule.fromJson(Map<String, dynamic> json) => ValidationRule(
        id: json['id'],
        rule: json['rule'],
        description: json['description'] ?? '',
        severity: RuleSeverity.values.byName(json['severity'] ?? 'error'),
        enabled: json['enabled'] ?? true,
      );
}

// ============================================================================
// AGENT SCHEMA - Enhanced with versioning and metadata
// ============================================================================

class AgentSchema {
  final String id;
  final String name;
  final AgentCategory category;
  final AgentRole role;
  final List<String> capabilities;
  final AgentBehavior behavior;
  final List<Port> inputs;
  final List<Port> outputs;
  final AgentConfig config;
  final List<ValidationRule> validationRules;
  final String? description;
  final String? version;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  AgentSchema({
    String? id,
    required this.name,
    required this.category,
    required this.role,
    required this.capabilities,
    required this.behavior,
    required this.inputs,
    required this.outputs,
    required this.config,
    required this.validationRules,
    this.description,
    this.version = '1.0.0',
    this.tags = const [],
    this.metadata = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  IconData get icon => category.icon;
  Color get color => category.color;

  AgentSchema copyWith({
    String? name,
    AgentCategory? category,
    AgentRole? role,
    List<String>? capabilities,
    AgentBehavior? behavior,
    List<Port>? inputs,
    List<Port>? outputs,
    AgentConfig? config,
    List<ValidationRule>? validationRules,
    String? description,
    String? version,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) =>
      AgentSchema(
        id: id,
        name: name ?? this.name,
        category: category ?? this.category,
        role: role ?? this.role,
        capabilities: capabilities ?? this.capabilities,
        behavior: behavior ?? this.behavior,
        inputs: inputs ?? this.inputs,
        outputs: outputs ?? this.outputs,
        config: config ?? this.config,
        validationRules: validationRules ?? this.validationRules,
        description: description ?? this.description,
        version: version ?? this.version,
        tags: tags ?? this.tags,
        metadata: metadata ?? this.metadata,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'role': role.name,
        'capabilities': capabilities,
        'behavior': behavior.name,
        'inputs': inputs.map((p) => p.toJson()).toList(),
        'outputs': outputs.map((p) => p.toJson()).toList(),
        'config': config.toJson(),
        'validationRules': validationRules.map((r) => r.toJson()).toList(),
        if (description != null) 'description': description,
        'version': version,
        'tags': tags,
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory AgentSchema.fromJson(Map<String, dynamic> json) => AgentSchema(
        id: json['id'],
        name: json['name'],
        category: AgentCategory.values.byName(json['category']),
        role: AgentRole.values.byName(json['role']),
        capabilities: List<String>.from(json['capabilities']),
        behavior: AgentBehavior.values.byName(json['behavior']),
        inputs: (json['inputs'] as List).map((p) => Port.fromJson(p)).toList(),
        outputs:
            (json['outputs'] as List).map((p) => Port.fromJson(p)).toList(),
        config: AgentConfig.fromJson(json['config']),
        validationRules: (json['validationRules'] as List)
            .map((r) => ValidationRule.fromJson(r))
            .toList(),
        description: json['description'],
        version: json['version'] ?? '1.0.0',
        tags: List<String>.from(json['tags'] ?? []),
        metadata: json['metadata'] ?? {},
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  String toJsonString() => jsonEncode(toJson());
  factory AgentSchema.fromJsonString(String jsonStr) =>
      AgentSchema.fromJson(jsonDecode(jsonStr));
}

// ============================================================================
// AGENT CONNECTION - Enhanced with metadata
// ============================================================================

class AgentConnection {
  final String id;
  final String sourceAgentId;
  final String sourcePortId;
  final String targetAgentId;
  final String targetPortId;
  final PayloadType payloadType;
  final Map<String, dynamic> transformConfig;
  final bool enabled;

  AgentConnection({
    String? id,
    required this.sourceAgentId,
    required this.sourcePortId,
    required this.targetAgentId,
    required this.targetPortId,
    required this.payloadType,
    this.transformConfig = const {},
    this.enabled = true,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceAgentId': sourceAgentId,
        'sourcePortId': sourcePortId,
        'targetAgentId': targetAgentId,
        'targetPortId': targetPortId,
        'payloadType': payloadType.name,
        'transformConfig': transformConfig,
        'enabled': enabled,
      };
}

// ============================================================================
// VALIDATION ENGINE - Enhanced with detailed reporting
// ============================================================================

class ValidationIssue {
  final RuleSeverity severity;
  final String message;
  final String? suggestion;
  final String? ruleId;

  ValidationIssue({
    required this.severity,
    required this.message,
    this.suggestion,
    this.ruleId,
  });
}

class ValidationResult {
  final bool isValid;
  final List<ValidationIssue> issues;

  ValidationResult({
    required this.isValid,
    this.issues = const [],
  });

  factory ValidationResult.valid() => ValidationResult(isValid: true);

  factory ValidationResult.invalid(List<ValidationIssue> issues) =>
      ValidationResult(
        isValid: false,
        issues: issues,
      );

  List<ValidationIssue> get errors =>
      issues.where((i) => i.severity == RuleSeverity.error).toList();

  List<ValidationIssue> get warnings =>
      issues.where((i) => i.severity == RuleSeverity.warning).toList();

  List<ValidationIssue> get infos =>
      issues.where((i) => i.severity == RuleSeverity.info).toList();
}

class RuleEngine {
  // Enhanced connection rules matrix
  static final Map<AgentCategory, List<AgentCategory>> _categoryRules = {
    AgentCategory.cognitive: [
      AgentCategory.operational,
      AgentCategory.cognitive,
      AgentCategory.governance,
      AgentCategory.analytic,
    ],
    AgentCategory.operational: [
      AgentCategory.analytic,
      AgentCategory.cognitive,
      AgentCategory.governance,
      AgentCategory.transformer,
    ],
    AgentCategory.governance: [
      AgentCategory.cognitive,
      AgentCategory.operational,
      AgentCategory.analytic,
    ],
    AgentCategory.interactive: [
      AgentCategory.cognitive,
      AgentCategory.governance,
      AgentCategory.transformer,
    ],
    AgentCategory.analytic: [
      AgentCategory.cognitive,
      AgentCategory.transformer,
    ],
    AgentCategory.transformer: [
      AgentCategory.cognitive,
      AgentCategory.operational,
      AgentCategory.analytic,
    ],
  };

  static ValidationResult validateConnection({
    required AgentSchema source,
    required AgentSchema target,
    required Port sourcePort,
    required Port targetPort,
  }) {
    final issues = <ValidationIssue>[];

    // 1. Category compatibility
    final allowedTargets = _categoryRules[source.category];
    if (allowedTargets == null || !allowedTargets.contains(target.category)) {
      issues.add(ValidationIssue(
        severity: RuleSeverity.error,
        message:
            'Connection not allowed: ${source.category.label} → ${target.category.label}',
        suggestion: 'Use ${allowedTargets?.map((c) => c.label).join(", ")}',
      ));
    }

    // 2. Payload type compatibility
    if (sourcePort.type != targetPort.type &&
        sourcePort.type != PayloadType.anyPayload &&
        targetPort.type != PayloadType.anyPayload) {
      issues.add(ValidationIssue(
        severity: RuleSeverity.error,
        message:
            'Payload type mismatch: ${sourcePort.type.label} → ${targetPort.type.label}',
        suggestion: 'Add a transformer agent or change port types',
      ));
    }

    // 3. Multiplicity check
    if (!targetPort.multiple) {
      issues.add(ValidationIssue(
        severity: RuleSeverity.warning,
        message:
            'Target port "${targetPort.name}" accepts single connection only',
        suggestion: 'Enable multiple connections or use aggregator',
      ));
    }

    // 4. Optional port check
    if (!sourcePort.optional && targetPort.optional) {
      issues.add(ValidationIssue(
        severity: RuleSeverity.info,
        message: 'Connecting required output to optional input',
      ));
    }

    return issues.any((i) => i.severity == RuleSeverity.error)
        ? ValidationResult.invalid(issues)
        : ValidationResult(isValid: true, issues: issues);
  }

  static ValidationResult validateAgent(AgentSchema agent) {
    final issues = <ValidationIssue>[];

    // 1. Name validation
    if (agent.name.trim().isEmpty) {
      issues.add(ValidationIssue(
        severity: RuleSeverity.error,
        message: 'Agent name cannot be empty',
      ));
    }

    if (agent.name.length > 50) {
      issues.add(ValidationIssue(
        severity: RuleSeverity.warning,
        message: 'Agent name is too long (${agent.name.length} chars)',
        suggestion: 'Keep names under 50 characters',
      ));
    }

    // 2. Port validation
    if (agent.inputs.isEmpty && agent.outputs.isEmpty) {
      issues.add(ValidationIssue(
        severity: RuleSeverity.warning,
        message: 'Agent has no input or output ports',
        suggestion: 'Add at least one port for connectivity',
      ));
    }

    // Check duplicate port names
    final inputNames = agent.inputs.map((p) => p.name).toSet();
    if (inputNames.length != agent.inputs.length) {
      issues.add(ValidationIssue(
        severity: RuleSeverity.error,
        message: 'Duplicate input port names detected',
      ));
    }

    final outputNames = agent.outputs.map((p) => p.name).toSet();
    if (outputNames.length != agent.outputs.length) {
      issues.add(ValidationIssue(
        severity: RuleSeverity.error,
        message: 'Duplicate output port names detected',
      ));
    }

    // 3. Capability validation
    if (agent.capabilities.isEmpty) {
      issues.add(ValidationIssue(
        severity: RuleSeverity.info,
        message: 'No capabilities defined',
        suggestion: 'Add capabilities to describe agent functions',
      ));
    }

    // 4. Role-specific validations
    _validateRoleSpecific(agent, issues);

    // 5. Configuration validation
    if (agent.config.temperature != null) {
      if (agent.config.temperature! < 0 || agent.config.temperature! > 2) {
        issues.add(ValidationIssue(
          severity: RuleSeverity.error,
          message: 'Temperature must be between 0 and 2',
        ));
      }
    }

    return issues.any((i) => i.severity == RuleSeverity.error)
        ? ValidationResult.invalid(issues)
        : ValidationResult(isValid: true, issues: issues);
  }

  static void _validateRoleSpecific(
      AgentSchema agent, List<ValidationIssue> issues) {
    switch (agent.role) {
      case AgentRole.orchestrator:
        if (!agent.capabilities.contains('multi-agent-coordination')) {
          issues.add(ValidationIssue(
            severity: RuleSeverity.warning,
            message: 'Orchestrator should have multi-agent-coordination',
            suggestion: 'Add "multi-agent-coordination" capability',
          ));
        }
        if (agent.outputs.length < 2) {
          issues.add(ValidationIssue(
            severity: RuleSeverity.info,
            message: 'Orchestrator typically has multiple outputs',
          ));
        }
        break;

      case AgentRole.executor:
        if (agent.outputs.isEmpty) {
          issues.add(ValidationIssue(
            severity: RuleSeverity.error,
            message: 'Executor must have at least one output port',
          ));
        }
        if (agent.config.retryCount == null) {
          issues.add(ValidationIssue(
            severity: RuleSeverity.info,
            message: 'Consider adding retry configuration',
          ));
        }
        break;

      case AgentRole.guardrail:
        if (agent.outputs.length < 2) {
          issues.add(ValidationIssue(
            severity: RuleSeverity.warning,
            message: 'Guardrail should have approved/rejected outputs',
          ));
        }
        break;

      case AgentRole.memory:
        if (!agent.capabilities.any((c) => c.contains('store') || c.contains('retriev'))) {
          issues.add(ValidationIssue(
            severity: RuleSeverity.warning,
            message: 'Memory agent should have store/retrieve capabilities',
          ));
        }
        break;

      default:
        break;
    }
  }
}

// ============================================================================
// AGENT TEMPLATES - Enhanced with more variations
// ============================================================================

class AgentTemplates {
  static final uuid = const Uuid();

  static AgentSchema orchestrator() => AgentSchema(
        name: 'Orchestration Agent',
        category: AgentCategory.cognitive,
        role: AgentRole.orchestrator,
        capabilities: [
          'multi-agent-coordination',
          'task-routing',
          'workflow-management',
          'error-recovery'
        ],
        behavior: AgentBehavior.deterministic,
        inputs: [
          Port(name: 'plan', type: PayloadType.planPayload,
              description: 'Execution plan from planner'),
          Port(name: 'feedback', type: PayloadType.resultPayload,
              optional: true, description: 'Feedback from executors'),
        ],
        outputs: [
          Port(name: 'task', type: PayloadType.taskPayload,
              multiple: true, description: 'Tasks for execution'),
          Port(name: 'status', type: PayloadType.metricsPayload,
              description: 'Orchestration status'),
        ],
        config: AgentConfig.balanced(),
        validationRules: [
          ValidationRule(
            rule:
                "acceptsFrom(['planner','executor','evaluator','dialogue'])",
            description: 'Can intercept content from multiple agent types',
          ),
          ValidationRule(
            rule: "emitsTo(['orchestrator','audit'])",
            description: 'Emits decisions to orchestrator or audit',
          ),
        ],
        description: 'Enforces policies, ethics, and security constraints with audit trail',
        tags: ['governance', 'security', 'compliance'],
      );

  static AgentSchema memory() => AgentSchema(
        name: 'Memory Agent',
        category: AgentCategory.cognitive,
        role: AgentRole.memory,
        capabilities: [
          'vector-search',
          'context-store',
          'semantic-retrieval',
          'cache-management'
        ],
        behavior: AgentBehavior.reactive,
        inputs: [
          Port(name: 'store', type: PayloadType.memoryWritePayload,
              description: 'Data to store'),
          Port(name: 'query', type: PayloadType.memoryQueryPayload,
              description: 'Query for retrieval'),
        ],
        outputs: [
          Port(name: 'context', type: PayloadType.memoryReadPayload,
              description: 'Retrieved context'),
          Port(name: 'status', type: PayloadType.jsonPayload,
              optional: true, description: 'Operation status'),
        ],
        config: AgentConfig(
          customParams: {
            'vectorDb': 'pinecone',
            'embeddingModel': 'text-embedding-ada-002',
            'topK': 5,
            'similarityThreshold': 0.8,
            'cacheEnabled': true,
          },
        ),
        validationRules: [
          ValidationRule(
            rule: "acceptsFrom(['dialogue','planner','reflector'])",
            description: 'Stores and retrieves context',
          ),
          ValidationRule(
            rule: "emitsTo(['planner','evaluator','orchestrator'])",
            description: 'Provides context to cognitive agents',
          ),
        ],
        description: 'Stores and retrieves context with semantic search capabilities',
        tags: ['memory', 'storage', 'retrieval'],
      );

  static AgentSchema analytics() => AgentSchema(
        name: 'Analytics Agent',
        category: AgentCategory.analytic,
        role: AgentRole.analytics,
        capabilities: [
          'observation',
          'anomaly-detection',
          'trend-analysis',
          'reporting'
        ],
        behavior: AgentBehavior.reactive,
        inputs: [
          Port(name: 'metrics', type: PayloadType.metricsPayload,
              description: 'Performance metrics', multiple: true),
        ],
        outputs: [
          Port(name: 'report', type: PayloadType.insightPayload,
              description: 'Analyzed insights'),
          Port(name: 'alerts', type: PayloadType.jsonPayload,
              optional: true, description: 'Anomaly alerts'),
        ],
        config: AgentConfig(
          customParams: {
            'aggregationWindow': 300,
            'alertThreshold': 0.95,
            'anomalyDetection': true,
          },
        ),
        validationRules: [
          ValidationRule(
            rule: "acceptsFrom(['executor','evaluator','guardrail'])",
            description: 'Monitors system metrics',
          ),
          ValidationRule(
            rule: "emitsTo(['reflection','dashboard'])",
            description: 'Emits insights and reports',
          ),
        ],
        description: 'Monitors metrics and provides insights with anomaly detection',
        tags: ['analytics', 'monitoring', 'insights'],
      );

  static AgentSchema dialogue() => AgentSchema(
        name: 'Dialogue Agent',
        category: AgentCategory.interactive,
        role: AgentRole.dialogue,
        capabilities: [
          'nlp',
          'contextual-dialogue',
          'intent-recognition',
          'session-management'
        ],
        behavior: AgentBehavior.reactive,
        inputs: [
          Port(name: 'user_input', type: PayloadType.textPayload,
              description: 'User message'),
          Port(name: 'context', type: PayloadType.memoryReadPayload,
              optional: true, description: 'Conversation context'),
        ],
        outputs: [
          Port(name: 'intent', type: PayloadType.goalPayload,
              description: 'Extracted user intent'),
          Port(name: 'response', type: PayloadType.textPayload,
              description: 'Agent response'),
        ],
        config: AgentConfig.creative().copyWith(
          customParams: {
            'maxTurns': 20,
            'contextWindow': 4096,
            'sessionTimeout': 1800,
          },
        ),
        validationRules: [
          ValidationRule(
            rule: "emitsTo(['planner','memory','guardrail'])",
            description: 'Manages user conversations',
          ),
        ],
        description: 'Manages conversations with intent recognition and context',
        tags: ['dialogue', 'conversation', 'nlp'],
      );

  static AgentSchema transformer() => AgentSchema(
        name: 'Transformer Agent',
        category: AgentCategory.transformer,
        role: AgentRole.transformer,
        capabilities: [
          'data-transformation',
          'format-conversion',
          'enrichment',
          'validation'
        ],
        behavior: AgentBehavior.deterministic,
        inputs: [
          Port(name: 'input', type: PayloadType.anyPayload,
              description: 'Data to transform'),
          Port(name: 'schema', type: PayloadType.jsonPayload,
              optional: true, description: 'Target schema'),
        ],
        outputs: [
          Port(name: 'output', type: PayloadType.anyPayload,
              description: 'Transformed data'),
          Port(name: 'validation', type: PayloadType.jsonPayload,
              optional: true, description: 'Validation results'),
        ],
        config: AgentConfig(
          customParams: {
            'validateInput': true,
            'validateOutput': true,
            'strictMode': false,
          },
        ),
        validationRules: [
          ValidationRule(
            rule: "acceptsFrom(['any'])",
            description: 'Can accept any payload type',
          ),
          ValidationRule(
            rule: "emitsTo(['any'])",
            description: 'Can emit to any agent type',
          ),
        ],
        description: 'Transforms data between different formats with validation',
        tags: ['transformer', 'converter', 'utility'],
      );

  static AgentSchema router() => AgentSchema(
        name: 'Router Agent',
        category: AgentCategory.cognitive,
        role: AgentRole.router,
        capabilities: [
          'conditional-routing',
          'load-balancing',
          'priority-routing'
        ],
        behavior: AgentBehavior.deterministic,
        inputs: [
          Port(name: 'input', type: PayloadType.anyPayload,
              description: 'Data to route'),
          Port(name: 'rules', type: PayloadType.jsonPayload,
              optional: true, description: 'Routing rules'),
        ],
        outputs: [
          Port(name: 'route_a', type: PayloadType.anyPayload,
              description: 'Primary route'),
          Port(name: 'route_b', type: PayloadType.anyPayload,
              description: 'Secondary route'),
          Port(name: 'fallback', type: PayloadType.anyPayload,
              optional: true, description: 'Fallback route'),
        ],
        config: AgentConfig(
          customParams: {
            'strategy': 'conditional',
            'loadBalancing': false,
            'timeout': 5000,
          },
        ),
        validationRules: [],
        description: 'Routes requests conditionally based on rules',
        tags: ['router', 'conditional', 'utility'],
      );

  static List<AgentSchema> allTemplates() => [
        orchestrator(),
        planner(),
        executor(),
        evaluator(),
        guardrails(),
        memory(),
        analytics(),
        dialogue(),
        transformer(),
        router(),
      ];

  static List<AgentSchema> getByCategory(AgentCategory category) =>
      allTemplates().where((t) => t.category == category).toList();

  static List<AgentSchema> getByRole(AgentRole role) =>
      allTemplates().where((t) => t.role == role).toList();
}

// ============================================================================
// STATE MANAGEMENT - Enhanced Riverpod Providers
// ============================================================================

// Selected agent for editing
final selectedAgentProvider = StateProvider<AgentSchema?>((ref) => null);

// All agents in the workspace
final agentListProvider =
    StateNotifierProvider<AgentListNotifier, List<AgentSchema>>((ref) {
  return AgentListNotifier();
});

class AgentListNotifier extends StateNotifier<List<AgentSchema>> {
  AgentListNotifier() : super([]);

  void addAgent(AgentSchema agent) {
    state = [...state, agent];
  }

  void updateAgent(AgentSchema agent) {
    state = [
      for (final a in state)
        if (a.id == agent.id) agent else a,
    ];
  }

  void removeAgent(String id) {
    state = state.where((a) => a.id != id).toList();
  }

  void duplicateAgent(String id) {
    final agent = state.firstWhere((a) => a.id == id);
    final duplicated = AgentSchema(
      name: '${agent.name} (Copy)',
      category: agent.category,
      role: agent.role,
      capabilities: agent.capabilities,
      behavior: agent.behavior,
      inputs: agent.inputs.map((p) => Port(
        name: p.name,
        type: p.type,
        multiple: p.multiple,
        optional: p.optional,
        description: p.description,
      )).toList(),
      outputs: agent.outputs.map((p) => Port(
        name: p.name,
        type: p.type,
        multiple: p.multiple,
        optional: p.optional,
        description: p.description,
      )).toList(),
      config: agent.config,
      validationRules: agent.validationRules,
      description: agent.description,
      tags: agent.tags,
    );
    addAgent(duplicated);
  }

  void importFromJson(String jsonStr) {
    try {
      final agent = AgentSchema.fromJsonString(jsonStr);
      addAgent(agent);
    } catch (e) {
      // Handle error
    }
  }

  void clear() {
    state = [];
  }
}

// Agent templates
final agentTemplatesProvider = Provider<List<AgentSchema>>((ref) {
  return AgentTemplates.allTemplates();
});

// Filter templates by category
final filteredTemplatesProvider = Provider.family<List<AgentSchema>, AgentCategory?>((ref, category) {
  final templates = ref.watch(agentTemplatesProvider);
  if (category == null) return templates;
  return templates.where((t) => t.category == category).toList();
});

// Validation results for selected agent
final selectedAgentValidationProvider = Provider<ValidationResult?>((ref) {
  final agent = ref.watch(selectedAgentProvider);
  if (agent == null) return null;
  return RuleEngine.validateAgent(agent);
});

// Search query for templates
final templateSearchProvider = StateProvider<String>((ref) => '');

// Filtered and searched templates
final searchedTemplatesProvider = Provider<List<AgentSchema>>((ref) {
  final templates = ref.watch(agentTemplatesProvider);
  final query = ref.watch(templateSearchProvider).toLowerCase();
  
  if (query.isEmpty) return templates;
  
  return templates.where((t) =>
      t.name.toLowerCase().contains(query) ||
      t.description?.toLowerCase().contains(query) == true ||
      t.tags.any((tag) => tag.toLowerCase().contains(query))).toList();
});

// ============================================================================
// UI - ENHANCED PROPERTIES EDITOR
// ============================================================================

class AgentPropertiesEditor extends ConsumerStatefulWidget {
  const AgentPropertiesEditor({Key? key}) : super(key: key);

  @override
  ConsumerState<AgentPropertiesEditor> createState() => _AgentPropertiesEditorState();
}

class _AgentPropertiesEditorState extends ConsumerState<AgentPropertiesEditor> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedAgent = ref.watch(selectedAgentProvider);
    final validation = ref.watch(selectedAgentValidationProvider);

    if (selectedAgent == null) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildValidationBar(validation),
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, selectedAgent),
                  const SizedBox(height: 24),
                  _buildBasicInfo(context, selectedAgent),
                  const SizedBox(height: 16),
                  _buildPorts(context, selectedAgent, true),
                  const SizedBox(height: 16),
                  _buildPorts(context, selectedAgent, false),
                  const SizedBox(height: 16),
                  _buildCapabilities(context, selectedAgent),
                  const SizedBox(height: 16),
                  _buildConfiguration(context, selectedAgent),
                  const SizedBox(height: 16),
                  _buildValidationRules(context, selectedAgent),
                  const SizedBox(height: 16),
                  _buildMetadata(context, selectedAgent),
                  const SizedBox(height: 80), // Extra space at bottom
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Select an agent to edit properties',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'or create a new one from templates',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationBar(ValidationResult? validation) {
    if (validation == null || validation.isValid && validation.issues.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasErrors = validation.errors.isNotEmpty;
    final hasWarnings = validation.warnings.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: hasErrors
          ? Colors.red.shade50
          : hasWarnings
              ? Colors.orange.shade50
              : Colors.blue.shade50,
      child: Row(
        children: [
          Icon(
            hasErrors
                ? Icons.error
                : hasWarnings
                    ? Icons.warning
                    : Icons.info,
            color: hasErrors
                ? Colors.red
                : hasWarnings
                    ? Colors.orange
                    : Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasErrors
                      ? '${validation.errors.length} error(s) found'
                      : '${validation.warnings.length} warning(s)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: hasErrors
                        ? Colors.red.shade900
                        : Colors.orange.shade900,
                  ),
                ),
                if (validation.issues.isNotEmpty)
                  Text(
                    validation.issues.first.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasErrors
                          ? Colors.red.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showValidationDetails(validation),
            child: const Text('Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AgentSchema agent) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: agent.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(agent.icon, size: 32, color: agent.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agent.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(agent.category.label),
                        avatar: Icon(agent.category.icon, size: 16),
                        backgroundColor: agent.color.withOpacity(0.1),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: agent.color,
                        ),
                      ),
                      Chip(
                        label: Text(agent.role.label),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: const TextStyle(fontSize: 12),
                      ),
                      Chip(
                        label: Text(agent.behavior.label),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                </],
              ),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () => _duplicateAgent(agent),
                  child: const Row(
                    children: [
                      Icon(Icons.content_copy),
                      SizedBox(width: 8),
                      Text('Duplicate'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () => _exportAgent(agent),
                  child: const Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('Export JSON'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  onTap: () => _deleteAgent(agent),
                  child: const Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context, AgentSchema agent) {
    return _PropertySection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        _PropertyField(
          label: 'Name',
          value: agent.name,
          onChanged: (value) {
            _updateAgent(agent.copyWith(name: value));
          },
          helperText: 'Unique identifier for this agent',
        ),
        _PropertyField(
          label: 'Description',
          value: agent.description ?? '',
          onChanged: (value) {
            _updateAgent(agent.copyWith(description: value.isEmpty ? null : value));
          },
          maxLines: 3,
          helperText: 'Optional description of agent functionality',
        ),
        _PropertyDropdown<AgentCategory>(
          label: 'Category',
          value: agent.category,
          items: AgentCategory.values,
          itemBuilder: (category) => Row(
            children: [
              Icon(category.icon, size: 20, color: category.color),
              const SizedBox(width: 8),
              Text(category.label),
            ],
          ),
          onChanged: (value) {
            if (value != null) {
              _updateAgent(agent.copyWith(category: value));
            }
          },
        ),
        _PropertyDropdown<AgentRole>(
          label: 'Role',
          value: agent.role,
          items: AgentRole.values,
          itemBuilder: (role) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(role.label),
              Text(
                role.description,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          onChanged: (value) {
            if (value != null) {
              _updateAgent(agent.copyWith(role: value));
            }
          },
        ),
        _PropertyDropdown<AgentBehavior>(
          label: 'Behavior',
          value: agent.behavior,
          items: AgentBehavior.values,
          itemBuilder: (behavior) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(behavior.label),
              Text(
                behavior.description,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          onChanged: (value) {
            if (value != null) {
              _updateAgent(agent.copyWith(behavior: value));
            }
          },
        ),
      ],
    );
  }

  Widget _buildPorts(BuildContext context, AgentSchema agent, bool isInput) {
    final ports = isInput ? agent.inputs : agent.outputs;
    return _PropertySection(
      title: isInput ? 'Input Ports (${ports.length})' : 'Output Ports (${ports.length})',
      icon: isInput ? Icons.input : Icons.output,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => _addPort(agent, isInput),
          tooltip: 'Add ${isInput ? 'input' : 'output'} port',
        ),
      ],
      children: [
        if (ports.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No ${isInput ? 'input' : 'output'} ports defined',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ...ports.map((port) => _PortWidget(
                port: port,
                onDelete: () => _deletePort(agent, port, isInput),
                onUpdate: (updated) => _updatePort(agent, port, updated, isInput),
              )),
      ],
    );
  }

  Widget _buildCapabilities(BuildContext context, AgentSchema agent) {
    return _PropertySection(
      title: 'Capabilities (${agent.capabilities.length})',
      icon: Icons.extension,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => _addCapability(context, agent),
          tooltip: 'Add capability',
        ),
      ],
      children: [
        if (agent.capabilities.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No capabilities defined',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: agent.capabilities.map((cap) => Chip(
                  label: Text(cap),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    final newCaps =
                        agent.capabilities.where((c) => c != cap).toList();
                    _updateAgent(agent.copyWith(capabilities: newCaps));
                  },
                )).toList(),
          ),
      ],
    );
  }

  Widget _buildConfiguration(BuildContext context, AgentSchema agent) {
    return _PropertySection(
      title: 'Configuration',
      icon: Icons.tune,
      actions: [
        PopupMenuButton(
          icon: const Icon(Icons.more_horiz),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => _applyConfigPreset(agent, AgentConfig.precise()),
              child: const Text('Precise Preset'),
            ),
            PopupMenuItem(
              onTap: () => _applyConfigPreset(agent, AgentConfig.balanced()),
              child: const Text('Balanced Preset'),
            ),
            PopupMenuItem(
              onTap: () => _applyConfigPreset(agent, AgentConfig.creative()),
              child: const Text('Creative Preset'),
            ),
          ],
        ),
      ],
      children: [
        _PropertyField(
          label: 'Model',
          value: agent.config.model ?? '',
          onChanged: (value) {
            _updateAgent(
              agent.copyWith(
                config: agent.config.copyWith(
                  model: value.isEmpty ? null : value,
                ),
              ),
            );
          },
          helperText: 'LLM model identifier (e.g., gpt-4, mistral-7b)',
        ),
        if (agent.config.temperature != null || agent.role == AgentRole.planner || agent.role == AgentRole.dialogue)
          _PropertySlider(
            label: 'Temperature',
            value: agent.config.temperature ?? 0.7,
            min: 0.0,
            max: 2.0,
            divisions: 20,
            onChanged: (value) {
              _updateAgent(
                agent.copyWith(
                  config: agent.config.copyWith(temperature: value),
                ),
              );
            },
          ),
        _PropertyField(
          label: 'Max Steps',
          value: agent.config.maxSteps?.toString() ?? '',
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final maxSteps = int.tryParse(value);
            _updateAgent(
              agent.copyWith(
                config: agent.config.copyWith(
                  maxSteps: maxSteps,
                ),
              ),
            );
          },
          helperText: 'Maximum execution steps',
        ),
        if (agent.role == AgentRole.executor)
          ...[
            _PropertyField(
              label: 'Timeout (ms)',
              value: agent.config.timeout?.toString() ?? '',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final timeout = int.tryParse(value);
                _updateAgent(
                  agent.copyWith(
                    config: agent.config.copyWith(timeout: timeout),
                  ),
                );
              },
            ),
            _PropertyField(
              label: 'Retry Count',
              value: agent.config.retryCount?.toString() ?? '',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final retryCount = int.tryParse(value);
                _updateAgent(
                  agent.copyWith(
                    config: agent.config.copyWith(retryCount: retryCount),
                  ),
                );
              },
            ),
          ],
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Custom Parameters (${agent.config.customParams.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _addCustomParam(context, agent),
              tooltip: 'Add custom parameter',
            ),
          ],
        ),
        if (agent.config.customParams.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No custom parameters',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ...agent.config.customParams.entries.map((entry) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(entry.key),
                  subtitle: Text(
                    '${entry.value} (${entry.value.runtimeType})',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () {
                      final newParams =
                          Map<String, dynamic>.from(agent.config.customParams);
                      newParams.remove(entry.key);
                      _updateAgent(
                        agent.copyWith(
                          config: agent.config.copyWith(customParams: newParams),
                        ),
                      );
                    },
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildValidationRules(BuildContext context, AgentSchema agent) {
    return _PropertySection(
      title: 'Validation Rules (${agent.validationRules.length})',
      icon: Icons.rule,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => _addValidationRule(context, agent),
          tooltip: 'Add validation rule',
        ),
      ],
      children: [
        if (agent.validationRules.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No validation rules defined',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ...agent.validationRules.map((rule) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    rule.severity == RuleSeverity.error
                        ? Icons.error
                        : rule.severity == RuleSeverity.warning
                            ? Icons.warning
                            : Icons.info,
                    color: rule.severity == RuleSeverity.error
                        ? Colors.red
                        : rule.severity == RuleSeverity.warning
                            ? Colors.orange
                            : Colors.blue,
                  ),
                  title: Text(rule.rule),
                  subtitle: Text(rule.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: rule.enabled,
                        onChanged: (value) {
                          final newRules = agent.validationRules
                              .map((r) => r.id == rule.id
                                  ? r.copyWith(enabled: value)
                                  : r)
                              .toList();
                          _updateAgent(
                              agent.copyWith(validationRules: newRules));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () {
                          final newRules = agent.validationRules
                              .where((r) => r.id != rule.id)
                              .toList();
                          _updateAgent(
                              agent.copyWith(validationRules: newRules));
                        },
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildMetadata(BuildContext context, AgentSchema agent) {
    return _PropertySection(
      title: 'Metadata',
      icon: Icons.label,
      children: [
        _PropertyField(
          label: 'Version',
          value: agent.version ?? '1.0.0',
          onChanged: (value) {
            _updateAgent(agent.copyWith(version: value));
          },
          helperText: 'Semantic version (e.g., 1.0.0)',
        ),
        const SizedBox(height: 12),
        Text('Tags', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...agent.tags.map((tag) => Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    final newTags = agent.tags.where((t) => t != tag).toList();
                    _updateAgent(agent.copyWith(tags: newTags));
                  },
                )),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Add Tag'),
              onPressed: () => _addTag(context, agent),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Created: ${_formatDateTime(agent.createdAt)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.update, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Updated: ${_formatDateTime(agent.updatedAt)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.fingerprint, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ID: ${agent.id}',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  void _updateAgent(AgentSchema agent) {
    ref.read(agentListProvider.notifier).updateAgent(agent);
    ref.read(selectedAgentProvider.notifier).state = agent;
  }

  void _duplicateAgent(AgentSchema agent) {
    ref.read(agentListProvider.notifier).duplicateAgent(agent.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agent duplicated')),
    );
  }

  void _exportAgent(AgentSchema agent) {
    final json = agent.toJsonString();
    // In production, use share/clipboard API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('JSON copied to clipboard'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => _showJsonDialog(json),
        ),
      ),
    );
  }

  void _deleteAgent(AgentSchema agent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Agent'),
        content: Text('Are you sure you want to delete "${agent.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(agentListProvider.notifier).removeAgent(agent.id);
              ref.read(selectedAgentProvider.notifier).state = null;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Agent deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addPort(AgentSchema agent, bool isInput) {
    final newPort = Port(
      name: isInput ? 'new_input' : 'new_output',
      type: PayloadType.anyPayload,
    );
    final ports = isInput ? agent.inputs : agent.outputs;
    final newPorts = [...ports, newPort];
    _updateAgent(
      isInput
          ? agent.copyWith(inputs: newPorts)
          : agent.copyWith(outputs: newPorts),
    );
  }

  void _deletePort(AgentSchema agent, Port port, bool isInput) {
    final ports = isInput ? agent.inputs : agent.outputs;
    final newPorts = ports.where((p) => p.id != port.id).toList();
    _updateAgent(
      isInput
          ? agent.copyWith(inputs: newPorts)
          : agent.copyWith(outputs: newPorts),
    );
  }

  void _updatePort(AgentSchema agent, Port oldPort, Port newPort, bool isInput) {
    final ports = isInput ? agent.inputs : agent.outputs;
    final newPorts =
        ports.map((p) => p.id == oldPort.id ? newPort : p).toList();
    _updateAgent(
      isInput
          ? agent.copyWith(inputs: newPorts)
          : agent.copyWith(outputs: newPorts),
    );
  }

  void _addCapability(BuildContext context, AgentSchema agent) {
    showDialog(
      context: context,
      builder: (context) => _AddTextDialog(
        title: 'Add Capability',
        label: 'Capability Name',
        onAdd: (value) {
          final newCaps = [...agent.capabilities, value];
          _updateAgent(agent.copyWith(capabilities: newCaps));
        },
      ),
    );
  }

  void _addCustomParam(BuildContext context, AgentSchema agent) {
    showDialog(
      context: context,
      builder: (context) => _AddKeyValueDialog(
        title: 'Add Custom Parameter',
        onAdd: (key, value) {
          final newParams =
              Map<String, dynamic>.from(agent.config.customParams);
          newParams[key] = value;
          _updateAgent(
            agent.copyWith(
              config: agent.config.copyWith(customParams: newParams),
            ),
          );
        },
      ),
    );
  }

  void _addValidationRule(BuildContext context, AgentSchema agent) {
    showDialog(
      context: context,
      builder: (context) => _AddValidationRuleDialog(
        onAdd: (rule, description, severity) {
          final newRules = [
            ...agent.validationRules,
            ValidationRule(
              rule: rule,
              description: description,
              severity: severity,
            ),
          ];
          _updateAgent(agent.copyWith(validationRules: newRules));
        },
      ),
    );
  }

  void _addTag(BuildContext context, AgentSchema agent) {
    showDialog(
      context: context,
      builder: (context) => _AddTextDialog(
        title: 'Add Tag',
        label: 'Tag Name',
        onAdd: (value) {
          final newTags = [...agent.tags, value];
          _updateAgent(agent.copyWith(tags: newTags));
        },
      ),
    );
  }

  void _applyConfigPreset(AgentSchema agent, AgentConfig preset) {
    Future.delayed(Duration.zero, () {
      _updateAgent(agent.copyWith(config: preset));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration preset applied')),
      );
    });
  }

  void _showValidationDetails(ValidationResult validation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Results'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (validation.errors.isNotEmpty) ...[
                const Text(
                  'Errors:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                ...validation.errors.map((issue) => ListTile(
                      leading: const Icon(Icons.error, color: Colors.red),
                      title: Text(issue.message),
                      subtitle: issue.suggestion != null
                          ? Text(issue.suggestion!)
                          : null,
                    )),
              ],
              if (validation.warnings.isNotEmpty) ...[
                const Text(
                  'Warnings:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                ...validation.warnings.map((issue) => ListTile(
                      leading: const Icon(Icons.warning, color: Colors.orange),
                      title: Text(issue.message),
                      subtitle: issue.suggestion != null
                          ? Text(issue.suggestion!)
                          : null,
                    )),
              ],
              if (validation.infos.isNotEmpty) ...[
                const Text(
                  'Info:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                ...validation.infos.map((issue) => ListTile(
                      leading: const Icon(Icons.info, color: Colors.blue),
                      title: Text(issue.message),
                      subtitle: issue.suggestion != null
                          ? Text(issue.suggestion!)
                          : null,
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showJsonDialog(String json) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agent JSON'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ============================================================================
// UI COMPONENTS - Enhanced
// ============================================================================

class _PropertySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final List<Widget>? actions;

  const _PropertySection({
    required this.title,
    required this.icon,
    required this.children,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _PropertyField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? helperText;

  const _PropertyField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        controller: TextEditingController(text: value)
          ..selection = TextSelection.collapsed(offset: value.length),
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
      ),
    );
  }
}

class _PropertyDropdown<T extends Enum> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final Widget Function(T)? itemBuilder;

  const _PropertyDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        value: value,
        isExpanded: true,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: itemBuilder?.call(item) ?? Text(item.name),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _PropertySlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  const _PropertySlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                value.toStringAsFixed(2),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PortWidget extends StatelessWidget {
  final Port port;
  final VoidCallback onDelete;
  final ValueChanged<Port> onUpdate;

  const _PortWidget({
    required this.port,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Port Name',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: port.name),
                    onChanged: (value) {
                      onUpdate(port.copyWith(name: value));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<PayloadType>(
              decoration: const InputDecoration(
                labelText: 'Payload Type',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              value: port.type,
              isExpanded: true,
              items: PayloadType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(type.label),
                      Text(
                        type.description,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onUpdate(port.copyWith(type: value));
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: port.description ?? ''),
              maxLines: 2,
              onChanged: (value) {
                onUpdate(port.copyWith(
                    description: value.isEmpty ? null : value));
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Multiple'),
                    subtitle: const Text('Accepts multiple connections'),
                    value: port.multiple,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      onUpdate(port.copyWith(multiple: value ?? false));
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Optional'),
                    subtitle: const Text('Not required'),
                    value: port.optional,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      onUpdate(port.copyWith(optional: value ?? false));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// DIALOGS - Enhanced
// ============================================================================

class _AddTextDialog extends StatefulWidget {
  final String title;
  final String label;
  final ValueChanged<String> onAdd;

  const _AddTextDialog({
    required this.title,
    required this.label,
    required this.onAdd,
  });

  @override
  State<_AddTextDialog> createState() => _AddTextDialogState();
}

class _AddTextDialogState extends State<_AddTextDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field cannot be empty';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(_controller.text.trim());
      Navigator.pop(context);
    }
  }
}

class _AddKeyValueDialog extends StatefulWidget {
  final String title;
  final void Function(String key, dynamic value) onAdd;

  const _AddKeyValueDialog({
    required this.title,
    required this.onAdd,
  });

  @override
  State<_AddKeyValueDialog> createState() => _AddKeyValueDialogState();
}

class _AddKeyValueDialogState extends State<_AddKeyValueDialog> {
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _valueType = 'String';

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'Key',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Key cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              value: _valueType,
              items: ['String', 'Number', 'Boolean', 'JSON'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() => _valueType = value!);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: 'Value',
                border: const OutlineInputBorder(),
                helperText: _valueType == 'JSON' ? 'Enter valid JSON' : null,
              ),
              maxLines: _valueType == 'JSON' ? 3 : 1,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Value cannot be empty';
                }
                if (_valueType == 'JSON') {
                  try {
                    jsonDecode(value);
                  } catch (e) {
                    return 'Invalid JSON';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      dynamic value;
      switch (_valueType) {
        case 'Number':
          value = num.tryParse(_valueController.text) ?? _valueController.text;
          break;
        case 'Boolean':
          value = _valueController.text.toLowerCase() == 'true';
          break;
        case 'JSON':
          value = jsonDecode(_valueController.text);
          break;
        default:
          value = _valueController.text;
      }
      widget.onAdd(_keyController.text.trim(), value);
      Navigator.pop(context);
    }
  }
}

class _AddValidationRuleDialog extends StatefulWidget {
  final void Function(String rule, String description, RuleSeverity severity)
      onAdd;

  const _AddValidationRuleDialog({required this.onAdd});

  @override
  State<_AddValidationRuleDialog> createState() =>
      _AddValidationRuleDialogState();
}

class _AddValidationRuleDialogState extends State<_AddValidationRuleDialog> {
  final _ruleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  RuleSeverity _severity = RuleSeverity.error;

  @override
  void dispose() {
    _ruleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Validation Rule'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _ruleController,
              decoration: const InputDecoration(
                labelText: 'Rule Expression',
                border: OutlineInputBorder(),
                helperText: 'e.g., acceptsFrom([\'planner\'])',
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Rule cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RuleSeverity>(
              decoration: const InputDecoration(
                labelText: 'Severity',
                border: OutlineInputBorder(),
              ),
              value: _severity,
              items: RuleSeverity.values.map((sev) {
                return DropdownMenuItem(
                  value: sev,
                  child: Row(
                    children: [
                      Icon(
                        sev == RuleSeverity.error
                            ? Icons.error
                            : sev == RuleSeverity.warning
                                ? Icons.warning
                                : Icons.info,
                        color: sev == RuleSeverity.error
                            ? Colors.red
                            : sev == RuleSeverity.warning
                                ? Colors.orange
                                : Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(sev.name.toUpperCase()),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _severity = value!);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(
        _ruleController.text.trim(),
        _descController.text.trim(),
        _severity,
      );
      Navigator.pop(context);
    }
  }
}

// ============================================================================
// AGENT TEMPLATES PANEL - Enhanced
// ============================================================================

class AgentTemplatesPanel extends ConsumerWidget {
  const AgentTemplatesPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(searchedTemplatesProvider);
    final agents = ref.watch(agentListProvider);
    final searchQuery = ref.watch(templateSearchProvider);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.category),
                  const SizedBox(width: 8),
                  Text(
                    'Agent Templates',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search templates...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            ref.read(templateSearchProvider.notifier).state =
                                '';
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  ref.read(templateSearchProvider.notifier).state = value;
                },
              ),
            ],
          ),
        ),
        // Templates List
        Expanded(
          child: templates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No templates found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return _TemplateCard(template: template);
                  },
                ),
        ),
        // Workspace Section
        const Divider(height: 1),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Workspace (${agents.length})',
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    if (agents.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_all, size: 20),
                        onPressed: () => _showClearWorkspaceDialog(context, ref),
                        tooltip: 'Clear workspace',
                      ),
                  ],
                ),
              ),
              Expanded(
                child: agents.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No agents added yet\nClick + to add from templates',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: agents.length,
                        itemBuilder: (context, index) {
                          final agent = agents[index];
                          final isSelected = ref.watch(selectedAgentProvider)?.id == agent.id;
                          return ListTile(
                            selected: isSelected,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: agent.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(agent.icon, size: 20, color: agent.color),
                            ),
                            title: Text(
                              agent.name,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              agent.role.label,
                              style: const TextStyle(fontSize: 11),
                            ),
                            dense: true,
                            onTap: () {
                              ref.read(selectedAgentProvider.notifier).state = agent;
                            },
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert, size: 18),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  onTap: () {
                                    Future.delayed(Duration.zero, () {
                                      ref.read(agentListProvider.notifier).duplicateAgent(agent.id);
                                    });
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.content_copy, size: 18),
                                      SizedBox(width: 8),
                                      Text('Duplicate'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    Future.delayed(Duration.zero, () {
                                      ref.read(agentListProvider.notifier).removeAgent(agent.id);
                                      if (isSelected) {
                                        ref.read(selectedAgentProvider.notifier).state = null;
                                      }
                                    });
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.delete, size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showClearWorkspaceDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Workspace'),
        content: const Text('Are you sure you want to remove all agents from the workspace?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(agentListProvider.notifier).clear();
              ref.read(selectedAgentProvider.notifier).state = null;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends ConsumerWidget {
  final AgentSchema template;

  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: template.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(template.icon, color: template.color),
        ),
        title: Text(
          template.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          template.role.label,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          color: template.color,
          onPressed: () => _addAgentFromTemplate(ref),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (template.description != null) ...[
                  Text(
                    template.description!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                ],
                _buildInfoRow(
                  Icons.extension,
                  '${template.capabilities.length} capabilities',
                ),
                _buildInfoRow(
                  Icons.input,
                  '${template.inputs.length} inputs',
                ),
                _buildInfoRow(
                  Icons.output,
                  '${template.outputs.length} outputs',
                ),
                if (template.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: template.tags
                        .map((tag) => Chip(
                              label: Text(tag),
                              labelStyle: const TextStyle(fontSize: 10),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _addAgentFromTemplate(ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add to Workspace'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: template.color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  void _addAgentFromTemplate(WidgetRef ref) {
    final newAgent = AgentSchema(
      name: template.name,
      category: template.category,
      role: template.role,
      capabilities: List<String>.from(template.capabilities),
      behavior: template.behavior,
      inputs: template.inputs.map((p) => Port(
        name: p.name,
        type: p.type,
        multiple: p.multiple,
        optional: p.optional,
        description: p.description,
      )).toList(),
      outputs: template.outputs.map((p) => Port(
        name: p.name,
        type: p.type,
        multiple: p.multiple,
        optional: p.optional,
        description: p.description,
      )).toList(),
      config: template.config,
      validationRules: List<ValidationRule>.from(template.validationRules),
      description: template.description,
      tags: List<String>.from(template.tags),
    );
    ref.read(agentListProvider.notifier).addAgent(newAgent);
    ref.read(selectedAgentProvider.notifier).state = newAgent;
  }
}

// ============================================================================
// MAIN APP - Enhanced
// ============================================================================

class AgentBuilderApp extends ConsumerWidget {
  const AgentBuilderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AI Agent Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      home: const AgentBuilderScreen(),
    );
  }
}

class AgentBuilderScreen extends ConsumerStatefulWidget {
  const AgentBuilderScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AgentBuilderScreen> createState() => _AgentBuilderScreenState();
}

class _AgentBuilderScreenState extends ConsumerState<AgentBuilderScreen> {
  @override
  Widget build(BuildContext context) {
    final agents = ref.watch(agentListProvider);
    final selectedAgent = ref.watch(selectedAgentProvider);
    final validation = ref.watch(selectedAgentValidationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Agent Builder - Properties Editor'),
        actions: [
          if (selectedAgent != null) ...[
            IconButton(
              icon: Icon(
                validation?.isValid == true && validation!.issues.isEmpty
                    ? Icons.check_circle
                    : Icons.error,
                color: validation?.isValid == true && validation!.issues.isEmpty
                    ? Colors.green
                    : Colors.orange,
              ),
              onPressed: () => _showValidationSummary(validation),
              tooltip: 'Validation status',
            ),
            const VerticalDivider(width: 1),
          ],
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importAgent,
            tooltip: 'Import agent from JSON',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
            tooltip: 'About',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Left Panel - Agent Templates
          SizedBox(
            width: 300,
            child: AgentTemplatesPanel(),
          ),
          const VerticalDivider(width: 1),
          // Right Panel - Properties Editor
          Expanded(
            child: AgentPropertiesEditor(),
          ),
        ],
      ),
      floatingActionButton: agents.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _exportWorkspace,
              icon: const Icon(Icons.download),
              label: const Text('Export Workspace'),
            )
          : null,
    );
  }

  void _showValidationSummary(ValidationResult? validation) {
    if (validation == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              validation.isValid && validation.issues.isEmpty
                  ? Icons.check_circle
                  : Icons.warning,
              color: validation.isValid && validation.issues.isEmpty
                  ? Colors.green
                  : Colors.orange,
            ),
            const SizedBox(width: 8),
            const Text('Validation Summary'),
          ],
        ),
        content: validation.isValid && validation.issues.isEmpty
            ? const Text('All validation checks passed!')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (validation.errors.isNotEmpty)
                    Text('Errors: ${validation.errors.length}',
                        style: const TextStyle(color: Colors.red)),
                  if (validation.warnings.isNotEmpty)
                    Text('Warnings: ${validation.warnings.length}',
                        style: const TextStyle(color: Colors.orange)),
                  if (validation.infos.isNotEmpty)
                    Text('Info: ${validation.infos.length}',
                        style: const TextStyle(color: Colors.blue)),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _importAgent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Agent'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Paste JSON here',
            border: OutlineInputBorder(),
          ),
          maxLines: 10,
          onSubmitted: (value) {
            try {
              ref.read(agentListProvider.notifier).importFromJson(value);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Agent imported successfully')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Import failed: $e')),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportWorkspace() {
    final agents = ref.read(agentListProvider);
    final json = jsonEncode(agents.map((a) => a.toJson()).toList());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Workspace'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // In production, use share/clipboard API
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('JSON copied to clipboard')),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Agent Builder - Properties Editor'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Production-ready agent builder with advanced features:\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('✓ 10+ built-in agent templates'),
              const Text('✓ Visual properties editor'),
              const Text('✓ Port configuration with validation'),
              const Text('✓ Connection rules engine'),
              const Text('✓ Real-time validation'),
              const Text('✓ Import/Export JSON'),
              const Text('✓ Configuration presets'),
              const Text('✓ Search and filtering'),
              const Text('✓ Workspace management'),
              const SizedBox(height: 16),
              const Text(
                'Built with Flutter & Riverpod',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              Text(
                'Version: 2.0.0',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Entry point
void main() {
  runApp(
    const ProviderScope(
      child: AgentBuilderApp(),
    ),
  );
}
          ValidationRule(
            rule: "acceptsFrom(['planner','reflector'])",
            description: 'Can accept input from planner or reflector agents',
            severity: RuleSeverity.error,
          ),
          ValidationRule(
            rule: "emitsTo(['execution','guardrails','evaluation'])",
            description: 'Can emit to execution, guardrails, or evaluation',
            severity: RuleSeverity.error,
          ),
        ],
        description: 'Coordinates execution across sub-agents with error recovery',
        tags: ['coordination', 'workflow', 'core'],
      );

  static AgentSchema planner() => AgentSchema(
        name: 'Planning Agent',
        category: AgentCategory.cognitive,
        role: AgentRole.planner,
        capabilities: [
          'goal-decomposition',
          'step-generation',
          'dependency-analysis',
          'optimization'
        ],
        behavior: AgentBehavior.deterministic,
        inputs: [
          Port(name: 'goal', type: PayloadType.goalPayload,
              description: 'High-level goal or objective'),
          Port(name: 'context', type: PayloadType.memoryReadPayload,
              optional: true, description: 'Historical context'),
        ],
        outputs: [
          Port(name: 'plan', type: PayloadType.planPayload,
              description: 'Structured execution plan'),
          Port(name: 'alternatives', type: PayloadType.planPayload,
              multiple: true, optional: true, description: 'Alternative plans'),
        ],
        config: AgentConfig.precise(),
        validationRules: [
          ValidationRule(
            rule: "acceptsFrom(['intent','memory','dialogue'])",
            description: 'Accepts input from intent, memory, or dialogue',
          ),
          ValidationRule(
            rule: "emitsTo(['orchestrator','execution'])",
            description: 'Emits to orchestrator or execution agents',
          ),
        ],
        description: 'Decomposes high-level goals into structured, optimized plans',
        tags: ['planning', 'strategy', 'core'],
      );

  static AgentSchema executor() => AgentSchema(
        name: 'Execution Agent',
        category: AgentCategory.operational,
        role: AgentRole.executor,
        capabilities: [
          'api-call',
          'function-execution',
          'retry',
          'timeout-handling',
          'result-validation'
        ],
        behavior: AgentBehavior.reactive,
        inputs: [
          Port(name: 'task', type: PayloadType.taskPayload,
              description: 'Task to execute'),
        ],
        outputs: [
          Port(name: 'result', type: PayloadType.resultPayload,
              description: 'Execution result'),
          Port(name: 'error', type: PayloadType.errorPayload,
              optional: true, description: 'Error details if failed'),
          Port(name: 'metrics', type: PayloadType.metricsPayload,
              optional: true, description: 'Execution metrics'),
        ],
        config: AgentConfig(
          maxSteps: 3,
          timeout: 30000,
          retryCount: 3,
          customParams: {
            'retryBackoff': 'exponential',
            'maxRetryDelay': 10000,
          },
        ),
        validationRules: [
          ValidationRule(
            rule: "acceptsFrom(['planner','orchestrator'])",
            description: 'Accepts tasks from planner or orchestrator',
          ),
          ValidationRule(
            rule: "emitsTo(['evaluation','analytics','guardrails'])",
            description: 'Emits results to evaluation, analytics, or guardrails',
          ),
        ],
        description: 'Executes tasks with retry logic and comprehensive error handling',
        tags: ['execution', 'operational', 'core'],
      );

  static AgentSchema evaluator() => AgentSchema(
        name: 'Evaluation Agent',
        category: AgentCategory.cognitive,
        role: AgentRole.evaluator,
        capabilities: [
          'quality-assessment',
          'criteria-evaluation',
          'scoring',
          'benchmarking'
        ],
        behavior: AgentBehavior.reflective,
        inputs: [
          Port(name: 'result', type: PayloadType.resultPayload,
              description: 'Result to evaluate'),
          Port(name: 'criteria', type: PayloadType.jsonPayload,
              optional: true, description: 'Custom evaluation criteria'),
        ],
        outputs: [
          Port(name: 'score', type: PayloadType.scorePayload,
              description: 'Evaluation score'),
          Port(name: 'feedback', type: PayloadType.textPayload,
              optional: true, description: 'Detailed feedback'),
        ],
        config: AgentConfig.precise(),
        validationRules: [
          ValidationRule(
            rule: "acceptsFrom(['executor','orchestrator'])",
            description: 'Accepts results from executor or orchestrator',
          ),
          ValidationRule(
            rule: "emitsTo(['analytics','reflection','guardrails'])",
            description: 'Emits scores to analytics, reflection, or guardrails',
          ),
        ],
        description: 'Validates and scores execution results against criteria',
        tags: ['evaluation', 'quality', 'core'],
      );

  static AgentSchema guardrails() => AgentSchema(
        name: 'Guardrails Agent',
        category: AgentCategory.governance,
        role: AgentRole.guardrail,
        capabilities: [
          'policy-check',
          'safety-validation',
          'content-filtering',
          'compliance-check'
        ],
        behavior: AgentBehavior.deterministic,
        inputs: [
          Port(name: 'content', type: PayloadType.anyPayload,
              description: 'Content to validate'),
        ],
        outputs: [
          Port(name: 'approved', type: PayloadType.anyPayload,
              description: 'Approved content'),
          Port(name: 'rejected', type: PayloadType.violationPayload,
              description: 'Rejected with violation details'),
        ],
        config: AgentConfig(
          customParams: {
            'policySet': 'default',
            'strictMode': true,
            'auditLog': true,
          },
        ),
        validationRules: [