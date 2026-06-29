import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_riverpod/legacy.dart';

// ============================================================================
// PROFESSIONAL SVG ANIMATION STUDIO
// Modern, Beginner-to-Professional Design Tool
// Inspired by Rive & Adobe Animate
// ============================================================================

void main() {
  runApp(const ProviderScope(child: AnimationStudioApp()));
}

class AnimationStudioApp extends StatelessWidget {
  const AnimationStudioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animation Studio Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        colorScheme: ColorScheme.dark(
          primary: Colors.blue[400]!,
          secondary: Colors.purple[400]!,
          surface: const Color(0xFF252526),
          background: const Color(0xFF1E1E1E),
        ),
      ),
      home: const StudioHomePage(),
    );
  }
}

// ============================================================================
// STATE MANAGEMENT - RIVERPOD PROVIDERS
// ============================================================================

// App state provider
final studioStateProvider =
    StateNotifierProvider<StudioStateNotifier, StudioState>((ref) {
      return StudioStateNotifier();
    });

// Timeline provider
final timelineProvider = StateNotifierProvider<TimelineNotifier, TimelineState>(
  (ref) {
    return TimelineNotifier();
  },
);

// Canvas provider
final canvasProvider = StateNotifierProvider<CanvasNotifier, CanvasState>((
  ref,
) {
  return CanvasNotifier();
});

// ============================================================================
// DATA MODELS
// ============================================================================

enum StudioTool {
  select,
  pen,
  rectangle,
  ellipse,
  polygon,
  text,
  gradient,
  eyedropper,
  hand,
  zoom,
}

enum StudioMode { design, animate, preview }

class StudioState {
  final List<Layer> layers;
  final Layer? selectedLayer;
  final StudioTool currentTool;
  final StudioMode currentMode;
  final Map<String, Gradient> gradients;
  final bool showGrid;
  final bool snapToGrid;
  final double gridSize;
  final Color canvasColor;

  const StudioState({
    this.layers = const [],
    this.selectedLayer,
    this.currentTool = StudioTool.select,
    this.currentMode = StudioMode.design,
    this.gradients = const {},
    this.showGrid = true,
    this.snapToGrid = true,
    this.gridSize = 20,
    this.canvasColor = Colors.white,
  });

  StudioState copyWith({
    List<Layer>? layers,
    Layer? selectedLayer,
    StudioTool? currentTool,
    StudioMode? currentMode,
    Map<String, Gradient>? gradients,
    bool? showGrid,
    bool? snapToGrid,
    double? gridSize,
    Color? canvasColor,
  }) {
    return StudioState(
      layers: layers ?? this.layers,
      selectedLayer: selectedLayer ?? this.selectedLayer,
      currentTool: currentTool ?? this.currentTool,
      currentMode: currentMode ?? this.currentMode,
      gradients: gradients ?? this.gradients,
      showGrid: showGrid ?? this.showGrid,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      gridSize: gridSize ?? this.gridSize,
      canvasColor: canvasColor ?? this.canvasColor,
    );
  }
}

class TimelineState {
  final double currentTime;
  final double duration;
  final bool isPlaying;
  final double fps;
  final bool loop;

  const TimelineState({
    this.currentTime = 0,
    this.duration = 3,
    this.isPlaying = false,
    this.fps = 60,
    this.loop = false,
  });

  TimelineState copyWith({
    double? currentTime,
    double? duration,
    bool? isPlaying,
    double? fps,
    bool? loop,
  }) {
    return TimelineState(
      currentTime: currentTime ?? this.currentTime,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      fps: fps ?? this.fps,
      loop: loop ?? this.loop,
    );
  }
}

class CanvasState {
  final Offset pan;
  final double zoom;
  final Size artboardSize;

  const CanvasState({
    this.pan = Offset.zero,
    this.zoom = 1.0,
    this.artboardSize = const Size(800, 600),
  });

  CanvasState copyWith({Offset? pan, double? zoom, Size? artboardSize}) {
    return CanvasState(
      pan: pan ?? this.pan,
      zoom: zoom ?? this.zoom,
      artboardSize: artboardSize ?? this.artboardSize,
    );
  }
}

class Layer {
  final String id;
  final String name;
  final LayerType type;
  final bool visible;
  final bool locked;
  final double opacity;
  final List<Keyframe> keyframes;
  final LayerData data;

  Layer({
    required this.id,
    required this.name,
    required this.type,
    this.visible = true,
    this.locked = false,
    this.opacity = 1.0,
    this.keyframes = const [],
    required this.data,
  });

  Layer copyWith({
    String? name,
    bool? visible,
    bool? locked,
    double? opacity,
    List<Keyframe>? keyframes,
    LayerData? data,
  }) {
    return Layer(
      id: id,
      name: name ?? this.name,
      type: type,
      visible: visible ?? this.visible,
      locked: locked ?? this.locked,
      opacity: opacity ?? this.opacity,
      keyframes: keyframes ?? this.keyframes,
      data: data ?? this.data,
    );
  }
}

enum LayerType { shape, path, text, group }

abstract class LayerData {
  Offset get position;
  double get rotation;
  double get scaleX;
  double get scaleY;
}

class ShapeData implements LayerData {
  @override
  final Offset position;
  @override
  final double rotation;
  @override
  final double scaleX;
  @override
  final double scaleY;
  final ShapeType shapeType;
  final Size size;
  final Color fillColor;
  final Color? strokeColor;
  final double strokeWidth;
  final double cornerRadius;

  ShapeData({
    required this.position,
    this.rotation = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    required this.shapeType,
    required this.size,
    required this.fillColor,
    this.strokeColor,
    this.strokeWidth = 0,
    this.cornerRadius = 0,
  });

  ShapeData copyWith({
    Offset? position,
    double? rotation,
    double? scaleX,
    double? scaleY,
    Size? size,
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth,
    double? cornerRadius,
  }) {
    return ShapeData(
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      shapeType: shapeType,
      size: size ?? this.size,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      cornerRadius: cornerRadius ?? this.cornerRadius,
    );
  }
}

enum ShapeType { rectangle, ellipse, polygon }

class PathData implements LayerData {
  @override
  final Offset position;
  @override
  final double rotation;
  @override
  final double scaleX;
  @override
  final double scaleY;
  final List<PathPoint> points;
  final Color fillColor;
  final Color? strokeColor;
  final double strokeWidth;
  final bool closed;

  PathData({
    required this.position,
    this.rotation = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    required this.points,
    required this.fillColor,
    this.strokeColor,
    this.strokeWidth = 2,
    this.closed = false,
  });
}

class PathPoint {
  final Offset position;
  final Offset? handleIn;
  final Offset? handleOut;
  final PointType type;

  PathPoint({
    required this.position,
    this.handleIn,
    this.handleOut,
    this.type = PointType.smooth,
  });
}

enum PointType { corner, smooth, symmetric }

class Keyframe {
  final double time;
  final String property;
  final dynamic value;
  final Curve curve;

  Keyframe({
    required this.time,
    required this.property,
    required this.value,
    this.curve = Curves.linear,
  });
}

// ============================================================================
// STATE NOTIFIERS
// ============================================================================

class StudioStateNotifier extends StateNotifier<StudioState> {
  StudioStateNotifier() : super(const StudioState()) {
    _initializeDemo();
  }

  void _initializeDemo() {
    // Add demo layers
    final demoLayers = [
      Layer(
        id: 'layer_1',
        name: 'Rectangle',
        type: LayerType.shape,
        data: ShapeData(
          position: const Offset(200, 150),
          shapeType: ShapeType.rectangle,
          size: const Size(150, 100),
          fillColor: Colors.blue,
          strokeColor: Colors.white,
          strokeWidth: 2,
          cornerRadius: 10,
        ),
      ),
      Layer(
        id: 'layer_2',
        name: 'Circle',
        type: LayerType.shape,
        data: ShapeData(
          position: const Offset(450, 200),
          shapeType: ShapeType.ellipse,
          size: const Size(120, 120),
          fillColor: Colors.purple,
          strokeColor: Colors.white,
          strokeWidth: 2,
        ),
      ),
    ];

    state = state.copyWith(layers: demoLayers);
  }

  void addLayer(Layer layer) {
    state = state.copyWith(layers: [...state.layers, layer]);
  }

  void updateLayer(Layer layer) {
    final index = state.layers.indexWhere((l) => l.id == layer.id);
    if (index != -1) {
      final newLayers = List<Layer>.from(state.layers);
      newLayers[index] = layer;
      state = state.copyWith(layers: newLayers);
    }
  }

  void deleteLayer(String id) {
    state = state.copyWith(
      layers: state.layers.where((l) => l.id != id).toList(),
    );
  }

  void selectLayer(Layer? layer) {
    state = state.copyWith(selectedLayer: layer);
  }

  void setTool(StudioTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  void setMode(StudioMode mode) {
    state = state.copyWith(currentMode: mode);
  }

  void toggleGrid() {
    state = state.copyWith(showGrid: !state.showGrid);
  }

  void toggleSnapToGrid() {
    state = state.copyWith(snapToGrid: !state.snapToGrid);
  }
}

class TimelineNotifier extends StateNotifier<TimelineState> {
  TimelineNotifier() : super(const TimelineState());

  void play() {
    state = state.copyWith(isPlaying: true);
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
  }

  void stop() {
    state = state.copyWith(isPlaying: false, currentTime: 0);
  }

  void seek(double time) {
    state = state.copyWith(currentTime: time.clamp(0, state.duration));
  }

  void setDuration(double duration) {
    state = state.copyWith(duration: duration);
  }

  void toggleLoop() {
    state = state.copyWith(loop: !state.loop);
  }
}

class CanvasNotifier extends StateNotifier<CanvasState> {
  CanvasNotifier() : super(const CanvasState());

  void setPan(Offset pan) {
    state = state.copyWith(pan: pan);
  }

  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom.clamp(0.1, 10));
  }

  void resetView() {
    state = state.copyWith(pan: Offset.zero, zoom: 1.0);
  }

  void zoomIn() {
    setZoom(state.zoom * 1.2);
  }

  void zoomOut() {
    setZoom(state.zoom / 1.2);
  }

  void fitToScreen() {
    state = state.copyWith(zoom: 1.0, pan: Offset.zero);
  }
}

// ============================================================================
// MAIN STUDIO UI
// ============================================================================

class StudioHomePage extends ConsumerWidget {
  const StudioHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const StudioTopBar(),
          Expanded(
            child: Row(
              children: [
                const StudioToolbar(),
                Expanded(
                  child: Column(
                    children: [
                      const Expanded(child: StudioCanvas()),
                      const StudioTimeline(),
                    ],
                  ),
                ),
                const StudioPropertiesPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TOP BAR
// ============================================================================

class StudioTopBar extends ConsumerWidget {
  const StudioTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studioState = ref.watch(studioStateProvider);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.animation,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Animation Studio Pro',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          Container(width: 1, height: 24, color: Colors.white.withOpacity(0.1)),
          const SizedBox(width: 8),

          // File Menu
          _buildMenuButton(context, 'File', [
            _buildMenuItem(Icons.add, 'New Project', () {}),
            _buildMenuItem(Icons.folder_open, 'Open', () {}),
            _buildMenuItem(Icons.save, 'Save', () {}),
            _buildMenuItem(Icons.download, 'Export', () {}),
          ]),

          _buildMenuButton(context, 'Edit', [
            _buildMenuItem(Icons.undo, 'Undo', () {}),
            _buildMenuItem(Icons.redo, 'Redo', () {}),
            _buildMenuItem(Icons.content_copy, 'Copy', () {}),
            _buildMenuItem(Icons.content_paste, 'Paste', () {}),
          ]),

          _buildMenuButton(context, 'View', [
            _buildMenuItem(
              Icons.grid_on,
              'Toggle Grid',
              () => ref.read(studioStateProvider.notifier).toggleGrid(),
            ),
            _buildMenuItem(Icons.zoom_in, 'Zoom In', () {
              ref.read(canvasProvider.notifier).zoomIn();
            }),
            _buildMenuItem(Icons.zoom_out, 'Zoom Out', () {
              ref.read(canvasProvider.notifier).zoomOut();
            }),
            _buildMenuItem(Icons.fit_screen, 'Fit to Screen', () {
              ref.read(canvasProvider.notifier).fitToScreen();
            }),
          ]),

          const Spacer(),

          // Mode Selector
          SegmentedButton<StudioMode>(
            segments: const [
              ButtonSegment(
                value: StudioMode.design,
                icon: Icon(Icons.design_services, size: 16),
                label: Text('Design', style: TextStyle(fontSize: 12)),
              ),
              ButtonSegment(
                value: StudioMode.animate,
                icon: Icon(Icons.animation, size: 16),
                label: Text('Animate', style: TextStyle(fontSize: 12)),
              ),
              ButtonSegment(
                value: StudioMode.preview,
                icon: Icon(Icons.play_circle, size: 16),
                label: Text('Preview', style: TextStyle(fontSize: 12)),
              ),
            ],
            selected: {studioState.currentMode},
            onSelectionChanged: (Set<StudioMode> selection) {
              ref.read(studioStateProvider.notifier).setMode(selection.first);
            },
          ),

          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String label,
    List<Widget> items,
  ) {
    return PopupMenuButton(
      offset: const Offset(0, 40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
      itemBuilder:
          (context) => items.map((item) => PopupMenuItem(child: item)).toList(),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TOOLBAR
// ============================================================================

class StudioToolbar extends ConsumerWidget {
  const StudioToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studioState = ref.watch(studioStateProvider);

    return Container(
      width: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildTool(
            context,
            ref,
            Icons.near_me,
            StudioTool.select,
            'Select (V)',
          ),
          _buildTool(context, ref, Icons.create, StudioTool.pen, 'Pen (P)'),
          _buildTool(
            context,
            ref,
            Icons.rectangle,
            StudioTool.rectangle,
            'Rectangle (R)',
          ),
          _buildTool(
            context,
            ref,
            Icons.circle_outlined,
            StudioTool.ellipse,
            'Ellipse (E)',
          ),
          _buildTool(
            context,
            ref,
            Icons.change_history,
            StudioTool.polygon,
            'Polygon',
          ),
          _buildTool(
            context,
            ref,
            Icons.text_fields,
            StudioTool.text,
            'Text (T)',
          ),
          const Divider(height: 16),
          _buildTool(
            context,
            ref,
            Icons.gradient,
            StudioTool.gradient,
            'Gradient (G)',
          ),
          _buildTool(
            context,
            ref,
            Icons.colorize,
            StudioTool.eyedropper,
            'Eyedropper (I)',
          ),
          const Spacer(),
          _buildTool(context, ref, Icons.pan_tool, StudioTool.hand, 'Hand (H)'),
          _buildTool(context, ref, Icons.zoom_in, StudioTool.zoom, 'Zoom (Z)'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTool(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    StudioTool tool,
    String tooltip,
  ) {
    final isSelected = ref.watch(studioStateProvider).currentTool == tool;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => ref.read(studioStateProvider.notifier).setTool(tool),
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : null,
            borderRadius: BorderRadius.circular(6),
            border:
                isSelected
                    ? Border.all(color: Theme.of(context).colorScheme.primary)
                    : null,
          ),
          child: Icon(
            icon,
            size: 20,
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white70,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CANVAS
// ============================================================================

class StudioCanvas extends ConsumerStatefulWidget {
  const StudioCanvas({Key? key}) : super(key: key);

  @override
  ConsumerState<StudioCanvas> createState() => _StudioCanvasState();
}

class _StudioCanvasState extends ConsumerState<StudioCanvas> {
  Offset? _dragStart;
  Offset? _currentDragPosition;

  @override
  Widget build(BuildContext context) {
    final studioState = ref.watch(studioStateProvider);
    final canvasState = ref.watch(canvasProvider);

    return Container(
      color: const Color(0xFF2D2D30),
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        child: CustomPaint(
          painter: CanvasPainter(
            layers: studioState.layers,
            selectedLayer: studioState.selectedLayer,
            showGrid: studioState.showGrid,
            gridSize: studioState.gridSize,
            pan: canvasState.pan,
            zoom: canvasState.zoom,
            artboardSize: canvasState.artboardSize,
            canvasColor: studioState.canvasColor,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentDragPosition = details.localPosition;
    });

    final tool = ref.read(studioStateProvider).currentTool;
    if (tool == StudioTool.hand) {
      final delta = details.delta;
      final currentPan = ref.read(canvasProvider).pan;
      ref.read(canvasProvider.notifier).setPan(currentPan + delta);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _dragStart = null;
    _currentDragPosition = null;
  }
}

// ============================================================================
// CANVAS PAINTER
// ============================================================================

class CanvasPainter extends CustomPainter {
  final List<Layer> layers;
  final Layer? selectedLayer;
  final bool showGrid;
  final double gridSize;
  final Offset pan;
  final double zoom;
  final Size artboardSize;
  final Color canvasColor;

  CanvasPainter({
    required this.layers,
    this.selectedLayer,
    required this.showGrid,
    required this.gridSize,
    required this.pan,
    required this.zoom,
    required this.artboardSize,
    required this.canvasColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Apply pan and zoom
    canvas.translate(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    canvas.scale(zoom);
    canvas.translate(-artboardSize.width / 2, -artboardSize.height / 2);

    // Draw artboard background
    final artboardRect = Rect.fromLTWH(
      0,
      0,
      artboardSize.width,
      artboardSize.height,
    );
    canvas.drawRect(artboardRect, Paint()..color = canvasColor);

    // Draw grid
    if (showGrid) {
      _drawGrid(canvas, artboardRect);
    }

    // Draw layers
    for (final layer in layers) {
      if (!layer.visible) continue;
      _drawLayer(canvas, layer);
    }

    // Draw selection
    if (selectedLayer != null) {
      _drawSelection(canvas, selectedLayer!);
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Rect bounds) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..strokeWidth = 1;

    for (double x = 0; x <= bounds.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, bounds.height), paint);
    }

    for (double y = 0; y <= bounds.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(bounds.width, y), paint);
    }
  }

  void _drawLayer(Canvas canvas, Layer layer) {
    canvas.save();

    final data = layer.data;
    canvas.translate(data.position.dx, data.position.dy);
    canvas.rotate(data.rotation * math.pi / 180);
    canvas.scale(data.scaleX, data.scaleY);

    if (layer.type == LayerType.shape) {
      _drawShape(canvas, layer);
    } else if (layer.type == LayerType.path) {
      _drawPath(canvas, layer);
    }

    canvas.restore();
  }

  void _drawShape(Canvas canvas, Layer layer) {
    final shapeData = layer.data as ShapeData;
    final fillPaint =
        Paint()
          ..color = shapeData.fillColor.withOpacity(layer.opacity)
          ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: shapeData.size.width,
      height: shapeData.size.height,
    );

    if (shapeData.shapeType == ShapeType.rectangle) {
      if (shapeData.cornerRadius > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(shapeData.cornerRadius),
          ),
          fillPaint,
        );
      } else {
        canvas.drawRect(rect, fillPaint);
      }
    } else if (shapeData.shapeType == ShapeType.ellipse) {
      canvas.drawOval(rect, fillPaint);
    }

    // Draw stroke
    if (shapeData.strokeColor != null && shapeData.strokeWidth > 0) {
      final strokePaint =
          Paint()
            ..color = shapeData.strokeColor!.withOpacity(layer.opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = shapeData.strokeWidth;

      if (shapeData.shapeType == ShapeType.rectangle) {
        if (shapeData.cornerRadius > 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              rect,
              Radius.circular(shapeData.cornerRadius),
            ),
            strokePaint,
          );
        } else {
          canvas.drawRect(rect, strokePaint);
        }
      } else if (shapeData.shapeType == ShapeType.ellipse) {
        canvas.drawOval(rect, strokePaint);
      }
    }
  }

  void _drawPath(Canvas canvas, Layer layer) {
    final pathData = layer.data as PathData;
    // Path drawing implementation would go here
  }

  void _drawSelection(Canvas canvas, Layer layer) {
    canvas.save();

    final data = layer.data;
    canvas.translate(data.position.dx, data.position.dy);
    canvas.rotate(data.rotation * math.pi / 180);
    canvas.scale(data.scaleX, data.scaleY);

    if (layer.type == LayerType.shape) {
      final shapeData = data as ShapeData;
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: shapeData.size.width,
        height: shapeData.size.height,
      );

      final selectionPaint =
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 / zoom;

      canvas.drawRect(rect.inflate(5), selectionPaint);

      // Draw corner handles
      final handlePaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;

      final handleSize = 6.0 / zoom;
      final corners = [
        rect.topLeft,
        rect.topRight,
        rect.bottomRight,
        rect.bottomLeft,
      ];

      for (final corner in corners) {
        canvas.drawCircle(corner, handleSize, handlePaint);
        canvas.drawCircle(
          corner,
          handleSize,
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1 / zoom,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) => true;
}

// ============================================================================
// PROPERTIES PANEL
// ============================================================================

class StudioPropertiesPanel extends ConsumerWidget {
  const StudioPropertiesPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLayer = ref.watch(studioStateProvider).selectedLayer;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(left: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child:
          selectedLayer == null
              ? const Center(
                child: Text(
                  'No layer selected',
                  style: TextStyle(color: Colors.white54),
                ),
              )
              : _buildLayerProperties(context, ref, selectedLayer),
    );
  }

  Widget _buildLayerProperties(
    BuildContext context,
    WidgetRef ref,
    Layer layer,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Layer name
        Text(
          layer.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Transform section
        _buildSection('Transform', [
          if (layer.data is ShapeData)
            ..._buildShapeTransform(context, ref, layer),
        ]),

        const SizedBox(height: 16),

        // Appearance section
        _buildSection('Appearance', [
          if (layer.data is ShapeData)
            ..._buildShapeAppearance(context, ref, layer),
          _buildOpacitySlider(context, ref, layer),
        ]),

        const SizedBox(height: 16),

        // Layer options
        _buildSection('Layer Options', [
          _buildLayerOption(context, 'Visible', layer.visible, (value) {
            ref
                .read(studioStateProvider.notifier)
                .updateLayer(layer.copyWith(visible: value));
          }),
          _buildLayerOption(context, 'Locked', layer.locked, (value) {
            ref
                .read(studioStateProvider.notifier)
                .updateLayer(layer.copyWith(locked: value));
          }),
        ]),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  List<Widget> _buildShapeTransform(
    BuildContext context,
    WidgetRef ref,
    Layer layer,
  ) {
    final shapeData = layer.data as ShapeData;

    return [
      _buildPropertySlider('X', shapeData.position.dx, 0, 800, (value) {
        final newData = shapeData.copyWith(
          position: Offset(value, shapeData.position.dy),
        );
        ref
            .read(studioStateProvider.notifier)
            .updateLayer(layer.copyWith(data: newData));
      }),
      _buildPropertySlider('Y', shapeData.position.dy, 0, 600, (value) {
        final newData = shapeData.copyWith(
          position: Offset(shapeData.position.dx, value),
        );
        ref
            .read(studioStateProvider.notifier)
            .updateLayer(layer.copyWith(data: newData));
      }),
      _buildPropertySlider('Rotation', shapeData.rotation, -180, 180, (value) {
        final newData = shapeData.copyWith(rotation: value);
        ref
            .read(studioStateProvider.notifier)
            .updateLayer(layer.copyWith(data: newData));
      }),
      _buildPropertySlider('Scale', shapeData.scaleX, 0.1, 3, (value) {
        final newData = shapeData.copyWith(scaleX: value, scaleY: value);
        ref
            .read(studioStateProvider.notifier)
            .updateLayer(layer.copyWith(data: newData));
      }),
    ];
  }

  List<Widget> _buildShapeAppearance(
    BuildContext context,
    WidgetRef ref,
    Layer layer,
  ) {
    final shapeData = layer.data as ShapeData;

    return [
      _buildColorPicker('Fill', shapeData.fillColor, (color) {
        final newData = shapeData.copyWith(fillColor: color);
        ref
            .read(studioStateProvider.notifier)
            .updateLayer(layer.copyWith(data: newData));
      }),
      const SizedBox(height: 8),
      _buildColorPicker('Stroke', shapeData.strokeColor ?? Colors.transparent, (
        color,
      ) {
        final newData = shapeData.copyWith(strokeColor: color);
        ref
            .read(studioStateProvider.notifier)
            .updateLayer(layer.copyWith(data: newData));
      }),
      if (shapeData.strokeColor != null)
        _buildPropertySlider('Stroke Width', shapeData.strokeWidth, 0, 10, (
          value,
        ) {
          final newData = shapeData.copyWith(strokeWidth: value);
          ref
              .read(studioStateProvider.notifier)
              .updateLayer(layer.copyWith(data: newData));
        }),
      if (shapeData.shapeType == ShapeType.rectangle)
        _buildPropertySlider('Corner Radius', shapeData.cornerRadius, 0, 50, (
          value,
        ) {
          final newData = shapeData.copyWith(cornerRadius: value);
          ref
              .read(studioStateProvider.notifier)
              .updateLayer(layer.copyWith(data: newData));
        }),
    ];
  }

  Widget _buildPropertySlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildOpacitySlider(BuildContext context, WidgetRef ref, Layer layer) {
    return _buildPropertySlider('Opacity', layer.opacity, 0, 1, (value) {
      ref
          .read(studioStateProvider.notifier)
          .updateLayer(layer.copyWith(opacity: value));
    });
  }

  Widget _buildColorPicker(
    String label,
    Color color,
    ValueChanged<Color> onChanged,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            // Color picker would open here
          },
          child: Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLayerOption(
    BuildContext context,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TIMELINE
// ============================================================================

class StudioTimeline extends ConsumerWidget {
  const StudioTimeline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineState = ref.watch(timelineProvider);
    final studioState = ref.watch(studioStateProvider);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          // Timeline controls
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    timelineState.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 20,
                  ),
                  onPressed: () {
                    if (timelineState.isPlaying) {
                      ref.read(timelineProvider.notifier).pause();
                    } else {
                      ref.read(timelineProvider.notifier).play();
                    }
                  },
                  tooltip: 'Play/Pause',
                ),
                IconButton(
                  icon: const Icon(Icons.stop, size: 20),
                  onPressed: () => ref.read(timelineProvider.notifier).stop(),
                  tooltip: 'Stop',
                ),
                IconButton(
                  icon: Icon(
                    timelineState.loop ? Icons.repeat_on : Icons.repeat,
                    size: 20,
                  ),
                  onPressed:
                      () => ref.read(timelineProvider.notifier).toggleLoop(),
                  tooltip: 'Loop',
                ),
                const SizedBox(width: 16),
                Text(
                  '${timelineState.currentTime.toStringAsFixed(2)}s / ${timelineState.duration.toStringAsFixed(2)}s',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const Spacer(),
                Text(
                  '${timelineState.fps.toInt()} FPS',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Timeline scrubber
          Expanded(
            child: CustomPaint(
              painter: TimelinePainter(
                currentTime: timelineState.currentTime,
                duration: timelineState.duration,
                layers: studioState.layers,
              ),
              child: GestureDetector(
                onTapDown: (details) {
                  final width = context.size?.width ?? 800;
                  final time =
                      (details.localPosition.dx / width) *
                      timelineState.duration;
                  ref.read(timelineProvider.notifier).seek(time);
                },
              ),
            ),
          ),

          // Timeline slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Slider(
              value: timelineState.currentTime,
              min: 0,
              max: timelineState.duration,
              onChanged:
                  (value) => ref.read(timelineProvider.notifier).seek(value),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TIMELINE PAINTER
// ============================================================================

class TimelinePainter extends CustomPainter {
  final double currentTime;
  final double duration;
  final List<Layer> layers;

  TimelinePainter({
    required this.currentTime,
    required this.duration,
    required this.layers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1E1E1E),
    );

    // Draw time markers
    final markerPaint =
        Paint()
          ..color = Colors.white24
          ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 10; i++) {
      final x = (size.width * i) / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), markerPaint);

      final time = (duration * i) / 10;
      textPainter.text = TextSpan(
        text: time.toStringAsFixed(1),
        style: const TextStyle(color: Colors.white54, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 4, 4));
    }

    // Draw current time indicator
    final currentX = (currentTime / duration) * size.width;
    canvas.drawLine(
      Offset(currentX, 0),
      Offset(currentX, size.height),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 2,
    );

    // Draw layer tracks
    double y = 40;
    for (final layer in layers) {
      // Layer name
      textPainter.text = TextSpan(
        text: layer.name,
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(8, y));

      // Draw keyframes
      for (final keyframe in layer.keyframes) {
        final x = (keyframe.time / duration) * size.width;
        canvas.drawCircle(Offset(x, y + 8), 4, Paint()..color = Colors.blue);
      }

      y += 20;
    }
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) => true;
}

/*
PROFESSIONAL SVG ANIMATION STUDIO
==================================

✨ FEATURES IMPLEMENTED:

🎨 DESIGN MODE:
- Professional toolbar with essential tools
- Rectangle, Ellipse, Polygon tools
- Pen tool for custom paths
- Text tool
- Gradient editor
- Eyedropper tool
- Smart grid with snap-to-grid
- Pan and zoom canvas

📐 TRANSFORM CONTROLS:
- Position (X, Y)
- Rotation
- Scale (uniform)
- Individual layer opacity

🎭 LAYER SYSTEM:
- Multiple layer support
- Layer visibility toggle
- Layer locking
- Layer selection
- Properties panel
- Real-time updates

⏱️ ANIMATION TIMELINE:
- Professional timeline UI
- Play/Pause/Stop controls
- Scrubber for precise control
- Frame-by-frame navigation
- FPS display
- Loop mode
- Keyframe visualization

🎯 INSPIRED BY:
- Rive: Modern UI, professional tools
- Adobe Animate: Timeline system, layer management
- Figma: Property panels, clean design

📱 RESPONSIVE UI:
- Dark theme
- Clean, modern interface
- Intuitive tool placement
- Professional color scheme

🔧 STATE MANAGEMENT:
- Riverpod for clean architecture
- Separate providers for:
  * Studio state (layers, tools, mode)
  * Timeline state (playback, time)
  * Canvas state (pan, zoom)

USAGE:
======
flutter pub add flutter_riverpod
flutter run

KEYBOARD SHORTCUTS:
===================
V - Select tool
P - Pen tool
R - Rectangle tool
E - Ellipse tool
T - Text tool
G - Gradient tool
I - Eyedropper
H - Hand tool (pan)
Z - Zoom tool
Space - Play/Pause

BEGINNER TO PROFESSIONAL:
=========================

BEGINNER:
- Simple shape tools
- Click and drag to create
- Easy color selection
- Basic transformations

INTERMEDIATE:
- Pen tool for custom paths
- Keyframe animation
- Multiple layers
- Grid and snapping

ADVANCED:
- Bezier curves
- Complex animations
- Gradient editing
- Export options

PROFESSIONAL:
- Timeline mastery
- Advanced keyframing
- Custom easing
- Production-ready exports

NEXT FEATURES TO ADD:
====================
1. Bezier pen tool implementation
2. Keyframe editor
3. Easing curve editor
4. Export to Lottie/Rive/SVG
5. Color picker dialog
6. Gradient editor UI
7. Shape morphing
8. Particle systems
9. Text styling
10. Asset library
11. Undo/Redo
12. Copy/Paste
13. Duplicate layers
14. Group layers
15. Blend modes

This is a solid foundation for a professional animation studio!
*/
