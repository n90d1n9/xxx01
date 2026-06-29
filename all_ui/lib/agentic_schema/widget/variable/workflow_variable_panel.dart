import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../schema/variable/variable_scope.dart';
import '../../state/workflow/workflow_provider.dart';
import 'add_variable_dialog.dart';

class WorkflowVariablesPanel extends ConsumerWidget {
  const WorkflowVariablesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflowState = ref.watch(workflowProvider);
    final workflow = workflowState.currentWorkflow;

    if (workflow == null) {
      return const Center(child: Text('No workflow loaded'));
    }

    final variables = workflow.variables ?? [];

    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder), //Icons.variable),
                const SizedBox(width: 8),
                const Text(
                  'Workflow Variables',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddVariableDialog(context, ref),
                ),
              ],
            ),
          ),

          // Variables list
          Expanded(
            child: variables.isEmpty
                ? const Center(child: Text('No variables defined'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: variables.length,
                    itemBuilder: (context, index) {
                      final variable = variables[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(_getVariableIcon(variable.type)),
                          title: Text(variable.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Type: ${variable.type.name}'),
                              if (variable.defaultValue != null)
                                Text('Default: ${variable.defaultValue}'),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                // Delete variable
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getVariableIcon(VariableType type) {
    switch (type) {
      case VariableType.string:
        return Icons.text_fields;
      case VariableType.number:
        return Icons.numbers;
      case VariableType.boolean:
        return Icons.toggle_on;
      case VariableType.array:
        return Icons.list;
      case VariableType.object:
        return Icons.data_object;
      default:
        return Icons.code;
    }
  }

  void _showAddVariableDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddVariableDialog(),
    );
  }
}
