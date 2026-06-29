import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widget/condition_editor_dialog.dart';
import '../model/ifelse_condition.dart';
import '../model/ifelse_node_definition.dart';
import '../widget/ifelse_test_dialog.dart';

class IfElseEditorScreen extends ConsumerStatefulWidget {
  final IfElseNodeDefinition? existingDefinition;

  const IfElseEditorScreen({super.key, this.existingDefinition});

  @override
  ConsumerState<IfElseEditorScreen> createState() => _IfElseEditorScreenState();
}

class _IfElseEditorScreenState extends ConsumerState<IfElseEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  List<IfElseCondition> _conditions = [];
  bool _hasElse = true;
  String? _testInput;
  String? _testResult;

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
      _conditions = List.from(widget.existingDefinition!.conditions);
      _hasElse = widget.existingDefinition!.hasElse;
    } else {
      _nameController = TextEditingController(text: 'If/Else Condition');
      _descriptionController = TextEditingController(
        text: 'Route data based on conditions',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: Row(
          children: [
            const Icon(Icons.alt_route, color: Colors.blue),
            const SizedBox(width: 12),
            const Text('If/Else Editor', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelp,
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _testConditions,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Test'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _save,
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
            flex: 3,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildBasicInfo(),
                const SizedBox(height: 24),
                _buildConditionsList(),
                const SizedBox(height: 24),
                _buildElseOption(),
              ],
            ),
          ),
          _buildExamplesPanel(),
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

  Widget _buildConditionsList() {
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
                  'Conditions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_conditions.length} conditions',
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addCondition,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Condition'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_conditions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.alt_route,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No conditions yet',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add conditions to route your data',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._conditions.asMap().entries.map(
                (entry) => _buildConditionCard(entry.value, entry.key),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionCard(IfElseCondition condition, int index) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        condition.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (condition.description != null)
                        Text(
                          condition.description!,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _editCondition(condition, index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => setState(() => _conditions.removeAt(index)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.code, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      condition.expression,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElseOption() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: SwitchListTile(
        title: const Text(
          'Include Else Branch',
          style: TextStyle(color: Colors.white),
        ),
        subtitle: const Text(
          'Add an else branch for when no conditions match',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        value: _hasElse,
        onChanged: (value) => setState(() => _hasElse = value),
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildExamplesPanel() {
    return Container(
      width: 400,
      color: const Color(0xFF252525),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'CEL Expression Examples',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          _buildExample(
            'Simple Equality',
            'input.type == "Q&A"',
            'Check if type equals Q&A',
          ),
          _buildExample(
            'Numeric Comparison',
            'input.score > 0.8',
            'Check if score is greater than 0.8',
          ),
          _buildExample(
            'String Contains',
            'input.text.contains("urgent")',
            'Check if text contains "urgent"',
          ),
          _buildExample(
            'Logical AND',
            'input.priority == "high" && input.status == "open"',
            'Check multiple conditions',
          ),
          _buildExample(
            'Logical OR',
            'input.category == "bug" || input.category == "error"',
            'Check either condition',
          ),
          _buildExample(
            'In List',
            'input.classification in ["Q&A", "FAQ", "Help"]',
            'Check if value is in list',
          ),
          _buildExample(
            'String Starts With',
            'input.message.startsWith("Error:")',
            'Check string prefix',
          ),
          _buildExample(
            'Complex Expression',
            'input.confidence >= 0.7 && input.category != "spam"',
            'Combine multiple checks',
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          const Text(
            'Available Variables:',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildVariableInfo('input.*', 'Access any input field'),
          _buildVariableInfo('input.classification', 'Classification result'),
          _buildVariableInfo('input.confidence', 'Confidence score'),
          _buildVariableInfo('input.type', 'Data type'),
        ],
      ),
    );
  }

  Widget _buildExample(String title, String expression, String description) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                expression,
                style: const TextStyle(
                  color: Colors.blue,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariableInfo(String variable, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              variable,
              style: const TextStyle(
                color: Colors.purple,
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  void _addCondition() {
    showDialog(
      context: context,
      builder: (context) => ConditionEditorDialog(
        onSave: (condition) {
          setState(() => _conditions.add(condition));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editCondition(IfElseCondition condition, int index) {
    showDialog(
      context: context,
      builder: (context) => ConditionEditorDialog(
        existingCondition: condition,
        onSave: (updated) {
          setState(() => _conditions[index] = updated);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _testConditions() {
    showDialog(
      context: context,
      builder: (context) => IfElseTestDialog(
        definition: IfElseNodeDefinition(
          id: 'test',
          name: _nameController.text,
          description: _descriptionController.text,
          conditions: _conditions,
          hasElse: _hasElse,
        ),
      ),
    );
  }

  void _save() {
    if (_nameController.text.isEmpty || _conditions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and at least one condition are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final definition = IfElseNodeDefinition(
      id:
          widget.existingDefinition?.id ??
          'ifelse_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      description: _descriptionController.text,
      conditions: _conditions,
      hasElse: _hasElse,
    );

    Navigator.pop(context, definition);
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'If/Else Node Help',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What is If/Else?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Route data to different paths based on conditions. Perfect for:\n'
                '• Classification routing\n'
                '• Priority handling\n'
                '• Content filtering\n'
                '• Decision trees',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                'How it works:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '1. Input data arrives\n'
                '2. Conditions evaluated in order\n'
                '3. First matching condition wins\n'
                '4. Data routed to matched output\n'
                '5. Else branch if no match',
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
