import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/human_approval_option.dart';
import '../model/human_approval_status.dart';
import '../model/human_loop_definition.dart';
import '../widget/approval_option_dialog.dart';
import '../widget/human_approval_preview_dialog.dart';

class HumanInLoopEditorScreen extends ConsumerStatefulWidget {
  final HumanInLoopNodeDefinition? existingDefinition;

  const HumanInLoopEditorScreen({super.key, this.existingDefinition});

  @override
  ConsumerState<HumanInLoopEditorScreen> createState() =>
      _HumanInLoopEditorScreenState();
}

class _HumanInLoopEditorScreenState
    extends ConsumerState<HumanInLoopEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _promptController;
  late TextEditingController _timeoutController;
  late TextEditingController _commentPromptController;
  HumanApprovalType _approvalType = HumanApprovalType.binary;
  List<HumanApprovalOption> _options = [];
  bool _allowSkip = false;
  bool _requireComment = false;
  List<String> _notificationEmails = [];

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
      _promptController = TextEditingController(
        text: widget.existingDefinition!.prompt,
      );
      _timeoutController = TextEditingController(
        text: widget.existingDefinition!.timeout != null
            ? (widget.existingDefinition!.timeout!.inMinutes).toString()
            : '',
      );
      _commentPromptController = TextEditingController(
        text: widget.existingDefinition!.commentPrompt ?? '',
      );
      _approvalType = widget.existingDefinition!.approvalType;
      _options = List.from(widget.existingDefinition!.options);
      _allowSkip = widget.existingDefinition!.allowSkip;
      _requireComment = widget.existingDefinition!.requireComment;
      _notificationEmails = List.from(
        widget.existingDefinition!.notificationEmails ?? [],
      );
    } else {
      _nameController = TextEditingController(text: 'Human Approval');
      _descriptionController = TextEditingController(
        text: 'Request human review',
      );
      _promptController = TextEditingController(
        text: 'Please review and approve this request',
      );
      _timeoutController = TextEditingController(text: '60');
      _commentPromptController = TextEditingController(
        text: 'Add your comments (optional)',
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _promptController.dispose();
    _timeoutController.dispose();
    _commentPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Row(
          children: [
            Icon(Icons.person_pin_circle, color: Colors.orange),
            SizedBox(width: 12),
            Text(
              'Human in the Loop Editor',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelp,
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _previewApproval,
            icon: const Icon(Icons.visibility),
            label: const Text('Preview'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
                _buildApprovalType(),
                const SizedBox(height: 24),
                if (_approvalType == HumanApprovalType.choice ||
                    _approvalType == HumanApprovalType.multiChoice)
                  _buildOptionsList(),
                if (_approvalType == HumanApprovalType.choice ||
                    _approvalType == HumanApprovalType.multiChoice)
                  const SizedBox(height: 24),
                _buildSettings(),
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
            const SizedBox(height: 16),
            TextField(
              controller: _promptController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Approval Prompt',
                labelStyle: TextStyle(color: Colors.white70),
                hintText:
                    'What question or instruction should the reviewer see?',
                hintStyle: TextStyle(color: Colors.white38),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalType() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Approval Type',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...HumanApprovalType.values.map(
              (type) => RadioListTile<HumanApprovalType>(
                title: Text(
                  _getApprovalTypeName(type),
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  _getApprovalTypeDescription(type),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                value: type,
                groupValue: _approvalType,
                onChanged: (value) => setState(() {
                  _approvalType = value!;
                  if (type == HumanApprovalType.binary) {
                    _options = [];
                  }
                }),
                activeColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsList() {
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
                  'Options',
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
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_options.length} options',
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Option'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_options.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.list_alt,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No options yet',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add options for reviewers to choose from',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._options.asMap().entries.map(
                (entry) => _buildOptionCard(entry.value, entry.key),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(HumanApprovalOption option, int index) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          option.label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: option.description != null
            ? Text(
                option.description!,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
              onPressed: () => _editOption(option, index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => setState(() => _options.removeAt(index)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeoutController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Timeout (minutes)',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: '60',
                border: OutlineInputBorder(),
                helperText: 'Leave empty for no timeout',
                helperStyle: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                'Allow Skip',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Reviewers can skip without making a decision',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              value: _allowSkip,
              onChanged: (value) => setState(() => _allowSkip = value),
              activeColor: Colors.orange,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                'Require Comment',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Reviewers must add a comment with their decision',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              value: _requireComment,
              onChanged: (value) => setState(() => _requireComment = value),
              activeColor: Colors.orange,
              contentPadding: EdgeInsets.zero,
            ),
            if (_requireComment) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _commentPromptController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Comment Prompt',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
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
            'Use Cases',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          _buildUseCase(
            Icons.thumb_up,
            'Content Moderation',
            'Review AI-generated content before publishing',
            Colors.blue,
          ),
          _buildUseCase(
            Icons.security,
            'Security Review',
            'Approve sensitive operations or data access',
            Colors.red,
          ),
          _buildUseCase(
            Icons.attach_money,
            'Budget Approval',
            'Review and approve high-value transactions',
            Colors.green,
          ),
          _buildUseCase(
            Icons.verified,
            'Quality Check',
            'Verify output quality meets standards',
            Colors.purple,
          ),
          _buildUseCase(
            Icons.policy,
            'Compliance Review',
            'Ensure regulatory compliance',
            Colors.orange,
          ),
          _buildUseCase(
            Icons.bug_report,
            'Exception Handling',
            'Human decision for edge cases',
            Colors.yellow,
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          const Text(
            'Best Practices:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildBestPractice(
            'Clear prompts help reviewers make decisions quickly',
          ),
          _buildBestPractice(
            'Set reasonable timeouts to prevent workflow stalls',
          ),
          _buildBestPractice(
            'Use specific options instead of open-ended choices',
          ),
          _buildBestPractice('Require comments for audit trails'),
          _buildBestPractice(
            'Configure notifications for time-sensitive reviews',
          ),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Pro Tip',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Combine with If/Else nodes to handle different approval outcomes. For example, route approved items to one path and rejected items to another.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseCase(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestPractice(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getApprovalTypeName(HumanApprovalType type) {
    switch (type) {
      case HumanApprovalType.binary:
        return 'Approve/Reject';
      case HumanApprovalType.choice:
        return 'Single Choice';
      case HumanApprovalType.multiChoice:
        return 'Multiple Choice';
      case HumanApprovalType.text:
        return 'Text Input';
    }
  }

  String _getApprovalTypeDescription(HumanApprovalType type) {
    switch (type) {
      case HumanApprovalType.binary:
        return 'Simple approve or reject decision';
      case HumanApprovalType.choice:
        return 'Select one option from multiple choices';
      case HumanApprovalType.multiChoice:
        return 'Select multiple options';
      case HumanApprovalType.text:
        return 'Free-form text response';
    }
  }

  void _addOption() {
    showDialog(
      context: context,
      builder: (context) => ApprovalOptionEditorDialog(
        onSave: (option) {
          setState(() => _options.add(option));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editOption(HumanApprovalOption option, int index) {
    showDialog(
      context: context,
      builder: (context) => ApprovalOptionEditorDialog(
        existingOption: option,
        onSave: (updated) {
          setState(() => _options[index] = updated);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _previewApproval() {
    final definition = HumanInLoopNodeDefinition(
      id: 'preview',
      name: _nameController.text,
      description: _descriptionController.text,
      approvalType: _approvalType,
      prompt: _promptController.text,
      options: _options,
      timeout: _timeoutController.text.isNotEmpty
          ? Duration(minutes: int.parse(_timeoutController.text))
          : null,
      allowSkip: _allowSkip,
      requireComment: _requireComment,
      commentPrompt: _commentPromptController.text,
      notificationEmails: _notificationEmails,
    );

    Navigator.pop(context, definition);
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Human in the Loop Help',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What is Human in the Loop?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Pause workflow execution to get human input or approval. Perfect for:\n'
                '• Content moderation\n'
                '• Quality assurance\n'
                '• Compliance reviews\n'
                '• Exception handling\n'
                '• Budget approvals',
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
                '1. Workflow reaches approval node\n'
                '2. Request is created and sent to reviewers\n'
                '3. Workflow pauses until human responds\n'
                '4. Human reviews data and makes decision\n'
                '5. Workflow continues based on decision',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                'Approval Types:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Binary: Simple approve/reject\n'
                '• Choice: Pick one option\n'
                '• Multi-Choice: Select multiple\n'
                '• Text: Free-form input',
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

  void _save() {
    if (_nameController.text.isEmpty || _promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and prompt are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if ((_approvalType == HumanApprovalType.choice ||
            _approvalType == HumanApprovalType.multiChoice) &&
        _options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one option is required for choice types'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final definition = HumanInLoopNodeDefinition(
      id:
          widget.existingDefinition?.id ??
          'human_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      description: _descriptionController.text,
      approvalType: _approvalType,
      prompt: _promptController.text,
      options: _options,
      timeout: _timeoutController.text.isNotEmpty
          ? Duration(minutes: int.parse(_timeoutController.text))
          : null,
      allowSkip: _allowSkip,
      requireComment: _requireComment,
      commentPrompt: _commentPromptController.text,
    );

    showDialog(
      context: context,
      builder: (context) => HumanApprovalPreviewDialog(definition: definition),
    );
  }
}
