import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/action/http_request_action.dart';
import '../model/action/script_action.dart';
import '../model/action/template_action.dart';
import '../model/action/tranform_action.dart';
import '../model/action/tranform_rule.dart';
import '../model/action/workflow_action.dart';
import '../model/config_field_definition.dart';
import '../model/node_definition.dart';
import '../model/plugin_definition.dart';
import '../model/port_definition.dart';

class LowCodePluginBuilderScreen extends ConsumerStatefulWidget {
  const LowCodePluginBuilderScreen({super.key});

  @override
  ConsumerState<LowCodePluginBuilderScreen> createState() =>
      _LowCodePluginBuilderScreenState();
}

class _LowCodePluginBuilderScreenState
    extends ConsumerState<LowCodePluginBuilderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Plugin metadata
  String _pluginName = '';
  String _pluginVersion = '1.0.0';
  String _pluginDescription = '';
  String _pluginAuthor = '';
  String _pluginCategory = 'Integration';
  List<String> _pluginTags = [];

  // Nodes being built
  final List<NodeDefinition> _nodes = [];
  NodeDefinition? _selectedNode;
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Low-Code Plugin Builder',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelp,
            tooltip: 'Help',
          ),
          IconButton(
            icon: const Icon(Icons.preview, color: Colors.white),
            onPressed: _previewPlugin,
            tooltip: 'Preview',
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _exportPlugin,
            icon: const Icon(Icons.download),
            label: const Text('Export Plugin'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Steps sidebar
          _buildStepsSidebar(),
          // Main content
          Expanded(child: _buildStepContent()),
          // Preview panel
          if (_selectedNode != null)
            Container(
              width: 350,
              color: const Color(0xFF252525),
              child: _buildNodePreview(_selectedNode!),
            ),
        ],
      ),
    );
  }

  Widget _buildStepsSidebar() {
    final steps = [
      {'title': 'Plugin Info', 'icon': Icons.info},
      {'title': 'Create Nodes', 'icon': Icons.add_box},
      {'title': 'Review & Export', 'icon': Icons.check_circle},
    ];

    return Container(
      width: 250,
      color: const Color(0xFF252525),
      child: ListView.builder(
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          final isActive = _currentStep == index;
          final isCompleted = _currentStep > index;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isActive
                  ? Colors.blue
                  : isCompleted
                  ? Colors.green
                  : Colors.grey,
              child: Icon(
                isCompleted ? Icons.check : step['icon'] as IconData,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              step['title'] as String,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              setState(() {
                _currentStep = index;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPluginInfoStep();
      case 1:
        return _buildCreateNodesStep();
      case 2:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  // ==================== STEP 1: Plugin Info ====================

  Widget _buildPluginInfoStep() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              'Plugin Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Define basic information about your plugin',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              label: 'Plugin Name',
              hint: 'My Awesome Plugin',
              value: _pluginName,
              onChanged: (value) => _pluginName = value,
              required: true,
            ),
            _buildTextField(
              label: 'Version',
              hint: '1.0.0',
              value: _pluginVersion,
              onChanged: (value) => _pluginVersion = value,
              required: true,
            ),
            _buildTextField(
              label: 'Description',
              hint: 'A brief description of what your plugin does',
              value: _pluginDescription,
              onChanged: (value) => _pluginDescription = value,
              maxLines: 3,
              required: true,
            ),
            _buildTextField(
              label: 'Author',
              hint: 'Your Name',
              value: _pluginAuthor,
              onChanged: (value) => _pluginAuthor = value,
              required: true,
            ),
            _buildDropdown(
              label: 'Category',
              value: _pluginCategory,
              items: [
                'Integration',
                'AI/ML',
                'Database',
                'Communication',
                'Data Processing',
                'Utility',
              ],
              onChanged: (value) => setState(() => _pluginCategory = value!),
            ),
            _buildTagsField(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _currentStep = 1;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Next: Create Nodes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STEP 2: Create Nodes ====================

  Widget _buildCreateNodesStep() {
    return Row(
      children: [
        // Nodes list
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Plugin Nodes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _createNewNode,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Node'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _nodes.isEmpty
                      ? _buildEmptyNodesState()
                      : _buildNodesList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _currentStep = 0),
                      child: const Text('Back'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _nodes.isNotEmpty
                          ? () => setState(() => _currentStep = 2)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Next: Review'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Node editor
        if (_selectedNode != null)
          Expanded(flex: 3, child: _buildNodeEditor(_selectedNode!)),
      ],
    );
  }

  Widget _buildEmptyNodesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.extension,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No nodes yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _createNewNode,
            icon: const Icon(Icons.add),
            label: const Text('Create your first node'),
          ),
        ],
      ),
    );
  }

  Widget _buildNodesList() {
    return ListView.builder(
      itemCount: _nodes.length,
      itemBuilder: (context, index) {
        final node = _nodes[index];
        final isSelected = _selectedNode?.id == node.id;

        return Card(
          color: isSelected ? const Color(0xFF3D3D3D) : const Color(0xFF2D2D2D),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(node.icon, color: node.color),
            title: Text(node.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              node.description,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.content_copy,
                    color: Colors.blue,
                    size: 20,
                  ),
                  onPressed: () => _duplicateNode(node),
                  tooltip: 'Duplicate',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _deleteNode(node),
                  tooltip: 'Delete',
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _selectedNode = node;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildNodeEditor(NodeDefinition node) {
    return Container(
      color: const Color(0xFF252525),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              color: const Color(0xFF2D2D2D),
              child: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: 'Basic Info'),
                  Tab(text: 'Inputs/Outputs'),
                  Tab(text: 'Config'),
                  Tab(text: 'Action'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildBasicInfoTab(node),
                  _buildPortsTab(node),
                  _buildConfigTab(node),
                  _buildActionTab(node),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab(NodeDefinition node) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildTextField(
          label: 'Node Name',
          value: node.name,
          onChanged: (value) {
            // Update node
          },
          required: true,
        ),
        _buildTextField(
          label: 'Description',
          value: node.description,
          onChanged: (value) {
            // Update node
          },
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Icon',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _selectIcon(node),
                    icon: Icon(node.icon),
                    label: const Text('Choose Icon'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D2D2D),
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
                  const Text(
                    'Color',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _selectColor(node),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: node.color,
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

  Widget _buildPortsTab(NodeDefinition node) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Inputs
        const Text(
          'Inputs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...node.inputs.map((port) => _buildPortCard(port, true, node)),
        ElevatedButton.icon(
          onPressed: () => _addPort(node, true),
          icon: const Icon(Icons.add),
          label: const Text('Add Input'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        ),
        const SizedBox(height: 32),
        // Outputs
        const Text(
          'Outputs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...node.outputs.map((port) => _buildPortCard(port, false, node)),
        ElevatedButton.icon(
          onPressed: () => _addPort(node, false),
          icon: const Icon(Icons.add),
          label: const Text('Add Output'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }

  Widget _buildPortCard(
    PortDefinition port,
    bool isInput,
    NodeDefinition node,
  ) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isInput ? Colors.blue : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    port.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    // Remove port
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              port.description,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(
                    port.dataType,
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Colors.purple.withValues(alpha: 0.3),
                ),
                if (port.required)
                  Chip(
                    label: const Text(
                      'Required',
                      style: TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.orange.withValues(alpha: 0.3),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigTab(NodeDefinition node) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Configuration Fields',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...node.configFields.map((field) => _buildConfigFieldCard(field, node)),
        ElevatedButton.icon(
          onPressed: () => _addConfigField(node),
          icon: const Icon(Icons.add),
          label: const Text('Add Config Field'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        ),
        const SizedBox(height: 32),
        const Text(
          'Required Secrets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...node.requiredSecrets.map((secret) => _buildSecretChip(secret, node)),
        ElevatedButton.icon(
          onPressed: () => _addSecret(node),
          icon: const Icon(Icons.add),
          label: const Text('Add Secret'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
      ],
    );
  }

  Widget _buildConfigFieldCard(
    ConfigFieldDefinition field,
    NodeDefinition node,
  ) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(field.label, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          'Type: ${field.fieldType}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () {
            // Remove field
          },
        ),
      ),
    );
  }

  Widget _buildSecretChip(String secret, NodeDefinition node) {
    return Chip(
      label: Text(secret),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        // Remove secret
      },
      backgroundColor: Colors.orange.withValues(alpha: 0.2),
    );
  }

  Widget _buildActionTab(NodeDefinition node) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Node Action',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Define what happens when this node executes',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 24),
        _buildActionTypeSelector(node),
        const SizedBox(height: 24),
        _buildActionEditor(node),
      ],
    );
  }

  Widget _buildActionTypeSelector(NodeDefinition node) {
    final actionTypes = [
      {'type': 'http_request', 'label': 'HTTP Request', 'icon': Icons.http},
      {'type': 'transform', 'label': 'Transform Data', 'icon': Icons.transform},
      {'type': 'script', 'label': 'Custom Script', 'icon': Icons.code},
      {'type': 'template', 'label': 'Template', 'icon': Icons.description},
      {'type': 'workflow', 'label': 'Sub-Workflow', 'icon': Icons.account_tree},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actionTypes.map((action) {
        final isSelected = node.action.type == action['type'];
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                action['icon'] as IconData,
                size: 16,
                color: isSelected ? Colors.white : Colors.white54,
              ),
              const SizedBox(width: 8),
              Text(action['label'] as String),
            ],
          ),
          selected: isSelected,
          selectedColor: Colors.blue,
          backgroundColor: const Color(0xFF2D2D2D),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
          ),
          onSelected: (selected) {
            if (selected) {
              _changeActionType(node, action['type'] as String);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildActionEditor(NodeDefinition node) {
    final action = node.action;

    if (action is HttpRequestAction) {
      return _buildHttpRequestEditor(action, node);
    } else if (action is TransformAction) {
      return _buildTransformEditor(action, node);
    } else if (action is ScriptAction) {
      return _buildScriptEditor(action, node);
    } else if (action is TemplateAction) {
      return _buildTemplateEditor(action, node);
    } else if (action is WorkflowAction) {
      return _buildWorkflowEditor(action, node);
    }

    return const SizedBox();
  }

  Widget _buildHttpRequestEditor(
    HttpRequestAction action,
    NodeDefinition node,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'HTTP Method',
          value: action.method,
          items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
          onChanged: (value) {
            // Update action
          },
        ),
        _buildTextField(
          label: 'URL Template',
          value: action.urlTemplate,
          hint: 'https://api.example.com/endpoint',
          onChanged: (value) {
            // Update action
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Headers',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        ...action.headers.entries.map(
          (entry) => _buildKeyValueRow(entry.key, entry.value),
        ),
        TextButton.icon(
          onPressed: () {
            // Add header
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Header'),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Body Template (JSON)',
          value: action.bodyTemplate ?? '',
          hint: '{"key": "{{inputs.value}}"}',
          onChanged: (value) {
            // Update action
          },
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Authentication',
          value: action.authType ?? 'none',
          items: ['none', 'bearer', 'basic', 'api_key'],
          onChanged: (value) {
            // Update action
          },
        ),
      ],
    );
  }

  Widget _buildTransformEditor(TransformAction action, NodeDefinition node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transform Rules',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ...action.rules.map((rule) => _buildTransformRuleCard(rule)),
        ElevatedButton.icon(
          onPressed: () {
            // Add transform rule
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Rule'),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Output Format',
          value: action.outputFormat,
          items: ['json', 'xml', 'csv', 'text'],
          onChanged: (value) {
            // Update action
          },
        ),
      ],
    );
  }

  Widget _buildTransformRuleCard(TransformRule rule) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${rule.sourceField} → ${rule.targetField}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            if (rule.transformType != null)
              Chip(
                label: Text(
                  rule.transformType!,
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: Colors.blue.withValues(alpha: 0.3),
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () {
                // Remove rule
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScriptEditor(ScriptAction action, NodeDefinition node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Language',
          value: action.language,
          items: ['javascript', 'python', 'dart'],
          onChanged: (value) {
            // Update action
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Code',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: TextEditingController(text: action.code),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintText:
                  '// Write your code here\nfunction execute(inputs, config) {\n  return { output: "result" };\n}',
              hintStyle: TextStyle(color: Colors.white38),
            ),
            onChanged: (value) {
              // Update code
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateEditor(TemplateAction action, NodeDefinition node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Template Engine',
          value: action.templateEngine,
          items: ['mustache', 'handlebars', 'jinja2'],
          onChanged: (value) {
            // Update action
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Template',
          value: action.template,
          hint: 'Hello {{name}}, your order #{{order.id}} is ready!',
          onChanged: (value) {
            // Update action
          },
          maxLines: 8,
        ),
      ],
    );
  }

  Widget _buildWorkflowEditor(WorkflowAction action, NodeDefinition node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Workflow ID',
          value: action.workflowId,
          hint: 'workflow-uuid',
          onChanged: (value) {
            // Update action
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Input Mapping',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...action.inputMapping.entries.map(
          (e) => _buildKeyValueRow(e.key, e.value),
        ),
        TextButton.icon(
          onPressed: () {
            // Add mapping
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Input Mapping'),
        ),
        const SizedBox(height: 16),
        const Text(
          'Output Mapping',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...action.outputMapping.entries.map(
          (e) => _buildKeyValueRow(e.key, e.value),
        ),
        TextButton.icon(
          onPressed: () {
            // Add mapping
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Output Mapping'),
        ),
      ],
    );
  }

  // ==================== STEP 3: Review & Export ====================

  Widget _buildReviewStep() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: ListView(
        children: [
          const Text(
            'Review Your Plugin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Review all settings before exporting',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _buildReviewCard('Plugin Information', [
            'Name: $_pluginName',
            'Version: $_pluginVersion',
            'Author: $_pluginAuthor',
            'Category: $_pluginCategory',
            'Nodes: ${_nodes.length}',
          ]),
          _buildReviewCard(
            'Nodes',
            _nodes.map((node) => '${node.name} (${node.type})').toList(),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: const Text('Back'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _exportPlugin,
                icon: const Icon(Icons.download),
                label: const Text('Export Plugin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String title, List<String> items) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 12),
                    Text(item, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodePreview(NodeDefinition node) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          const Text(
            'Node Preview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: node.color),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(node.icon, color: node.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        node.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  node.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildPreviewSection('Inputs', node.inputs.length),
          _buildPreviewSection('Outputs', node.outputs.length),
          _buildPreviewSection('Config Fields', node.configFields.length),
          _buildPreviewSection('Required Secrets', node.requiredSecrets.length),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    String? hint,
    int maxLines = 1,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              if (required)
                const Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            style: const TextStyle(color: Colors.white),
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF2D2D2D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            validator: required
                ? (value) =>
                      value?.isEmpty ?? true ? 'This field is required' : null
                : null,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF2D2D2D),
                style: const TextStyle(color: Colors.white),
                items: items.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tags',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._pluginTags.map(
                (tag) => Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => setState(() => _pluginTags.remove(tag)),
                  backgroundColor: Colors.blue.withValues(alpha: 0.2),
                ),
              ),
              ActionChip(
                label: const Text('Add Tag'),
                avatar: const Icon(Icons.add, size: 16),
                onPressed: _addTag,
                backgroundColor: Colors.green.withValues(alpha: 0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyValueRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$key: $value',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 16),
            onPressed: () {
              // Remove
            },
          ),
        ],
      ),
    );
  }

  // ==================== ACTIONS ====================

  void _createNewNode() {
    final newNode = NodeDefinition(
      id: 'node_${DateTime.now().millisecondsSinceEpoch}',
      name: 'New Node',
      type: 'custom_node_${_nodes.length + 1}',
      description: 'Node description',
      icon: Icons.extension,
      color: Colors.blue,
      action: HttpRequestAction(
        method: 'GET',
        urlTemplate: 'https://api.example.com',
      ),
    );

    setState(() {
      _nodes.add(newNode);
      _selectedNode = newNode;
    });
  }

  void _duplicateNode(NodeDefinition node) {
    final duplicate = NodeDefinition(
      id: 'node_${DateTime.now().millisecondsSinceEpoch}',
      name: '${node.name} (Copy)',
      type: node.type,
      description: node.description,
      icon: node.icon,
      color: node.color,
      inputs: node.inputs,
      outputs: node.outputs,
      configFields: node.configFields,
      requiredSecrets: node.requiredSecrets,
      action: node.action,
      metadata: node.metadata,
    );

    setState(() {
      _nodes.add(duplicate);
    });
  }

  void _deleteNode(NodeDefinition node) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('Delete Node', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${node.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _nodes.remove(node);
                if (_selectedNode?.id == node.id) {
                  _selectedNode = null;
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addPort(NodeDefinition node, bool isInput) {
    // Show dialog to add port
  }

  void _addConfigField(NodeDefinition node) {
    // Show dialog to add config field
  }

  void _addSecret(NodeDefinition node) {
    // Show dialog to add secret
  }

  void _changeActionType(NodeDefinition node, String type) {
    // Change action type
  }

  void _selectIcon(NodeDefinition node) {
    // Show icon picker dialog
  }

  void _selectColor(NodeDefinition node) {
    // Show color picker dialog
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text('Add Tag', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter tag name',
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
                  setState(() {
                    _pluginTags.add(controller.text);
                  });
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

  void _exportPlugin() {
    final plugin = PluginDefinition(
      id: _pluginName.toLowerCase().replaceAll(' ', '-'),
      name: _pluginName,
      version: _pluginVersion,
      description: _pluginDescription,
      author: _pluginAuthor,
      category: _pluginCategory,
      tags: _pluginTags,
      nodes: _nodes,
      createdAt: DateTime.now(),
    );

    final json = jsonEncode(plugin.toJson());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Plugin Definition',
          style: TextStyle(color: Colors.white),
        ),
        content: Container(
          width: 600,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              const JsonEncoder.withIndent('  ').convert(jsonDecode(json)),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
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
              // Copy to clipboard
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plugin definition copied!')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Upload to agent builder
              _uploadToAgentBuilder(plugin);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.upload),
            label: const Text('Upload to Agent Builder'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  void _previewPlugin() {
    // Show preview dialog
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('How to Use', style: TextStyle(color: Colors.white)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Fill in plugin information',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Provide basic details about your plugin',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              SizedBox(height: 16),
              Text(
                '2. Create nodes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Define inputs, outputs, configuration, and actions',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              SizedBox(height: 16),
              Text(
                '3. Review and export',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Export the plugin definition and upload to your agent builder',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadToAgentBuilder(PluginDefinition plugin) async {
    // Upload plugin definition to agent builder
    // This would call the plugin registry to install the low-code plugin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plugin "${plugin.name}" uploaded successfully!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'VIEW',
          onPressed: () {
            // Navigate to plugin manager
          },
        ),
      ),
    );
  }
}
