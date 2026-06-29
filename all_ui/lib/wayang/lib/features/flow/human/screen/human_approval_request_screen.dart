import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/human_approval_request.dart';
import '../model/human_approval_status.dart';

class HumanApprovalRequestScreen extends ConsumerStatefulWidget {
  final HumanApprovalRequest request;
  final Function(HumanApprovalRequest) onRespond;

  const HumanApprovalRequestScreen({
    super.key,
    required this.request,
    required this.onRespond,
  });

  @override
  ConsumerState<HumanApprovalRequestScreen> createState() =>
      _HumanApprovalRequestScreenState();
}

class _HumanApprovalRequestScreenState
    extends ConsumerState<HumanApprovalRequestScreen> {
  String? _selectedOption;
  Set<String> _selectedOptions = {};
  final TextEditingController _textResponseController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _textResponseController.dispose();
    _commentController.dispose();
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
            Icon(Icons.pending_actions, color: Colors.orange),
            SizedBox(width: 12),
            Text('Approval Request', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRequestInfo(),
                const SizedBox(height: 24),
                _buildInputData(),
                const SizedBox(height: 24),
                _buildApprovalSection(),
                if (widget.request.definition.requireComment ||
                    widget.request.definition.commentPrompt != null) ...[
                  const SizedBox(height: 24),
                  _buildCommentSection(),
                ],
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestInfo() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.request.definition.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.request.definition.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.request.expiresAt != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.orange, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _getTimeRemaining(),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Text(
                widget.request.definition.prompt,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputData() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.data_object, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Input Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.request.inputData.entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 150,
                              child: Text(
                                '${entry.key}:',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalSection() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Decision',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildApprovalOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalOptions() {
    switch (widget.request.definition.approvalType) {
      case HumanApprovalType.binary:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleApprove(),
                icon: const Icon(Icons.check_circle, size: 24),
                label: const Text('Approve', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleReject(),
                icon: const Icon(Icons.cancel, size: 24),
                label: const Text('Reject', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.all(20),
                ),
              ),
            ),
          ],
        );

      case HumanApprovalType.choice:
        return Column(
          children: widget.request.definition.options
              .map(
                (option) => Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: RadioListTile<String>(
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
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          )
                        : null,
                    value: option.id,
                    groupValue: _selectedOption,
                    onChanged: (value) =>
                        setState(() => _selectedOption = value),
                    activeColor: Colors.orange,
                  ),
                ),
              )
              .toList(),
        );

      case HumanApprovalType.multiChoice:
        return Column(
          children: widget.request.definition.options
              .map(
                (option) => Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: CheckboxListTile(
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
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          )
                        : null,
                    value: _selectedOptions.contains(option.id),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedOptions.add(option.id);
                        } else {
                          _selectedOptions.remove(option.id);
                        }
                      });
                    },
                    activeColor: Colors.orange,
                  ),
                ),
              )
              .toList(),
        );

      case HumanApprovalType.text:
        return TextField(
          controller: _textResponseController,
          style: const TextStyle(color: Colors.white),
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Enter your response...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: const OutlineInputBorder(),
          ),
        );
    }
  }

  Widget _buildCommentSection() {
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
                  'Comments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.request.definition.requireComment)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Required',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (widget.request.definition.commentPrompt != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.request.definition.commentPrompt!,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add your comments here...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.request.definition.allowSkip)
          Expanded(
            child: OutlinedButton(
              onPressed: _handleSkip,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                side: const BorderSide(color: Colors.white38),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        if (widget.request.definition.allowSkip) const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.all(16),
            ),
            child: const Text(
              'Submit Decision',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  String _getTimeRemaining() {
    if (widget.request.expiresAt == null) return 'No limit';
    final remaining = widget.request.expiresAt!.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    if (remaining.inHours > 0)
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
    if (remaining.inMinutes > 0) return '${remaining.inMinutes}m';
    return '${remaining.inSeconds}s';
  }

  void _handleApprove() {
    if (!_validateComment()) return;

    widget.request.status = HumanApprovalStatus.approved;
    widget.request.comment = _commentController.text.isEmpty
        ? null
        : _commentController.text;
    widget.request.approvedBy = 'current_user'; // In real app, get from auth
    widget.request.respondedAt = DateTime.now();

    widget.onRespond(widget.request);
    Navigator.pop(context);
  }

  void _handleReject() {
    if (!_validateComment()) return;

    widget.request.status = HumanApprovalStatus.rejected;
    widget.request.comment = _commentController.text.isEmpty
        ? null
        : _commentController.text;
    widget.request.approvedBy = 'current_user';
    widget.request.respondedAt = DateTime.now();

    widget.onRespond(widget.request);
    Navigator.pop(context);
  }

  void _handleSkip() {
    widget.request.status = HumanApprovalStatus.cancelled;
    widget.request.approvedBy = 'current_user';
    widget.request.respondedAt = DateTime.now();

    widget.onRespond(widget.request);
    Navigator.pop(context);
  }

  void _handleSubmit() {
    if (!_validateResponse()) return;
    if (!_validateComment()) return;

    widget.request.status = HumanApprovalStatus.completed;
    widget.request.comment = _commentController.text.isEmpty
        ? null
        : _commentController.text;
    widget.request.approvedBy = 'current_user';
    widget.request.respondedAt = DateTime.now();

    switch (widget.request.definition.approvalType) {
      case HumanApprovalType.binary:
        // Handled by approve/reject buttons
        break;
      case HumanApprovalType.choice:
        widget.request.selectedOption = _selectedOption;
        break;
      case HumanApprovalType.multiChoice:
        widget.request.selectedOptions = _selectedOptions.toList();
        break;
      case HumanApprovalType.text:
        widget.request.textResponse = _textResponseController.text;
        break;
    }

    widget.onRespond(widget.request);
    Navigator.pop(context);
  }

  bool _validateResponse() {
    switch (widget.request.definition.approvalType) {
      case HumanApprovalType.binary:
        return true; // Handled separately
      case HumanApprovalType.choice:
        if (_selectedOption == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select an option'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        break;
      case HumanApprovalType.multiChoice:
        if (_selectedOptions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select at least one option'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        break;
      case HumanApprovalType.text:
        if (_textResponseController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a response'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        break;
    }
    return true;
  }

  bool _validateComment() {
    if (widget.request.definition.requireComment &&
        _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment is required'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }
}
