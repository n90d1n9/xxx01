import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Models
class AgentOrchestrator {
  final String id;
  final String name;
  final String description;
  final OrchestratorType type;
  final int maxAgents;
  final double timeout;
  final ExecutionStrategy strategy;
  final List<AgentConfig> agents;
  final Map<String, dynamic> metadata;

  AgentOrchestrator({
    required this.id,
    required this.name,
    this.description = '',
    required this.type,
    this.maxAgents = 5,
    this.timeout = 30.0,
    required this.strategy,
    this.agents = const [],
    this.metadata = const {},
  });

  AgentOrchestrator copyWith({
    String? name,
    String? description,
    OrchestratorType? type,
    int? maxAgents,
    double? timeout,
    ExecutionStrategy? strategy,
    List<AgentConfig>? agents,
    Map<String, dynamic>? metadata,
  }) {
    return AgentOrchestrator(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      maxAgents: maxAgents ?? this.maxAgents,
      timeout: timeout ?? this.timeout,
      strategy: strategy ?? this.strategy,
      agents: agents ?? this.agents,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum OrchestratorType { sequential, parallel, hierarchical, dynamic }

enum ExecutionStrategy { roundRobin, priority, loadBalanced, adaptive }

class AgentConfig {
  final String id;
  final String name;
  final bool enabled;
  final int priority;

  AgentConfig({
    required this.id,
    required this.name,
    this.enabled = true,
    this.priority = 1,
  });

  AgentConfig copyWith({String? name, bool? enabled, int? priority}) {
    return AgentConfig(
      id: id,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
    );
  }
}

// State Management
class OrchestratorNotifier extends StateNotifier<AgentOrchestrator> {
  OrchestratorNotifier(AgentOrchestrator orchestrator) : super(orchestrator);

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateType(OrchestratorType type) {
    state = state.copyWith(type: type);
  }

  void updateMaxAgents(int maxAgents) {
    state = state.copyWith(maxAgents: maxAgents);
  }

  void updateTimeout(double timeout) {
    state = state.copyWith(timeout: timeout);
  }

  void updateStrategy(ExecutionStrategy strategy) {
    state = state.copyWith(strategy: strategy);
  }

  void addAgent(AgentConfig agent) {
    state = state.copyWith(agents: [...state.agents, agent]);
  }

  void removeAgent(String agentId) {
    state = state.copyWith(
      agents: state.agents.where((a) => a.id != agentId).toList(),
    );
  }

  void updateAgent(String agentId, AgentConfig updatedAgent) {
    state = state.copyWith(
      agents: state.agents
          .map((a) => a.id == agentId ? updatedAgent : a)
          .toList(),
    );
  }

  void updateMetadata(String key, dynamic value) {
    final newMetadata = Map<String, dynamic>.from(state.metadata);
    newMetadata[key] = value;
    state = state.copyWith(metadata: newMetadata);
  }
}

// Providers
final orchestratorProvider =
    StateNotifierProvider<OrchestratorNotifier, AgentOrchestrator>((ref) {
      return OrchestratorNotifier(
        AgentOrchestrator(
          id: 'orchestrator_1',
          name: 'Main Orchestrator',
          description: 'Primary agent orchestration system',
          type: OrchestratorType.sequential,
          strategy: ExecutionStrategy.roundRobin,
          agents: [
            AgentConfig(id: 'agent_1', name: 'Data Processor', priority: 1),
            AgentConfig(id: 'agent_2', name: 'Analyzer', priority: 2),
          ],
        ),
      );
    });

// UI Components
class AgentOrchestratorPropertyEditor extends ConsumerWidget {
  const AgentOrchestratorPropertyEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orchestrator = ref.watch(orchestratorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Orchestrator Properties'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBasicPropertiesSection(context, ref, orchestrator),
          const SizedBox(height: 24),
          _buildConfigurationSection(context, ref, orchestrator),
          const SizedBox(height: 24),
          _buildAgentsSection(context, ref, orchestrator),
        ],
      ),
    );
  }

  Widget _buildBasicPropertiesSection(
    BuildContext context,
    WidgetRef ref,
    AgentOrchestrator orchestrator,
  ) {
    return _PropertySection(
      title: 'Basic Properties',
      icon: Icons.info_outline,
      children: [
        _PropertyTextField(
          label: 'Name',
          value: orchestrator.name,
          onChanged: (value) =>
              ref.read(orchestratorProvider.notifier).updateName(value),
        ),
        const SizedBox(height: 16),
        _PropertyTextField(
          label: 'Description',
          value: orchestrator.description,
          maxLines: 3,
          onChanged: (value) =>
              ref.read(orchestratorProvider.notifier).updateDescription(value),
        ),
      ],
    );
  }

  Widget _buildConfigurationSection(
    BuildContext context,
    WidgetRef ref,
    AgentOrchestrator orchestrator,
  ) {
    return _PropertySection(
      title: 'Configuration',
      icon: Icons.settings_outlined,
      children: [
        _PropertyDropdown<OrchestratorType>(
          label: 'Orchestrator Type',
          value: orchestrator.type,
          items: OrchestratorType.values,
          itemLabel: (type) => type.name.toUpperCase(),
          onChanged: (value) =>
              ref.read(orchestratorProvider.notifier).updateType(value!),
        ),
        const SizedBox(height: 16),
        _PropertyDropdown<ExecutionStrategy>(
          label: 'Execution Strategy',
          value: orchestrator.strategy,
          items: ExecutionStrategy.values,
          itemLabel: (strategy) => strategy.name
              .replaceAllMapped(
                RegExp(r'([A-Z])'),
                (match) => ' ${match.group(0)}',
              )
              .trim()
              .toUpperCase(),
          onChanged: (value) =>
              ref.read(orchestratorProvider.notifier).updateStrategy(value!),
        ),
        const SizedBox(height: 16),
        _PropertySlider(
          label: 'Max Agents',
          value: orchestrator.maxAgents.toDouble(),
          min: 1,
          max: 20,
          divisions: 19,
          onChanged: (value) => ref
              .read(orchestratorProvider.notifier)
              .updateMaxAgents(value.toInt()),
        ),
        const SizedBox(height: 16),
        _PropertySlider(
          label: 'Timeout (seconds)',
          value: orchestrator.timeout,
          min: 5,
          max: 120,
          divisions: 23,
          onChanged: (value) =>
              ref.read(orchestratorProvider.notifier).updateTimeout(value),
        ),
      ],
    );
  }

  Widget _buildAgentsSection(
    BuildContext context,
    WidgetRef ref,
    AgentOrchestrator orchestrator,
  ) {
    return _PropertySection(
      title: 'Agents',
      icon: Icons.smart_toy_outlined,
      children: [
        ...orchestrator.agents.map(
          (agent) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AgentCard(agent: agent),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showAddAgentDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Agent'),
        ),
      ],
    );
  }

  void _showAddAgentDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Agent'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Agent Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref
                    .read(orchestratorProvider.notifier)
                    .addAgent(
                      AgentConfig(
                        id: 'agent_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text,
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

class _PropertyTextField extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const _PropertyTextField({
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

class _PropertyDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _PropertyDropdown({
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
        return DropdownMenuItem<T>(value: item, child: Text(itemLabel(item)));
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _PropertySlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _PropertySlider({
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
              value.toStringAsFixed(0),
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

class _AgentCard extends ConsumerWidget {
  final AgentConfig agent;

  const _AgentCard({required this.agent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: ListTile(
        leading: Icon(
          Icons.smart_toy,
          color: agent.enabled ? Colors.green : Colors.grey,
        ),
        title: Text(agent.name),
        subtitle: Text('Priority: ${agent.priority}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: agent.enabled,
              onChanged: (value) {
                ref
                    .read(orchestratorProvider.notifier)
                    .updateAgent(agent.id, agent.copyWith(enabled: value));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                ref.read(orchestratorProvider.notifier).removeAgent(agent.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Main App
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agent Orchestrator Editor',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AgentOrchestratorPropertyEditor(),
    );
  }
}
