import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../schema/common/position.dart';
import '../schema/model/llm_config.dart';
import '../schema/node/node_type.dart';
import '../schema/workflow/workflow_node.dart';
import '../state/ui_provider.dart';
import '../state/workflow/workflow_provider.dart';

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(uiProvider);
    final workflowState = ref.watch(workflowProvider);

    if (uiState.selectedNodeForConfig == null) {
      return const Center(child: Text('Select a node to edit properties'));
    }

    final node = workflowState.currentWorkflow?.nodes.firstWhere(
      (n) => n.id == uiState.selectedNodeForConfig,
    );

    if (node == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Properties', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),

        // Basic properties
        _buildSection(context, 'Basic', [
          _buildTextField(
            label: 'Name',
            value: node.name,
            onChanged: (value) {
              ref
                  .read(workflowProvider.notifier)
                  .updateNode(node.copyWith(name: value));
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Description',
            value: node.description ?? '',
            maxLines: 3,
            onChanged: (value) {
              ref
                  .read(workflowProvider.notifier)
                  .updateNode(node.copyWith(description: value));
            },
          ),
        ]),

        const SizedBox(height: 16),

        // Node-specific configuration
        _buildNodeSpecificConfig(context, ref, node),

        const SizedBox(height: 16),

        // Position
        _buildSection(context, 'Position', [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'X',
                  value: node.position.x.toStringAsFixed(0),
                  onChanged: (value) {
                    final x = double.tryParse(value) ?? node.position.x;
                    ref
                        .read(workflowProvider.notifier)
                        .updateNode(
                          node.copyWith(
                            position: Position(x: x, y: node.position.y),
                          ),
                        );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  label: 'Y',
                  value: node.position.y.toStringAsFixed(0),
                  onChanged: (value) {
                    final y = double.tryParse(value) ?? node.position.y;
                    ref
                        .read(workflowProvider.notifier)
                        .updateNode(
                          node.copyWith(
                            position: Position(x: node.position.x, y: y),
                          ),
                        );
                  },
                ),
              ),
            ],
          ),
        ]),

        const SizedBox(height: 24),

        // Actions
        ElevatedButton.icon(
          onPressed: () {
            ref.read(workflowProvider.notifier).duplicateNode(node.id);
          },
          icon: const Icon(Icons.copy),
          label: const Text('Duplicate Node'),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(workflowProvider.notifier).deleteNode(node.id);
            ref.read(uiProvider.notifier).selectNodeForConfig(null);
          },
          icon: const Icon(Icons.delete),
          label: const Text('Delete Node'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }

  Widget _buildNodeSpecificConfig(
    BuildContext context,
    WidgetRef ref,
    WorkflowNode node,
  ) {
    switch (node.type) {
      case NodeType.llm:
        return _buildLLMConfig(context, ref, node);
      case NodeType.splitter:
        return _buildSplitterConfig(context, ref, node);
      case NodeType.aggregator:
        return _buildAggregatorConfig(context, ref, node);
      case NodeType.condition:
        return _buildConditionConfig(context, ref, node);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLLMConfig(
    BuildContext context,
    WidgetRef ref,
    WorkflowNode node,
  ) {
    return _buildSection(context, 'LLM Configuration', [
      DropdownButtonFormField<LLMProvider>(
        decoration: const InputDecoration(
          labelText: 'Provider',
          border: OutlineInputBorder(),
        ),
        value: node.config?.llmConfig?.provider,
        items: LLMProvider.values.map((provider) {
          return DropdownMenuItem(
            value: provider,
            child: Text(provider.name.toUpperCase()),
          );
        }).toList(),
        onChanged: (value) {
          // Update provider
        },
      ),
      const SizedBox(height: 12),
      _buildTextField(
        label: 'Prompt',
        value: node.config?.prompt ?? '',
        maxLines: 5,
        onChanged: (value) {
          // Update prompt
        },
      ),
    ]);
  }

  Widget _buildSplitterConfig(
    BuildContext context,
    WidgetRef ref,
    WorkflowNode node,
  ) {
    return _buildSection(context, 'Splitter Configuration', [
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Strategy',
          border: OutlineInputBorder(),
        ),
        value: node.config?.splitterConfig?.strategy,
        items: const [
          DropdownMenuItem(value: 'token', child: Text('Token')),
          DropdownMenuItem(value: 'line', child: Text('Line')),
          DropdownMenuItem(value: 'xpath', child: Text('XPath')),
          DropdownMenuItem(value: 'jsonpath', child: Text('JSONPath')),
        ],
        onChanged: (value) {
          // Update strategy
        },
      ),
    ]);
  }

  Widget _buildAggregatorConfig(
    BuildContext context,
    WidgetRef ref,
    WorkflowNode node,
  ) {
    return _buildSection(context, 'Aggregator Configuration', [
      _buildTextField(
        label: 'Completion Size',
        value: node.config?.aggregatorConfig?.completionSize?.toString() ?? '0',
        onChanged: (value) {
          // Update completion size
        },
      ),
      const SizedBox(height: 12),
      _buildTextField(
        label: 'Timeout (ms)',
        value:
            node.config?.aggregatorConfig?.completionTimeout?.toString() ?? '0',
        onChanged: (value) {
          // Update timeout
        },
      ),
    ]);
  }

  Widget _buildConditionConfig(
    BuildContext context,
    WidgetRef ref,
    WorkflowNode node,
  ) {
    return _buildSection(context, 'Condition Configuration', [
      _buildTextField(
        label: 'Expression',
        value: node.config?.condition?.expression ?? '',
        maxLines: 3,
        onChanged: (value) {
          // Update expression
        },
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Language',
          border: OutlineInputBorder(),
        ),
        value: node.config?.condition?.language,
        items: const [
          DropdownMenuItem(value: 'simple', child: Text('Simple')),
          DropdownMenuItem(value: 'jsonpath', child: Text('JSONPath')),
          DropdownMenuItem(value: 'xpath', child: Text('XPath')),
          DropdownMenuItem(value: 'javascript', child: Text('JavaScript')),
        ],
        onChanged: (value) {
          // Update language
        },
      ),
    ]);
  }
}
