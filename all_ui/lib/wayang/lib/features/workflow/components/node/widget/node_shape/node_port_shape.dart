import 'package:flutter/material.dart';

import '../../../connection/model/connection_state.dart';
import '../../../connection/model/node_port.dart';

class NodePortShape extends StatefulWidget {
  final String id;
  final Offset position;
  final ConnectionType type;
  final double totalHeight;
  final int? conditionIndex;
  final bool isElse;
  final ValueChanged<NodePort>? onNodePortTap;
  final ValueChanged<NodePort>? onNodePortHover;
  const NodePortShape({
    super.key,
    required this.id,
    required this.position,
    required this.type,
    required this.totalHeight,
    this.conditionIndex,
    this.isElse = false,
    this.onNodePortHover,
    this.onNodePortTap,
  });

  @override
  State<NodePortShape> createState() => _NodePortShapeState();
}

class _NodePortShapeState extends State<NodePortShape> {
  @override
  Widget build(BuildContext context) {
    final Map<String, bool> _hoverStates = {};
    return Positioned(
      left: widget.position.dx - 6, // Center the circle
      top: widget.position.dy - 6, // Center the circle
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _hoverStates[widget.id] = true);
          widget.onNodePortHover?.call(
            NodePort(
              id: widget.id,
              type: widget.type,
              position: widget.position,
              conditionIndex: widget.conditionIndex,
              isElse: widget.isElse,
            ),
          );
        },
        onExit: (_) {
          setState(() => _hoverStates[widget.id] = false);
          widget.onNodePortHover?.call(
            NodePort(
              id: widget.id,
              type: widget.type,
              position: widget.position,
              conditionIndex: widget.conditionIndex,
              isElse: widget.isElse,
            ),
          );
        },
        child: GestureDetector(
          onTap: () {
            widget.onNodePortTap?.call(
              NodePort(
                id: widget.id,
                type: widget.type,
                position: widget.position,
                conditionIndex: widget.conditionIndex,
                isElse: widget.isElse,
              ),
            );
          },
          child: Container(
            width: 24,
            height: 24,
            color: Colors.transparent,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _hoverStates[widget.id] == true ? 16 : 12,
                height: _hoverStates[widget.id] == true ? 16 : 12,
                decoration: BoxDecoration(
                  color: _getCircleColor(
                    widget.type,
                    _hoverStates[widget.id] == true,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF979797), width: 1),
                  boxShadow: _hoverStates[widget.id] == true
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCircleColor(ConnectionType type, bool isHovered) {
    if (isHovered) {
      return type == ConnectionType.input
          ? const Color(0xFF4CAF50) // Green for input
          : const Color(0xFF2196F3); // Blue for output
    }
    return const Color(0xFFD8D8D8);
  }
}
