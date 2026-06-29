import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';

// ============================================================================
// COMPLETE PROFESSIONAL SVG ANIMATION STUDIO
// Inspired by Rive, Adobe Animate, with all advanced features
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

final studioStateProvider =
    StateNotifierProvider<StudioStateNotifier, StudioState>((ref) {
      return StudioStateNotifier();
    });

final timelineProvider = StateNotifierProvider<TimelineNotifier, TimelineState>(
  (ref) {
    return TimelineNotifier();
  },
);

final canvasProvider = StateNotifierProvider<CanvasNotifier, CanvasState>((
  ref,
) {
  return CanvasNotifier();
});

final particleSystemProvider =
    StateNotifierProvider<ParticleSystemNotifier, ParticleSystemState>((ref) {
      return ParticleSystemNotifier();
    });

final physicsProvider = StateNotifierProvider<PhysicsNotifier, PhysicsState>((
  ref,
) {
  return PhysicsNotifier();
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
  particle,
  bone,
  eyedropper,
  hand,
  zoom,
}

enum StudioMode { design, animate, preview, export }

class StudioState {
  final List<Layer> layers;
  final Layer? selectedLayer;
  final StudioTool currentTool;
  final StudioMode currentMode;
  final Map<String, GradientDefinition> gradients;
  final bool showGrid;
  final bool snapToGrid;
  final double gridSize;
  final Color canvasColor;
  final BezierPathData? currentPath;
  final List<BoneData> skeleton;
  final List<UndoAction> undoStack;
  final List<UndoAction> redoStack;

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
    this.currentPath,
    this.skeleton = const [],
    this.undoStack = const [],
    this.redoStack = const [],
  });

  StudioState copyWith({
    List<Layer>? layers,
    Layer? selectedLayer,
    StudioTool? currentTool,
    StudioMode? currentMode,
    Map<String, GradientDefinition>? gradients,
    bool? showGrid,
    bool? snapToGrid,
    double? gridSize,
    Color? canvasColor,
    BezierPathData? currentPath,
    List<BoneData>? skeleton,
    List<UndoAction>? undoStack,
    List<UndoAction>? redoStack,
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
      currentPath: currentPath ?? this.currentPath,
      skeleton: skeleton ?? this.skeleton,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }
}

class TimelineState {
  final double currentTime;
  final double duration;
  final bool isPlaying;
  final double fps;
  final bool loop;
  final AnimationCurve selectedCurve;

  const TimelineState({
    this.currentTime = 0,
    this.duration = 3,
    this.isPlaying = false,
    this.fps = 60,
    this.loop = false,
    this.selectedCurve = AnimationCurve.linear,
  });

  TimelineState copyWith({
    double? currentTime,
    double? duration,
    bool? isPlaying,
    double? fps,
    bool? loop,
    AnimationCurve? selectedCurve,
  }) {
    return TimelineState(
      currentTime: currentTime ?? this.currentTime,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      fps: fps ?? this.fps,
      loop: loop ?? this.loop,
      selectedCurve: selectedCurve ?? this.selectedCurve,
    );
  }
}

class CanvasState {
  final Offset pan;
  final double zoom;
  final Size artboardSize;
  final CameraSettings camera;

  const CanvasState({
    this.pan = Offset.zero,
    this.zoom = 1.0,
    this.artboardSize = const Size(800, 600),
    this.camera = const CameraSettings(),
  });

  CanvasState copyWith({
    Offset? pan,
    double? zoom,
    Size? artboardSize,
    CameraSettings? camera,
  }) {
    return CanvasState(
      pan: pan ?? this.pan,
      zoom: zoom ?? this.zoom,
      artboardSize: artboardSize ?? this.artboardSize,
      camera: camera ?? this.camera,
    );
  }
}

class CameraSettings {
  final double distance;
  final double pitch;
  final double yaw;
  final double fov;

  const CameraSettings({
    this.distance = 1000,
    this.pitch = 0,
    this.yaw = 0,
    this.fov = 60,
  });

  CameraSettings copyWith({
    double? distance,
    double? pitch,
    double? yaw,
    double? fov,
  }) {
    return CameraSettings(
      distance: distance ?? this.distance,
      pitch: pitch ?? this.pitch,
      yaw: yaw ?? this.yaw,
      fov: fov ?? this.fov,
    );
  }
}

class ParticleSystemState {
  final bool active;
  final double emissionRate;
  final double particleSize;
  final Color particleColor;
  final double lifeSpan;
  final double speed;
  final double spread;
  final Offset emitterPosition;
  final List<Particle> particles;

  const ParticleSystemState({
    this.active = false,
    this.emissionRate = 20,
    this.particleSize = 5,
    this.particleColor = Colors.yellow,
    this.lifeSpan = 2,
    this.speed = 100,
    this.spread = math.pi * 2,
    this.emitterPosition = const Offset(400, 300),
    this.particles = const [],
  });

  ParticleSystemState copyWith({
    bool? active,
    double? emissionRate,
    double? particleSize,
    Color? particleColor,
    double? lifeSpan,
    double? speed,
    double? spread,
    Offset? emitterPosition,
    List<Particle>? particles,
  }) {
    return ParticleSystemState(
      active: active ?? this.active,
      emissionRate: emissionRate ?? this.emissionRate,
      particleSize: particleSize ?? this.particleSize,
      particleColor: particleColor ?? this.particleColor,
      lifeSpan: lifeSpan ?? this.lifeSpan,
      speed: speed ?? this.speed,
      spread: spread ?? this.spread,
      emitterPosition: emitterPosition ?? this.emitterPosition,
      particles: particles ?? this.particles,
    );
  }
}

class PhysicsState {
  final bool active;
  final double gravity;
  final List<PhysicsBody> bodies;
  final Rect bounds;

  const PhysicsState({
    this.active = false,
    this.gravity = 980,
    this.bodies = const [],
    this.bounds = const Rect.fromLTWH(0, 0, 800, 600),
  });

  PhysicsState copyWith({
    bool? active,
    double? gravity,
    List<PhysicsBody>? bodies,
    Rect? bounds,
  }) {
    return PhysicsState(
      active: active ?? this.active,
      gravity: gravity ?? this.gravity,
      bodies: bodies ?? this.bodies,
      bounds: bounds ?? this.bounds,
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
  final Transform3D? transform3D;

  Layer({
    required this.id,
    required this.name,
    required this.type,
    this.visible = true,
    this.locked = false,
    this.opacity = 1.0,
    this.keyframes = const [],
    required this.data,
    this.transform3D,
  });

  Layer copyWith({
    String? name,
    bool? visible,
    bool? locked,
    double? opacity,
    List<Keyframe>? keyframes,
    LayerData? data,
    Transform3D? transform3D,
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
      transform3D: transform3D ?? this.transform3D,
    );
  }

  dynamic getPropertyAtTime(String property, double time) {
    final propertyKeyframes =
        keyframes.where((k) => k.property == property).toList();
    if (propertyKeyframes.isEmpty) {
      return _getDefaultPropertyValue(property);
    }
    if (propertyKeyframes.length == 1) return propertyKeyframes.first.value;

    Keyframe? before, after;
    for (var i = 0; i < propertyKeyframes.length - 1; i++) {
      if (time >= propertyKeyframes[i].time &&
          time <= propertyKeyframes[i + 1].time) {
        before = propertyKeyframes[i];
        after = propertyKeyframes[i + 1];
        break;
      }
    }

    if (before == null || after == null) return propertyKeyframes.last.value;

    final t = (time - before.time) / (after.time - before.time);
    return _interpolateValue(before.value, after.value, t, before.curve);
  }

  dynamic _getDefaultPropertyValue(String property) {
    switch (property) {
      case 'opacity':
        return opacity;
      case 'position':
        return data.position;
      case 'rotation':
        return data.rotation;
      case 'scale':
        return Offset(data.scaleX, data.scaleY);
      default:
        return null;
    }
  }

  dynamic _interpolateValue(dynamic a, dynamic b, double t, Curve curve) {
    final curvedT = curve.transform(t);
    if (a is num && b is num) {
      return a + (b - a) * curvedT;
    } else if (a is Offset && b is Offset) {
      return Offset.lerp(a, b, curvedT);
    } else if (a is Color && b is Color) {
      return Color.lerp(a, b, curvedT);
    }
    return t < 0.5 ? a : b;
  }
}

enum LayerType { shape, path, text, group, particle }

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
  final GradientDefinition? gradient;

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
    this.gradient,
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
    GradientDefinition? gradient,
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
      gradient: gradient ?? this.gradient,
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

  PathData copyWith({
    Offset? position,
    double? rotation,
    double? scaleX,
    double? scaleY,
    List<PathPoint>? points,
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth,
    bool? closed,
  }) {
    return PathData(
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      points: points ?? this.points,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      closed: closed ?? this.closed,
    );
  }

  Path toPath() {
    if (points.isEmpty) return Path();
    final path = Path();
    path.moveTo(points[0].position.dx, points[0].position.dy);

    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];

      if (prev.handleOut != null && current.handleIn != null) {
        final cp1 = prev.position + prev.handleOut!;
        final cp2 = current.position + current.handleIn!;
        path.cubicTo(
          cp1.dx,
          cp1.dy,
          cp2.dx,
          cp2.dy,
          current.position.dx,
          current.position.dy,
        );
      } else {
        path.lineTo(current.position.dx, current.position.dy);
      }
    }

    if (closed) path.close();
    return path;
  }
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

  PathPoint copyWith({
    Offset? position,
    Offset? handleIn,
    Offset? handleOut,
    PointType? type,
  }) {
    return PathPoint(
      position: position ?? this.position,
      handleIn: handleIn ?? this.handleIn,
      handleOut: handleOut ?? this.handleOut,
      type: type ?? this.type,
    );
  }
}

enum PointType { corner, smooth, symmetric }

class BezierPathData {
  final List<PathPoint> points;
  final bool closed;

  BezierPathData({required this.points, this.closed = false});

  Path toPath() {
    if (points.isEmpty) return Path();
    final path = Path();
    path.moveTo(points[0].position.dx, points[0].position.dy);

    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];

      if (prev.handleOut != null && current.handleIn != null) {
        final cp1 = prev.position + prev.handleOut!;
        final cp2 = current.position + current.handleIn!;
        path.cubicTo(
          cp1.dx,
          cp1.dy,
          cp2.dx,
          cp2.dy,
          current.position.dx,
          current.position.dy,
        );
      } else {
        path.lineTo(current.position.dx, current.position.dy);
      }
    }

    if (closed) path.close();
    return path;
  }
}

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

class Transform3D {
  final double rotateX;
  final double rotateY;
  final double rotateZ;
  final double translateZ;

  const Transform3D({
    this.rotateX = 0,
    this.rotateY = 0,
    this.rotateZ = 0,
    this.translateZ = 0,
  });

  Transform3D copyWith({
    double? rotateX,
    double? rotateY,
    double? rotateZ,
    double? translateZ,
  }) {
    return Transform3D(
      rotateX: rotateX ?? this.rotateX,
      rotateY: rotateY ?? this.rotateY,
      rotateZ: rotateZ ?? this.rotateZ,
      translateZ: translateZ ?? this.translateZ,
    );
  }
}

class GradientDefinition {
  final String id;
  final GradientType type;
  final List<GradientStop> stops;
  final Offset start;
  final Offset end;

  GradientDefinition({
    required this.id,
    required this.type,
    required this.stops,
    this.start = Offset.zero,
    this.end = const Offset(1, 1),
  });

  Gradient toGradient(Rect bounds) {
    final colors = stops.map((s) => s.color).toList();
    final offsets = stops.map((s) => s.offset).toList();

    switch (type) {
      case GradientType.linear:
        return LinearGradient(
          begin: Alignment(start.dx * 2 - 1, start.dy * 2 - 1),
          end: Alignment(end.dx * 2 - 1, end.dy * 2 - 1),
          colors: colors,
          stops: offsets,
        );
      case GradientType.radial:
        return RadialGradient(colors: colors, stops: offsets);
      case GradientType.sweep:
        return SweepGradient(colors: colors, stops: offsets);
    }
  }
}

enum GradientType { linear, radial, sweep }

class GradientStop {
  final double offset;
  final Color color;

  GradientStop({required this.offset, required this.color});
}

class Particle {
  Offset position;
  Offset velocity;
  final Color color;
  final double size;
  double life;
  final double maxLife;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.maxLife,
  }) : life = maxLife;

  bool get isDead => life <= 0;

  void update(double dt) {
    position += velocity * dt;
    velocity += const Offset(0, 200) * dt;
    life -= dt;
  }
}

class PhysicsBody {
  Offset position;
  Offset velocity;
  final double mass;
  final double restitution;
  final double radius;
  Offset acceleration;

  PhysicsBody({
    required this.position,
    this.velocity = Offset.zero,
    this.mass = 1.0,
    this.restitution = 0.8,
    this.radius = 20,
    this.acceleration = Offset.zero,
  });

  void update(double dt) {
    velocity += acceleration * dt;
    position += velocity * dt;
    acceleration = Offset.zero;
  }

  void applyForce(Offset force) {
    acceleration += force / mass;
  }
}

class BoneData {
  final String id;
  final String name;
  Offset position;
  double rotation;
  final double length;
  BoneData? parent;

  BoneData({
    required this.id,
    required this.name,
    required this.position,
    this.rotation = 0,
    required this.length,
    this.parent,
  });

  Offset get endPosition {
    return position +
        Offset(
          math.cos(rotation * math.pi / 180) * length,
          math.sin(rotation * math.pi / 180) * length,
        );
  }
}

enum AnimationCurve { linear, easeIn, easeOut, easeInOut, bounce, elastic }

class UndoAction {
  final String type;
  final dynamic data;

  UndoAction({required this.type, required this.data});
}

// ============================================================================
// STATE NOTIFIERS
// ============================================================================

class StudioStateNotifier extends StateNotifier<StudioState> {
  StudioStateNotifier() : super(const StudioState()) {
    _initializeDemo();
  }

  void _initializeDemo() {
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
        keyframes: [
          Keyframe(
            time: 0,
            property: 'position',
            value: const Offset(200, 150),
          ),
          Keyframe(
            time: 2,
            property: 'position',
            value: const Offset(500, 150),
            curve: Curves.easeInOut,
          ),
        ],
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
        keyframes: [
          Keyframe(time: 0, property: 'scale', value: const Offset(1, 1)),
          Keyframe(
            time: 1.5,
            property: 'scale',
            value: const Offset(1.5, 1.5),
            curve: Curves.elasticOut,
          ),
        ],
      ),
    ];

    final demoGradient = GradientDefinition(
      id: 'grad_1',
      type: GradientType.linear,
      stops: [
        GradientStop(offset: 0.0, color: Colors.blue),
        GradientStop(offset: 1.0, color: Colors.purple),
      ],
    );

    state = state.copyWith(
      layers: demoLayers,
      gradients: {'grad_1': demoGradient},
    );
  }

  void addLayer(Layer layer) {
    _saveUndoState();
    state = state.copyWith(layers: [...state.layers, layer]);
  }

  void updateLayer(Layer layer) {
    _saveUndoState();
    final index = state.layers.indexWhere((l) => l.id == layer.id);
    if (index != -1) {
      final newLayers = List<Layer>.from(state.layers);
      newLayers[index] = layer;
      state = state.copyWith(layers: newLayers);
    }
  }

  void deleteLayer(String id) {
    _saveUndoState();
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

  void addKeyframe(
    String layerId,
    String property,
    double time,
    dynamic value,
  ) {
    _saveUndoState();
    final layer = state.layers.firstWhere((l) => l.id == layerId);
    final newKeyframes = [
      ...layer.keyframes,
      Keyframe(time: time, property: property, value: value),
    ];
    updateLayer(layer.copyWith(keyframes: newKeyframes));
  }

  void addGradient(GradientDefinition gradient) {
    final newGradients = Map<String, GradientDefinition>.from(state.gradients);
    newGradients[gradient.id] = gradient;
    state = state.copyWith(gradients: newGradients);
  }

  void addBone(BoneData bone) {
    state = state.copyWith(skeleton: [...state.skeleton, bone]);
  }

  void updateBone(int index, BoneData bone) {
    final newSkeleton = List<BoneData>.from(state.skeleton);
    newSkeleton[index] = bone;
    state = state.copyWith(skeleton: newSkeleton);
  }

  void setCurrentPath(BezierPathData? path) {
    state = state.copyWith(currentPath: path);
  }

  void _saveUndoState() {
    final action = UndoAction(type: 'state', data: state);
    final newUndoStack = [...state.undoStack, action];
    if (newUndoStack.length > 50) newUndoStack.removeAt(0);
    state = state.copyWith(undoStack: newUndoStack, redoStack: []);
  }

  void undo() {
    if (state.undoStack.isEmpty) return;
    final action = state.undoStack.last;
    final newRedoStack = [
      ...state.redoStack,
      UndoAction(type: 'state', data: state),
    ];
    final newUndoStack = List<UndoAction>.from(state.undoStack)..removeLast();
    state = (action.data as StudioState).copyWith(
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    final action = state.redoStack.last;
    final newUndoStack = [
      ...state.undoStack,
      UndoAction(type: 'state', data: state),
    ];
    final newRedoStack = List<UndoAction>.from(state.redoStack)..removeLast();
    state = (action.data as StudioState).copyWith(
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
  }

  Map<String, dynamic> exportToJson() {
    return {
      'version': '1.0.0',
      'duration': 3.0,
      'layers':
          state.layers
              .map(
                (l) => {
                  'id': l.id,
                  'name': l.name,
                  'type': l.type.toString(),
                  'visible': l.visible,
                  'opacity': l.opacity,
                  'keyframes':
                      l.keyframes
                          .map(
                            (k) => {
                              'time': k.time,
                              'property': k.property,
                              'value': k.value.toString(),
                            },
                          )
                          .toList(),
                },
              )
              .toList(),
    };
  }

  String exportToSvg() {
    final buffer = StringBuffer();
    buffer.writeln(
      '<svg width="800" height="600" xmlns="http://www.w3.org/2000/svg">',
    );

    for (final layer in state.layers) {
      if (!layer.visible) continue;

      if (layer.type == LayerType.shape) {
        final shapeData = layer.data as ShapeData;
        final transform =
            'translate(${shapeData.position.dx},${shapeData.position.dy}) rotate(${shapeData.rotation})';

        if (shapeData.shapeType == ShapeType.rectangle) {
          buffer.writeln(
            '  <rect x="${-shapeData.size.width / 2}" y="${-shapeData.size.height / 2}" '
            'width="${shapeData.size.width}" height="${shapeData.size.height}" '
            'fill="${_colorToHex(shapeData.fillColor)}" '
            'stroke="${shapeData.strokeColor != null ? _colorToHex(shapeData.strokeColor!) : 'none'}" '
            'stroke-width="${shapeData.strokeWidth}" '
            'rx="${shapeData.cornerRadius}" '
            'opacity="${layer.opacity}" '
            'transform="$transform" />',
          );
        } else if (shapeData.shapeType == ShapeType.ellipse) {
          buffer.writeln(
            '  <ellipse cx="${shapeData.position.dx}" cy="${shapeData.position.dy}" '
            'rx="${shapeData.size.width / 2}" ry="${shapeData.size.height / 2}" '
            'fill="${_colorToHex(shapeData.fillColor)}" '
            'stroke="${shapeData.strokeColor != null ? _colorToHex(shapeData.strokeColor!) : 'none'}" '
            'stroke-width="${shapeData.strokeWidth}" '
            'opacity="${layer.opacity}" />',
          );
        }
      }
    }

    buffer.writeln('</svg>');
    return buffer.toString();
  }

  String _colorToHex(Color color) {
    return '#${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}';
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

  void updateTime(double dt) {
    if (!state.isPlaying) return;

    var newTime = state.currentTime + dt;
    if (newTime >= state.duration) {
      if (state.loop) {
        newTime = 0;
      } else {
        newTime = state.duration;
        state = state.copyWith(isPlaying: false);
      }
    }
    state = state.copyWith(currentTime: newTime);
  }

  void setAnimationCurve(AnimationCurve curve) {
    state = state.copyWith(selectedCurve: curve);
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

  void updateCamera(CameraSettings camera) {
    state = state.copyWith(camera: camera);
  }
}

class ParticleSystemNotifier extends StateNotifier<ParticleSystemState> {
  ParticleSystemNotifier() : super(const ParticleSystemState());

  void toggleActive() {
    state = state.copyWith(active: !state.active);
  }

  void setEmissionRate(double rate) {
    state = state.copyWith(emissionRate: rate);
  }

  void setParticleSize(double size) {
    state = state.copyWith(particleSize: size);
  }

  void setParticleColor(Color color) {
    state = state.copyWith(particleColor: color);
  }

  void setLifeSpan(double lifeSpan) {
    state = state.copyWith(lifeSpan: lifeSpan);
  }

  void setSpeed(double speed) {
    state = state.copyWith(speed: speed);
  }

  void setSpread(double spread) {
    state = state.copyWith(spread: spread);
  }

  void setEmitterPosition(Offset position) {
    state = state.copyWith(emitterPosition: position);
  }

  void update(double dt) {
    if (!state.active) return;

    final newParticles = List<Particle>.from(state.particles);

    // Emit new particles
    final shouldEmit =
        math.Random().nextDouble() < (state.emissionRate * dt / 60);
    if (shouldEmit) {
      final random = math.Random();
      final angle = random.nextDouble() * state.spread - state.spread / 2;
      final velocity = Offset(
        math.cos(angle) * state.speed,
        math.sin(angle) * state.speed,
      );

      newParticles.add(
        Particle(
          position: state.emitterPosition,
          velocity: velocity,
          color: state.particleColor,
          size: state.particleSize,
          maxLife: state.lifeSpan,
        ),
      );
    }

    // Update existing particles
    newParticles.removeWhere((p) => p.isDead);
    for (var particle in newParticles) {
      particle.update(dt);
    }

    state = state.copyWith(particles: newParticles);
  }
}

class PhysicsNotifier extends StateNotifier<PhysicsState> {
  PhysicsNotifier() : super(const PhysicsState());

  void toggleActive() {
    state = state.copyWith(active: !state.active);
  }

  void setGravity(double gravity) {
    state = state.copyWith(gravity: gravity);
  }

  void addBody(PhysicsBody body) {
    state = state.copyWith(bodies: [...state.bodies, body]);
  }

  void update(double dt) {
    if (!state.active) return;

    final newBodies = List<PhysicsBody>.from(state.bodies);

    for (var body in newBodies) {
      body.applyForce(Offset(0, state.gravity * body.mass));
      body.update(dt);

      // Boundary collision
      if (body.position.dy + body.radius > state.bounds.bottom) {
        body.position = Offset(
          body.position.dx,
          state.bounds.bottom - body.radius,
        );
        body.velocity = Offset(
          body.velocity.dx,
          -body.velocity.dy * body.restitution,
        );
      }

      if (body.position.dx - body.radius < state.bounds.left ||
          body.position.dx + body.radius > state.bounds.right) {
        body.velocity = Offset(
          -body.velocity.dx * body.restitution,
          body.velocity.dy,
        );
      }

      if (body.position.dy - body.radius < state.bounds.top) {
        body.position = Offset(
          body.position.dx,
          state.bounds.top + body.radius,
        );
        body.velocity = Offset(
          body.velocity.dx,
          -body.velocity.dy * body.restitution,
        );
      }
    }

    state = state.copyWith(bodies: newBodies);
  }
}

// ============================================================================
// MAIN STUDIO UI
// ============================================================================

class StudioHomePage extends ConsumerStatefulWidget {
  const StudioHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<StudioHomePage> createState() => _StudioHomePageState();
}

class _StudioHomePageState extends ConsumerState<StudioHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_onTick);
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTick() {
    final dt = 1 / 60;
    ref.read(timelineProvider.notifier).updateTime(dt);
    ref.read(particleSystemProvider.notifier).update(dt);
    ref.read(physicsProvider.notifier).update(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const StudioTopBar(),
          Expanded(
            child: Row(
              children: [
                const StudioToolbar(),
                const StudioLayersPanel(),
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

          _buildMenuButton(context, ref, 'File', [
            _buildMenuItem(Icons.add, 'New Project', () {}),
            _buildMenuItem(Icons.folder_open, 'Open', () {}),
            _buildMenuItem(Icons.save, 'Save', () {}),
            _buildMenuItem(Icons.download, 'Export JSON', () {
              final json =
                  ref.read(studioStateProvider.notifier).exportToJson();
              debugPrint(jsonEncode(json));
            }),
            _buildMenuItem(Icons.code, 'Export SVG', () {
              final svg = ref.read(studioStateProvider.notifier).exportToSvg();
              debugPrint(svg);
            }),
          ]),

          _buildMenuButton(context, ref, 'Edit', [
            _buildMenuItem(Icons.undo, 'Undo (Ctrl+Z)', () {
              ref.read(studioStateProvider.notifier).undo();
            }),
            _buildMenuItem(Icons.redo, 'Redo (Ctrl+Shift+Z)', () {
              ref.read(studioStateProvider.notifier).redo();
            }),
            _buildMenuItem(Icons.content_copy, 'Copy', () {}),
            _buildMenuItem(Icons.content_paste, 'Paste', () {}),
          ]),

          _buildMenuButton(context, ref, 'View', [
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
              ButtonSegment(
                value: StudioMode.export,
                icon: Icon(Icons.download, size: 16),
                label: Text('Export', style: TextStyle(fontSize: 12)),
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
    WidgetRef ref,
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
      child: ListView(
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
            Icons.bubble_chart,
            StudioTool.particle,
            'Particle',
          ),
          _buildTool(
            context,
            ref,
            Icons.accessibility,
            StudioTool.bone,
            'Bone/IK',
          ),
          _buildTool(
            context,
            ref,
            Icons.colorize,
            StudioTool.eyedropper,
            'Eyedropper (I)',
          ),
          const Divider(height: 16),
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
// LAYERS PANEL
// ============================================================================

class StudioLayersPanel extends ConsumerWidget {
  const StudioLayersPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studioState = ref.watch(studioStateProvider);

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'Layers',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () {
                    final newLayer = Layer(
                      id: 'layer_${DateTime.now().millisecondsSinceEpoch}',
                      name: 'Layer ${studioState.layers.length + 1}',
                      type: LayerType.shape,
                      data: ShapeData(
                        position: const Offset(400, 300),
                        shapeType: ShapeType.rectangle,
                        size: const Size(100, 100),
                        fillColor:
                            Colors.primaries[studioState.layers.length %
                                Colors.primaries.length],
                      ),
                    );
                    ref.read(studioStateProvider.notifier).addLayer(newLayer);
                  },
                  tooltip: 'Add Layer',
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: studioState.layers.length,
              onReorder: (oldIndex, newIndex) {},
              itemBuilder: (context, index) {
                final layer = studioState.layers[index];
                final isSelected = layer == studioState.selectedLayer;

                return ListTile(
                  key: ValueKey(layer.id),
                  selected: isSelected,
                  selectedTileColor: Colors.blue.withOpacity(0.2),
                  dense: true,
                  leading: Icon(_getLayerIcon(layer.type), size: 16),
                  title: Text(layer.name, style: const TextStyle(fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          layer.visible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 14,
                        ),
                        onPressed: () {
                          ref
                              .read(studioStateProvider.notifier)
                              .updateLayer(
                                layer.copyWith(visible: !layer.visible),
                              );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 14),
                        onPressed: () {
                          ref
                              .read(studioStateProvider.notifier)
                              .deleteLayer(layer.id);
                        },
                      ),
                    ],
                  ),
                  onTap:
                      () => ref
                          .read(studioStateProvider.notifier)
                          .selectLayer(layer),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLayerIcon(LayerType type) {
    switch (type) {
      case LayerType.shape:
        return Icons.rectangle;
      case LayerType.path:
        return Icons.polyline;
      case LayerType.text:
        return Icons.text_fields;
      case LayerType.group:
        return Icons.folder;
      case LayerType.particle:
        return Icons.bubble_chart;
    }
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
    final timelineState = ref.watch(timelineProvider);
    final particleState = ref.watch(particleSystemProvider);
    final physicsState = ref.watch(physicsProvider);

    return Container(
      color: const Color(0xFF2D2D30),
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onTapDown: _handleTapDown,
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
            currentTime: timelineState.currentTime,
            currentPath: studioState.currentPath,
            skeleton: studioState.skeleton,
            particles: particleState.particles,
            physicsBodies: physicsState.bodies,
            camera: canvasState.camera,
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
    } else if (tool == StudioTool.select) {
      final selectedLayer = ref.read(studioStateProvider).selectedLayer;
      if (selectedLayer != null && _dragStart != null) {
        final canvasState = ref.read(canvasProvider);
        final delta = (details.localPosition - _dragStart!) / canvasState.zoom;

        if (selectedLayer.data is ShapeData) {
          final shapeData = selectedLayer.data as ShapeData;
          final newData = shapeData.copyWith(
            position: shapeData.position + delta,
          );
          ref
              .read(studioStateProvider.notifier)
              .updateLayer(selectedLayer.copyWith(data: newData));
        } else if (selectedLayer.data is PathData) {
          final pathData = selectedLayer.data as PathData;
          final newData = pathData.copyWith(
            position: pathData.position + delta,
          );
          ref
              .read(studioStateProvider.notifier)
              .updateLayer(selectedLayer.copyWith(data: newData));
        }

        _dragStart = details.localPosition;
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _dragStart = null;
    _currentDragPosition = null;
  }

  void _handleTapDown(TapDownDetails details) {
    final canvasState = ref.read(canvasProvider);
    final studioState = ref.read(studioStateProvider);

    // Convert screen coordinates to canvas coordinates
    final screenCenter = Offset(
      context.size!.width / 2,
      context.size!.height / 2,
    );
    final canvasPos =
        (details.localPosition - screenCenter - canvasState.pan) /
            canvasState.zoom +
        Offset(
          canvasState.artboardSize.width / 2,
          canvasState.artboardSize.height / 2,
        );

    // Check if clicked on a layer
    for (final layer in studioState.layers.reversed) {
      if (!layer.visible || layer.locked) continue;

      if (layer.data is ShapeData) {
        final shapeData = layer.data as ShapeData;
        final rect = Rect.fromCenter(
          center: shapeData.position,
          width: shapeData.size.width,
          height: shapeData.size.height,
        );

        if (rect.contains(canvasPos)) {
          ref.read(studioStateProvider.notifier).selectLayer(layer);
          return;
        }
      }
    }

    // If no layer was clicked, handle tool-specific actions
    final tool = studioState.currentTool;
    if (tool == StudioTool.rectangle) {
      final newLayer = Layer(
        id: 'layer_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Rectangle ${studioState.layers.length + 1}',
        type: LayerType.shape,
        data: ShapeData(
          position: canvasPos,
          shapeType: ShapeType.rectangle,
          size: const Size(100, 80),
          fillColor: Colors.blue,
          strokeColor: Colors.white,
          strokeWidth: 2,
        ),
      );
      ref.read(studioStateProvider.notifier).addLayer(newLayer);
      ref.read(studioStateProvider.notifier).selectLayer(newLayer);
    } else if (tool == StudioTool.ellipse) {
      final newLayer = Layer(
        id: 'layer_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Ellipse ${studioState.layers.length + 1}',
        type: LayerType.shape,
        data: ShapeData(
          position: canvasPos,
          shapeType: ShapeType.ellipse,
          size: const Size(100, 100),
          fillColor: Colors.purple,
          strokeColor: Colors.white,
          strokeWidth: 2,
        ),
      );
      ref.read(studioStateProvider.notifier).addLayer(newLayer);
      ref.read(studioStateProvider.notifier).selectLayer(newLayer);
    } else if (tool == StudioTool.particle) {
      ref.read(particleSystemProvider.notifier).setEmitterPosition(canvasPos);
      ref.read(particleSystemProvider.notifier).toggleActive();
    }
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
  final double currentTime;
  final BezierPathData? currentPath;
  final List<BoneData> skeleton;
  final List<Particle> particles;
  final List<PhysicsBody> physicsBodies;
  final CameraSettings camera;

  CanvasPainter({
    required this.layers,
    this.selectedLayer,
    required this.showGrid,
    required this.gridSize,
    required this.pan,
    required this.zoom,
    required this.artboardSize,
    required this.canvasColor,
    required this.currentTime,
    this.currentPath,
    required this.skeleton,
    required this.particles,
    required this.physicsBodies,
    required this.camera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

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

    // Draw layers with animation
    for (final layer in layers) {
      if (!layer.visible) continue;
      _drawAnimatedLayer(canvas, layer);
    }

    // Draw current bezier path being edited
    if (currentPath != null) {
      _drawBezierPath(canvas, currentPath!);
    }

    // Draw skeleton
    for (final bone in skeleton) {
      _drawBone(canvas, bone);
    }

    // Draw particles
    for (final particle in particles) {
      _drawParticle(canvas, particle);
    }

    // Draw physics bodies
    for (final body in physicsBodies) {
      _drawPhysicsBody(canvas, body);
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

  void _drawAnimatedLayer(Canvas canvas, Layer layer) {
    canvas.save();

    // Get animated properties
    final animatedOpacity =
        layer.getPropertyAtTime('opacity', currentTime) as double? ??
        layer.opacity;
    final animatedPosition =
        layer.getPropertyAtTime('position', currentTime) as Offset? ??
        layer.data.position;
    final animatedRotation =
        layer.getPropertyAtTime('rotation', currentTime) as double? ??
        layer.data.rotation;
    final animatedScale =
        layer.getPropertyAtTime('scale', currentTime) as Offset? ??
        Offset(layer.data.scaleX, layer.data.scaleY);

    // Apply transforms
    canvas.translate(animatedPosition.dx, animatedPosition.dy);
    canvas.rotate(animatedRotation * math.pi / 180);
    canvas.scale(animatedScale.dx, animatedScale.dy);

    // Apply 3D transform if present
    if (layer.transform3D != null) {
      _apply3DTransform(canvas, layer.transform3D!);
    }

    if (layer.type == LayerType.shape) {
      _drawShape(canvas, layer, animatedOpacity);
    } else if (layer.type == LayerType.path) {
      _drawPath(canvas, layer, animatedOpacity);
    }

    canvas.restore();
  }

  void _apply3DTransform(Canvas canvas, Transform3D transform3D) {
    // Simplified 3D transform (perspective would need proper matrix operations)
    canvas.translate(0, 0);
    // Note: Full 3D transforms would require custom matrix operations
  }

  void _drawShape(Canvas canvas, Layer layer, double opacity) {
    final shapeData = layer.data as ShapeData;

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: shapeData.size.width,
      height: shapeData.size.height,
    );

    Paint fillPaint;
    if (shapeData.gradient != null) {
      fillPaint =
          Paint()
            ..shader = shapeData.gradient!.toGradient(rect).createShader(rect)
            ..style = PaintingStyle.fill;
    } else {
      fillPaint =
          Paint()
            ..color = shapeData.fillColor.withOpacity(opacity)
            ..style = PaintingStyle.fill;
    }

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
    } else if (shapeData.shapeType == ShapeType.polygon) {
      final path = _createPolygonPath(rect, 5);
      canvas.drawPath(path, fillPaint);
    }

    // Draw stroke
    if (shapeData.strokeColor != null && shapeData.strokeWidth > 0) {
      final strokePaint =
          Paint()
            ..color = shapeData.strokeColor!.withOpacity(opacity)
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
      } else if (shapeData.shapeType == ShapeType.polygon) {
        final path = _createPolygonPath(rect, 5);
        canvas.drawPath(path, strokePaint);
      }
    }
  }

  Path _createPolygonPath(Rect rect, int sides) {
    final path = Path();
    final center = rect.center;
    final radius = math.min(rect.width, rect.height) / 2;

    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  void _drawPath(Canvas canvas, Layer layer, double opacity) {
    final pathData = layer.data as PathData;
    final path = pathData.toPath();

    final fillPaint =
        Paint()
          ..color = pathData.fillColor.withOpacity(opacity)
          ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    if (pathData.strokeColor != null && pathData.strokeWidth > 0) {
      final strokePaint =
          Paint()
            ..color = pathData.strokeColor!.withOpacity(opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = pathData.strokeWidth;

      canvas.drawPath(path, strokePaint);
    }
  }

  void _drawBezierPath(Canvas canvas, BezierPathData pathData) {
    final path = pathData.toPath();

    // Draw path
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw points and handles
    for (final point in pathData.points) {
      // Draw handles
      if (point.handleIn != null) {
        canvas.drawLine(
          point.position,
          point.position + point.handleIn!,
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 1,
        );
        canvas.drawCircle(
          point.position + point.handleIn!,
          4,
          Paint()..color = Colors.red,
        );
      }

      if (point.handleOut != null) {
        canvas.drawLine(
          point.position,
          point.position + point.handleOut!,
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 1,
        );
        canvas.drawCircle(
          point.position + point.handleOut!,
          4,
          Paint()..color = Colors.green,
        );
      }

      // Draw anchor point
      canvas.drawCircle(
        point.position,
        6,
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        point.position,
        6,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawBone(Canvas canvas, BoneData bone) {
    final paint =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 3;

    canvas.drawLine(bone.position, bone.endPosition, paint);

    // Draw joints
    canvas.drawCircle(
      bone.position,
      5,
      Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      bone.endPosition,
      5,
      Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.fill,
    );
  }

  void _drawParticle(Canvas canvas, Particle particle) {
    final opacity = (particle.life / particle.maxLife).clamp(0.0, 1.0);
    canvas.drawCircle(
      particle.position,
      particle.size,
      Paint()..color = particle.color.withOpacity(opacity),
    );
  }

  void _drawPhysicsBody(Canvas canvas, PhysicsBody body) {
    canvas.drawCircle(
      body.position,
      body.radius,
      Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.fill,
    );

    // Draw velocity vector
    final velocityEnd = body.position + body.velocity * 0.1;
    canvas.drawLine(
      body.position,
      velocityEnd,
      Paint()
        ..color = Colors.red
        ..strokeWidth = 2,
    );
  }

  void _drawSelection(Canvas canvas, Layer layer) {
    canvas.save();

    final data = layer.data;
    final animatedPosition =
        layer.getPropertyAtTime('position', currentTime) as Offset? ??
        data.position;
    final animatedRotation =
        layer.getPropertyAtTime('rotation', currentTime) as double? ??
        data.rotation;
    final animatedScale =
        layer.getPropertyAtTime('scale', currentTime) as Offset? ??
        Offset(data.scaleX, data.scaleY);

    canvas.translate(animatedPosition.dx, animatedPosition.dy);
    canvas.rotate(animatedRotation * math.pi / 180);
    canvas.scale(animatedScale.dx, animatedScale.dy);

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
    final studioState = ref.watch(studioStateProvider);
    final selectedLayer = studioState.selectedLayer;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(left: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child:
          studioState.currentMode == StudioMode.export
              ? _buildExportPanel(context, ref)
              : selectedLayer == null
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
        Text(
          layer.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        _buildSection('Transform', [
          if (layer.data is ShapeData)
            ..._buildShapeTransform(context, ref, layer),
        ]),

        const SizedBox(height: 16),

        _buildSection('Appearance', [
          if (layer.data is ShapeData)
            ..._buildShapeAppearance(context, ref, layer),
          _buildOpacitySlider(context, ref, layer),
        ]),

        const SizedBox(height: 16),

        _buildSection('3D Transform', [
          ElevatedButton.icon(
            icon: const Icon(Icons.view_in_ar, size: 16),
            label: const Text('Enable 3D'),
            onPressed: () {
              ref
                  .read(studioStateProvider.notifier)
                  .updateLayer(
                    layer.copyWith(transform3D: const Transform3D()),
                  );
            },
          ),
          if (layer.transform3D != null)
            ..._build3DTransform(context, ref, layer),
        ]),

        const SizedBox(height: 16),

        _buildSection('Animation', [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Keyframe'),
            onPressed: () {
              final timelineState = ref.read(timelineProvider);
              ref
                  .read(studioStateProvider.notifier)
                  .addKeyframe(
                    layer.id,
                    'position',
                    timelineState.currentTime,
                    layer.data.position,
                  );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${layer.keyframes.length} keyframes',
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
        ]),

        const SizedBox(height: 16),

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

  Widget _buildExportPanel(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Export',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        _buildExportButton(
          context,
          ref,
          'Export as JSON',
          Icons.data_object,
          () {
            final json = ref.read(studioStateProvider.notifier).exportToJson();
            debugPrint('JSON: ${jsonEncode(json)}');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('JSON exported to console')),
            );
          },
        ),

        const SizedBox(height: 12),

        _buildExportButton(context, ref, 'Export as SVG', Icons.code, () {
          final svg = ref.read(studioStateProvider.notifier).exportToSvg();
          debugPrint('SVG:\n$svg');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SVG exported to console')),
          );
        }),

        const SizedBox(height: 12),

        _buildExportButton(
          context,
          ref,
          'Export as Lottie',
          Icons.animation,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lottie export coming soon')),
            );
          },
        ),

        const SizedBox(height: 12),

        _buildExportButton(context, ref, 'Export as Rive', Icons.api, () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rive export coming soon')),
          );
        }),
      ],
    );
  }

  Widget _buildExportButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      onPressed: onPressed,
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

  List<Widget> _build3DTransform(
    BuildContext context,
    WidgetRef ref,
    Layer layer,
  ) {
    final transform3D = layer.transform3D!;

    return [
      _buildPropertySlider('Rotate X', transform3D.rotateX, -180, 180, (value) {
        ref
            .read(studioStateProvider.notifier)
            .updateLayer(
              layer.copyWith(transform3D: transform3D.copyWith(rotateX: value)),
            );
      }),
      _buildPropertySlider('Rotate Y', transform3D.rotateY, -180, 180, (value) {
        ref
            .read(studioStateProvider.notifier)
            .updateLayer(
              layer.copyWith(transform3D: transform3D.copyWith(rotateY: value)),
            );
      }),
      _buildPropertySlider('Z Position', transform3D.translateZ, -500, 500, (
        value,
      ) {
        ref
            .read(studioStateProvider.notifier)
            .updateLayer(
              layer.copyWith(
                transform3D: transform3D.copyWith(translateZ: value),
              ),
            );
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
          onTap: () {},
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
                  tooltip: 'Play/Pause (Space)',
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
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1E1E1E),
    );

    final markerPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= 10; i++) {
      final x = (size.width * i) / 10;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        markerPaint,
      );

      final */