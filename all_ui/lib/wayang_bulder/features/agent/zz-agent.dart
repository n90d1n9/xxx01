// ============================================================================
// DOMAIN MODELS - Core Schema Definitions
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

// --- Enums ---

enum AgentCategory {
  cognitive,
  operational,
  governance,
  analytic,
  interactive,
  transformer,
}

enum AgentRole {
  orchestrator,
  planner,
  executor,
  evaluator,
  guardrail,
  memory,
  analytics,
  dialogue,
  transformer,
}

enum AgentBehavior { deterministic, reflective, reactive }

enum PayloadType {
  goalPayload,
  planPayload,
  taskPayload,
  resultPayload,
  errorPayload,
  scorePayload,
  violationPayload,
  memoryWritePayload,
  memoryQueryPayload,
  memoryReadPayload,
  metricsPayload,
  insightPayload,
  textPayload,
  anyPayload,
}

// --- Port Definition ---

class Port {
  final String name;
  final PayloadType type;
  final bool multiple;
  final bool optional;

  Port({
    required this.name,
    required this.type,
    this.multiple = false,
    this.optional = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type.name,
    'multiple': multiple,
    'optional': optional,
  };

  factory Port.fromJson(Map<String, dynamic> json) => Port(
    name: json['name'],
    type: PayloadType.values.byName(json['type']),
    multiple: json['multiple'] ?? false,
    optional: json['optional'] ?? false,
  );
}

// --- Agent Configuration ---

class AgentConfig {
  final String? model;
  final double? temperature;
  final int? maxSteps;
  final Map<String, dynamic> customParams;

  AgentConfig({
    this.model,
    this.temperature,
    this.maxSteps,
    this.customParams = const {},
  });

  AgentConfig copyWith({
    String? model,
    double? temperature,
    int? maxSteps,
    Map<String, dynamic>? customParams,
  }) => AgentConfig(
    model: model ?? this.model,
    temperature: temperature ?? this.temperature,
    maxSteps: maxSteps ?? this.maxSteps,
    customParams: customParams ?? this.customParams,
  );

  Map<String, dynamic> toJson() => {
    if (model != null) 'model': model,
    if (temperature != null) 'temperature': temperature,
    if (maxSteps != null) 'max_steps': maxSteps,
    ...customParams,
  };

  factory AgentConfig.fromJson(Map<String, dynamic> json) {
    final customParams = Map<String, dynamic>.from(json);
    customParams.remove('model');
    customParams.remove('temperature');
    customParams.remove('max_steps');

    return AgentConfig(
      model: json['model'],
      temperature: json['temperature']?.toDouble(),
      maxSteps: json['max_steps'],
      customParams: customParams,
    );
  }
}

// --- Validation Rule ---

class ValidationRule {
  final String rule;
  final String description;

  ValidationRule({required this.rule, required this.description});

  Map<String, dynamic> toJson() => {'rule': rule, 'description': description};

  factory ValidationRule.fromJson(Map<String, dynamic> json) => ValidationRule(
    rule: json['rule'],
    description: json['description'] ?? '',
  );
}

// --- Agent Schema ---

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
  final IconData? icon;

  AgentSchema({
    required this.id,
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
    this.icon,
  });

  AgentSchema copyWith({
    String? id,
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
    IconData? icon,
  }) => AgentSchema(
    id: id ?? this.id,
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
    icon: icon ?? this.icon,
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
  };

  factory AgentSchema.fromJson(Map<String, dynamic> json) => AgentSchema(
    id: json['id'],
    name: json['name'],
    category: AgentCategory.values.byName(json['category']),
    role: AgentRole.values.byName(json['role']),
    capabilities: List<String>.from(json['capabilities']),
    behavior: AgentBehavior.values.byName(json['behavior']),
    inputs: (json['inputs'] as List).map((p) => Port.fromJson(p)).toList(),
    outputs: (json['outputs'] as List).map((p) => Port.fromJson(p)).toList(),
    config: AgentConfig.fromJson(json['config']),
    validationRules: (json['validationRules'] as List)
        .map((r) => ValidationRule.fromJson(r))
        .toList(),
    description: json['description'],
  );
}

// --- Connection Rule ---

class ConnectionRule {
  final String id;
  final AgentCategory fromCategory;
  final AgentCategory toCategory;
  final List<String> allowedRoles;
  final String constraint;
  final String description;

  ConnectionRule({
    required this.id,
    required this.fromCategory,
    required this.toCategory,
    required this.allowedRoles,
    required this.constraint,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromCategory': fromCategory.name,
    'toCategory': toCategory.name,
    'allowedRoles': allowedRoles,
    'constraint': constraint,
    'description': description,
  };
}

// --- Agent Connection ---

class AgentConnection {
  final String id;
  final String sourceAgentId;
  final String sourcePortName;
  final String targetAgentId;
  final String targetPortName;
  final PayloadType payloadType;

  AgentConnection({
    required this.id,
    required this.sourceAgentId,
    required this.sourcePortName,
    required this.targetAgentId,
    required this.targetPortName,
    required this.payloadType,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceAgentId': sourceAgentId,
    'sourcePortName': sourcePortName,
    'targetAgentId': targetAgentId,
    'targetPortName': targetPortName,
    'payloadType': payloadType.name,
  };
}

// ============================================================================
// BUILT-IN AGENT TEMPLATES
// ============================================================================

class AgentTemplates {
  static final uuid = Uuid();

  static AgentSchema orchestrator() => AgentSchema(
    id: uuid.v4(),
    name: 'Orchestration Agent',
    category: AgentCategory.cognitive,
    role: AgentRole.orchestrator,
    capabilities: ['multi-agent-coordination', 'task-routing'],
    behavior: AgentBehavior.deterministic,
    inputs: [Port(name: 'plan', type: PayloadType.planPayload)],
    outputs: [
      Port(name: 'task', type: PayloadType.taskPayload, multiple: true),
    ],
    config: AgentConfig(model: 'mistral-7b', temperature: 0.3, maxSteps: 10),
    validationRules: [
      ValidationRule(
        rule: "acceptsFrom(['planner','reflector'])",
        description: 'Can accept input from planner or reflector agents',
      ),
      ValidationRule(
        rule: "emitsTo(['execution','guardrails','evaluation'])",
        description: 'Can emit to execution, guardrails, or evaluation',
      ),
    ],
    description: 'Coordinates execution across sub-agents',
    icon: Icons.hub,
  );

  static AgentSchema planner() => AgentSchema(
    id: uuid.v4(),
    name: 'Planning Agent',
    category: AgentCategory.cognitive,
    role: AgentRole.planner,
    capabilities: ['goal-decomposition', 'step-generation'],
    behavior: AgentBehavior.deterministic,
    inputs: [Port(name: 'goal', type: PayloadType.goalPayload)],
    outputs: [Port(name: 'plan', type: PayloadType.planPayload)],
    config: AgentConfig(model: 'mistral-7b', temperature: 0.3, maxSteps: 5),
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
    description: 'Decomposes high-level goals into structured plans',
    icon: Icons.event_note,
  );

  static AgentSchema executor() => AgentSchema(
    id: uuid.v4(),
    name: 'Execution Agent',
    category: AgentCategory.operational,
    role: AgentRole.executor,
    capabilities: ['api-call', 'function-execution', 'retry'],
    behavior: AgentBehavior.reactive,
    inputs: [Port(name: 'task', type: PayloadType.taskPayload)],
    outputs: [
      Port(name: 'result', type: PayloadType.resultPayload),
      Port(name: 'error', type: PayloadType.errorPayload, optional: true),
    ],
    config: AgentConfig(
      maxSteps: 3,
      customParams: {'retryCount': 3, 'timeout': 30000},
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
    description: 'Executes plans or tasks',
    icon: Icons.play_circle,
  );

  static AgentSchema evaluator() => AgentSchema(
    id: uuid.v4(),
    name: 'Evaluation Agent',
    category: AgentCategory.cognitive,
    role: AgentRole.evaluator,
    capabilities: ['quality-assessment', 'criteria-evaluation'],
    behavior: AgentBehavior.reflective,
    inputs: [Port(name: 'result', type: PayloadType.resultPayload)],
    outputs: [Port(name: 'score', type: PayloadType.scorePayload)],
    config: AgentConfig(model: 'mistral-7b', temperature: 0.1),
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
    description: 'Validates or scores execution results',
    icon: Icons.assessment,
  );

  static AgentSchema guardrails() => AgentSchema(
    id: uuid.v4(),
    name: 'Guardrails Agent',
    category: AgentCategory.governance,
    role: AgentRole.guardrail,
    capabilities: ['policy-check', 'safety-validation'],
    behavior: AgentBehavior.deterministic,
    inputs: [Port(name: 'content', type: PayloadType.anyPayload)],
    outputs: [
      Port(name: 'approved', type: PayloadType.anyPayload),
      Port(name: 'rejected', type: PayloadType.violationPayload),
    ],
    config: AgentConfig(
      customParams: {'policySet': 'default', 'strictMode': true},
    ),
    validationRules: [
      ValidationRule(
        rule: "acceptsFrom(['planner','executor','evaluator','dialogue'])",
        description: 'Can intercept content from multiple agent types',
      ),
      ValidationRule(
        rule: "emitsTo(['orchestrator','audit'])",
        description: 'Emits decisions to orchestrator or audit',
      ),
    ],
    description: 'Applies policies, ethics, and security constraints',
    icon: Icons.shield,
  );

  static AgentSchema memory() => AgentSchema(
    id: uuid.v4(),
    name: 'Memory Agent',
    category: AgentCategory.cognitive,
    role: AgentRole.memory,
    capabilities: ['vector-search', 'context-store'],
    behavior: AgentBehavior.reactive,
    inputs: [
      Port(name: 'store', type: PayloadType.memoryWritePayload),
      Port(name: 'query', type: PayloadType.memoryQueryPayload),
    ],
    outputs: [Port(name: 'context', type: PayloadType.memoryReadPayload)],
    config: AgentConfig(
      customParams: {
        'vectorDb': 'pinecone',
        'embeddingModel': 'text-embedding-ada-002',
        'topK': 5,
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
    description: 'Stores and retrieves context or facts',
    icon: Icons.storage,
  );

  static AgentSchema analytics() => AgentSchema(
    id: uuid.v4(),
    name: 'Analytics Agent',
    category: AgentCategory.analytic,
    role: AgentRole.analytics,
    capabilities: ['observation', 'anomaly-detection'],
    behavior: AgentBehavior.reactive,
    inputs: [Port(name: 'metrics', type: PayloadType.metricsPayload)],
    outputs: [Port(name: 'report', type: PayloadType.insightPayload)],
    config: AgentConfig(
      customParams: {'aggregationWindow': 300, 'alertThreshold': 0.95},
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
    description: 'Monitors system metrics and emits insights',
    icon: Icons.analytics,
  );

  static AgentSchema dialogue() => AgentSchema(
    id: uuid.v4(),
    name: 'Dialogue Agent',
    category: AgentCategory.interactive,
    role: AgentRole.dialogue,
    capabilities: ['nlp', 'contextual-dialogue'],
    behavior: AgentBehavior.reactive,
    inputs: [Port(name: 'user_input', type: PayloadType.textPayload)],
    outputs: [
      Port(name: 'intent', type: PayloadType.goalPayload),
      Port(name: 'response', type: PayloadType.textPayload),
    ],
    config: AgentConfig(
      model: 'mistral-7b',
      temperature: 0.7,
      customParams: {'maxTurns': 20, 'contextWindow': 4096},
    ),
    validationRules: [
      ValidationRule(
        rule: "emitsTo(['planner','memory','guardrail'])",
        description: 'Manages user conversations',
      ),
    ],
    description: 'Manages user conversations and session memory',
    icon: Icons.chat,
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
  ];
}

// ============================================================================
// VALIDATION ENGINE
// ============================================================================

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory ValidationResult.valid() => ValidationResult(isValid: true);

  factory ValidationResult.invalid(
    List<String> errors, [
    List<String> warnings = const [],
  ]) => ValidationResult(isValid: false, errors: errors, warnings: warnings);
}

class RuleEngine {
  // Connection rules matrix
  static final Map<AgentCategory, List<AgentCategory>> _categoryRules = {
    AgentCategory.cognitive: [
      AgentCategory.operational,
      AgentCategory.cognitive,
      AgentCategory.governance,
    ],
    AgentCategory.operational: [
      AgentCategory.analytic,
      AgentCategory.cognitive,
      AgentCategory.governance,
    ],
    AgentCategory.governance: [
      AgentCategory.cognitive,
      AgentCategory.operational,
      AgentCategory.analytic,
    ],
    AgentCategory.interactive: [
      AgentCategory.cognitive,
      AgentCategory.governance,
    ],
    AgentCategory.analytic: [AgentCategory.cognitive],
  };

  static ValidationResult validateConnection({
    required AgentSchema source,
    required AgentSchema target,
    required String sourcePortName,
    required String targetPortName,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // 1. Check if categories are compatible
    final allowedTargets = _categoryRules[source.category];
    if (allowedTargets == null || !allowedTargets.contains(target.category)) {
      errors.add(
        'Connection not allowed: ${source.category.name} → ${target.category.name}',
      );
    }

    // 2. Validate ports exist
    final sourcePort = source.outputs.firstWhere(
      (p) => p.name == sourcePortName,
      orElse: () => throw Exception('Source port not found'),
    );

    final targetPort = source.inputs.firstWhere(
      (p) => p.name == targetPortName,
      orElse: () => throw Exception('Target port not found'),
    );

    // 3. Check payload type compatibility
    if (sourcePort.type != targetPort.type &&
        sourcePort.type != PayloadType.anyPayload &&
        targetPort.type != PayloadType.anyPayload) {
      errors.add(
        'Payload type mismatch: ${sourcePort.type.name} → ${targetPort.type.name}',
      );
    }

    // 4. Check multiplicity
    if (!targetPort.multiple && targetPort.type == sourcePort.type) {
      warnings.add(
        'Target port "${targetPort.name}" does not accept multiple connections',
      );
    }

    return errors.isEmpty
        ? ValidationResult(isValid: true, warnings: warnings)
        : ValidationResult.invalid(errors, warnings);
  }

  static ValidationResult validateAgent(AgentSchema agent) {
    final errors = <String>[];
    final warnings = <String>[];

    // 1. Validate name
    if (agent.name.trim().isEmpty) {
      errors.add('Agent name cannot be empty');
    }

    // 2. Validate ports
    if (agent.inputs.isEmpty && agent.outputs.isEmpty) {
      warnings.add('Agent has no input or output ports');
    }

    // 3. Validate capabilities
    if (agent.capabilities.isEmpty) {
      warnings.add('Agent has no capabilities defined');
    }

    // 4. Role-specific validations
    switch (agent.role) {
      case AgentRole.orchestrator:
        if (!agent.capabilities.contains('multi-agent-coordination')) {
          warnings.add(
            'Orchestrator should have multi-agent-coordination capability',
          );
        }
        break;
      case AgentRole.executor:
        if (agent.outputs.isEmpty) {
          errors.add('Executor must have at least one output port');
        }
        break;
      case AgentRole.guardrail:
        if (agent.outputs.length < 2) {
          warnings.add('Guardrail should have approved and rejected outputs');
        }
        break;
      default:
        break;
    }

    return errors.isEmpty
        ? ValidationResult(isValid: true, warnings: warnings)
        : ValidationResult.invalid(errors, warnings);
  }
}

// ============================================================================
// STATE MANAGEMENT - RIVERPOD PROVIDERS
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
}

// Agent templates
final agentTemplatesProvider = Provider<List<AgentSchema>>((ref) {
  return AgentTemplates.allTemplates();
});

// ============================================================================
// UI - PROPERTIES EDITOR
// ============================================================================

class AgentPropertiesEditor extends ConsumerWidget {
  const AgentPropertiesEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAgent = ref.watch(selectedAgentProvider);

    if (selectedAgent == null) {
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
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, selectedAgent),
          const SizedBox(height: 24),
          _buildBasicInfo(context, ref, selectedAgent),
          const SizedBox(height: 16),
          _buildPorts(context, ref, selectedAgent, true),
          const SizedBox(height: 16),
          _buildPorts(context, ref, selectedAgent, false),
          const SizedBox(height: 16),
          _buildCapabilities(context, ref, selectedAgent),
          const SizedBox(height: 16),
          _buildConfiguration(context, ref, selectedAgent),
          const SizedBox(height: 16),
          _buildValidationRules(context, ref, selectedAgent),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AgentSchema agent) {
    return Row(
      children: [
        Icon(agent.icon ?? Icons.settings, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agent.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                '${agent.category.name} • ${agent.role.name}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.red,
          onPressed: () {
            ref.read(agentListProvider.notifier).removeAgent(agent.id);
            ref.read(selectedAgentProvider.notifier).state = null;
          },
        ),
      ],
    );
  }

  Widget _buildBasicInfo(
    BuildContext context,
    WidgetRef ref,
    AgentSchema agent,
  ) {
    return _PropertySection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        _PropertyField(
          label: 'Name',
          value: agent.name,
          onChanged: (value) {
            _updateAgent(ref, agent.copyWith(name: value));
          },
        ),
        _PropertyDropdown<AgentCategory>(
          label: 'Category',
          value: agent.category,
          items: AgentCategory.values,
          onChanged: (value) {
            if (value != null) {
              _updateAgent(ref, agent.copyWith(category: value));
            }
          },
        ),
        _PropertyDropdown<AgentRole>(
          label: 'Role',
          value: agent.role,
          items: AgentRole.values,
          onChanged: (value) {
            if (value != null) {
              _updateAgent(ref, agent.copyWith(role: value));
            }
          },
        ),
        _PropertyDropdown<AgentBehavior>(
          label: 'Behavior',
          value: agent.behavior,
          items: AgentBehavior.values,
          onChanged: (value) {
            if (value != null) {
              _updateAgent(ref, agent.copyWith(behavior: value));
            }
          },
        ),
      ],
    );
  }

  Widget _buildPorts(
    BuildContext context,
    WidgetRef ref,
    AgentSchema agent,
    bool isInput,
  ) {
    final ports = isInput ? agent.inputs : agent.outputs;
    return _PropertySection(
      title: isInput ? 'Input Ports' : 'Output Ports',
      icon: isInput ? Icons.input : Icons.output,
      children: [
        ...ports.map(
          (port) => _PortWidget(
            port: port,
            onDelete: () {
              final newPorts = ports.where((p) => p != port).toList();
              _updateAgent(
                ref,
                isInput
                    ? agent.copyWith(inputs: newPorts)
                    : agent.copyWith(outputs: newPorts),
              );
            },
            onUpdate: (updated) {
              final newPorts = ports
                  .map((p) => p == port ? updated : p)
                  .toList();
              _updateAgent(
                ref,
                isInput
                    ? agent.copyWith(inputs: newPorts)
                    : agent.copyWith(outputs: newPorts),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _addPort(ref, agent, isInput),
          icon: const Icon(Icons.add),
          label: Text('Add ${isInput ? 'Input' : 'Output'} Port'),
        ),
      ],
    );
  }

  Widget _buildCapabilities(
    BuildContext context,
    WidgetRef ref,
    AgentSchema agent,
  ) {
    return _PropertySection(
      title: 'Capabilities',
      icon: Icons.extension,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...agent.capabilities.map(
              (cap) => Chip(
                label: Text(cap),
                onDeleted: () {
                  final newCaps = agent.capabilities
                      .where((c) => c != cap)
                      .toList();
                  _updateAgent(ref, agent.copyWith(capabilities: newCaps));
                },
              ),
            ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              onPressed: () => _addCapability(context, ref, agent),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfiguration(
    BuildContext context,
    WidgetRef ref,
    AgentSchema agent,
  ) {
    return _PropertySection(
      title: 'Configuration',
      icon: Icons.tune,
      children: [
        if (agent.config.model != null)
          _PropertyField(
            label: 'Model',
            value: agent.config.model!,
            onChanged: (value) {
              _updateAgent(
                ref,
                agent.copyWith(config: agent.config.copyWith(model: value)),
              );
            },
          ),
        if (agent.config.temperature != null)
          _PropertySlider(
            label: 'Temperature',
            value: agent.config.temperature!,
            min: 0.0,
            max: 2.0,
            onChanged: (value) {
              _updateAgent(
                ref,
                agent.copyWith(
                  config: agent.config.copyWith(temperature: value),
                ),
              );
            },
          ),
        if (agent.config.maxSteps != null)
          _PropertyField(
            label: 'Max Steps',
            value: agent.config.maxSteps.toString(),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final maxSteps = int.tryParse(value);
              if (maxSteps != null) {
                _updateAgent(
                  ref,
                  agent.copyWith(
                    config: agent.config.copyWith(maxSteps: maxSteps),
                  ),
                );
              }
            },
          ),
        const Divider(),
        Text(
          'Custom Parameters',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...agent.config.customParams.entries.map(
          (entry) => ListTile(
            title: Text(entry.key),
            subtitle: Text(entry.value.toString()),
            trailing: IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () {
                final newParams = Map<String, dynamic>.from(
                  agent.config.customParams,
                );
                newParams.remove(entry.key);
                _updateAgent(
                  ref,
                  agent.copyWith(
                    config: agent.config.copyWith(customParams: newParams),
                  ),
                );
              },
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _addCustomParam(context, ref, agent),
          icon: const Icon(Icons.add),
          label: const Text('Add Custom Parameter'),
        ),
      ],
    );
  }

  Widget _buildValidationRules(
    BuildContext context,
    WidgetRef ref,
    AgentSchema agent,
  ) {
    return _PropertySection(
      title: 'Validation Rules',
      icon: Icons.rule,
      children: [
        ...agent.validationRules.asMap().entries.map(
          (entry) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(entry.value.rule),
              subtitle: Text(entry.value.description),
              trailing: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () {
                  final newRules = List<ValidationRule>.from(
                    agent.validationRules,
                  )..removeAt(entry.key);
                  _updateAgent(ref, agent.copyWith(validationRules: newRules));
                },
              ),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _addValidationRule(context, ref, agent),
          icon: const Icon(Icons.add),
          label: const Text('Add Rule'),
        ),
      ],
    );
  }

  void _updateAgent(WidgetRef ref, AgentSchema agent) {
    ref.read(agentListProvider.notifier).updateAgent(agent);
    ref.read(selectedAgentProvider.notifier).state = agent;
  }

  void _addPort(WidgetRef ref, AgentSchema agent, bool isInput) {
    final newPort = Port(
      name: isInput ? 'new_input' : 'new_output',
      type: PayloadType.anyPayload,
    );
    final ports = isInput ? agent.inputs : agent.outputs;
    final newPorts = [...ports, newPort];
    _updateAgent(
      ref,
      isInput
          ? agent.copyWith(inputs: newPorts)
          : agent.copyWith(outputs: newPorts),
    );
  }

  void _addCapability(BuildContext context, WidgetRef ref, AgentSchema agent) {
    showDialog(
      context: context,
      builder: (context) => _AddTextDialog(
        title: 'Add Capability',
        onAdd: (value) {
          final newCaps = [...agent.capabilities, value];
          _updateAgent(ref, agent.copyWith(capabilities: newCaps));
        },
      ),
    );
  }

  void _addCustomParam(BuildContext context, WidgetRef ref, AgentSchema agent) {
    showDialog(
      context: context,
      builder: (context) => _AddKeyValueDialog(
        title: 'Add Custom Parameter',
        onAdd: (key, value) {
          final newParams = Map<String, dynamic>.from(
            agent.config.customParams,
          );
          newParams[key] = value;
          _updateAgent(
            ref,
            agent.copyWith(
              config: agent.config.copyWith(customParams: newParams),
            ),
          );
        },
      ),
    );
  }

  void _addValidationRule(
    BuildContext context,
    WidgetRef ref,
    AgentSchema agent,
  ) {
    showDialog(
      context: context,
      builder: (context) => _AddValidationRuleDialog(
        onAdd: (rule, description) {
          final newRules = [
            ...agent.validationRules,
            ValidationRule(rule: rule, description: description),
          ];
          _updateAgent(ref, agent.copyWith(validationRules: newRules));
        },
      ),
    );
  }
}

// ============================================================================
// UI COMPONENTS
// ============================================================================

class _PropertySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _PropertySection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

  const _PropertyField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        controller: TextEditingController(text: value)
          ..selection = TextSelection.collapsed(offset: value.length),
        keyboardType: keyboardType,
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

  const _PropertyDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
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
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item.name));
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
  final ValueChanged<double> onChanged;

  const _PropertySlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
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
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 10).toInt(),
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
                      onUpdate(
                        Port(
                          name: value,
                          type: port.type,
                          multiple: port.multiple,
                          optional: port.optional,
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
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
              items: PayloadType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.name));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onUpdate(
                    Port(
                      name: port.name,
                      type: value,
                      multiple: port.multiple,
                      optional: port.optional,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Multiple'),
                    value: port.multiple,
                    dense: true,
                    onChanged: (value) {
                      onUpdate(
                        Port(
                          name: port.name,
                          type: port.type,
                          multiple: value ?? false,
                          optional: port.optional,
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Optional'),
                    value: port.optional,
                    dense: true,
                    onChanged: (value) {
                      onUpdate(
                        Port(
                          name: port.name,
                          type: port.type,
                          multiple: port.multiple,
                          optional: value ?? false,
                        ),
                      );
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
// DIALOGS
// ============================================================================

class _AddTextDialog extends StatefulWidget {
  final String title;
  final ValueChanged<String> onAdd;

  const _AddTextDialog({required this.title, required this.onAdd});

  @override
  State<_AddTextDialog> createState() => _AddTextDialogState();
}

class _AddTextDialogState extends State<_AddTextDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Value',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onAdd(_controller.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _AddKeyValueDialog extends StatefulWidget {
  final String title;
  final void Function(String key, dynamic value) onAdd;

  const _AddKeyValueDialog({required this.title, required this.onAdd});

  @override
  State<_AddKeyValueDialog> createState() => _AddKeyValueDialogState();
}

class _AddKeyValueDialogState extends State<_AddKeyValueDialog> {
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  String _valueType = 'String';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _keyController,
            decoration: const InputDecoration(
              labelText: 'Key',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
            ),
            value: _valueType,
            items: ['String', 'Number', 'Boolean'].map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              setState(() => _valueType = value!);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _valueController,
            decoration: const InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_keyController.text.isNotEmpty &&
                _valueController.text.isNotEmpty) {
              dynamic value;
              switch (_valueType) {
                case 'Number':
                  value =
                      num.tryParse(_valueController.text) ??
                      _valueController.text;
                  break;
                case 'Boolean':
                  value = _valueController.text.toLowerCase() == 'true';
                  break;
                default:
                  value = _valueController.text;
              }
              widget.onAdd(_keyController.text, value);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _AddValidationRuleDialog extends StatefulWidget {
  final void Function(String rule, String description) onAdd;

  const _AddValidationRuleDialog({required this.onAdd});

  @override
  State<_AddValidationRuleDialog> createState() =>
      _AddValidationRuleDialogState();
}

class _AddValidationRuleDialogState extends State<_AddValidationRuleDialog> {
  final _ruleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Validation Rule'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _ruleController,
            decoration: const InputDecoration(
              labelText: 'Rule Expression',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_ruleController.text.isNotEmpty) {
              widget.onAdd(_ruleController.text, _descController.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// ============================================================================
// MAIN DEMO APP
// ============================================================================

class AgentBuilderApp extends ConsumerWidget {
  const AgentBuilderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AI Agent Builder',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AgentBuilderScreen(),
    );
  }
}

class AgentBuilderScreen extends ConsumerWidget {
  const AgentBuilderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Agent Builder - Properties Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel - Agent Templates
          SizedBox(width: 280, child: _AgentTemplatesPanel()),
          const VerticalDivider(width: 1),
          // Right Panel - Properties Editor
          const Expanded(child: AgentPropertiesEditor()),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'AI Agent Builder Properties Editor\n\n'
          'Features:\n'
          '• Drag & drop agent templates\n'
          '• Visual properties editor\n'
          '• Port configuration\n'
          '• Validation rules\n'
          '• Connection rules engine\n\n'
          'Built with Flutter & Riverpod',
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

class _AgentTemplatesPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(agentTemplatesProvider);
    final agents = ref.watch(agentListProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            children: [
              const Icon(Icons.category),
              const SizedBox(width: 8),
              Text(
                'Agent Templates',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return ListTile(
                leading: Icon(template.icon),
                title: Text(template.name),
                subtitle: Text(template.role.name),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    final newAgent = AgentSchema(
                      id: const Uuid().v4(),
                      name: template.name,
                      category: template.category,
                      role: template.role,
                      capabilities: template.capabilities,
                      behavior: template.behavior,
                      inputs: template.inputs,
                      outputs: template.outputs,
                      config: template.config,
                      validationRules: template.validationRules,
                      description: template.description,
                      icon: template.icon,
                    );
                    ref.read(agentListProvider.notifier).addAgent(newAgent);
                    ref.read(selectedAgentProvider.notifier).state = newAgent;
                  },
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workspace Agents (${agents.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: agents.isEmpty
                    ? const Center(child: Text('No agents added yet'))
                    : ListView.builder(
                        itemCount: agents.length,
                        itemBuilder: (context, index) {
                          final agent = agents[index];
                          final isSelected =
                              ref.watch(selectedAgentProvider)?.id == agent.id;
                          return ListTile(
                            selected: isSelected,
                            leading: Icon(agent.icon, size: 20),
                            title: Text(agent.name),
                            dense: true,
                            onTap: () {
                              ref.read(selectedAgentProvider.notifier).state =
                                  agent;
                            },
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
}

// Entry point
void main() {
  runApp(const ProviderScope(child: AgentBuilderApp()));
}
