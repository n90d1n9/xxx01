import 'package:flutter/material.dart';

class ComponentDropTarget extends StatefulWidget {
  final Widget child;
  final void Function(Object data, Offset position) onDrop;
  final void Function(Object data, Offset position)? onHover;
  final VoidCallback? onExit;

  const ComponentDropTarget({
    super.key,
    required this.child,
    required this.onDrop,
    this.onHover,
    this.onExit,
  });

  @override
  State<ComponentDropTarget> createState() => _ComponentDropTargetState();
}

class _ComponentDropTargetState extends State<ComponentDropTarget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      onWillAcceptWithDetails: (_) {
        setState(() => _isHovered = true);
        return true;
      },
      onLeave: (_) {
        setState(() => _isHovered = false);
        widget.onExit?.call();
      },
      onMove: (details) {
        final position = _localPositionForGlobal(details.offset);
        if (position == null) return;
        widget.onHover?.call(details.data, position);
      },
      onAcceptWithDetails: (details) {
        setState(() => _isHovered = false);
        widget.onExit?.call();
        final position = _localPositionForGlobal(details.offset);
        if (position == null) return;
        widget.onDrop(details.data, position);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _isHovered ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }

  Offset? _localPositionForGlobal(Offset globalPosition) {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.globalToLocal(globalPosition);
  }
}
