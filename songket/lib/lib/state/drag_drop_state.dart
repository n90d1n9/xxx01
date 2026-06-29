import 'package:flutter/widgets.dart';

import '../model/report_component.dart';

class DragDropState {
  final ReportComponent? draggedComponent;
  final Offset? dragOffset;
  final bool isDragging;
  final List<ReportComponent> selectedComponents;
  final ReportComponent? hoveredComponent;
  final bool showGrid;
  final bool snapToGrid;
  final double gridSize;

  const DragDropState({
    this.draggedComponent,
    this.dragOffset,
    this.isDragging = false,
    this.selectedComponents = const [],
    this.hoveredComponent,
    this.showGrid = true,
    this.snapToGrid = true,
    this.gridSize = 10,
  });

  DragDropState copyWith({
    ReportComponent? draggedComponent,
    Offset? dragOffset,
    bool? isDragging,
    List<ReportComponent>? selectedComponents,
    ReportComponent? hoveredComponent,
    bool? showGrid,
    bool? snapToGrid,
  }) {
    return DragDropState(
      draggedComponent: draggedComponent ?? this.draggedComponent,
      dragOffset: dragOffset ?? this.dragOffset,
      isDragging: isDragging ?? this.isDragging,
      selectedComponents: selectedComponents ?? this.selectedComponents,
      hoveredComponent: hoveredComponent ?? this.hoveredComponent,
      showGrid: showGrid ?? this.showGrid,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      gridSize: gridSize,
    );
  }
}
