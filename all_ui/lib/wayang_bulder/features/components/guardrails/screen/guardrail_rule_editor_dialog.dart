import 'package:flutter/material.dart';

import '../model/guardrail_rule.dart';
import '../model/guardrail_type.dart';

class GuardrailRuleEditorDialog extends StatefulWidget {
  final GuardrailRule? existingRule;
  final Function(GuardrailRule) onSave;

  const GuardrailRuleEditorDialog({
    super.key,
    this.existingRule,
    required this.onSave,
  });

  @override
  State<GuardrailRuleEditorDialog> createState() =>
      _GuardrailRuleEditorDialogState();
}

class _GuardrailRuleEditorDialogState extends State<GuardrailRuleEditorDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late GuardrailType _type;
  late GuardrailSeverity _severity;
  late RuleAction _action;
  late double _threshold;
  late Map<String, dynamic> _config;

  @override
  void initState() {
    super.initState();

    if (widget.existingRule != null) {
      _nameController = TextEditingController(text: widget.existingRule!.name);
      _descriptionController = TextEditingController(
        text: widget.existingRule!.description,
      );
      _type = widget.existingRule!.type;
      _severity = widget.existingRule!.severity;
      _action = widget.existingRule!.action;
      _threshold = widget.existingRule!.threshold;
      _config = Map.from(widget.existingRule!.config);
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _type = GuardrailType.customKeywords;
      _severity = GuardrailSeverity.medium;
      _action = RuleAction.warn;
      _threshold = 0.7;
      _config = {};
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surface;
    return Dialog(
      backgroundColor: backgroundColor,
      child: Container(
        width: 600,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guardrail Rule Editor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Rule Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<GuardrailSeverity>(
                    value: _severity,
                    decoration: const InputDecoration(
                      labelText: 'Severity',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    items: GuardrailSeverity.values
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(_formatEnumName(s)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _severity = value!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<GuardrailType>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Rule Type',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    items: GuardrailType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_formatEnumName(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _type = value!;
                        // Reset config when type changes
                        _config = {};
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Threshold: ${(_threshold * 100).toInt()}%',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Slider(
                        value: _threshold,
                        onChanged: (value) =>
                            setState(() => _threshold = value),
                        activeColor: Colors.orange,
                      ),
                    ],
                  ),
                  // Inside ListView, after Threshold
                  const SizedBox(height: 16),
                  if (_type == GuardrailType.customKeywords ||
                      _type == GuardrailType.toxicityDetection ||
                      _type == GuardrailType.biasDetection ||
                      _type == GuardrailType.sensitiveTopics)
                    _buildKeywordConfig(),
                  if (_type == GuardrailType.customRegex) _buildRegexConfig(),
                  // Add more as needed
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) {
                      // Show snackbar or dialog error
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rule name is required')),
                      );
                      return;
                    }

                    widget.onSave(
                      GuardrailRule(
                        id:
                            widget.existingRule?.id ??
                            'rule_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        description: _descriptionController.text.trim(),
                        type: _type,
                        severity: _severity,
                        action: _action, // now RuleAction
                        threshold: _threshold,
                        config: _config,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeywordConfig() {
    final keywords = List<String>.from(
      (_config['keywords'] as List<dynamic>?)?.map((e) => e.toString()) ?? [],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keywords (one per line)',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          controller: TextEditingController(text: keywords.join('\n')),
          onChanged: (text) {
            final list = text
                .split('\n')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            setState(() {
              _config['keywords'] = list;
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Color(0xFF3A3A3A),
          ),
        ),
      ],
    );
  }

  Widget _buildRegexConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Regex Patterns (one per line)',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          controller: TextEditingController(
            text:
                (_config['patterns'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .join('\n') ??
                '',
          ),
          onChanged: (text) {
            final list = text
                .split('\n')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            setState(() {
              _config['patterns'] = list;
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Color(0xFF3A3A3A),
          ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text(
            'Case Sensitive',
            style: TextStyle(color: Colors.white),
          ),
          value: _config['case_sensitive'] as bool? ?? false,
          onChanged: (value) => setState(() {
            _config['case_sensitive'] = value;
          }),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  String _formatEnumName(Enum e) {
    return e.name.replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2').toUpperCase();
  }
}
