import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/guardrail_node_definition.dart';
import '../model/guardrail_rule.dart';
import '../model/guardrail_type.dart';
import 'guardrail_rule_editor_dialog.dart';
import 'guardrail_test_dialog.dart';

class GuardrailEditorScreen extends ConsumerStatefulWidget {
  final GuardrailNodeDefinition? existingDefinition;

  const GuardrailEditorScreen({super.key, this.existingDefinition});

  @override
  ConsumerState<GuardrailEditorScreen> createState() =>
      _GuardrailEditorScreenState();
}

class _GuardrailEditorScreenState extends ConsumerState<GuardrailEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  List<GuardrailRule> _rules = [];
  bool _stopOnFirstViolation = false;
  bool _returnViolations = true;

  @override
  void initState() {
    super.initState();

    if (widget.existingDefinition != null) {
      _nameController = TextEditingController(
        text: widget.existingDefinition!.name,
      );
      _descriptionController = TextEditingController(
        text: widget.existingDefinition!.description,
      );
      _rules = List.from(widget.existingDefinition!.rules);
      _stopOnFirstViolation = widget.existingDefinition!.stopOnFirstViolation;
      _returnViolations = widget.existingDefinition!.returnViolations;
    } else {
      _nameController = TextEditingController(text: 'Guardrail Check');
      _descriptionController = TextEditingController(
        text: 'Monitor and filter inputs/outputs',
      );
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
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: Row(
          children: [
            const Icon(Icons.shield, color: Colors.orange),
            const SizedBox(width: 12),
            const Text(
              'Guardrail Editor',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelp,
            tooltip: 'Help',
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _testGuardrails,
            icon: const Icon(Icons.bug_report),
            label: const Text('Test'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _saveGuardrail,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildBasicInfo(),
                const SizedBox(height: 32),
                _buildOptions(),
                const SizedBox(height: 32),
                _buildRulesSection(),
              ],
            ),
          ),
          _buildRuleTemplates(),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
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
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Stop on First Violation', style: TextStyle()),
              subtitle: const Text(
                'Stop checking after the first violation is found',
                style: TextStyle(fontSize: 12),
              ),
              value: _stopOnFirstViolation,
              onChanged: (value) =>
                  setState(() => _stopOnFirstViolation = value),
              activeColor: Colors.orange,
            ),
            SwitchListTile(
              title: const Text('Return Violations', style: TextStyle()),
              subtitle: const Text(
                'Include detailed violation information in the output',
                style: TextStyle(fontSize: 12),
              ),
              value: _returnViolations,
              onChanged: (value) => setState(() => _returnViolations = value),
              activeColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesSection() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Guardrail Rules',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_rules.length} rules',
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addCustomRule,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Custom Rule'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_rules.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(Icons.shield_outlined, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'No guardrail rules yet',
                        style: TextStyle(
                          // color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add rules from templates or create custom rules',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._rules.map((rule) => _buildRuleCard(rule)),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(GuardrailRule rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          rule.enabled ? Icons.check_circle : Icons.cancel,
          color: rule.enabled ? Colors.green : Colors.grey,
        ),
        title: Text(
          rule.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            _buildChip(
              rule.type.toString().split('.').last,
              _getTypeColor(rule.type),
            ),
            const SizedBox(width: 8),
            _buildChip(
              rule.severity.toString().split('.').last,
              _getSeverityColor(rule.severity),
            ),
            const SizedBox(width: 8),
            _buildChip(
              rule.action.toString().split('.').last,
              _getActionColor(rule.action),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: rule.enabled,
              onChanged: (value) {
                setState(() {
                  final index = _rules.indexOf(rule);
                  _rules[index] = rule.copyWith(enabled: value);
                });
              },
              activeColor: Colors.green,
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: () => _editRule(rule),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => setState(() => _rules.remove(rule)),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule.description, style: const TextStyle()),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Threshold: ', style: TextStyle()),
                    Text(
                      '${(rule.threshold * 100).toInt()}%',
                      style: const TextStyle(),
                    ),
                    const Spacer(),
                    Text('Confidence Score', style: TextStyle()),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: rule.threshold,

                  valueColor: AlwaysStoppedAnimation(
                    _getSeverityColor(rule.severity),
                  ),
                ),
                if (rule.config.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Configuration:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...rule.config.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Text(
                        '${e.key}: ${e.value}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10)),
    );
  }

  Widget _buildRuleTemplates() {
    return Container(
      width: 350,
      color: const Color(0xFF252525),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: const Text(
              'Rule Templates',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTemplateCategory('Security', [
                  _buildTemplate(
                    'PII Detection',
                    Icons.privacy_tip,
                    GuardrailType.piiDetection,
                  ),
                  _buildTemplate(
                    'Jailbreak Detection',
                    Icons.security,
                    GuardrailType.jailbreakDetection,
                  ),
                  _buildTemplate(
                    'Prompt Injection',
                    Icons.warning,
                    GuardrailType.promptInjection,
                  ),
                ]),
                _buildTemplateCategory('Content Safety', [
                  _buildTemplate(
                    'Toxicity Filter',
                    Icons.block,
                    GuardrailType.toxicityDetection,
                  ),
                  _buildTemplate(
                    'Content Moderation',
                    Icons.shield,
                    GuardrailType.contentModeration,
                  ),
                  _buildTemplate(
                    'Sensitive Topics',
                    Icons.report,
                    GuardrailType.sensitiveTopics,
                  ),
                ]),
                _buildTemplateCategory('Quality', [
                  _buildTemplate(
                    'Hallucination Check',
                    Icons.psychology,
                    GuardrailType.hallucinationDetection,
                  ),
                  _buildTemplate(
                    'Factual Accuracy',
                    Icons.fact_check,
                    GuardrailType.factualAccuracy,
                  ),
                  _buildTemplate(
                    'Bias Detection',
                    Icons.balance,
                    GuardrailType.biasDetection,
                  ),
                ]),
                _buildTemplateCategory('Custom', [
                  _buildTemplate(
                    'Custom Regex',
                    Icons.code,
                    GuardrailType.customRegex,
                  ),
                  _buildTemplate(
                    'Custom Keywords',
                    Icons.text_fields,
                    GuardrailType.customKeywords,
                  ),
                  _buildTemplate(
                    'Custom ML Model',
                    Icons.model_training,
                    GuardrailType.customML,
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCategory(String title, List<Widget> templates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...templates,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTemplate(String name, IconData icon, GuardrailType type) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: _getTypeColor(type), size: 20),
        title: Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green, size: 20),
          onPressed: () => _addRuleFromTemplate(type),
        ),
      ),
    );
  }

  Color _getTypeColor(GuardrailType type) {
    switch (type) {
      case GuardrailType.piiDetection:
      case GuardrailType.jailbreakDetection:
      case GuardrailType.promptInjection:
        return Colors.red;
      case GuardrailType.toxicityDetection:
      case GuardrailType.contentModeration:
      case GuardrailType.sensitiveTopics:
        return Colors.orange;
      case GuardrailType.hallucinationDetection:
      case GuardrailType.factualAccuracy:
      case GuardrailType.biasDetection:
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  Color _getSeverityColor(GuardrailSeverity severity) {
    switch (severity) {
      case GuardrailSeverity.low:
        return Colors.green;
      case GuardrailSeverity.medium:
        return Colors.yellow;
      case GuardrailSeverity.high:
        return Colors.orange;
      case GuardrailSeverity.critical:
        return Colors.red;
    }
  }

  Color _getActionColor(RuleAction action) {
    switch (action) {
      case RuleAction.warn:
        return Colors.yellow;
      case RuleAction.block:
        return Colors.red;
      case RuleAction.sanitize:
        return Colors.blue;
      case RuleAction.log:
        return Colors.grey;
      case RuleAction.redact:
        return Colors.purple;
      case RuleAction.notify:
        return Colors.orange;
    }
  }

  void _addRuleFromTemplate(GuardrailType type) {
    final rule = _createDefaultRule(type);
    setState(() => _rules.add(rule));
  }

  GuardrailRule _createDefaultRule(GuardrailType type) {
    final id = 'rule_${DateTime.now().millisecondsSinceEpoch}';

    switch (type) {
      case GuardrailType.piiDetection:
        return GuardrailRule(
          id: id,
          name: 'PII Detection',
          description: 'Detects personally identifiable information',
          type: type,
          severity: GuardrailSeverity.high,
          action: RuleAction.block,
          threshold: 0.9,
        );
      case GuardrailType.jailbreakDetection:
        return GuardrailRule(
          id: id,
          name: 'Jailbreak Detection',
          description: 'Prevents prompt injection and jailbreak attempts',
          type: type,
          severity: GuardrailSeverity.critical,
          action: RuleAction.block,
          threshold: 0.85,
        );
      case GuardrailType.toxicityDetection:
        return GuardrailRule(
          id: id,
          name: 'Toxicity Filter',
          description: 'Filters toxic and harmful content',
          type: type,
          severity: GuardrailSeverity.high,
          action: RuleAction.block,
          threshold: 0.75,
          config: {
            'keywords': ['hate', 'violence', 'abuse', 'threat'],
          },
        );
      case GuardrailType.hallucinationDetection:
        return GuardrailRule(
          id: id,
          name: 'Hallucination Check',
          description: 'Detects potential AI hallucinations',
          type: type,
          severity: GuardrailSeverity.medium,
          action: RuleAction.warn,
          threshold: 0.7,
        );
      case GuardrailType.customKeywords:
        return GuardrailRule(
          id: id,
          name: 'Custom Keywords',
          description: 'Check for custom keyword list',
          type: type,
          severity: GuardrailSeverity.medium,
          action: RuleAction.warn,
          threshold: 1.0,
          config: {'keywords': [], 'case_sensitive': false},
        );
      default:
        return GuardrailRule(
          id: id,
          name: type.toString().split('.').last,
          description: 'Custom guardrail rule',
          type: type,
          severity: GuardrailSeverity.medium,
          action: RuleAction.warn,
          threshold: 0.7,
        );
    }
  }

  void _addCustomRule() {
    showDialog(
      context: context,
      builder: (context) => GuardrailRuleEditorDialog(
        onSave: (rule) {
          setState(() => _rules.add(rule));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editRule(GuardrailRule rule) {
    showDialog(
      context: context,
      builder: (context) => GuardrailRuleEditorDialog(
        existingRule: rule,
        onSave: (updatedRule) {
          setState(() {
            final index = _rules.indexOf(rule);
            _rules[index] = updatedRule;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _testGuardrails() {
    showDialog(
      context: context,
      builder: (context) => GuardrailTestDialog(rules: _rules),
    );
  }

  void _saveGuardrail() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final definition = GuardrailNodeDefinition(
      id: 'guardrail_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      description: _descriptionController.text,
      rules: _rules,
      stopOnFirstViolation: _stopOnFirstViolation,
      returnViolations: _returnViolations,
    );

    Navigator.pop(context, definition);
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Guardrail Help',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What are Guardrails?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Guardrails monitor and filter AI inputs/outputs to prevent:\n'
                '• PII leakage\n'
                '• Jailbreak attempts\n'
                '• Toxic content\n'
                '• Hallucinations\n'
                '• And more...',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                'How to Use:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '1. Add rules from templates\n'
                '2. Configure thresholds and actions\n'
                '3. Test with sample inputs\n'
                '4. Deploy in your workflow',
                style: TextStyle(color: Colors.white70, fontSize: 13),
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
}
