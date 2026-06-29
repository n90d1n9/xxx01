import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

import '../model/action/action_definition.dart';
import '../model/action/http_request_action.dart';
import '../model/action/script_action.dart';
import '../model/action/template_action.dart';
import '../model/action/tranform_action.dart';
import '../model/action/workflow_action.dart';
import '../model/config_field_definition.dart';
import '../model/node_definition.dart';
import '../model/port_definition.dart';
import 'config_field_editor_dialog.dart';
import 'http_request_editor.dart';
import 'icon_picker_dialog.dart';
import 'port_editor_dialog.dart';
import 'script_action_editor.dart';
import 'template_action_editor.dart';
import 'tranform_action_editor.dart';
import 'workflow_action_editor.dart';

class NodeBuilderDialog extends ConsumerStatefulWidget {
  final NodeDefinition? existingNode;

  const NodeBuilderDialog({super.key, this.existingNode});

  @override
  ConsumerState<NodeBuilderDialog> createState() => _NodeBuilderDialogState();
}

class _NodeBuilderDialogState extends ConsumerState<NodeBuilderDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _typeController;
  IconData _selectedIcon = Icons.extension;
  Color _selectedColor = Colors.blue;
  List<PortDefinition> _inputs = [];
  List<PortDefinition> _outputs = [];
  List<ConfigFieldDefinition> _configFields = [];
  List<String> _requiredSecrets = [];
  late ActionDefinition _action;

  @override
  void initState() {
    super.initState();

    if (widget.existingNode != null) {
      _nameController = TextEditingController(text: widget.existingNode!.name);
      _descriptionController = TextEditingController(
        text: widget.existingNode!.description,
      );
      _typeController = TextEditingController(text: widget.existingNode!.type);
      _selectedIcon = widget.existingNode!.icon;
      _selectedColor = widget.existingNode!.color;
      _inputs = List.from(widget.existingNode!.inputs);
      _outputs = List.from(widget.existingNode!.outputs);
      _configFields = List.from(widget.existingNode!.configFields);
      _requiredSecrets = List.from(widget.existingNode!.requiredSecrets);
      _action = widget.existingNode!.action;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _typeController = TextEditingController();
      _action = HttpRequestAction(method: 'GET', urlTemplate: '');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2D2D2D),
      child: Container(
        width: 900,
        height: 700,
        child: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Node Builder',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: 'Basic'),
                  Tab(text: 'Ports'),
                  Tab(text: 'Config'),
                  Tab(text: 'Action'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildBasicTab(),
                    _buildPortsTab(),
                    _buildConfigTab(),
                    _buildActionTab(),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveNode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Save Node'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Node Name',
            labelStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description',
            labelStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _typeController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Node Type (unique identifier)',
            labelStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Icon', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _selectIcon(),
                    icon: Icon(_selectedIcon, color: Colors.white),
                    label: const Text(
                      'Choose Icon',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Color', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _selectColor(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _selectedColor,
                    ),
                    child: const Text('Choose Color'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPortsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            const Text(
              'Inputs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.blue),
              onPressed: () => _addPort(true),
            ),
          ],
        ),
        ..._inputs.map((port) => _buildPortCard(port, true)),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text(
              'Outputs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: () => _addPort(false),
            ),
          ],
        ),
        ..._outputs.map((port) => _buildPortCard(port, false)),
      ],
    );
  }

  Widget _buildPortCard(PortDefinition port, bool isInput) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isInput ? Colors.blue : Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(port.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          '${port.dataType} ${port.required ? "(required)" : ""}',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: () => _editPort(port, isInput),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _deletePort(port, isInput),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            const Text(
              'Configuration Fields',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.blue),
              onPressed: _addConfigField,
            ),
          ],
        ),
        ..._configFields.map(_buildConfigFieldCard),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text(
              'Required Secrets',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.orange),
              onPressed: _addSecret,
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: _requiredSecrets
              .map(
                (secret) => Chip(
                  label: Text(
                    secret,
                    style: const TextStyle(color: Colors.white),
                  ),
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                  onDeleted: () =>
                      setState(() => _requiredSecrets.remove(secret)),
                  backgroundColor: Colors.orange.withValues(alpha: 0.3),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildConfigFieldCard(ConfigFieldDefinition field) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(field.label, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          '${field.fieldType} ${field.required ? "(required)" : ""}',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: () => _editConfigField(field),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => setState(() => _configFields.remove(field)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Action Type',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionTypeChip('HTTP Request', 'http_request', Icons.http),
              _buildActionTypeChip('Transform', 'transform', Icons.transform),
              _buildActionTypeChip('Script', 'script', Icons.code),
              _buildActionTypeChip('Template', 'template', Icons.description),
              _buildActionTypeChip('Workflow', 'workflow', Icons.account_tree),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionEditor(),
        ],
      ),
    );
  }

  Widget _buildActionTypeChip(String label, String type, IconData icon) {
    final isSelected = _action.type == type;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.white54,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: Colors.blue,
      backgroundColor: const Color(0xFF1E1E1E),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white54),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _action = _createActionOfType(type);
          });
        }
      },
    );
  }

  Widget _buildActionEditor() {
    if (_action is HttpRequestAction) {
      return HttpRequestActionEditor(
        action: _action as HttpRequestAction,
        onChanged: (updated) => setState(() => _action = updated),
      );
    } else if (_action is TransformAction) {
      return TransformActionEditor(
        action: _action as TransformAction,
        onChanged: (updated) => setState(() => _action = updated),
      );
    } else if (_action is ScriptAction) {
      return ScriptActionEditor(
        action: _action as ScriptAction,
        onChanged: (updated) => setState(() => _action = updated),
      );
    } else if (_action is TemplateAction) {
      return TemplateActionEditor(
        action: _action as TemplateAction,
        onChanged: (updated) => setState(() => _action = updated),
      );
    } else if (_action is WorkflowAction) {
      return WorkflowActionEditor(
        action: _action as WorkflowAction,
        onChanged: (updated) => setState(() => _action = updated),
      );
    }
    return const SizedBox();
  }

  ActionDefinition _createActionOfType(String type) {
    switch (type) {
      case 'http_request':
        return HttpRequestAction(method: 'GET', urlTemplate: '');
      case 'transform':
        return TransformAction(rules: []);
      case 'script':
        return ScriptAction(language: 'javascript', code: '');
      case 'template':
        return TemplateAction(template: '');
      case 'workflow':
        return WorkflowAction(workflowId: '');
      default:
        return HttpRequestAction(method: 'GET', urlTemplate: '');
    }
  }

  void _selectIcon() {
    showDialog(
      context: context,
      builder: (context) => IconPickerDialog(
        onIconSelected: (icon) {
          setState(() => _selectedIcon = icon);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _selectColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Pick a Color',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _addPort(bool isInput) {
    showDialog(
      context: context,
      builder: (context) => PortEditorDialog(
        onSave: (port) {
          setState(() {
            if (isInput) {
              _inputs.add(port);
            } else {
              _outputs.add(port);
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editPort(PortDefinition port, bool isInput) {
    showDialog(
      context: context,
      builder: (context) => PortEditorDialog(
        existingPort: port,
        onSave: (updatedPort) {
          setState(() {
            final list = isInput ? _inputs : _outputs;
            final index = list.indexOf(port);
            list[index] = updatedPort;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deletePort(PortDefinition port, bool isInput) {
    setState(() {
      if (isInput) {
        _inputs.remove(port);
      } else {
        _outputs.remove(port);
      }
    });
  }

  void _addConfigField() {
    showDialog(
      context: context,
      builder: (context) => ConfigFieldEditorDialog(
        onSave: (field) {
          setState(() => _configFields.add(field));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editConfigField(ConfigFieldDefinition field) {
    showDialog(
      context: context,
      builder: (context) => ConfigFieldEditorDialog(
        existingField: field,
        onSave: (updatedField) {
          setState(() {
            final index = _configFields.indexOf(field);
            _configFields[index] = updatedField;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _addSecret() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text(
            'Add Required Secret',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'SECRET_NAME',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(
                    () => _requiredSecrets.add(controller.text.toUpperCase()),
                  );
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

  void _saveNode() {
    if (_nameController.text.isEmpty || _typeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and Type are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final node = NodeDefinition(
      id:
          widget.existingNode?.id ??
          'node_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      type: _typeController.text,
      description: _descriptionController.text,
      icon: _selectedIcon,
      color: _selectedColor,
      inputs: _inputs,
      outputs: _outputs,
      configFields: _configFields,
      requiredSecrets: _requiredSecrets,
      action: _action,
    );

    Navigator.pop(context, node);
  }
}
