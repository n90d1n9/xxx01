// Widget to display control flow node in the workflow canvas
import 'package:flutter/material.dart';

class ControlFlowNodeWidget extends StatelessWidget {
  final String nodeType;
  final Map<String, dynamic> definition;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;

  const ControlFlowNodeWidget({
    super.key,
    required this.nodeType,
    required this.definition,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color nodeColor = _getNodeColor();
    final IconData nodeIcon = _getNodeIcon();

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? nodeColor : Colors.white24,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: nodeColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: nodeColor.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(nodeIcon, color: nodeColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    definition['name'] ?? 'Unnamed',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16),

                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onEdit,
                  ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (definition['description'] != null)
                  Text(
                    definition['description'],
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                _buildNodeDetails(),
              ],
            ),
          ),

          // Footer with outputs
          _buildOutputSection(),
        ],
      ),
    );
  }

  Widget _buildIfElseOutputs() {
    final conditions = definition['conditions'] as List? ?? [];
    final hasElse = definition['hasElse'] ?? true;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        children: [
          const Text(
            'Outputs:',
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              ...conditions
                  .take(3)
                  .map((c) => _buildOutputChip(c['label'], Colors.blue)),
              if (conditions.length > 3)
                _buildOutputChip('+${conditions.length - 3} more', Colors.blue),
              if (hasElse) _buildOutputChip('else', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhileLoopOutputs() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOutputChip('loop', Colors.purple),
          _buildOutputChip('exit', Colors.green),
        ],
      ),
    );
  }
  /* 
  Widget _buildOutputChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  } */

  //////

  Color _getNodeColor() {
    switch (nodeType) {
      case 'if_else':
        return Colors.blue;
      case 'while_loop':
        return Colors.purple;
      case 'human_in_loop':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getNodeIcon() {
    switch (nodeType) {
      case 'if_else':
        return Icons.alt_route;
      case 'while_loop':
        return Icons.loop;
      case 'human_in_loop':
        return Icons.person_pin_circle;
      default:
        return Icons.help;
    }
  }

  Widget _buildNodeDetails() {
    switch (nodeType) {
      case 'if_else':
        final conditions = definition['conditions'] as List? ?? [];
        return Row(
          children: [
            const Icon(Icons.rule, color: Colors.blue, size: 14),
            const SizedBox(width: 6),
            Text(
              '${conditions.length} condition${conditions.length != 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        );

      case 'while_loop':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.repeat, color: Colors.purple, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Max: ${definition['maxIterations'] ?? 100}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                definition['condition'] ?? '',
                style: const TextStyle(
                  color: Colors.purple,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );

      case 'human_in_loop':
        final approvalType = definition['approvalType'] ?? 'binary';
        final timeout = definition['timeout'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.how_to_vote, color: Colors.orange, size: 14),
                const SizedBox(width: 6),
                Text(
                  _getApprovalTypeShortLabel(approvalType),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
            if (timeout != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer, color: Colors.orange, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '${timeout}min timeout',
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ],
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildOutputSection() {
    switch (nodeType) {
      case 'if_else':
        final conditions = definition['conditions'] as List? ?? [];
        final hasElse = definition['hasElse'] ?? true;

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
          ),
          child: Column(
            children: [
              const Text(
                'Outputs:',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  ...conditions
                      .take(3)
                      .map((c) => _buildOutputChip(c['label'], Colors.blue)),
                  if (conditions.length > 3)
                    _buildOutputChip('+${conditions.length - 3}', Colors.blue),
                  if (hasElse) _buildOutputChip('else', Colors.orange),
                ],
              ),
            ],
          ),
        );

      case 'while_loop':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOutputChip('loop', Colors.purple),
              _buildOutputChip('exit', Colors.green),
            ],
          ),
        );

      case 'human_in_loop':
        final approvalType = definition['approvalType'] ?? 'binary';
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
          ),
          child: _buildHumanInLoopOutputs(approvalType),
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildHumanInLoopOutputs(String approvalType) {
    switch (approvalType) {
      case 'binary':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOutputChip('approved', Colors.green),
            _buildOutputChip('rejected', Colors.red),
          ],
        );
      case 'choice':
        final options = definition['options'] as List? ?? [];
        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            ...options
                .take(2)
                .map((o) => _buildOutputChip(o['label'], Colors.orange)),
            if (options.length > 2)
              _buildOutputChip('+${options.length - 2}', Colors.orange),
          ],
        );
      case 'multiChoice':
        return _buildOutputChip('completed', Colors.orange);
      case 'text':
        return _buildOutputChip('completed', Colors.orange);
      default:
        return const SizedBox();
    }
  }

  Widget _buildOutputChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getApprovalTypeShortLabel(String type) {
    switch (type) {
      case 'binary':
        return 'Approve/Reject';
      case 'choice':
        return 'Single Choice';
      case 'multiChoice':
        return 'Multi Choice';
      case 'text':
        return 'Text Input';
      default:
        return type;
    }
  }
}
