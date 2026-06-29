import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/node/model/schema/node_data.dart';

class WorkflowSearchWidget extends ConsumerStatefulWidget {
  final List<NodeData> nodes;
  final Function(String) onNodeSelected;

  const WorkflowSearchWidget({
    super.key,
    required this.nodes,
    required this.onNodeSelected,
  });

  @override
  ConsumerState<WorkflowSearchWidget> createState() =>
      _WorkflowSearchWidgetState();
}

class _WorkflowSearchWidgetState extends ConsumerState<WorkflowSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  List<NodeData> _filteredNodes = [];
  bool _isOpen = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_filterNodes);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterNodes() {
    final query = _controller.text.toLowerCase();
    setState(() {
      _filteredNodes = widget.nodes.where((node) {
        return node.label.toLowerCase().contains(query) ||
            node.type.toLowerCase().contains(query) ||
            node.id.toLowerCase().contains(query);
      }).toList();
      _isOpen = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search nodes... (Ctrl+K)',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _isOpen = false;
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF2D2D2D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          if (_isOpen && _filteredNodes.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredNodes.length,
                itemBuilder: (context, index) {
                  final node = _filteredNodes[index];
                  return ListTile(
                    leading: Icon(
                      _getNodeIcon(node.type),
                      color: _getNodeColor(node.type),
                    ),
                    title: Text(
                      node.label,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      node.type,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      widget.onNodeSelected(node.id);
                      _controller.clear();
                      setState(() {
                        _isOpen = false;
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  IconData _getNodeIcon(String type) {
    switch (type) {
      case 'webhook':
        return Icons.webhook;
      case 'llm':
        return Icons.psychology;
      case 'condition':
        return Icons.alt_route;
      case 'api':
        return Icons.api;
      default:
        return Icons.circle;
    }
  }

  Color _getNodeColor(String type) {
    switch (type) {
      case 'webhook':
        return Colors.green;
      case 'llm':
        return Colors.purple;
      case 'condition':
        return Colors.orange;
      case 'api':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }
}
