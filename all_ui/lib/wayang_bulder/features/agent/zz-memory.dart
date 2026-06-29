import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// ========== MEMORY MODELS ==========
class MemoryConfig {
  final String id;
  final String name;
  final MemoryType type;
  final int maxSize;
  final RetentionPolicy retentionPolicy;
  final bool persistEnabled;
  final bool searchEnabled;
  final EmbeddingConfig? embeddingConfig;
  final List<MemoryEntry> entries;
  final Map<String, dynamic> metadata;

  MemoryConfig({
    required this.id,
    required this.name,
    required this.type,
    this.maxSize = 1000,
    required this.retentionPolicy,
    this.persistEnabled = true,
    this.searchEnabled = false,
    this.embeddingConfig,
    this.entries = const [],
    this.metadata = const {},
  });

  MemoryConfig copyWith({
    String? name,
    MemoryType? type,
    int? maxSize,
    RetentionPolicy? retentionPolicy,
    bool? persistEnabled,
    bool? searchEnabled,
    EmbeddingConfig? embeddingConfig,
    List<MemoryEntry>? entries,
    Map<String, dynamic>? metadata,
  }) {
    return MemoryConfig(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      maxSize: maxSize ?? this.maxSize,
      retentionPolicy: retentionPolicy ?? this.retentionPolicy,
      persistEnabled: persistEnabled ?? this.persistEnabled,
      searchEnabled: searchEnabled ?? this.searchEnabled,
      embeddingConfig: embeddingConfig ?? this.embeddingConfig,
      entries: entries ?? this.entries,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum MemoryType { shortTerm, longTerm, episodic, semantic, working }

enum RetentionPolicy { fifo, lifo, lru, priority, permanent }

class EmbeddingConfig {
  final String model;
  final int dimensions;
  final double similarityThreshold;

  EmbeddingConfig({
    required this.model,
    this.dimensions = 768,
    this.similarityThreshold = 0.7,
  });

  EmbeddingConfig copyWith({
    String? model,
    int? dimensions,
    double? similarityThreshold,
  }) {
    return EmbeddingConfig(
      model: model ?? this.model,
      dimensions: dimensions ?? this.dimensions,
      similarityThreshold: similarityThreshold ?? this.similarityThreshold,
    );
  }
}

class MemoryEntry {
  final String id;
  final String content;
  final DateTime timestamp;
  final int priority;
  final Map<String, dynamic> tags;

  MemoryEntry({
    required this.id,
    required this.content,
    required this.timestamp,
    this.priority = 1,
    this.tags = const {},
  });
}

// ========== INSTRUCTION MODELS ==========
class InstructionConfig {
  final String id;
  final String name;
  final String systemPrompt;
  final List<InstructionRule> rules;
  final PromptTemplate promptTemplate;
  final ResponseFormat responseFormat;
  final List<String> constraints;
  final List<Example> examples;
  final Map<String, dynamic> variables;

  InstructionConfig({
    required this.id,
    required this.name,
    required this.systemPrompt,
    this.rules = const [],
    required this.promptTemplate,
    required this.responseFormat,
    this.constraints = const [],
    this.examples = const [],
    this.variables = const {},
  });

  InstructionConfig copyWith({
    String? name,
    String? systemPrompt,
    List<InstructionRule>? rules,
    PromptTemplate? promptTemplate,
    ResponseFormat? responseFormat,
    List<String>? constraints,
    List<Example>? examples,
    Map<String, dynamic>? variables,
  }) {
    return InstructionConfig(
      id: id,
      name: name ?? this.name,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      rules: rules ?? this.rules,
      promptTemplate: promptTemplate ?? this.promptTemplate,
      responseFormat: responseFormat ?? this.responseFormat,
      constraints: constraints ?? this.constraints,
      examples: examples ?? this.examples,
      variables: variables ?? this.variables,
    );
  }
}

class InstructionRule {
  final String id;
  final String condition;
  final String action;
  final int priority;
  final bool enabled;

  InstructionRule({
    required this.id,
    required this.condition,
    required this.action,
    this.priority = 1,
    this.enabled = true,
  });

  InstructionRule copyWith({
    String? condition,
    String? action,
    int? priority,
    bool? enabled,
  }) {
    return InstructionRule(
      id: id,
      condition: condition ?? this.condition,
      action: action ?? this.action,
      priority: priority ?? this.priority,
      enabled: enabled ?? this.enabled,
    );
  }
}

class PromptTemplate {
  final String template;
  final List<String> requiredVariables;
  final String format;

  PromptTemplate({
    required this.template,
    this.requiredVariables = const [],
    this.format = 'markdown',
  });

  PromptTemplate copyWith({
    String? template,
    List<String>? requiredVariables,
    String? format,
  }) {
    return PromptTemplate(
      template: template ?? this.template,
      requiredVariables: requiredVariables ?? this.requiredVariables,
      format: format ?? this.format,
    );
  }
}

class ResponseFormat {
  final String type;
  final String? schema;
  final bool structured;

  ResponseFormat({
    required this.type,
    this.schema,
    this.structured = false,
  });

  ResponseFormat copyWith({
    String? type,
    String? schema,
    bool? structured,
  }) {
    return ResponseFormat(
      type: type ?? this.type,
      schema: schema ?? this.schema,
      structured: structured ?? this.structured,
    );
  }
}

class Example {
  final String id;
  final String input;
  final String output;
  final String? explanation;

  Example({
    required this.id,
    required this.input,
    required this.output,
    this.explanation,
  });
}

// ========== STATE MANAGEMENT ==========
class MemoryNotifier extends StateNotifier<MemoryConfig> {
  MemoryNotifier(MemoryConfig memory) : super(memory);

  void updateName(String name) => state = state.copyWith(name: name);
  void updateType(MemoryType type) => state = state.copyWith(type: type);
  void updateMaxSize(int size) => state = state.copyWith(maxSize: size);
  void updateRetentionPolicy(RetentionPolicy policy) =>
      state = state.copyWith(retentionPolicy: policy);
  void updatePersistEnabled(bool enabled) =>
      state = state.copyWith(persistEnabled: enabled);
  void updateSearchEnabled(bool enabled) =>
      state = state.copyWith(searchEnabled: enabled);
  void updateEmbeddingConfig(EmbeddingConfig config) =>
      state = state.copyWith(embeddingConfig: config);

  void addEntry(MemoryEntry entry) {
    state = state.copyWith(entries: [...state.entries, entry]);
  }

  void removeEntry(String entryId) {
    state = state.copyWith(
      entries: state.entries.where((e) => e.id != entryId).toList(),
    );
  }
}

class InstructionNotifier extends StateNotifier<InstructionConfig> {
  InstructionNotifier(InstructionConfig instruction) : super(instruction);

  void updateName(String name) => state = state.copyWith(name: name);
  void updateSystemPrompt(String prompt) =>
      state = state.copyWith(systemPrompt: prompt);
  void updatePromptTemplate(PromptTemplate template) =>
      state = state.copyWith(promptTemplate: template);
  void updateResponseFormat(ResponseFormat format) =>
      state = state.copyWith(responseFormat: format);

  void addRule(InstructionRule rule) {
    state = state.copyWith(rules: [...state.rules, rule]);
  }

  void removeRule(String ruleId) {
    state = state.copyWith(
      rules: state.rules.where((r) => r.id != ruleId).toList(),
    );
  }

  void updateRule(String ruleId, InstructionRule updatedRule) {
    state = state.copyWith(
      rules: state.rules.map((r) => r.id == ruleId ? updatedRule : r).toList(),
    );
  }

  void addConstraint(String constraint) {
    state = state.copyWith(constraints: [...state.constraints, constraint]);
  }

  void removeConstraint(int index) {
    final newConstraints = List<String>.from(state.constraints);
    newConstraints.removeAt(index);
    state = state.copyWith(constraints: newConstraints);
  }

  void addExample(Example example) {
    state = state.copyWith(examples: [...state.examples, example]);
  }

  void removeExample(String exampleId) {
    state = state.copyWith(
      examples: state.examples.where((e) => e.id != exampleId).toList(),
    );
  }
}

// ========== PROVIDERS ==========
final memoryProvider = StateNotifierProvider<MemoryNotifier, MemoryConfig>((ref) {
  return MemoryNotifier(
    MemoryConfig(
      id: 'memory_1',
      name: 'Agent Memory',
      type: MemoryType.longTerm,
      retentionPolicy: RetentionPolicy.lru,
      maxSize: 1000,
      searchEnabled: true,
      embeddingConfig: EmbeddingConfig(
        model: 'text-embedding-ada-002',
        dimensions: 1536,
      ),
    ),
  );
});

final instructionProvider =
    StateNotifierProvider<InstructionNotifier, InstructionConfig>((ref) {
  return InstructionNotifier(
    InstructionConfig(
      id: 'instruction_1',
      name: 'Agent Instructions',
      systemPrompt: 'You are a helpful AI assistant.',
      promptTemplate: PromptTemplate(
        template: '{{context}}\n\nUser: {{input}}\n\nAssistant:',
        requiredVariables: ['context', 'input'],
      ),
      responseFormat: ResponseFormat(type: 'text'),
      constraints: ['Be concise', 'Be accurate'],
    ),
  );
});

// ========== UI COMPONENTS ==========
class MemoryPropertyEditor extends ConsumerWidget {
  const MemoryPropertyEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memory = ref.watch(memoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Configuration'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBasicSection(context, ref, memory),
          const SizedBox(height: 24),
          _buildStorageSection(context, ref, memory),
          const SizedBox(height: 24),
          _buildSearchSection(context, ref, memory),
          const SizedBox(height: 24),
          _buildEntriesSection(context, ref, memory),
        ],
      ),
    );
  }

  Widget _buildBasicSection(
    BuildContext context,
    WidgetRef ref,
    MemoryConfig memory,
  ) {
    return _PropertyCard(
      title: 'Basic Configuration',
      icon: Icons.memory,
      children: [
        _TextField(
          label: 'Memory Name',
          value: memory.name,
          onChanged: (v) => ref.read(memoryProvider.notifier).updateName(v),
        ),
        const SizedBox(height: 16),
        _Dropdown<MemoryType>(
          label: 'Memory Type',
          value: memory.type,
          items: MemoryType.values,
          itemLabel: (t) => t.name.toUpperCase(),
          onChanged: (v) => ref.read(memoryProvider.notifier).updateType(v!),
        ),
        const SizedBox(height: 16),
        _Dropdown<RetentionPolicy>(
          label: 'Retention Policy',
          value: memory.retentionPolicy,
          items: RetentionPolicy.values,
          itemLabel: (p) => p.name.toUpperCase(),
          onChanged: (v) =>
              ref.read(memoryProvider.notifier).updateRetentionPolicy(v!),
        ),
      ],
    );
  }

  Widget _buildStorageSection(
    BuildContext context,
    WidgetRef ref,
    MemoryConfig memory,
  ) {
    return _PropertyCard(
      title: 'Storage Settings',
      icon: Icons.storage,
      children: [
        _SliderField(
          label: 'Max Entries',
          value: memory.maxSize.toDouble(),
          min: 100,
          max: 10000,
          divisions: 99,
          onChanged: (v) =>
              ref.read(memoryProvider.notifier).updateMaxSize(v.toInt()),
        ),
        const SizedBox(height: 16),
        _SwitchField(
          label: 'Persist to Storage',
          value: memory.persistEnabled,
          onChanged: (v) =>
              ref.read(memoryProvider.notifier).updatePersistEnabled(v),
        ),
      ],
    );
  }

  Widget _buildSearchSection(
    BuildContext context,
    WidgetRef ref,
    MemoryConfig memory,
  ) {
    return _PropertyCard(
      title: 'Semantic Search',
      icon: Icons.search,
      children: [
        _SwitchField(
          label: 'Enable Semantic Search',
          value: memory.searchEnabled,
          onChanged: (v) =>
              ref.read(memoryProvider.notifier).updateSearchEnabled(v),
        ),
        if (memory.searchEnabled && memory.embeddingConfig != null) ...[
          const SizedBox(height: 16),
          _TextField(
            label: 'Embedding Model',
            value: memory.embeddingConfig!.model,
            onChanged: (v) {
              final config = memory.embeddingConfig!.copyWith(model: v);
              ref.read(memoryProvider.notifier).updateEmbeddingConfig(config);
            },
          ),
          const SizedBox(height: 16),
          _SliderField(
            label: 'Similarity Threshold',
            value: memory.embeddingConfig!.similarityThreshold,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            onChanged: (v) {
              final config =
                  memory.embeddingConfig!.copyWith(similarityThreshold: v);
              ref.read(memoryProvider.notifier).updateEmbeddingConfig(config);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildEntriesSection(
    BuildContext context,
    WidgetRef ref,
    MemoryConfig memory,
  ) {
    return _PropertyCard(
      title: 'Memory Entries (${memory.entries.length})',
      icon: Icons.list,
      children: [
        if (memory.entries.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No memory entries yet'),
            ),
          )
        else
          ...memory.entries.map((entry) => _MemoryEntryCard(entry: entry)),
      ],
    );
  }
}

class InstructionPropertyEditor extends ConsumerWidget {
  const InstructionPropertyEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instruction = ref.watch(instructionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instruction Configuration'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBasicSection(context, ref, instruction),
          const SizedBox(height: 24),
          _buildPromptSection(context, ref, instruction),
          const SizedBox(height: 24),
          _buildRulesSection(context, ref, instruction),
          const SizedBox(height: 24),
          _buildConstraintsSection(context, ref, instruction),
          const SizedBox(height: 24),
          _buildExamplesSection(context, ref, instruction),
        ],
      ),
    );
  }

  Widget _buildBasicSection(
    BuildContext context,
    WidgetRef ref,
    InstructionConfig instruction,
  ) {
    return _PropertyCard(
      title: 'Basic Configuration',
      icon: Icons.description,
      children: [
        _TextField(
          label: 'Instruction Name',
          value: instruction.name,
          onChanged: (v) => ref.read(instructionProvider.notifier).updateName(v),
        ),
        const SizedBox(height: 16),
        _TextField(
          label: 'System Prompt',
          value: instruction.systemPrompt,
          maxLines: 5,
          onChanged: (v) =>
              ref.read(instructionProvider.notifier).updateSystemPrompt(v),
        ),
      ],
    );
  }

  Widget _buildPromptSection(
    BuildContext context,
    WidgetRef ref,
    InstructionConfig instruction,
  ) {
    return _PropertyCard(
      title: 'Prompt Template',
      icon: Icons.code,
      children: [
        _TextField(
          label: 'Template',
          value: instruction.promptTemplate.template,
          maxLines: 4,
          onChanged: (v) {
            final template = instruction.promptTemplate.copyWith(template: v);
            ref.read(instructionProvider.notifier).updatePromptTemplate(template);
          },
        ),
        const SizedBox(height: 16),
        _Dropdown<String>(
          label: 'Response Format',
          value: instruction.responseFormat.type,
          items: const ['text', 'json', 'markdown', 'code'],
          itemLabel: (t) => t.toUpperCase(),
          onChanged: (v) {
            final format = instruction.responseFormat.copyWith(type: v);
            ref.read(instructionProvider.notifier).updateResponseFormat(format);
          },
        ),
      ],
    );
  }

  Widget _buildRulesSection(
    BuildContext context,
    WidgetRef ref,
    InstructionConfig instruction,
  ) {
    return _PropertyCard(
      title: 'Instruction Rules',
      icon: Icons.rule,
      children: [
        ...instruction.rules.map((rule) => _RuleCard(rule: rule)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showAddRuleDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Rule'),
        ),
      ],
    );
  }

  Widget _buildConstraintsSection(
    BuildContext context,
    WidgetRef ref,
    InstructionConfig instruction,
  ) {
    return _PropertyCard(
      title: 'Constraints',
      icon: Icons.warning_amber,
      children: [
        ...instruction.constraints.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ConstraintChip(
              label: entry.value,
              onDelete: () => ref
                  .read(instructionProvider.notifier)
                  .removeConstraint(entry.key),
            ),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showAddConstraintDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Constraint'),
        ),
      ],
    );
  }

  Widget _buildExamplesSection(
    BuildContext context,
    WidgetRef ref,
    InstructionConfig instruction,
  ) {
    return _PropertyCard(
      title: 'Examples',
      icon: Icons.lightbulb_outline,
      children: [
        ...instruction.examples.map((example) => _ExampleCard(example: example)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showAddExampleDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Example'),
        ),
      ],
    );
  }

  void _showAddRuleDialog(BuildContext context, WidgetRef ref) {
    final conditionController = TextEditingController();
    final actionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Rule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: conditionController,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: actionController,
              decoration: const InputDecoration(
                labelText: 'Action',
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
              if (conditionController.text.isNotEmpty &&
                  actionController.text.isNotEmpty) {
                ref.read(instructionProvider.notifier).addRule(
                      InstructionRule(
                        id: 'rule_${DateTime.now().millisecondsSinceEpoch}',
                        condition: conditionController.text,
                        action: actionController.text,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddConstraintDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Constraint'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Constraint',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(instructionProvider.notifier)
                    .addConstraint(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddExampleDialog(BuildContext context, WidgetRef ref) {
    final inputController = TextEditingController();
    final outputController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Example'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: inputController,
              decoration: const InputDecoration(
                labelText: 'Input',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: outputController,
              decoration: const InputDecoration(
                labelText: 'Expected Output',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
              if (inputController.text.isNotEmpty &&
                  outputController.text.isNotEmpty) {
                ref.read(instructionProvider.notifier).addExample(
                      Example(
                        id: 'example_${DateTime.now().millisecondsSinceEpoch}',
                        input: inputController.text,
                        output: outputController.text,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// ========== REUSABLE WIDGETS ==========
class _PropertyCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _PropertyCard({
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
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
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

class _TextField extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const _TextField({
    required this.label,
    required this.value,
    this.maxLines = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
      ),
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              value < 1 ? value.toStringAsFixed(2) : value.toStringAsFixed(0),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SwitchField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _MemoryEntryCard extends StatelessWidget {
  final MemoryEntry entry;

  const _MemoryEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.note),
        title: Text(entry.content),
        subtitle: Text(
          '${entry.timestamp.toString().substring(0, 19)} • Priority: ${entry.priority}',
        ),
      ),
    );
  }
}

class _RuleCard extends ConsumerWidget {
  final InstructionRule rule;

  const _RuleCard({required this.rule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.rule,
          color: rule.enabled ? Colors.green : Colors.grey,
        ),
        title: Text('IF: ${rule.condition}'),
        subtitle: Text('THEN: ${rule.action}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: rule.enabled,
              onChanged: (v) {
                ref.read(instructionProvider.notifier).updateRule(
                      rule.id,
                      rule.copyWith(enabled: v),
                    );
              },