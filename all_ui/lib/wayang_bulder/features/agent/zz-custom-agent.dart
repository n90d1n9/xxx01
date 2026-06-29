// ============================================================================
// CUSTOM AGENT BUILDER WIZARD - Production Ready
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Assuming all the models from the previous artifact are imported
// import 'agent_builder_models.dart';

// ============================================================================
// CUSTOM AGENT WIZARD STATE
// ============================================================================

class CustomAgentDraft {
  String name;
  AgentCategory category;
  AgentRole role;
  AgentBehavior behavior;
  List<String> capabilities;
  List<Port> inputs;
  List<Port> outputs;
  AgentConfig config;
  List<ValidationRule> validationRules;
  String? description;
  List<String> tags;

  CustomAgentDraft({
    this.name = 'New Custom Agent',
    this.category = AgentCategory.operational,
    this.role = AgentRole.executor,
    this.behavior = AgentBehavior.reactive,
    this.capabilities = const [],
    this.inputs = const [],
    this.outputs = const [],
    AgentConfig? config,
    this.validationRules = const [],
    this.description,
    this.tags = const [],
  }) : config = config ?? AgentConfig();

  AgentSchema toAgentSchema() {
    return AgentSchema(
      name: name,
      category: category,
      role: role,
      capabilities: capabilities,
      behavior: behavior,
      inputs: inputs,
      outputs: outputs,
      config: config,
      validationRules: validationRules,
      description: description,
      tags: tags,
    );
  }

  CustomAgentDraft copyWith({
    String? name,
    AgentCategory? category,
    AgentRole? role,
    AgentBehavior? behavior,
    List<String>? capabilities,
    List<Port>? inputs,
    List<Port>? outputs,
    AgentConfig? config,
    List<ValidationRule>? validationRules,
    String? description,
    List<String>? tags,
  }) =>
      CustomAgentDraft(
        name: name ?? this.name,
        category: category ?? this.category,
        role: role ?? this.role,
        behavior: behavior ?? this.behavior,
        capabilities: capabilities ?? this.capabilities,
        inputs: inputs ?? this.inputs,
        outputs: outputs ?? this.outputs,
        config: config ?? this.config,
        validationRules: validationRules ?? this.validationRules,
        description: description ?? this.description,
        tags: tags ?? this.tags,
      );
}

// State provider for custom agent draft
final customAgentDraftProvider =
    StateProvider<CustomAgentDraft>((ref) => CustomAgentDraft());

final customAgentWizardStepProvider = StateProvider<int>((ref) => 0);

// ============================================================================
// CUSTOM AGENT WIZARD
// ============================================================================

class CustomAgentWizard extends ConsumerStatefulWidget {
  final AgentSchema? cloneFrom;

  const CustomAgentWizard({Key? key, this.cloneFrom}) : super(key: key);

  @override
  ConsumerState<CustomAgentWizard> createState() => _CustomAgentWizardState();
}

class _CustomAgentWizardState extends ConsumerState<CustomAgentWizard> {
  final _formKey = GlobalKey<FormState>();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Initialize from clone if provided
    if (widget.cloneFrom != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(customAgentDraftProvider.notifier).state = CustomAgentDraft(
          name: '${widget.cloneFrom!.name} (Custom)',
          category: widget.cloneFrom!.category,
          role: widget.cloneFrom!.role,
          behavior: widget.cloneFrom!.behavior,
          capabilities: List.from(widget.cloneFrom!.capabilities),
          inputs: widget.cloneFrom!.inputs
              .map((p) => Port(
                    name: p.name,
                    type: p.type,
                    multiple: p.multiple,
                    optional: p.optional,
                    description: p.description,
                  ))
              .toList(),
          outputs: widget.cloneFrom!.outputs
              .map((p) => Port(
                    name: p.name,
                    type: p.type,
                    multiple: p.multiple,
                    optional: p.optional,
                    description: p.description,
                  ))
              .toList(),
          config: widget.cloneFrom!.config,
          validationRules: List.from(widget.cloneFrom!.validationRules),
          description: widget.cloneFrom!.description,
          tags: List.from(widget.cloneFrom!.tags),
        );
      });
    }
  }

  @override
  void dispose() {
    _capabilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(customAgentDraftProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Define Agent Capabilities',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'What can this agent do?',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _capabilityController,
                  decoration: const InputDecoration(
                    labelText: 'Add Capability',
                    hintText: 'e.g., data-transformation',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addCapability(draft),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _addCapability(draft),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Suggestions:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((suggestion) {
              final isAdded = draft.capabilities.contains(suggestion);
              return FilterChip(
                label: Text(suggestion),
                selected: isAdded,
                onSelected: (selected) {
                  if (selected) {
                    _addCapabilityDirect(draft, suggestion);
                  } else {
                    _removeCapability(draft, suggestion);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Current Capabilities (${draft.capabilities.length}):',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (draft.capabilities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.extension, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text(
                      'No capabilities added yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: draft.capabilities.map((capability) {
                return Chip(
                  label: Text(capability),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeCapability(draft, capability),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _addCapability(CustomAgentDraft draft) {
    final capability = _capabilityController.text.trim();
    if (capability.isNotEmpty && !draft.capabilities.contains(capability)) {
      final newCapabilities = [...draft.capabilities, capability];
      ref.read(customAgentDraftProvider.notifier).state =
          draft.copyWith(capabilities: newCapabilities);
      _capabilityController.clear();
    }
  }

  void _addCapabilityDirect(CustomAgentDraft draft, String capability) {
    if (!draft.capabilities.contains(capability)) {
      final newCapabilities = [...draft.capabilities, capability];
      ref.read(customAgentDraftProvider.notifier).state =
          draft.copyWith(capabilities: newCapabilities);
    }
  }

  void _removeCapability(CustomAgentDraft draft, String capability) {
    final newCapabilities =
        draft.capabilities.where((c) => c != capability).toList();
    ref.read(customAgentDraftProvider.notifier).state =
        draft.copyWith(capabilities: newCapabilities);
  }
}

// ============================================================================
// STEP 5: CONFIGURATION
// ============================================================================

class _ConfigurationStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(customAgentDraftProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agent Configuration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Optional: Set default configuration',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              PopupMenuButton<AgentConfig>(
                child: const Chip(
                  avatar: Icon(Icons.auto_awesome, size: 16),
                  label: Text('Apply Preset'),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: AgentConfig.precise(),
                    child: const Text('Precise'),
                  ),
                  PopupMenuItem(
                    value: AgentConfig.balanced(),
                    child: const Text('Balanced'),
                  ),
                  PopupMenuItem(
                    value: AgentConfig.creative(),
                    child: const Text('Creative'),
                  ),
                ],
                onSelected: (preset) {
                  ref.read(customAgentDraftProvider.notifier).state =
                      draft.copyWith(config: preset);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Model',
              hintText: 'e.g., gpt-4, mistral-7b',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: draft.config.model ?? ''),
            onChanged: (value) {
              ref.read(customAgentDraftProvider.notifier).state = draft.copyWith(
                config: draft.config.copyWith(
                  model: value.isEmpty ? null : value,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Temperature'),
                  Text(
                    draft.config.temperature?.toStringAsFixed(2) ?? '0.70',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                value: draft.config.temperature ?? 0.7,
                min: 0.0,
                max: 2.0,
                divisions: 20,
                label: (draft.config.temperature ?? 0.7).toStringAsFixed(2),
                onChanged: (value) {
                  ref.read(customAgentDraftProvider.notifier).state =
                      draft.copyWith(
                    config: draft.config.copyWith(temperature: value),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Max Steps',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                      text: draft.config.maxSteps?.toString() ?? ''),
                  onChanged: (value) {
                    final maxSteps = int.tryParse(value);
                    ref.read(customAgentDraftProvider.notifier).state =
                        draft.copyWith(
                      config: draft.config.copyWith(maxSteps: maxSteps),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Timeout (ms)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                      text: draft.config.timeout?.toString() ?? ''),
                  onChanged: (value) {
                    final timeout = int.tryParse(value);
                    ref.read(customAgentDraftProvider.notifier).state =
                        draft.copyWith(
                      config: draft.config.copyWith(timeout: timeout),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Retry Count',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            controller: TextEditingController(
                text: draft.config.retryCount?.toString() ?? ''),
            onChanged: (value) {
              final retryCount = int.tryParse(value);
              ref.read(customAgentDraftProvider.notifier).state = draft.copyWith(
                config: draft.config.copyWith(retryCount: retryCount),
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Tags',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _TagsEditor(
            tags: draft.tags,
            onTagsChanged: (tags) {
              ref.read(customAgentDraftProvider.notifier).state =
                  draft.copyWith(tags: tags);
            },
          ),
        ],
      ),
    );
  }
}

class _TagsEditor extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;

  const _TagsEditor({
    required this.tags,
    required this.onTagsChanged,
  });

  @override
  State<_TagsEditor> createState() => _TagsEditorState();
}

class _TagsEditorState extends State<_TagsEditor> {
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Add Tag',
                  hintText: 'e.g., production, experimental',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addTag,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.tags.isEmpty)
          Text(
            'No tags added',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeTag(tag),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !widget.tags.contains(tag)) {
      widget.onTagsChanged([...widget.tags, tag]);
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    widget.onTagsChanged(widget.tags.where((t) => t != tag).toList());
  }
}

// ============================================================================
// STEP 6: REVIEW
// ============================================================================

class _ReviewStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(customAgentDraftProvider);
    final agent = draft.toAgentSchema();
    final validation = RuleEngine.validateAgent(agent);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Create',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Review your custom agent before creating',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          // Validation Status
          _ValidationStatusCard(validation: validation),
          const SizedBox(height: 16),
          // Agent Preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              children: [
                                Chip(
                                  label: Text(agent.category.label),
                                  avatar:
                                      Icon(agent.category.icon, size: 16),
                                  visualDensity: VisualDensity.compact,
                                ),
                                Chip(
                                  label: Text(agent.role.label),
                                  visualDensity: VisualDensity.compact,
                                ),
                                Chip(
                                  label: Text(agent.behavior.label),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (agent.description != null) ...[
                    const SizedBox(height: 16),
                    Text(agent.description!),
                  ],
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                      context, 'Inputs', '${agent.inputs.length} ports'),
                  _buildInfoRow(
                      context, 'Outputs', '${agent.outputs.length} ports'),
                  _buildInfoRow(context, 'Capabilities',
                      '${agent.capabilities.length} defined'),
                  if (agent.tags.isNotEmpty)
                    _buildInfoRow(context, 'Tags', agent.tags.join(', ')),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Configuration',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  if (agent.config.model != null)
                    _buildConfigRow(context, 'Model', agent.config.model!),
                  if (agent.config.temperature != null)
                    _buildConfigRow(context, 'Temperature',
                        agent.config.temperature!.toStringAsFixed(2)),
                  if (agent.config.maxSteps != null)
                    _buildConfigRow(context, 'Max Steps',
                        agent.config.maxSteps.toString()),
                  if (agent.config.timeout != null)
                    _buildConfigRow(
                        context, 'Timeout', '${agent.config.timeout}ms'),
                  if (agent.config.retryCount != null)
                    _buildConfigRow(context, 'Retry Count',
                        agent.config.retryCount.toString()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Export JSON Preview
          ExpansionTile(
            title: const Text('View JSON'),
            leading: const Icon(Icons.code),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: SelectableText(
                  agent.toJsonString(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ValidationStatusCard extends StatelessWidget {
  final ValidationResult validation;

  const _ValidationStatusCard({required this.validation});

  @override
  Widget build(BuildContext context) {
    final hasErrors = validation.errors.isNotEmpty;
    final hasWarnings = validation.warnings.isNotEmpty;
    final isValid = validation.isValid && !hasErrors;

    return Card(
      color: hasErrors
          ? Colors.red.shade50
          : hasWarnings
              ? Colors.orange.shade50
              : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isValid
                      ? Icons.check_circle
                      : hasErrors
                          ? Icons.error
                          : Icons.warning,
                  color: isValid
                      ? Colors.green
                      : hasErrors
                          ? Colors.red
                          : Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isValid
                        ? 'Validation Passed'
                        : hasErrors
                            ? 'Validation Errors Found'
                            : 'Validation Warnings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isValid
                          ? Colors.green.shade900
                          : hasErrors
                              ? Colors.red.shade900
                              : Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
            if (hasErrors || hasWarnings) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              if (hasErrors)
                ...validation.errors.map((issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error, size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(issue.message),
                                if (issue.suggestion != null)
                                  Text(
                                    'Suggestion: ${issue.suggestion}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              if (hasWarnings)
                ...validation.warnings.map((issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning,
                              size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(issue.message),
                                if (issue.suggestion != null)
                                  Text(
                                    'Suggestion: ${issue.suggestion}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// USAGE EXAMPLE - Add to main screen
// ============================================================================

// Add this button to AgentBuilderScreen or AgentTemplatesPanel
class CreateCustomAgentButton extends StatelessWidget {
  const CreateCustomAgentButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const CustomAgentWizard(),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Create Custom Agent'),
      heroTag: 'create_custom_agent',
    );
  }
}

// Or add as menu item in templates panel
class CustomAgentMenuItem extends StatelessWidget {
  const CustomAgentMenuItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.add_circle_outline, color: Colors.blue),
      title: const Text('Create Custom Agent'),
      subtitle: const Text('Build from scratch'),
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const CustomAgentWizard(),
        );
      },
    );
  }
}_pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(customAgentWizardStepProvider);
    final draft = ref.watch(customAgentDraftProvider);

    final steps = [
      _WizardStep(
        title: 'Basic Info',
        icon: Icons.info_outline,
        isComplete: draft.name.isNotEmpty,
      ),
      _WizardStep(
        title: 'Input Ports',
        icon: Icons.input,
        isComplete: draft.inputs.isNotEmpty,
      ),
      _WizardStep(
        title: 'Output Ports',
        icon: Icons.output,
        isComplete: draft.outputs.isNotEmpty,
      ),
      _WizardStep(
        title: 'Capabilities',
        icon: Icons.extension,
        isComplete: draft.capabilities.isNotEmpty,
      ),
      _WizardStep(
        title: 'Configuration',
        icon: Icons.tune,
        isComplete: true,
      ),
      _WizardStep(
        title: 'Review',
        icon: Icons.preview,
        isComplete: true,
      ),
    ];

    return Dialog(
      child: Container(
        width: 900,
        height: 700,
        child: Column(
          children: [
            // Header
            _buildHeader(context, steps[currentStep]),
            const Divider(height: 1),
            // Stepper
            _buildStepper(steps, currentStep),
            const Divider(height: 1),
            // Content
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _BasicInfoStep(),
                    _InputPortsStep(),
                    _OutputPortsStep(),
                    _CapabilitiesStep(),
                    _ConfigurationStep(),
                    _ReviewStep(),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            // Footer
            _buildFooter(context, currentStep, steps.length),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, _WizardStep step) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Icon(step.icon, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Custom Agent',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                step.title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _cancelWizard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(List<_WizardStep> steps, int currentStep) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: List.generate(
          steps.length * 2 - 1,
          (index) {
            if (index.isEven) {
              final stepIndex = index ~/ 2;
              final step = steps[stepIndex];
              final isActive = stepIndex == currentStep;
              final isCompleted = stepIndex < currentStep;

              return _StepIndicator(
                step: step,
                isActive: isActive,
                isCompleted: isCompleted,
                stepNumber: stepIndex + 1,
                onTap: () => _goToStep(stepIndex),
              );
            } else {
              return Expanded(
                child: Container(
                  height: 2,
                  color: index ~/ 2 < currentStep
                      ? Colors.green
                      : Colors.grey.shade300,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, int currentStep, int totalSteps) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentStep > 0)
            OutlinedButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            )
          else
            const SizedBox.shrink(),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => _cancelWizard(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              if (currentStep < totalSteps - 1)
                ElevatedButton.icon(
                  onPressed: _nextStep,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                )
              else
                ElevatedButton.icon(
                  onPressed: _createAgent,
                  icon: const Icon(Icons.check),
                  label: const Text('Create Agent'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _goToStep(int step) {
    ref.read(customAgentWizardStepProvider.notifier).state = step;
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      final currentStep = ref.read(customAgentWizardStepProvider);
      _goToStep(currentStep + 1);
    }
  }

  void _previousStep() {
    final currentStep = ref.read(customAgentWizardStepProvider);
    _goToStep(currentStep - 1);
  }

  void _cancelWizard(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Creation'),
        content: const Text('Are you sure? All progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Editing'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close wizard
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _createAgent() {
    if (_formKey.currentState?.validate() ?? false) {
      final draft = ref.read(customAgentDraftProvider);
      final agent = draft.toAgentSchema();

      // Validate agent
      final validation = RuleEngine.validateAgent(agent);

      if (!validation.isValid) {
        _showValidationErrors(validation);
        return;
      }

      // Add to workspace
      ref.read(agentListProvider.notifier).addAgent(agent);
      ref.read(selectedAgentProvider.notifier).state = agent;

      // Show success and close
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Custom agent "${agent.name}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  void _showValidationErrors(ValidationResult validation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Validation Errors'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...validation.errors.map((issue) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(issue.message)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fix Issues'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIZARD STEPS
// ============================================================================

class _WizardStep {
  final String title;
  final IconData icon;
  final bool isComplete;

  _WizardStep({
    required this.title,
    required this.icon,
    required this.isComplete,
  });
}

class _StepIndicator extends StatelessWidget {
  final _WizardStep step;
  final bool isActive;
  final bool isCompleted;
  final int stepNumber;
  final VoidCallback onTap;

  const _StepIndicator({
    required this.step,
    required this.isActive,
    required this.isCompleted,
    required this.stepNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        stepNumber.toString(),
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              step.title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STEP 1: BASIC INFO
// ============================================================================

class _BasicInfoStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(customAgentDraftProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Define your agent\'s basic information',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: draft.name,
            decoration: const InputDecoration(
              labelText: 'Agent Name *',
              hintText: 'e.g., Email Processor Agent',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Name is required' : null,
            onChanged: (value) {
              ref.read(customAgentDraftProvider.notifier).state =
                  draft.copyWith(name: value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: draft.description,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'What does this agent do?',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) {
              ref.read(customAgentDraftProvider.notifier).state =
                  draft.copyWith(description: value.isEmpty ? null : value);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<AgentCategory>(
            value: draft.category,
            decoration: const InputDecoration(
              labelText: 'Category *',
              border: OutlineInputBorder(),
            ),
            items: AgentCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(category.icon, size: 20, color: category.color),
                    const SizedBox(width: 8),
                    Text(category.label),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(customAgentDraftProvider.notifier).state =
                    draft.copyWith(category: value);
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<AgentRole>(
            value: draft.role,
            decoration: const InputDecoration(
              labelText: 'Role *',
              border: OutlineInputBorder(),
            ),
            items: AgentRole.values.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Column(
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
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(customAgentDraftProvider.notifier).state =
                    draft.copyWith(role: value);
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<AgentBehavior>(
            value: draft.behavior,
            decoration: const InputDecoration(
              labelText: 'Behavior *',
              border: OutlineInputBorder(),
            ),
            items: AgentBehavior.values.map((behavior) {
              return DropdownMenuItem(
                value: behavior,
                child: Column(
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
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(customAgentDraftProvider.notifier).state =
                    draft.copyWith(behavior: value);
              }
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STEP 2 & 3: INPUT/OUTPUT PORTS
// ============================================================================

class _InputPortsStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PortsStep(isInput: true);
  }
}

class _OutputPortsStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PortsStep(isInput: false);
  }
}

class _PortsStep extends ConsumerWidget {
  final bool isInput;

  const _PortsStep({required this.isInput});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(customAgentDraftProvider);
    final ports = isInput ? draft.inputs : draft.outputs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configure ${isInput ? 'Input' : 'Output'} Ports',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Define how data flows ${isInput ? 'into' : 'out of'} this agent',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _addPort(ref, draft),
                icon: const Icon(Icons.add),
                label: const Text('Add Port'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (ports.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(isInput ? Icons.input : Icons.output,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'No ${isInput ? 'input' : 'output'} ports defined',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click "Add Port" to get started',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            ...ports.asMap().entries.map((entry) {
              final index = entry.key;
              final port = entry.value;
              return _PortEditorCard(
                port: port,
                onUpdate: (updated) => _updatePort(ref, draft, index, updated),
                onDelete: () => _deletePort(ref, draft, index),
              );
            }),
        ],
      ),
    );
  }

  void _addPort(WidgetRef ref, CustomAgentDraft draft) {
    final newPort = Port(
      name: isInput ? 'input_${draft.inputs.length + 1}' : 'output_${draft.outputs.length + 1}',
      type: PayloadType.anyPayload,
    );
    final ports = isInput ? [...draft.inputs, newPort] : draft.inputs;
    final outputs = isInput ? draft.outputs : [...draft.outputs, newPort];
    ref.read(customAgentDraftProvider.notifier).state =
        draft.copyWith(inputs: ports, outputs: outputs);
  }

  void _updatePort(WidgetRef ref, CustomAgentDraft draft, int index, Port port) {
    if (isInput) {
      final newInputs = List<Port>.from(draft.inputs);
      newInputs[index] = port;
      ref.read(customAgentDraftProvider.notifier).state =
          draft.copyWith(inputs: newInputs);
    } else {
      final newOutputs = List<Port>.from(draft.outputs);
      newOutputs[index] = port;
      ref.read(customAgentDraftProvider.notifier).state =
          draft.copyWith(outputs: newOutputs);
    }
  }

  void _deletePort(WidgetRef ref, CustomAgentDraft draft, int index) {
    if (isInput) {
      final newInputs = List<Port>.from(draft.inputs)..removeAt(index);
      ref.read(customAgentDraftProvider.notifier).state =
          draft.copyWith(inputs: newInputs);
    } else {
      final newOutputs = List<Port>.from(draft.outputs)..removeAt(index);
      ref.read(customAgentDraftProvider.notifier).state =
          draft.copyWith(outputs: newOutputs);
    }
  }
}

class _PortEditorCard extends StatefulWidget {
  final Port port;
  final ValueChanged<Port> onUpdate;
  final VoidCallback onDelete;

  const _PortEditorCard({
    required this.port,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_PortEditorCard> createState() => _PortEditorCardState();
}

class _PortEditorCardState extends State<_PortEditorCard> {
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.port.name);
    _descController = TextEditingController(text: widget.port.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Port Name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      widget.onUpdate(widget.port.copyWith(name: value));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PayloadType>(
              value: widget.port.type,
              decoration: const InputDecoration(
                labelText: 'Payload Type',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              isExpanded: true,
              items: PayloadType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Text(type.label),
                      const SizedBox(width: 8),
                      Text(
                        '- ${type.description}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.onUpdate(widget.port.copyWith(type: value));
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
              onChanged: (value) {
                widget.onUpdate(widget.port.copyWith(
                    description: value.isEmpty ? null : value));
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Multiple'),
                    subtitle: const Text('Accept multiple connections'),
                    value: widget.port.multiple,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      widget.onUpdate(
                          widget.port.copyWith(multiple: value ?? false));
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Optional'),
                    subtitle: const Text('Not required'),
                    value: widget.port.optional,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      widget.onUpdate(
                          widget.port.copyWith(optional: value ?? false));
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
// STEP 4: CAPABILITIES
// ============================================================================

class _CapabilitiesStep extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CapabilitiesStep> createState() => _CapabilitiesStepState();
}

class _CapabilitiesStepState extends ConsumerState<_CapabilitiesStep> {
  final _capabilityController = TextEditingController();

  // Common capabilities suggestions
  final List<String> _suggestions = [
    'api-call',
    'data-transformation',
    'validation',
    'enrichment',
    'filtering',
    'aggregation',
    'caching',
    'retry',
    'error-handling',
    'logging',
    'monitoring',
    'rate-limiting',
  ];

  @override
  void dispose() {