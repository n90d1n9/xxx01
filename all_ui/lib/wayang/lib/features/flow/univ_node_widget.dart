import 'package:flutter/material.dart';

import 'node_catalog.dart';

class UniversalNodeWidget extends StatelessWidget {
  final String nodeType;
  final Map<String, dynamic> definition;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onConnect;
  final bool isSelected;
  final bool isExecuting;

  const UniversalNodeWidget({
    super.key,
    required this.nodeType,
    required this.definition,
    this.onEdit,
    this.onDelete,
    this.onConnect,
    this.isSelected = false,
    this.isExecuting = false,
  });

  @override
  Widget build(BuildContext context) {
    final nodeInfo = NodeCatalog.getNodeInfo(nodeType);
    final Color nodeColor = nodeInfo?['color'] ?? Colors.grey;
    final IconData nodeIcon = nodeInfo?['icon'] ?? Icons.help;

    return Container(
      width: 240,
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
          _buildHeader(nodeColor, nodeIcon),
          _buildBody(),
          _buildOutputPorts(nodeColor),
        ],
      ),
    );
  }

  Widget _buildHeader(Color nodeColor, IconData nodeIcon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: nodeColor.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(nodeIcon, color: nodeColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              definition['name'] ?? 'Unnamed Node',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isExecuting)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(nodeColor),
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
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (definition['description'] != null)
            Text(
              definition['description'],
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 8),
          _buildNodeSpecificInfo(),
        ],
      ),
    );
  }

  Widget _buildNodeSpecificInfo() {
    switch (nodeType) {
      case 'if_else':
        final conditions = definition['conditions'] as List? ?? [];
        return _buildInfoRow(
          Icons.rule,
          '${conditions.length} conditions',
          Colors.blue,
        );

      case 'while_loop':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              Icons.repeat,
              'Max: ${definition['maxIterations'] ?? 100}',
              Colors.purple,
            ),
            const SizedBox(height: 4),
            if (definition['condition'] != null)
              _buildConditionChip(definition['condition'], Colors.purple),
          ],
        );

      case 'human_in_loop':
        final approvalType = definition['approvalType'] ?? 'binary';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              Icons.how_to_vote,
              _getApprovalTypeLabel(approvalType),
              Colors.orange,
            ),
            if (definition['timeout'] != null)
              _buildInfoRow(
                Icons.timer,
                '${definition['timeout']}min',
                Colors.orange,
              ),
          ],
        );

      case 'try_catch':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              Icons.refresh,
              'Retries: ${definition['maxRetries'] ?? 3}',
              Colors.red,
            ),
            _buildInfoRow(
              Icons.trending_up,
              definition['retryStrategy'] ?? 'exponential',
              Colors.red,
            ),
          ],
        );

      case 'parallel':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              Icons.call_split,
              '${definition['parallelBranches'] ?? 2} branches',
              Colors.cyan,
            ),
            _buildInfoRow(
              Icons.rule,
              definition['waitStrategy'] ?? 'all',
              Colors.cyan,
            ),
          ],
        );

      case 'router':
        final routes = definition['routes'] as List? ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.route, '${routes.length} routes', Colors.teal),
            _buildInfoRow(
              Icons.settings,
              definition['strategy'] ?? 'roundRobin',
              Colors.teal,
            ),
          ],
        );

      case 'batch':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              Icons.layers,
              'Size: ${definition['batchSize'] ?? 10}',
              Colors.amber,
            ),
            _buildInfoRow(
              Icons.timer,
              '${definition['batchTimeout'] ?? 30}s',
              Colors.amber,
            ),
          ],
        );

      case 'merge':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              Icons.merge,
              '${definition['inputCount'] ?? 2} inputs',
              Colors.indigo,
            ),
            _buildInfoRow(
              Icons.construction,
              definition['strategy'] ?? 'union',
              Colors.indigo,
            ),
          ],
        );

      case 'delay':
        return _buildInfoRow(
          Icons.schedule,
          definition['scheduleType'] ?? 'delay',
          Colors.deepOrange,
        );

      case 'filter':
        return _buildInfoRow(
          Icons.filter_alt,
          definition['operation'] ?? 'filter',
          Colors.green,
        );

      case 'cache':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              Icons.cached,
              definition['strategy'] ?? 'ttl',
              Colors.pink,
            ),
            _buildInfoRow(
              Icons.storage,
              'Max: ${definition['maxSize'] ?? 100}',
              Colors.pink,
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionChip(String condition, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        condition,
        style: TextStyle(color: color, fontSize: 10, fontFamily: 'monospace'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildOutputPorts(Color nodeColor) {
    final ports = _getOutputPorts();

    if (ports.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Outputs:', style: TextStyle(fontSize: 10)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: ports
                .map((port) => _buildOutputChip(port, nodeColor))
                .toList(),
          ),
        ],
      ),
    );
  }

  List<String> _getOutputPorts() {
    switch (nodeType) {
      case 'if_else':
        final conditions = definition['conditions'] as List? ?? [];
        final ports = conditions
            .take(3)
            .map((c) => c['label'].toString())
            .toList();
        if (conditions.length > 3) ports.add('+${conditions.length - 3}');
        if (definition['hasElse'] == true) ports.add('else');
        return ports;

      case 'while_loop':
        return ['loop', 'exit'];

      case 'human_in_loop':
        final approvalType = definition['approvalType'] ?? 'binary';
        if (approvalType == 'binary') {
          return ['approved', 'rejected'];
        } else {
          return ['completed'];
        }

      case 'try_catch':
        return ['success', 'catch', 'finally'];

      case 'parallel':
        return ['success', 'error'];

      case 'router':
        final routes = definition['routes'] as List? ?? [];
        return routes.take(3).map((r) => r['label'].toString()).toList();

      case 'batch':
        return ['batched'];

      case 'merge':
        return ['merged'];

      case 'delay':
        return ['executed'];

      case 'filter':
        return ['transformed'];

      case 'cache':
        return ['cached', 'executed'];

      default:
        return [];
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

  String _getApprovalTypeLabel(String type) {
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
