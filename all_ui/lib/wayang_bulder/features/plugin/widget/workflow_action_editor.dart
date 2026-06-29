import 'package:flutter/material.dart';

import '../model/action/workflow_action.dart';

class WorkflowActionEditor extends StatefulWidget {
  final WorkflowAction action;
  final Function(WorkflowAction) onChanged;

  const WorkflowActionEditor({
    super.key,
    required this.action,
    required this.onChanged,
  });

  @override
  State<WorkflowActionEditor> createState() => _WorkflowActionEditorState();
}

class _WorkflowActionEditorState extends State<WorkflowActionEditor> {
  late TextEditingController _workflowIdController;
  late Map<String, String> _inputMapping;
  late Map<String, String> _outputMapping;

  @override
  void initState() {
    super.initState();
    _workflowIdController = TextEditingController(
      text: widget.action.workflowId,
    );
    _inputMapping = Map.from(widget.action.inputMapping);
    _outputMapping = Map.from(widget.action.outputMapping);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _workflowIdController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Workflow ID',
            labelStyle: TextStyle(color: Colors.white70),
            hintText: 'workflow-uuid',
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _updateAction(),
        ),
        const SizedBox(height: 24),
        const Text(
          'Input Mapping',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ..._inputMapping.entries.map(
          (e) => _buildMappingRow(e.key, e.value, true),
        ),
        TextButton.icon(
          onPressed: () => _addMapping(true),
          icon: const Icon(Icons.add),
          label: const Text('Add Input Mapping'),
        ),
        const SizedBox(height: 24),
        const Text(
          'Output Mapping',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ..._outputMapping.entries.map(
          (e) => _buildMappingRow(e.key, e.value, false),
        ),
        TextButton.icon(
          onPressed: () => _addMapping(false),
          icon: const Icon(Icons.add),
          label: const Text('Add Output Mapping'),
        ),
      ],
    );
  }

  Widget _buildMappingRow(String key, String value, bool isInput) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$key → $value',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: () {
              setState(() {
                if (isInput) {
                  _inputMapping.remove(key);
                } else {
                  _outputMapping.remove(key);
                }
              });
              _updateAction();
            },
          ),
        ],
      ),
    );
  }

  void _addMapping(bool isInput) {
    showDialog(
      context: context,
      builder: (context) {
        final keyController = TextEditingController();
        final valueController = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: Text(
            'Add ${isInput ? "Input" : "Output"} Mapping',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: isInput ? 'Workflow Input Key' : 'Node Output Key',
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: valueController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: isInput ? 'Node Input Key' : 'Workflow Output Key',
                  labelStyle: const TextStyle(color: Colors.white70),
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
                if (keyController.text.isNotEmpty &&
                    valueController.text.isNotEmpty) {
                  setState(() {
                    if (isInput) {
                      _inputMapping[keyController.text] = valueController.text;
                    } else {
                      _outputMapping[keyController.text] = valueController.text;
                    }
                  });
                  _updateAction();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _updateAction() {
    widget.onChanged(
      WorkflowAction(
        workflowId: _workflowIdController.text,
        inputMapping: _inputMapping,
        outputMapping: _outputMapping,
      ),
    );
  }
}
