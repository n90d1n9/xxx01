import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../plugin/model/config_field.dart';
import '../../workflow/model/workflow_node.dart';
import '../../workflow/components/node/model/schema/node_type_config.dart';
import '../../workflow/state/workflow_provider.dart';
import '../../components/fields/multi_field.dart';
import '../../components/fields/number_field.dart';
import '../../components/fields/select_field.dart';
import '../../components/fields/switch_field.dart';
import '../../components/fields/w_text_field.dart';

class PropertiesPanel extends ConsumerWidget {
  final Map<String, List<NodeConfig>> nodeTypes;
  const PropertiesPanel({super.key, required this.nodeTypes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflowState = ref.watch(workflowProvider);

    // Handle case where no node is selected
    if (workflowState.selectedNodeId == null) {
      return _buildNoSelectionPanel(context);
    }

    // Safely find the selected node
    final selectedNode = workflowState.nodes.cast<WorkflowNode?>().firstWhere(
      (n) => n?.id == workflowState.selectedNodeId,
      orElse: () => null,
    );

    // Handle case where selected node doesn't exist (e.g., after undo)
    if (selectedNode == null) {
      return _buildNoSelectionPanel(context);
    }

    final allNodes = nodeTypes.values.expand((list) => list).toList();
    final nodeConfig = allNodes.firstWhere(
      (t) => t.type == selectedNode.type,
      orElse: () =>
          throw StateError('Node type ${selectedNode.type} not found'),
    );

    return Container(
      width: 320,
      color: Theme.of(context).canvasColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide())),
            child: Row(
              children: [
                Icon(nodeConfig.icon, color: nodeConfig.style!.color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedNode.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        nodeConfig.description,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildConfigSection('General', [
                  WTextField(
                    label: 'Node Name',
                    value: selectedNode.label,
                    onChanged: (value) {
                      ref
                          .read(workflowProvider.notifier)
                          .updateNodeLabel(selectedNode.id, value);
                    },
                  ),
                  WTextField(
                    label: 'Node ID',
                    value: selectedNode.id,
                    onChanged: null,
                    readOnly: true,
                  ),
                ]),
                const SizedBox(height: 24),
                if (nodeConfig.configFields.isNotEmpty)
                  _buildConfigSection(
                    'Configuration',
                    nodeConfig.configFields.entries.map((entry) {
                      return _buildConfigFieldWidget(
                        selectedNode.id,
                        entry.value,
                        selectedNode.config[entry.key],
                        ref,
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSelectionPanel(BuildContext context) {
    return Container(
      width: 320,
      color: Theme.of(context).canvasColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide())),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No Node Selected',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.select_all, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Select a node to view properties',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildConfigFieldWidget(
    String nodeId,
    ConfigField field,
    dynamic value,
    WidgetRef ref,
  ) {
    // Use defaultValue if value is null
    final currentValue = value ?? field.defaultValue;

    switch (field.type) {
      case ConfigFieldType.text:
      case ConfigFieldType.password:
        return WTextField(
          label: field.label,
          value: currentValue?.toString() ?? '',
          onChanged: (newValue) {
            ref
                .read(workflowProvider.notifier)
                .updateNodeConfig(nodeId, field.key, newValue);
          },
          obscureText: field.type == ConfigFieldType.password,
          placeholder: field.placeholder,
          required: field.required,
        );
      case ConfigFieldType.number:
        return NumberField(
          label: field.label,
          value: currentValue ?? 0,
          onChanged: (newValue) {
            ref
                .read(workflowProvider.notifier)
                .updateNodeConfig(nodeId, field.key, newValue);
          },
          min: field.min,
          max: field.max,
          required: field.required,
        );
      case ConfigFieldType.boolean:
        return SwitchField(
          label: field.label,
          value: currentValue ?? false,
          onChanged: (newValue) {
            ref
                .read(workflowProvider.notifier)
                .updateNodeConfig(nodeId, field.key, newValue);
          },
        );
      case ConfigFieldType.select:
        return SelectField(
          label: field.label,
          value: currentValue?.toString() ?? '',
          options: field.options ?? [],
          onChanged: (newValue) {
            ref
                .read(workflowProvider.notifier)
                .updateNodeConfig(nodeId, field.key, newValue);
          },
          required: field.required,
        );
      case ConfigFieldType.multiline:
        return MultilineField(
          label: field.label,
          value: currentValue?.toString() ?? '',
          onChanged: (newValue) {
            ref
                .read(workflowProvider.notifier)
                .updateNodeConfig(nodeId, field.key, newValue);
          },
          placeholder: field.placeholder,
          required: field.required,
        );
      case ConfigFieldType.json:
        return _buildJsonField(field.label, currentValue?.toString() ?? '{}', (
          newValue,
        ) {
          ref
              .read(workflowProvider.notifier)
              .updateNodeConfig(nodeId, field.key, newValue);
        }, required: field.required);
      default:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Unsupported field type: ${field.type}',
            style: const TextStyle(color: Colors.red),
          ),
        );
    }
  }

  Widget _buildJsonField(
    String label,
    String value,
    void Function(String) onChanged, {
    bool required = false,
  }) {
    bool isValid = true;
    try {
      if (value.isNotEmpty) {
        jsonDecode(value);
      }
    } catch (e) {
      isValid = false;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              if (required)
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              const Spacer(),
              if (!isValid)
                const Text(
                  'Invalid JSON',
                  style: TextStyle(color: Colors.red, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: TextEditingController(text: value),
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            maxLines: 8,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: isValid ? Colors.white.withOpacity(0.1) : Colors.red,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: isValid ? Colors.white.withOpacity(0.1) : Colors.red,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: isValid ? Colors.blue : Colors.red,
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
