// pubspec.yaml dependencies:
/*
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  uuid: ^4.2.1
  vector_math: ^2.1.4
  json_annotation: ^4.8.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
*/

// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'dart:math';

void main() {
  runApp(const ProviderScope(child: BpmnApp()));
}

class BpmnApp extends StatelessWidget {
  const BpmnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BPMN Builder',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const BpmnEditorScreen(),
    );
  }
}

// models/bpmn_element.dart

enum BpmnElementType {
  startEvent,
  endEvent,
  task,
  gateway,
  sequenceFlow,
  annotation,
}

class BpmnElement {
  final String id;
  final BpmnElementType type;
  final String name;
  final Offset position;
  final Size size;
  final String? documentation;
  final Map<String, dynamic> properties;
  final List<String> incomingFlows;
  final List<String> outgoingFlows;

  BpmnElement({
    String? id,
    required this.type,
    required this.name,
    required this.position,
    Size? size,
    this.documentation,
    Map<String, dynamic>? properties,
    List<String>? incomingFlows,
    List<String>? outgoingFlows,
  }) : id = id ?? const Uuid().v4(),
       size = size ?? _getDefaultSize(type),
       properties = properties ?? {},
       incomingFlows = incomingFlows ?? [],
       outgoingFlows = outgoingFlows ?? [];

  static Size _getDefaultSize(BpmnElementType type) {
    switch (type) {
      case BpmnElementType.startEvent:
      case BpmnElementType.endEvent:
        return const Size(36, 36);
      case BpmnElementType.task:
        return const Size(100, 80);
      case BpmnElementType.gateway:
        return const Size(50, 50);
      case BpmnElementType.sequenceFlow:
        return const Size(0, 0);
      case BpmnElementType.annotation:
        return const Size(100, 60);
    }
  }

  factory BpmnElement.fromJson(Map<String, dynamic> json) {
    return BpmnElement(
      id: json['id'] as String?,
      type: BpmnElementType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      name: json['name'] as String,
      position: Offset(
        (json['position']['dx'] as num).toDouble(),
        (json['position']['dy'] as num).toDouble(),
      ),
      size: Size(
        (json['size']['width'] as num).toDouble(),
        (json['size']['height'] as num).toDouble(),
      ),
      documentation: json['documentation'] as String?,
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      incomingFlows: List<String>.from(json['incomingFlows'] ?? []),
      outgoingFlows: List<String>.from(json['outgoingFlows'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'name': name,
    'position': {'dx': position.dx, 'dy': position.dy},
    'size': {'width': size.width, 'height': size.height},
    'documentation': documentation,
    'properties': properties,
    'incomingFlows': incomingFlows,
    'outgoingFlows': outgoingFlows,
  };

  BpmnElement copyWith({
    String? name,
    Offset? position,
    Size? size,
    String? documentation,
    Map<String, dynamic>? properties,
    List<String>? incomingFlows,
    List<String>? outgoingFlows,
  }) {
    return BpmnElement(
      id: id,
      type: type,
      name: name ?? this.name,
      position: position ?? this.position,
      size: size ?? this.size,
      documentation: documentation ?? this.documentation,
      properties: properties ?? this.properties,
      incomingFlows: incomingFlows ?? this.incomingFlows,
      outgoingFlows: outgoingFlows ?? this.outgoingFlows,
    );
  }
}

class SequenceFlow {
  final String id;
  final String sourceId;
  final String targetId;
  final String? name;
  final List<Offset> waypoints;
  final String? condition;

  SequenceFlow({
    String? id,
    required this.sourceId,
    required this.targetId,
    this.name,
    List<Offset>? waypoints,
    this.condition,
  }) : id = id ?? const Uuid().v4(),
       waypoints = waypoints ?? [];

  factory SequenceFlow.fromJson(Map<String, dynamic> json) {
    return SequenceFlow(
      id: json['id'] as String?,
      sourceId: json['sourceId'] as String,
      targetId: json['targetId'] as String,
      name: json['name'] as String?,
      waypoints:
          (json['waypoints'] as List?)
              ?.map(
                (wp) => Offset(
                  (wp['dx'] as num).toDouble(),
                  (wp['dy'] as num).toDouble(),
                ),
              )
              .toList() ??
          [],
      condition: json['condition'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceId': sourceId,
    'targetId': targetId,
    'name': name,
    'waypoints': waypoints.map((wp) => {'dx': wp.dx, 'dy': wp.dy}).toList(),
    'condition': condition,
  };

  SequenceFlow copyWith({
    String? name,
    List<Offset>? waypoints,
    String? condition,
  }) {
    return SequenceFlow(
      id: id,
      sourceId: sourceId,
      targetId: targetId,
      name: name ?? this.name,
      waypoints: waypoints ?? this.waypoints,
      condition: condition ?? this.condition,
    );
  }
}

class BpmnDiagram {
  final String id;
  final String name;
  final List<BpmnElement> elements;
  final List<SequenceFlow> sequenceFlows;
  final DateTime createdAt;
  final DateTime updatedAt;

  BpmnDiagram({
    String? id,
    required this.name,
    List<BpmnElement>? elements,
    List<SequenceFlow>? sequenceFlows,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       elements = elements ?? [],
       sequenceFlows = sequenceFlows ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory BpmnDiagram.fromJson(Map<String, dynamic> json) {
    return BpmnDiagram(
      id: json['id'] as String?,
      name: json['name'] as String,
      elements:
          (json['elements'] as List?)
              ?.map((e) => BpmnElement.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      sequenceFlows:
          (json['sequenceFlows'] as List?)
              ?.map((f) => SequenceFlow.fromJson(Map<String, dynamic>.from(f)))
              .toList() ??
          [],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'elements': elements.map((e) => e.toJson()).toList(),
    'sequenceFlows': sequenceFlows.map((f) => f.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  BpmnDiagram copyWith({
    String? name,
    List<BpmnElement>? elements,
    List<SequenceFlow>? sequenceFlows,
  }) {
    return BpmnDiagram(
      id: id,
      name: name ?? this.name,
      elements: elements ?? this.elements,
      sequenceFlows: sequenceFlows ?? this.sequenceFlows,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

// providers/bpmn_providers.dart

// Current diagram state
final bpmnDiagramProvider =
    StateNotifierProvider<BpmnDiagramNotifier, BpmnDiagram>((ref) {
      return BpmnDiagramNotifier();
    });

class BpmnDiagramNotifier extends StateNotifier<BpmnDiagram> {
  BpmnDiagramNotifier() : super(BpmnDiagram(name: 'New Diagram'));

  void updateDiagramName(String name) {
    state = state.copyWith(name: name);
  }

  void addElement(BpmnElement element) {
    state = state.copyWith(elements: [...state.elements, element]);
  }

  void updateElement(String id, BpmnElement updatedElement) {
    final elements =
        state.elements.map((e) => e.id == id ? updatedElement : e).toList();
    state = state.copyWith(elements: elements);
  }

  void removeElement(String id) {
    final elements = state.elements.where((e) => e.id != id).toList();
    final flows =
        state.sequenceFlows
            .where((f) => f.sourceId != id && f.targetId != id)
            .toList();
    state = state.copyWith(elements: elements, sequenceFlows: flows);
  }

  void addSequenceFlow(SequenceFlow flow) {
    state = state.copyWith(sequenceFlows: [...state.sequenceFlows, flow]);
  }

  void updateSequenceFlow(String id, SequenceFlow updatedFlow) {
    final flows =
        state.sequenceFlows.map((f) => f.id == id ? updatedFlow : f).toList();
    state = state.copyWith(sequenceFlows: flows);
  }

  void removeSequenceFlow(String id) {
    final flows = state.sequenceFlows.where((f) => f.id != id).toList();
    state = state.copyWith(sequenceFlows: flows);
  }

  void clearDiagram() {
    state = BpmnDiagram(name: 'New Diagram');
  }

  void loadDiagram(BpmnDiagram diagram) {
    state = diagram;
  }
}

// Selected element state
final selectedElementProvider = StateProvider<String?>((ref) => null);

// Editor mode state
enum EditorMode { select, connect, pan }

final editorModeProvider = StateProvider<EditorMode>(
  (ref) => EditorMode.select,
);

// Connection state
final connectionStateProvider = StateProvider<ConnectionState?>((ref) => null);

class ConnectionState {
  final String sourceId;
  final Offset? currentPosition;

  ConnectionState({required this.sourceId, this.currentPosition});

  ConnectionState copyWith({Offset? currentPosition}) {
    return ConnectionState(
      sourceId: sourceId,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}

// Zoom and pan state
final viewportProvider = StateNotifierProvider<ViewportNotifier, ViewportState>(
  (ref) {
    return ViewportNotifier();
  },
);

class ViewportState {
  final Offset offset;
  final double scale;

  ViewportState({this.offset = Offset.zero, this.scale = 1.0});

  ViewportState copyWith({Offset? offset, double? scale}) {
    return ViewportState(
      offset: offset ?? this.offset,
      scale: scale ?? this.scale,
    );
  }
}

class ViewportNotifier extends StateNotifier<ViewportState> {
  ViewportNotifier() : super(ViewportState());

  void updateOffset(Offset offset) {
    state = state.copyWith(offset: offset);
  }

  void updateScale(double scale) {
    state = state.copyWith(scale: scale.clamp(0.1, 3.0));
  }

  void reset() {
    state = ViewportState();
  }
}

// widgets/bpmn_canvas.dart

class BpmnCanvas extends ConsumerStatefulWidget {
  const BpmnCanvas({super.key});

  @override
  ConsumerState<BpmnCanvas> createState() => _BpmnCanvasState();
}

class _BpmnCanvasState extends ConsumerState<BpmnCanvas> {
  Offset? _panStart;
  Offset? _dragStart;
  String? _draggedElementId;

  @override
  Widget build(BuildContext context) {
    final diagram = ref.watch(bpmnDiagramProvider);
    final viewport = ref.watch(viewportProvider);
    final selectedElement = ref.watch(selectedElementProvider);
    final editorMode = ref.watch(editorModeProvider);
    final connectionState = ref.watch(connectionStateProvider);

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTap: _handleTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[100],
        child: CustomPaint(
          painter: GridPainter(),
          child: Transform(
            transform:
                Matrix4.identity()
                  ..translate(viewport.offset.dx, viewport.offset.dy)
                  ..scale(viewport.scale),
            child: Stack(
              children: [
                // Sequence flows
                ...diagram.sequenceFlows.map((flow) {
                  final source = diagram.elements.firstWhere(
                    (e) => e.id == flow.sourceId,
                  );
                  final target = diagram.elements.firstWhere(
                    (e) => e.id == flow.targetId,
                  );
                  return SequenceFlowWidget(
                    key: ValueKey(flow.id),
                    flow: flow,
                    source: source,
                    target: target,
                    isSelected: selectedElement == flow.id,
                    onTap: () => _selectElement(flow.id),
                  );
                }),
                // Elements
                ...diagram.elements.map(
                  (element) => BpmnElementWidget(
                    key: ValueKey(element.id),
                    element: element,
                    isSelected: selectedElement == element.id,
                    onTap: () => _selectElement(element.id),
                    onDragStart: (details) => _startDrag(element.id, details),
                    onDragUpdate: (details) => _updateDrag(element.id, details),
                    onDragEnd: (details) => _endDrag(element.id, details),
                    onConnectionStart:
                        (elementId) => _startConnection(elementId),
                    onConnectionEnd: (elementId) => _endConnection(elementId),
                  ),
                ),
                // Connection preview
                if (connectionState != null &&
                    connectionState.currentPosition != null)
                  CustomPaint(
                    painter: ConnectionPreviewPainter(
                      start: _getElementCenter(connectionState.sourceId),
                      end: connectionState.currentPosition!,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    if (ref.read(editorModeProvider) == EditorMode.pan) {
      _panStart = details.localPosition;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (ref.read(editorModeProvider) == EditorMode.pan && _panStart != null) {
      final delta = details.localPosition - _panStart!;
      final currentOffset = ref.read(viewportProvider).offset;
      ref.read(viewportProvider.notifier).updateOffset(currentOffset + delta);
      _panStart = details.localPosition;
    }

    // Update connection preview
    final connectionState = ref.read(connectionStateProvider);
    if (connectionState != null) {
      final viewport = ref.read(viewportProvider);
      final worldPosition =
          (details.localPosition - viewport.offset) / viewport.scale;
      ref.read(connectionStateProvider.notifier).state = connectionState
          .copyWith(currentPosition: worldPosition);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _panStart = null;

    // End connection if no target found
    if (ref.read(connectionStateProvider) != null) {
      ref.read(connectionStateProvider.notifier).state = null;
    }
  }

  void _handleTap() {
    ref.read(selectedElementProvider.notifier).state = null;
  }

  void _selectElement(String elementId) {
    ref.read(selectedElementProvider.notifier).state = elementId;
  }

  void _startDrag(String elementId, DragStartDetails details) {
    if (ref.read(editorModeProvider) == EditorMode.select) {
      _draggedElementId = elementId;
      _dragStart = details.localPosition;
      _selectElement(elementId);
    }
  }

  void _updateDrag(String elementId, DragUpdateDetails details) {
    if (_draggedElementId == elementId && _dragStart != null) {
      final viewport = ref.read(viewportProvider);
      final delta = (details.localPosition - _dragStart!) / viewport.scale;
      final diagram = ref.read(bpmnDiagramProvider);
      final element = diagram.elements.firstWhere((e) => e.id == elementId);

      ref
          .read(bpmnDiagramProvider.notifier)
          .updateElement(
            elementId,
            element.copyWith(position: element.position + delta),
          );

      _dragStart = details.localPosition;
    }
  }

  void _endDrag(String elementId, DragEndDetails details) {
    _draggedElementId = null;
    _dragStart = null;
  }

  void _startConnection(String elementId) {
    if (ref.read(editorModeProvider) == EditorMode.connect) {
      ref.read(connectionStateProvider.notifier).state = ConnectionState(
        sourceId: elementId,
      );
    }
  }

  void _endConnection(String targetId) {
    final connectionState = ref.read(connectionStateProvider);
    if (connectionState != null && connectionState.sourceId != targetId) {
      // Create sequence flow
      final flow = SequenceFlow(
        sourceId: connectionState.sourceId,
        targetId: targetId,
        name: '',
      );
      ref.read(bpmnDiagramProvider.notifier).addSequenceFlow(flow);
    }
    ref.read(connectionStateProvider.notifier).state = null;
  }

  Offset _getElementCenter(String elementId) {
    final diagram = ref.read(bpmnDiagramProvider);
    final element = diagram.elements.firstWhere((e) => e.id == elementId);
    return element.position +
        Offset(element.size.width / 2, element.size.height / 2);
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey[300]!
          ..strokeWidth = 0.5;

    const gridSize = 20.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ConnectionPreviewPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  ConnectionPreviewPainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);

    // Draw arrowhead
    final direction = (end - start).direction;
    final arrowLength = 10.0;
    final arrowAngle = 0.5;

    final arrowPoint1 =
        end +
        Offset(
          arrowLength * cos(direction + arrowAngle),
          arrowLength * sin(direction + arrowAngle),
        );
    final arrowPoint2 =
        end +
        Offset(
          arrowLength * cos(direction - arrowAngle),
          arrowLength * sin(direction - arrowAngle),
        );

    final arrowPath =
        Path()
          ..moveTo(end.dx, end.dy)
          ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
          ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
          ..close();

    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// widgets/bpmn_element_widget.dart

class BpmnElementWidget extends StatelessWidget {
  final BpmnElement element;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(DragStartDetails) onDragStart;
  final Function(DragUpdateDetails) onDragUpdate;
  final Function(DragEndDetails) onDragEnd;
  final Function(String) onConnectionStart;
  final Function(String) onConnectionEnd;

  const BpmnElementWidget({
    super.key,
    required this.element,
    required this.isSelected,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onConnectionStart,
    required this.onConnectionEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: element.position.dx,
      top: element.position.dy,
      child: GestureDetector(
        onTap: () {
          onTap();
          onConnectionEnd(element.id);
        },
        onPanStart: onDragStart,
        onPanUpdate: onDragUpdate,
        onPanEnd: onDragEnd,
        child: Container(
          width: element.size.width,
          height: element.size.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.black,
              width: isSelected ? 2.0 : 1.0,
            ),
            color: _getElementColor(),
            borderRadius: _getElementBorderRadius(),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  element.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Positioned(
                  right: -5,
                  top: -5,
                  child: GestureDetector(
                    onTap: () => onConnectionStart(element.id),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getElementColor() {
    switch (element.type) {
      case BpmnElementType.startEvent:
        return Colors.green[100]!;
      case BpmnElementType.endEvent:
        return Colors.red[100]!;
      case BpmnElementType.task:
        return Colors.blue[100]!;
      case BpmnElementType.gateway:
        return Colors.yellow[100]!;
      case BpmnElementType.annotation:
        return Colors.grey[100]!;
      case BpmnElementType.sequenceFlow:
        return Colors.transparent;
    }
  }

  BorderRadius? _getElementBorderRadius() {
    switch (element.type) {
      case BpmnElementType.startEvent:
      case BpmnElementType.endEvent:
        return BorderRadius.circular(element.size.width / 2);
      case BpmnElementType.gateway:
        return BorderRadius.circular(4);
      case BpmnElementType.task:
      case BpmnElementType.annotation:
        return BorderRadius.circular(8);
      case BpmnElementType.sequenceFlow:
        return null;
    }
  }
}

// widgets/sequence_flow_widget.dart

class SequenceFlowWidget extends StatelessWidget {
  final SequenceFlow flow;
  final BpmnElement source;
  final BpmnElement target;
  final bool isSelected;
  final VoidCallback onTap;

  const SequenceFlowWidget({
    super.key,
    required this.flow,
    required this.source,
    required this.target,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sourceCenter =
        source.position + Offset(source.size.width / 2, source.size.height / 2);
    final targetCenter =
        target.position + Offset(target.size.width / 2, target.size.height / 2);

    return CustomPaint(
      painter: SequenceFlowPainter(
        start: sourceCenter,
        end: targetCenter,
        isSelected: isSelected,
        name: flow.name,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
        ),
      ),
    );
  }
}

class SequenceFlowPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final bool isSelected;
  final String? name;

  SequenceFlowPainter({
    required this.start,
    required this.end,
    required this.isSelected,
    this.name,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = isSelected ? Colors.blue : Colors.black
          ..strokeWidth = isSelected ? 2.0 : 1.0
          ..style = PaintingStyle.stroke;

    // Draw line
    canvas.drawLine(start, end, paint);

    // Draw arrowhead
    final direction = (end - start).direction;
    final arrowLength = 8.0;
    final arrowAngle = 0.5;

    final arrowPoint1 =
        end +
        Offset(
          arrowLength * cos(direction + arrowAngle + 3.14159),
          arrowLength * sin(direction + arrowAngle + 3.14159),
        );
    final arrowPoint2 =
        end +
        Offset(
          arrowLength * cos(direction - arrowAngle + 3.14159),
          arrowLength * sin(direction - arrowAngle + 3.14159),
        );

    final arrowPath =
        Path()
          ..moveTo(end.dx, end.dy)
          ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
          ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
          ..close();

    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);

    // Draw name if exists
    if (name != null && name!.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: name!,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 10,
            backgroundColor: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final midPoint = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

      textPainter.paint(
        canvas,
        midPoint - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// widgets/element_palette.dart

class ElementPalette extends ConsumerWidget {
  const ElementPalette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorMode = ref.watch(editorModeProvider);

    return Container(
      width: 80,
      color: Colors.grey[200],
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Elements',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          // Mode buttons
          _buildModeButton(
            context,
            ref,
            'Select',
            Icons.select_all,
            EditorMode.select,
            editorMode,
          ),
          _buildModeButton(
            context,
            ref,
            'Connect',
            Icons.timeline,
            EditorMode.connect,
            editorMode,
          ),
          _buildModeButton(
            context,
            ref,
            'Pan',
            Icons.pan_tool,
            EditorMode.pan,
            editorMode,
          ),
          const Divider(),
          // Element buttons
          _buildElementButton(
            context,
            ref,
            'Start',
            Icons.play_circle_outline,
            BpmnElementType.startEvent,
          ),
          _buildElementButton(
            context,
            ref,
            'Task',
            Icons.assignment,
            BpmnElementType.task,
          ),
          _buildElementButton(
            context,
            ref,
            'Gateway',
            Icons.alt_route,
            BpmnElementType.gateway,
          ),
          _buildElementButton(
            context,
            ref,
            'End',
            Icons.stop_circle_outlined,
            BpmnElementType.endEvent,
          ),
          _buildElementButton(
            context,
            ref,
            'Note',
            Icons.note,
            BpmnElementType.annotation,
          ),
          const Spacer(),
          // Zoom controls
          _buildZoomButton(context, ref, Icons.zoom_in, true),
          _buildZoomButton(context, ref, Icons.zoom_out, false),
          _buildActionButton(context, ref, Icons.center_focus_strong, () {
            ref.read(viewportProvider.notifier).reset();
          }),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    EditorMode mode,
    EditorMode currentMode,
  ) {
    final isActive = currentMode == mode;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: isActive ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => ref.read(editorModeProvider.notifier).state = mode,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isActive ? Colors.white : Colors.black87,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 8,
                    color: isActive ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElementButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    BpmnElementType type,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => _addElement(ref, type),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: Colors.black87),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(fontSize: 8, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomButton(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    bool zoomIn,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {
            final currentScale = ref.read(viewportProvider).scale;
            final newScale = zoomIn ? currentScale * 1.2 : currentScale / 1.2;
            ref.read(viewportProvider.notifier).updateScale(newScale);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 16, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 16, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  void _addElement(WidgetRef ref, BpmnElementType type) {
    final viewport = ref.read(viewportProvider);
    final element = BpmnElement(
      type: type,
      name: _getDefaultName(type),
      position: const Offset(200, 200) - viewport.offset,
    );
    ref.read(bpmnDiagramProvider.notifier).addElement(element);
  }

  String _getDefaultName(BpmnElementType type) {
    switch (type) {
      case BpmnElementType.startEvent:
        return 'Start';
      case BpmnElementType.endEvent:
        return 'End';
      case BpmnElementType.task:
        return 'Task';
      case BpmnElementType.gateway:
        return 'Gateway';
      case BpmnElementType.annotation:
        return 'Note';
      case BpmnElementType.sequenceFlow:
        return 'Flow';
    }
  }
}

// widgets/properties_panel.dart

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedElementId = ref.watch(selectedElementProvider);
    final diagram = ref.watch(bpmnDiagramProvider);

    if (selectedElementId == null) {
      return Container(
        width: 300,
        color: Colors.grey[50],
        child: const Center(
          child: Text('Select an element to view properties'),
        ),
      );
    }

    // Find selected element or flow
    BpmnElement? selectedElement;
    SequenceFlow? selectedFlow;

    try {
      selectedElement = diagram.elements.firstWhere(
        (e) => e.id == selectedElementId,
      );
    } catch (e) {
      try {
        selectedFlow = diagram.sequenceFlows.firstWhere(
          (f) => f.id == selectedElementId,
        );
      } catch (e) {
        // Element not found
      }
    }

    return Container(
      width: 300,
      color: Colors.grey[50],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                const Text(
                  'Properties',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteSelected(ref, selectedElementId),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                selectedElement != null
                    ? _buildElementProperties(ref, selectedElement)
                    : selectedFlow != null
                    ? _buildFlowProperties(ref, selectedFlow)
                    : const Center(child: Text('Element not found')),
          ),
        ],
      ),
    );
  }

  Widget _buildElementProperties(WidgetRef ref, BpmnElement element) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPropertyField(
          'Name',
          element.name,
          (value) =>
              _updateElement(ref, element, element.copyWith(name: value)),
        ),
        const SizedBox(height: 16),
        _buildPropertyField(
          'Documentation',
          element.documentation ?? '',
          (value) => _updateElement(
            ref,
            element,
            element.copyWith(documentation: value),
          ),
        ),
        const SizedBox(height: 16),
        Text('Type: ${element.type.name}'),
        const SizedBox(height: 16),
        Text(
          'Position: (${element.position.dx.toInt()}, ${element.position.dy.toInt()})',
        ),
        const SizedBox(height: 16),
        Text(
          'Size: ${element.size.width.toInt()} x ${element.size.height.toInt()}',
        ),
        const SizedBox(height: 16),
        _buildCustomProperties(ref, element),
      ],
    );
  }

  Widget _buildFlowProperties(WidgetRef ref, SequenceFlow flow) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPropertyField(
          'Name',
          flow.name ?? '',
          (value) => _updateFlow(ref, flow, flow.copyWith(name: value)),
        ),
        const SizedBox(height: 16),
        _buildPropertyField(
          'Condition',
          flow.condition ?? '',
          (value) => _updateFlow(ref, flow, flow.copyWith(condition: value)),
        ),
        const SizedBox(height: 16),
        Text('Source: ${flow.sourceId}'),
        const SizedBox(height: 8),
        Text('Target: ${flow.targetId}'),
      ],
    );
  }

  Widget _buildPropertyField(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCustomProperties(WidgetRef ref, BpmnElement element) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Custom Properties',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addCustomProperty(ref, element),
            ),
          ],
        ),
        ...element.properties.entries.map(
          (entry) => Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(child: Text('${entry.key}: ${entry.value}')),
                IconButton(
                  icon: const Icon(Icons.delete, size: 16),
                  onPressed:
                      () => _removeCustomProperty(ref, element, entry.key),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _updateElement(
    WidgetRef ref,
    BpmnElement element,
    BpmnElement updatedElement,
  ) {
    ref
        .read(bpmnDiagramProvider.notifier)
        .updateElement(element.id, updatedElement);
  }

  void _updateFlow(WidgetRef ref, SequenceFlow flow, SequenceFlow updatedFlow) {
    ref
        .read(bpmnDiagramProvider.notifier)
        .updateSequenceFlow(flow.id, updatedFlow);
  }

  void _deleteSelected(WidgetRef ref, String elementId) {
    ref.read(bpmnDiagramProvider.notifier).removeElement(elementId);
    ref.read(bpmnDiagramProvider.notifier).removeSequenceFlow(elementId);
    ref.read(selectedElementProvider.notifier).state = null;
  }

  void _addCustomProperty(WidgetRef ref, BpmnElement element) {
    final properties = Map<String, dynamic>.from(element.properties);
    properties['property${properties.length + 1}'] = 'value';
    _updateElement(ref, element, element.copyWith(properties: properties));
  }

  void _removeCustomProperty(WidgetRef ref, BpmnElement element, String key) {
    final properties = Map<String, dynamic>.from(element.properties);
    properties.remove(key);
    _updateElement(ref, element, element.copyWith(properties: properties));
  }
}

// bpmn_editor_screen.dart

class BpmnEditorScreen extends ConsumerWidget {
  const BpmnEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagram = ref.watch(bpmnDiagramProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(diagram.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveDiagram(ref),
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () => _loadDiagram(ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _clearDiagram(ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context, ref),
          ),
        ],
      ),
      body: Row(
        children: [
          const ElementPalette(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: const BpmnCanvas(),
            ),
          ),
          const PropertiesPanel(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _exportDiagram(ref),
        child: const Icon(Icons.download),
      ),
    );
  }

  void _saveDiagram(WidgetRef ref) {
    final diagram = ref.read(bpmnDiagramProvider);
    // TODO: Implement save functionality
    print('Saving diagram: ${diagram.toJson()}');
  }

  void _loadDiagram(WidgetRef ref) {
    // TODO: Implement load functionality
    print('Loading diagram');
  }

  void _clearDiagram(WidgetRef ref) {
    ref.read(bpmnDiagramProvider.notifier).clearDiagram();
    ref.read(selectedElementProvider.notifier).state = null;
    ref.read(viewportProvider.notifier).reset();
  }

  void _exportDiagram(WidgetRef ref) {
    final diagram = ref.read(bpmnDiagramProvider);
    // TODO: Implement export functionality (XML, JSON, etc.)
    print('Exporting diagram: ${diagram.toJson()}');
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Grid Size'),
                  trailing: const Text('20px'),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Auto-save'),
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),
                ListTile(
                  title: const Text('Snap to Grid'),
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

// services/bpmn_xml_service.dart

class BpmnXmlService {
  static String exportToXml(BpmnDiagram diagram) {
    final buffer = StringBuffer();

    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
      '<bpmn:definitions xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL"',
    );
    buffer.writeln('  xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI"');
    buffer.writeln('  xmlns:dc="http://www.omg.org/spec/DD/20100524/DC"');
    buffer.writeln('  xmlns:di="http://www.omg.org/spec/DD/20100524/DI"');
    buffer.writeln('  id="Definitions_${diagram.id}"');
    buffer.writeln('  targetNamespace="http://bpmn.io/schema/bpmn">');

    buffer.writeln(
      '  <bpmn:process id="Process_${diagram.id}" isExecutable="true">',
    );

    // Export elements
    for (final element in diagram.elements) {
      _writeElement(buffer, element);
    }

    // Export sequence flows
    for (final flow in diagram.sequenceFlows) {
      _writeSequenceFlow(buffer, flow);
    }

    buffer.writeln('  </bpmn:process>');

    // Export diagram information
    buffer.writeln('  <bpmndi:BPMNDiagram id="BPMNDiagram_${diagram.id}">');
    buffer.writeln(
      '    <bpmndi:BPMNPlane id="BPMNPlane_${diagram.id}" bpmnElement="Process_${diagram.id}">',
    );

    // Export shapes
    for (final element in diagram.elements) {
      _writeShape(buffer, element);
    }

    // Export edges
    for (final flow in diagram.sequenceFlows) {
      _writeEdge(buffer, flow, diagram.elements);
    }

    buffer.writeln('    </bpmndi:BPMNPlane>');
    buffer.writeln('  </bpmndi:BPMNDiagram>');
    buffer.writeln('</bpmn:definitions>');

    return buffer.toString();
  }

  static void _writeElement(StringBuffer buffer, BpmnElement element) {
    switch (element.type) {
      case BpmnElementType.startEvent:
        buffer.writeln(
          '    <bpmn:startEvent id="${element.id}" name="${element.name}">',
        );
        if (element.outgoingFlows.isNotEmpty) {
          element.outgoingFlows.forEach((flow) {
            buffer.writeln('      <bpmn:outgoing>$flow</bpmn:outgoing>');
          });
        }
        buffer.writeln('    </bpmn:startEvent>');
        break;
      case BpmnElementType.endEvent:
        buffer.writeln(
          '    <bpmn:endEvent id="${element.id}" name="${element.name}">',
        );
        if (element.incomingFlows.isNotEmpty) {
          element.incomingFlows.forEach((flow) {
            buffer.writeln('      <bpmn:incoming>$flow</bpmn:incoming>');
          });
        }
        buffer.writeln('    </bpmn:endEvent>');
        break;
      case BpmnElementType.task:
        buffer.writeln(
          '    <bpmn:task id="${element.id}" name="${element.name}">',
        );
        element.incomingFlows.forEach((flow) {
          buffer.writeln('      <bpmn:incoming>$flow</bpmn:incoming>');
        });
        element.outgoingFlows.forEach((flow) {
          buffer.writeln('      <bpmn:outgoing>$flow</bpmn:outgoing>');
        });
        buffer.writeln('    </bpmn:task>');
        break;
      case BpmnElementType.gateway:
        buffer.writeln(
          '    <bpmn:exclusiveGateway id="${element.id}" name="${element.name}">',
        );
        element.incomingFlows.forEach((flow) {
          buffer.writeln('      <bpmn:incoming>$flow</bpmn:incoming>');
        });
        element.outgoingFlows.forEach((flow) {
          buffer.writeln('      <bpmn:outgoing>$flow</bpmn:outgoing>');
        });
        buffer.writeln('    </bpmn:exclusiveGateway>');
        break;
      default:
        break;
    }
  }

  static void _writeSequenceFlow(StringBuffer buffer, SequenceFlow flow) {
    buffer.write(
      '    <bpmn:sequenceFlow id="${flow.id}" sourceRef="${flow.sourceId}" targetRef="${flow.targetId}"',
    );
    if (flow.name != null && flow.name!.isNotEmpty) {
      buffer.write(' name="${flow.name}"');
    }
    buffer.writeln(' />');
  }

  static void _writeShape(StringBuffer buffer, BpmnElement element) {
    buffer.writeln(
      '      <bpmndi:BPMNShape id="BPMNShape_${element.id}" bpmnElement="${element.id}">',
    );
    buffer.writeln(
      '        <dc:Bounds x="${element.position.dx}" y="${element.position.dy}" width="${element.size.width}" height="${element.size.height}" />',
    );
    buffer.writeln('      </bpmndi:BPMNShape>');
  }

  static void _writeEdge(
    StringBuffer buffer,
    SequenceFlow flow,
    List<BpmnElement> elements,
  ) {
    final source = elements.firstWhere((e) => e.id == flow.sourceId);
    final target = elements.firstWhere((e) => e.id == flow.targetId);

    buffer.writeln(
      '      <bpmndi:BPMNEdge id="BPMNEdge_${flow.id}" bpmnElement="${flow.id}">',
    );
    buffer.writeln(
      '        <di:waypoint x="${source.position.dx + source.size.width / 2}" y="${source.position.dy + source.size.height / 2}" />',
    );
    buffer.writeln(
      '        <di:waypoint x="${target.position.dx + target.size.width / 2}" y="${target.position.dy + target.size.height / 2}" />',
    );
    buffer.writeln('      </bpmndi:BPMNEdge>');
  }
}

// utils/bpmn_validation.dart
class BpmnValidation {
  static List<String> validateDiagram(BpmnDiagram diagram) {
    final errors = <String>[];

    // Check for start events
    final startEvents = diagram.elements.where(
      (e) => e.type == BpmnElementType.startEvent,
    );
    if (startEvents.isEmpty) {
      errors.add('Process must have at least one start event');
    }

    // Check for end events
    final endEvents = diagram.elements.where(
      (e) => e.type == BpmnElementType.endEvent,
    );
    if (endEvents.isEmpty) {
      errors.add('Process must have at least one end event');
    }

    // Check for orphaned elements
    for (final element in diagram.elements) {
      if (element.type != BpmnElementType.startEvent &&
          element.incomingFlows.isEmpty) {
        errors.add('Element "${element.name}" has no incoming flows');
      }
      if (element.type != BpmnElementType.endEvent &&
          element.outgoingFlows.isEmpty) {
        errors.add('Element "${element.name}" has no outgoing flows');
      }
    }

    // Check for valid connections
    for (final flow in diagram.sequenceFlows) {
      final sourceExists = diagram.elements.any((e) => e.id == flow.sourceId);
      final targetExists = diagram.elements.any((e) => e.id == flow.targetId);

      if (!sourceExists) {
        errors.add(
          'Sequence flow references non-existent source: ${flow.sourceId}',
        );
      }
      if (!targetExists) {
        errors.add(
          'Sequence flow references non-existent target: ${flow.targetId}',
        );
      }
    }

    return errors;
  }
}

// Generated files would be created by running:
// dart run build_runner build

// This is a placeholder for the generated code
// bpmn_element.g.dart
/*
part of 'bpmn_element.dart';

// ... Generated JSON serialization code would go here
*/
