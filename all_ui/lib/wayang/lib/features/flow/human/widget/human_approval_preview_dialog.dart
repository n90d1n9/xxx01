import 'package:flutter/material.dart';

import '../model/human_approval_status.dart';
import '../model/human_loop_definition.dart';

class HumanApprovalPreviewDialog extends StatelessWidget {
  final HumanInLoopNodeDefinition definition;

  const HumanApprovalPreviewDialog({super.key, required this.definition});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      title: const Row(
        children: [
          Icon(Icons.visibility, color: Colors.orange),
          SizedBox(width: 12),
          Text(
            'Preview Approval Request',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    definition.prompt,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewContent(),
                ],
              ),
            ),
            if (definition.timeout != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.timer, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Timeout: ${definition.timeout!.inMinutes} minutes',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildPreviewContent() {
    switch (definition.approvalType) {
      case HumanApprovalType.binary:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.close),
                label: const Text('Reject'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        );

      case HumanApprovalType.choice:
        return Column(
          children: definition.options
              .map(
                (option) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: RadioListTile(
                    title: Text(
                      option.label,
                      style: const TextStyle(color: Colors.white),
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
                    groupValue: null,
                    onChanged: null,
                    activeColor: Colors.orange,
                  ),
                ),
              )
              .toList(),
        );

      case HumanApprovalType.multiChoice:
        return Column(
          children: definition.options
              .map(
                (option) => CheckboxListTile(
                  title: Text(
                    option.label,
                    style: const TextStyle(color: Colors.white),
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
                  value: false,
                  onChanged: null,
                  activeColor: Colors.orange,
                ),
              )
              .toList(),
        );

      case HumanApprovalType.text:
        return const TextField(
          style: TextStyle(color: Colors.white),
          maxLines: 4,
          enabled: false,
          decoration: InputDecoration(
            hintText: 'Enter your response here...',
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(),
          ),
        );
    }
  }
}
