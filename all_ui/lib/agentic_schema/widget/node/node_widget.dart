import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../schema/node/node_type.dart';
import '../../schema/workflow/workflow_node.dart';
import '../../state/canvas_provider.dart';
import '../../state/ui_provider.dart';
import '../../state/workflow/workflow_provider.dart';
import '../canvas/workflow_canvas.dart';

class NodeWidget extends ConsumerStatefulWidget {
  final WorkflowNode node;
  final bool isSelected;
  final CanvasState? canvasState;
  final Function(NodeInteraction)? onInteraction;
  final bool isHighlighted;

  const NodeWidget({
    super.key,
    required this.node,
    required this.isSelected,
    this.canvasState,
    this.onInteraction,
    this.isHighlighted = false,
  });

  @override
  ConsumerState<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends ConsumerState<NodeWidget>
    with SingleTickerProviderStateMixin {
  static const double _nodeWidth = 200.0;
  static const double _nodeHeight = 100.0;

  bool _isHovered = false;
  bool _isDragging = false;
  Offset? _dragStartLocal;
  Offset? _dragStartCanvas;
  late AnimationController _highlightController;
  Timer? _dragDelayTimer;

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.isHighlighted) {
      _highlightController.forward();
    }
  }

  @override
  void didUpdateWidget(NodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _highlightController.forward();
    } else if (!widget.isHighlighted && oldWidget.isHighlighted) {
      _highlightController.reverse();
    }
  }

  @override
  void dispose() {
    _highlightController.dispose();
    _dragDelayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = widget.canvasState ?? ref.watch(canvasProvider);
    final screenPosition = canvasState!.canvasToScreen(
      Offset(widget.node.position.x, widget.node.position.y),
    );

    // Skip rendering if node is far outside viewport (performance optimization)
    if (!_isNodeInViewport(
      screenPosition,
      canvasState,
      MediaQuery.of(context).size,
    )) {
      return const SizedBox.shrink();
    }

    return AnimatedPositioned(
      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 100),
      left: screenPosition.dx,
      top: screenPosition.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => _handleTapDown(details, canvasState),
        onTap: () => _handleTap(canvasState),
        onTapCancel: _handleTapCancel,
        onPanStart: (details) => _handlePanStart(details, canvasState),
        onPanUpdate: (details) => _handlePanUpdate(details, canvasState),
        onPanEnd: (details) => _handlePanEnd(),
        onPanCancel: _handlePanCancel,
        child: MouseRegion(
          cursor: _isDragging
              ? SystemMouseCursors.grabbing
              : SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedBuilder(
            animation: _highlightController,
            builder: (context, child) {
              final highlightValue = _highlightController.value;
              return Transform.scale(
                scale: canvasState.zoom * (1 + highlightValue * 0.05),
                alignment: Alignment.topLeft,
                child: Opacity(opacity: _isDragging ? 0.8 : 1.0, child: child),
              );
            },
            child: _buildNodeContent(canvasState),
          ),
        ),
      ),
    );
  }

  bool _isNodeInViewport(
    Offset screenPosition,
    CanvasState canvasState,
    Size viewportSize,
  ) {
    const margin = 200.0; // Render margin outside viewport
    final nodeRect = Rect.fromLTWH(
      screenPosition.dx,
      screenPosition.dy,
      _nodeWidth * canvasState.zoom,
      _nodeHeight * canvasState.zoom,
    );
    final extendedViewport = Rect.fromLTWH(
      -margin,
      -margin,
      viewportSize.width + margin * 2,
      viewportSize.height + margin * 2,
    );
    return extendedViewport.overlaps(nodeRect);
  }

  Widget _buildNodeContent(CanvasState canvasState) {
    final theme = Theme.of(context);
    final nodeType = widget.node.type;
    final isActive = _isHovered || widget.isSelected || _isDragging;

    return Container(
      width: _nodeWidth,
      height: _nodeHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(theme, nodeType, isActive),
          width: _getBorderWidth(isActive),
        ),
        boxShadow: _getBoxShadows(isActive, theme),
      ),
      child: Stack(
        children: [
          // Node content
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildNodeHeader(theme, nodeType),

              // Body
              Expanded(child: _buildNodeBody(theme)),

              // Footer with connection handles
              _buildNodeFooter(),
            ],
          ),

          // Selection overlay
          if (widget.isSelected) _buildSelectionOverlay(),

          // Highlight overlay
          if (widget.isHighlighted) _buildHighlightOverlay(),

          // Drag handle
          if (_isHovered) _buildDragHandle(),
        ],
      ),
    );
  }

  Color _getBorderColor(ThemeData theme, NodeType nodeType, bool isActive) {
    if (widget.isSelected) return theme.colorScheme.primary;
    if (isActive) return nodeType.color;
    if (widget.isHighlighted) return nodeType.color.withOpacity(0.7);
    return theme.colorScheme.outline.withOpacity(0.3);
  }

  double _getBorderWidth(bool isActive) {
    if (widget.isSelected) return 3.0;
    if (isActive) return 2.0;
    return 1.5;
  }

  List<BoxShadow> _getBoxShadows(bool isActive, ThemeData theme) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isActive ? 0.2 : 0.1),
        blurRadius: isActive ? 12 : 8,
        offset: Offset(0, isActive ? 4 : 2),
      ),
      if (widget.isSelected)
        BoxShadow(
          color: theme.colorScheme.primary.withOpacity(0.3),
          blurRadius: 8,
          spreadRadius: 1,
        ),
    ];
  }

  Widget _buildNodeHeader(ThemeData theme, NodeType nodeType) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: nodeType.color.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(nodeType.icon, color: nodeType.color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.node.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_isHovered) _buildContextMenu(),
        ],
      ),
    );
  }

  Widget _buildNodeBody(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.node.description != null)
            Text(
              widget.node.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const Spacer(),
          _buildNodeStatus(theme),
        ],
      ),
    );
  }

  Widget _buildNodeStatus(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Ready',
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.green),
        ),
      ],
    );
  }

  Widget _buildNodeFooter() {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildConnectionHandle(isInput: true),
          _buildConnectionHandle(isInput: false),
        ],
      ),
    );
  }

  Widget _buildConnectionHandle({required bool isInput}) {
    return GestureDetector(
      onTapDown: (_) => _handleConnectionHandleTap(isInput),
      child: MouseRegion(
        cursor: SystemMouseCursors.precise,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: widget.node.type.color,
              width: _isHovered ? 2.5 : 2.0,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: widget.node.type.color.withOpacity(0.5),
                  blurRadius: 4,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 4,
        ),
      ),
    );
  }

  Widget _buildHighlightOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.node.type.color.withOpacity(0.5),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Positioned(
      top: 4,
      right: 4,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(Icons.drag_handle, size: 12, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildContextMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 16, color: Colors.grey.shade600),
      offset: const Offset(0, 40),
      itemBuilder: (context) => _buildContextMenuItems(),
      onSelected: (value) => _handleContextMenuSelection(value),
    );
  }

  List<PopupMenuItem<String>> _buildContextMenuItems() {
    return [
      PopupMenuItem(
        value: 'edit',
        child: const ListTile(
          dense: true,
          leading: Icon(Icons.edit, size: 18),
          title: Text('Edit'),
        ),
      ),
      PopupMenuItem(
        value: 'duplicate',
        child: const ListTile(
          dense: true,
          leading: Icon(Icons.copy, size: 18),
          title: Text('Duplicate'),
        ),
      ),
      //const PopupMenuDivider(),
      PopupMenuItem(
        value: 'delete',
        child: ListTile(
          dense: true,
          leading: Icon(Icons.delete, size: 18, color: Colors.red.shade600),
          title: Text('Delete', style: TextStyle(color: Colors.red.shade600)),
        ),
      ),
    ];
  }

  void _handleTapDown(TapDownDetails details, CanvasState canvasState) {
    widget.onInteraction?.call(NodeInteraction.tapDown);
  }

  void _handleTap(CanvasState canvasState) {
    ref.read(workflowProvider.notifier).selectNode(widget.node.id);
    ref.read(uiProvider.notifier).selectNodeForConfig(widget.node.id);
    widget.onInteraction?.call(NodeInteraction.selected);
  }

  void _handleTapCancel() {
    widget.onInteraction?.call(NodeInteraction.tapCancel);
  }

  void _handlePanStart(DragStartDetails details, CanvasState canvasState) {
    _dragStartLocal = details.localPosition;
    _dragStartCanvas = Offset(widget.node.position.x, widget.node.position.y);

    // Start drag after a short delay to distinguish from tap
    _dragDelayTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() => _isDragging = true);
      ref.read(workflowProvider.notifier).selectNode(widget.node.id);
      widget.onInteraction?.call(NodeInteraction.dragStart);
    });
  }

  void _handlePanUpdate(DragUpdateDetails details, CanvasState canvasState) {
    if (!_isDragging || _dragStartCanvas == null) return;

    final delta = details.delta / canvasState.zoom;
    ref.read(workflowProvider.notifier).moveNode(widget.node.id, delta);
    widget.onInteraction?.call(NodeInteraction.moved);
  }

  void _handlePanEnd() {
    _dragDelayTimer?.cancel();
    setState(() => _isDragging = false);
    widget.onInteraction?.call(NodeInteraction.dragEnd);
  }

  void _handlePanCancel() {
    _dragDelayTimer?.cancel();
    setState(() => _isDragging = false);
    widget.onInteraction?.call(NodeInteraction.dragCancel);
  }

  void _handleConnectionHandleTap(bool isInput) {
    final workflowState = ref.read(workflowProvider);

    if (isInput) {
      // Complete connection
      if (workflowState.isConnecting) {
        ref
            .read(workflowProvider.notifier)
            .completeConnection(widget.node.id, targetHandleId: 'input');
      }
    } else {
      // Start connection
      ref
          .read(workflowProvider.notifier)
          .startConnecting(widget.node.id, handleId: 'output');
    }

    widget.onInteraction?.call(NodeInteraction.connectionHandleTapped);
  }

  void _handleContextMenuSelection(String value) {
    switch (value) {
      case 'edit':
        ref.read(uiProvider.notifier).selectNodeForConfig(widget.node.id);
        widget.onInteraction?.call(NodeInteraction.edited);
        break;
      case 'duplicate':
        ref.read(workflowProvider.notifier).duplicateNode(widget.node.id);
        widget.onInteraction?.call(NodeInteraction.duplicated);
        break;
      case 'delete':
        ref.read(workflowProvider.notifier).deleteNode(widget.node.id);
        widget.onInteraction?.call(NodeInteraction.deleted);
        break;
    }
  }
}
