import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../schema/workflow/workflow_node.dart';

class CanvasState {
  final Offset panOffset;
  final double zoom;
  final bool isPanning;
  final bool showGrid;
  final bool snapToGrid;
  final int gridSize;
  final Rect? selectionRect;
  final Offset? cursorPosition;
  final Set<String> highlightedNodes;
  final Set<String> highlightedEdges;
  final Matrix4? transformMatrix;

  const CanvasState({
    this.panOffset = Offset.zero,
    this.zoom = 1.0,
    this.isPanning = false,
    this.showGrid = true,
    this.snapToGrid = true,
    this.gridSize = 20,
    this.selectionRect,
    this.cursorPosition,
    this.highlightedNodes = const {},
    this.highlightedEdges = const {},
    this.transformMatrix,
  });

  CanvasState copyWith({
    Offset? panOffset,
    double? zoom,
    bool? isPanning,
    bool? showGrid,
    bool? snapToGrid,
    int? gridSize,
    Rect? selectionRect,
    Offset? cursorPosition,
    Set<String>? highlightedNodes,
    Set<String>? highlightedEdges,
    Matrix4? transformMatrix,
  }) {
    return CanvasState(
      panOffset: panOffset ?? this.panOffset,
      zoom: zoom ?? this.zoom,
      isPanning: isPanning ?? this.isPanning,
      showGrid: showGrid ?? this.showGrid,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      gridSize: gridSize ?? this.gridSize,
      selectionRect: selectionRect ?? this.selectionRect,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      highlightedNodes: highlightedNodes ?? this.highlightedNodes,
      highlightedEdges: highlightedEdges ?? this.highlightedEdges,
      transformMatrix: transformMatrix ?? this.transformMatrix,
    );
  }

  Offset snapToGridIfEnabled(Offset position) {
    if (!snapToGrid) return position;

    final snappedX = (position.dx / gridSize).round() * gridSize.toDouble();
    final snappedY = (position.dy / gridSize).round() * gridSize.toDouble();
    return Offset(snappedX, snappedY);
  }

  Offset screenToCanvas(Offset screenPosition) {
    if (transformMatrix != null) {
      final inverseMatrix = Matrix4.inverted(transformMatrix!);
      final transformed = MatrixUtils.transformPoint(
        inverseMatrix,
        screenPosition,
      );
      return transformed;
    }
    return (screenPosition - panOffset) / zoom;
  }

  Offset canvasToScreen(Offset canvasPosition) {
    if (transformMatrix != null) {
      return MatrixUtils.transformPoint(transformMatrix!, canvasPosition);
    }
    return canvasPosition * zoom + panOffset;
  }

  Rect? getCanvasSelectionRect(Size screenSize) {
    if (selectionRect == null) return null;

    final topLeft = screenToCanvas(selectionRect!.topLeft);
    final bottomRight = screenToCanvas(selectionRect!.bottomRight);
    return Rect.fromPoints(topLeft, bottomRight);
  }

  bool get isAtMinZoom => zoom <= 0.1;
  bool get isAtMaxZoom => zoom >= 3.0;
  double get effectiveGridSize => gridSize * zoom;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CanvasState &&
            runtimeType == other.runtimeType &&
            panOffset == other.panOffset &&
            zoom == other.zoom &&
            isPanning == other.isPanning &&
            showGrid == other.showGrid &&
            snapToGrid == other.snapToGrid &&
            gridSize == other.gridSize &&
            selectionRect == other.selectionRect &&
            cursorPosition == other.cursorPosition &&
            setEquals(highlightedNodes, other.highlightedNodes) &&
            setEquals(highlightedEdges, other.highlightedEdges);
  }

  @override
  int get hashCode {
    return Object.hash(
      panOffset,
      zoom,
      isPanning,
      showGrid,
      snapToGrid,
      gridSize,
      selectionRect,
      cursorPosition,
      Object.hashAll(highlightedNodes),
      Object.hashAll(highlightedEdges),
    );
  }
}

class CanvasNotifier extends StateNotifier<CanvasState> {
  CanvasNotifier() : super(CanvasState());

  void pan(Offset delta) {
    state = state.copyWith(panOffset: state.panOffset + delta);
  }

  void panTo(Offset targetPosition, {Duration duration = Duration.zero}) {
    if (duration > Duration.zero) {
      // TODO: Implement animated panning
      _animateToState(state.copyWith(panOffset: targetPosition), duration);
    } else {
      state = state.copyWith(panOffset: targetPosition);
    }
  }

  void zoom(double delta, Offset focalPoint) {
    final oldZoom = state.zoom;
    final newZoom = (state.zoom + delta).clamp(0.1, 3.0);

    if (oldZoom == newZoom) return;

    // Zoom towards focal point (pivot-based zooming)
    final zoomFactor = newZoom / oldZoom;
    final canvasPoint = state.screenToCanvas(focalPoint);
    final newOffset = focalPoint - canvasPoint * newZoom;

    state = state.copyWith(zoom: newZoom, panOffset: newOffset);
  }

  void zoomTo(double targetZoom, Offset focalPoint) {
    final clampedZoom = targetZoom.clamp(0.1, 3.0);
    if (state.zoom == clampedZoom) return;

    final canvasPoint = state.screenToCanvas(focalPoint);
    final newOffset = focalPoint - canvasPoint * clampedZoom;

    state = state.copyWith(zoom: clampedZoom, panOffset: newOffset);
  }

  void resetView() {
    state = CanvasState();
  }

  void centerOnNode(String nodeId, List<WorkflowNode> nodes, Size canvasSize) {
    final node = nodes.firstWhere(
      (n) => n.id == nodeId,
      orElse: () => nodes.first,
    );
    final nodeCenter = Offset(
      node.position.x + 100,
      node.position.y + 50,
    ); // Center of node
    final screenCenter = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final targetOffset = screenCenter - nodeCenter * state.zoom;

    state = state.copyWith(panOffset: targetOffset);
  }

  Offset screenToCanvas(Offset screenPosition) {
    return state.screenToCanvas(screenPosition);
  }

  Offset canvasToScreen(Offset canvasPosition) {
    return state.canvasToScreen(canvasPosition);
  }

  void fitToView(
    List<WorkflowNode> nodes, {
    Size? viewportSize,
    double padding = 100,
  }) {
    if (nodes.isEmpty) {
      resetView();
      return;
    }

    final effectiveViewport = viewportSize ?? const Size(1200, 800);

    // Calculate bounding box of all nodes
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final node in nodes) {
      final nodeRect = _getNodeBoundingBox(node);
      minX = math.min(minX, nodeRect.left);
      minY = math.min(minY, nodeRect.top);
      maxX = math.max(maxX, nodeRect.right);
      maxY = math.max(maxY, nodeRect.bottom);
    }

    final contentWidth = maxX - minX + padding * 2;
    final contentHeight = maxY - minY + padding * 2;
    final contentCenter = Offset(
      minX + (maxX - minX) / 2,
      minY + (maxY - minY) / 2,
    );

    // Calculate optimal zoom level
    final scaleX = effectiveViewport.width / contentWidth;
    final scaleY = effectiveViewport.height / contentHeight;
    final newZoom = math.min(scaleX, scaleY).clamp(0.1, 3.0);

    // Calculate pan offset to center the content
    final screenCenter = Offset(
      effectiveViewport.width / 2,
      effectiveViewport.height / 2,
    );
    final newOffset = screenCenter - contentCenter * newZoom;

    state = state.copyWith(zoom: newZoom, panOffset: newOffset);
  }

  Rect _getNodeBoundingBox(WorkflowNode node) {
    const nodeWidth = 200.0;
    const nodeHeight = 100.0;
    return Rect.fromLTWH(
      node.position.x,
      node.position.y,
      nodeWidth,
      nodeHeight,
    );
  }

  void toggleGrid() {
    state = state.copyWith(showGrid: !state.showGrid);
  }

  void toggleSnapToGrid() {
    state = state.copyWith(snapToGrid: !state.snapToGrid);
  }

  void setGridSize(int size) {
    state = state.copyWith(gridSize: size.clamp(5, 100));
  }

  void setSelectionRect(Rect? rect) {
    state = state.copyWith(selectionRect: rect);
  }

  void updateCursorPosition(Offset? screenPosition) {
    state = state.copyWith(cursorPosition: screenPosition);
  }

  void highlightNodes(Set<String> nodeIds) {
    state = state.copyWith(highlightedNodes: nodeIds);
  }

  void highlightEdges(Set<String> edgeIds) {
    state = state.copyWith(highlightedEdges: edgeIds);
  }

  void clearHighlights() {
    state = state.copyWith(
      highlightedNodes: const {},
      highlightedEdges: const {},
    );
  }

  void _animateToState(CanvasState targetState, Duration duration) {
    // TODO: Implement smooth animation
    // This would use an animation controller to interpolate between states
    state = targetState;
  }

  // Utility methods for coordinate transformations
  Offset? getCursorCanvasPosition() {
    return state.cursorPosition != null
        ? state.screenToCanvas(state.cursorPosition!)
        : null;
  }

  bool isNodeVisible(WorkflowNode node, Size viewportSize) {
    final screenPos = state.canvasToScreen(
      Offset(node.position.x, node.position.y),
    );
    final nodeRect = Rect.fromLTWH(
      screenPos.dx,
      screenPos.dy,
      200 * state.zoom,
      100 * state.zoom,
    );
    final viewportRect = Offset.zero & viewportSize;
    return viewportRect.overlaps(nodeRect);
  }
}

final canvasProvider = StateNotifierProvider<CanvasNotifier, CanvasState>((
  ref,
) {
  return CanvasNotifier();
});
