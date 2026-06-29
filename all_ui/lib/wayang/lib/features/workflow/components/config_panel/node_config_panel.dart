import 'package:flutter/material.dart';

import '../../service/secret_manager.dart';
import '../node/model/schema/node_template.dart';
import '../node/node_execution_registry.dart';

class NodeConfigurationPanel extends StatefulWidget {
  final NodeTemplate template;
  final Map<String, dynamic> currentConfig;
  final Function(Map<String, dynamic>) onConfigChanged;

  const NodeConfigurationPanel({
    super.key,
    required this.template,
    required this.currentConfig,
    required this.onConfigChanged,
  });

  @override
  State<NodeConfigurationPanel> createState() => _NodeConfigurationPanelState();
}

class _NodeConfigurationPanelState extends State<NodeConfigurationPanel> {
  late Map<String, dynamic> _config;
  final _secretManager = SecretManager();

  @override
  void initState() {
    super.initState();
    _config = Map.from(widget.currentConfig);
  }

  @override
  Widget build(BuildContext context) {
    final executor = NodeExecutorRegistry.getExecutor(widget.template.nodeType);
    if (executor == null) {
      return const Center(child: Text('No executor found', style: TextStyle()));
    }

    final schema = executor.getSchema();
    final requiredSecrets = executor.getRequiredSecrets();

    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // Header
          Row(
            children: [
              Icon(
                widget.template.icon,
                color: widget.template.color,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.template.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.template.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Required Secrets
          if (requiredSecrets.isNotEmpty) ...[
            const Text(
              'Required Secrets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...requiredSecrets.map((secret) => _buildSecretField(secret)),
            const SizedBox(height: 24),
          ],

          // Configuration Fields
          if (schema['config'] != null) ...[
            const Text(
              'Configuration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...(schema['config'] as List).map(
              (field) => _buildConfigField(field),
            ),
          ],

          // Input Schema
          const SizedBox(height: 24),
          const Text(
            'Inputs',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...(schema['inputs'] as List).map((input) => _buildSchemaItem(input)),

          // Output Schema
          const SizedBox(height: 24),
          const Text(
            'Outputs',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...(schema['outputs'] as List).map(
            (output) => _buildSchemaItem(output),
          ),
        ],
      ),
    );
  }

  Widget _buildSecretField(String secretKey) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        obscureText: true,
        style: const TextStyle(),
        decoration: InputDecoration(
          labelText: secretKey,
          labelStyle: const TextStyle(),
          filled: true,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          suffixIcon: _secretManager.hasSecret(secretKey)
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.warning, color: Colors.orange),
        ),
        onChanged: (value) {
          _secretManager.setSecret(secretKey, value);
        },
      ),
    );
  }

  Widget _buildConfigField(Map<String, dynamic> field) {
    final name = field['name'] as String;
    final type = field['type'] as String;

    if (type == 'select') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          initialValue: _config[name]?.toString(),
          decoration: InputDecoration(
            labelText: name,
            labelStyle: const TextStyle(),
            filled: true,
            fillColor: const Color(0xFF2D2D2D),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
          dropdownColor: const Color(0xFF2D2D2D),
          style: const TextStyle(),
          items: (field['options'] as List).map((option) {
            return DropdownMenuItem(
              value: option.toString(),
              child: Text(option.toString()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _config[name] = value;
              widget.onConfigChanged(_config);
            });
          },
        ),
      );
    } else if (type == 'number') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          keyboardType: TextInputType.number,
          controller: TextEditingController(
            text: _config[name]?.toString() ?? '',
          ),
          style: const TextStyle(),
          decoration: InputDecoration(
            labelText: name,
            labelStyle: const TextStyle(),
            filled: true,
            // fillColor: const Color(0xFF2D2D2D),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onChanged: (value) {
            final parsed = num.tryParse(value);
            if (parsed != null) {
              setState(() {
                _config[name] = parsed;
                widget.onConfigChanged(_config);
              });
            }
          },
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: TextEditingController(
            text: _config[name]?.toString() ?? '',
          ),
          style: const TextStyle(),
          maxLines: type == 'text' ? 3 : 1,
          decoration: InputDecoration(
            labelText: name,
            labelStyle: const TextStyle(),
            filled: true,

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onChanged: (value) {
            setState(() {
              _config[name] = value;
              widget.onConfigChanged(_config);
            });
          },
        ),
      );
    }
  }

  Widget _buildSchemaItem(Map<String, dynamic> item) {
    final name = item['name'] as String;
    final type = item['type'] as String;
    final required = item['required'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              type,
              style: const TextStyle(color: Colors.blue, fontSize: 11),
            ),
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
          if (required)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'required',
                style: TextStyle(color: Colors.red, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
