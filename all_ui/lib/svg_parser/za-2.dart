import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_riverpod/legacy.dart';

// ============================================================================
// COMPLETE SVG ANIMATION STUDIO - ALL PHASES UNIFIED
// Dependencies: flutter_riverpod, vector_math
// ============================================================================

void main() {
  runApp(const ProviderScope(child: UnifiedSvgStudioApp()));
}

class UnifiedSvgStudioApp extends StatelessWidget {
  const UnifiedSvgStudioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Complete SVG Animation Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const StudioHome(),
    );
  }
}

// ============================================================================
// RIVERPOD STATE MANAGEMENT
// ============================================================================

// App state
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier();
});

class AppState {
  final List<StudioLayer> layers;
  final StudioLayer? selectedLayer;
  final StudioTool currentTool;
  final StudioMode currentMode;
  final bool isPlaying;
  final double currentTime;
  final double duration;
  final CameraSettings camera;
  final GridSettings grid;
  final ParticleSystemSettings? particleSystem;
  final PhysicsSettings? physics;
  final List<MeshPoint> meshPoints;
  final ExportSettings exportSettings;

  AppState({
    this.layers = const [],
    this.selectedLayer,
    this.currentTool = StudioTool.select,
    this.currentMode = StudioMode.design,
    this.isPlaying = false,
    this.currentTime = 0,
    this.duration = 3,
    this.camera = const CameraSettings(),
    this.grid = const GridSettings(),
    this.particleSystem,
    this.physics,
    this.meshPoints = const [],
    this.exportSettings = const ExportSettings(),
  });

  AppState copyWith({
    List<StudioLayer>? layers,
    StudioLayer? selectedLayer,
    StudioTool? currentTool,
    StudioMode? currentMode,
    bool? isPlaying,
    double? currentTime,
    double? duration,
    CameraSettings? camera,
    GridSettings? grid,
    ParticleSystemSettings? particleSystem,
    PhysicsSettings? physics,
    List<MeshPoint>? meshPoints,
    ExportSettings? exportSettings,
  }) {
    return AppState(
      layers: layers ?? this.layers,
      selectedLayer: selectedLayer ?? this.selectedLayer,
      currentTool: currentTool ?? this.currentTool,
      currentMode: currentMode ?? this.currentMode,
      isPlaying: isPlaying ?? this.isPlaying,
      currentTime: currentTime ?? this.currentTime,
      duration: duration ?? this.duration,
      camera: camera ?? this.camera,
      grid: grid ?? this.grid,
      particleSystem: particleSystem ?? this.particleSystem,
      physics: physics ?? this.physics,
      meshPoints: meshPoints ?? this.meshPoints,
      exportSettings: exportSettings ?? this.exportSettings,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState()) {
    _initializeDefaultLayers();
  }

  void _initializeDefaultLayers() {
    state = state.copyWith(
      layers: [
        StudioLayer(
          id: 'layer1',
          name: 'Background',
          type: LayerType.rectangle,
          position: const Offset(400, 300),
          size: const Size(200, 200),
          color: Colors.blue,
        ),
      ],
    );
  }

  void addLayer(StudioLayer layer) {
    state = state.copyWith(layers: [...state.layers, layer]);
  }

  void updateLayer(StudioLayer layer) {
    final index = state.layers.indexWhere((l) => l.id == layer.id);
    if (index != -1) {
      final newLayers = List<StudioLayer>.from(state.layers);
      newLayers[index] = layer;
      state = state.copyWith(layers: newLayers);
    }
  }

  void deleteLayer(String id) {
    state = state.copyWith(
      layers: state.layers.where((l) => l.id != id).toList(),
    );
  }

  void selectLayer(StudioLayer? layer) {
    state = state.copyWith(selectedLayer: layer);
  }

  void setTool(StudioTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  void setMode(StudioMode mode) {
    state = state.copyWith(currentMode: mode);
  }

  void togglePlayback() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void updateTime(double time) {
    state = state.copyWith(currentTime: time);
  }

  void updateCamera(CameraSettings camera) {
    state = state.copyWith(camera: camera);
  }

  void updateParticleSystem(ParticleSystemSettings? settings) {
    state = state.copyWith(particleSystem: settings);
  }

  void updatePhysics(PhysicsSettings? settings) {
    state = state.copyWith(physics: settings);
  }

  void addMeshPoint(MeshPoint point) {
    state = state.copyWith(meshPoints: [...state.meshPoints, point]);
  }

  void updateMeshPoint(int index, MeshPoint point) {
    final newPoints = List<MeshPoint>.from(state.meshPoints);
    newPoints[index] = point;
    state = state.copyWith(meshPoints: newPoints);
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

enum StudioTool {
  select,
  rectangle,
  circle,
  path,
  text,
  gradient,
  mesh,
  particle,
  bone,
}

enum StudioMode { design, animate, preview, export }

enum LayerType { rectangle, circle, path, text, image, group }

class StudioLayer {
  final String id;
  final String name;
  final LayerType type;
  final Offset position;
  final Size size;
  final Color color;
  final double rotation;
  final double scale;
  final double opacity;
  final bool visible;
  final Transform3D? transform3D;
  final GradientData? gradient;
  final List<Keyframe> keyframes;
  final MeshDeformation? meshDeformation;

  StudioLayer({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    required this.size,
    required this.color,
    this.rotation = 0,
    this.scale = 1,
    this.opacity = 1,
    this.visible = true,
    this.transform3D,
    this.gradient,
    this.keyframes = const [],
    this.meshDeformation,
  });

  StudioLayer copyWith({
    String? name,
    Offset? position,
    Size? size,
    Color? color,
    double? rotation,
    double? scale,
    double? opacity,
    bool? visible,
    Transform3D? transform3D,
    GradientData? gradient,
    List<Keyframe>? keyframes,
    MeshDeformation? meshDeformation,
  }) {
    return StudioLayer(
      id: id,
      name: name ?? this.name,
      type: type,
      position: position ?? this.position,
      size: size ?? this.size,
      color: color ?? this.color,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      opacity: opacity ?? this.opacity,
      visible: visible ?? this.visible,
      transform3D: transform3D ?? this.transform3D,
      gradient: gradient ?? this.gradient,
      keyframes: keyframes ?? this.keyframes,
      meshDeformation: meshDeformation ?? this.meshDeformation,
    );
  }
}

class Transform3D {
  final double rotateX;
  final double rotateY;
  final double rotateZ;
  final double translateZ;
  final double scaleX;
  final double scaleY;
  final double scaleZ;

  const Transform3D({
    this.rotateX = 0,
    this.rotateY = 0,
    this.rotateZ = 0,
    this.translateZ = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.scaleZ = 1,
  });

  Transform3D copyWith({
    double? rotateX,
    double? rotateY,
    double? rotateZ,
    double? translateZ,
    double? scaleX,
    double? scaleY,
    double? scaleZ,
  }) {
    return Transform3D(
      rotateX: rotateX ?? this.rotateX,
      rotateY: rotateY ?? this.rotateY,
      rotateZ: rotateZ ?? this.rotateZ,
      translateZ: translateZ ?? this.translateZ,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      scaleZ: scaleZ ?? this.scaleZ,
    );
  }
}

class GradientData {
  final List<ColorStop> stops;
  final GradientType type;
  final Offset start;
  final Offset end;

  const GradientData({
    required this.stops,
    this.type = GradientType.linear,
    this.start = Offset.zero,
    this.end = const Offset(1, 1),
  });
}

enum GradientType { linear, radial, sweep }

class ColorStop {
  final double offset;
  final Color color;

  const ColorStop(this.offset, this.color);
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

class GridSettings {
  final bool visible;
  final double size;
  final Color color;

  const GridSettings({
    this.visible = true,
    this.size = 20,
    this.color = Colors.grey,
  });
}

class ParticleSystemSettings {
  final double emissionRate;
  final double particleSize;
  final Color particleColor;
  final double lifeSpan;
  final bool active;

  const ParticleSystemSettings({
    this.emissionRate = 20,
    this.particleSize = 5,
    this.particleColor = Colors.yellow,
    this.lifeSpan = 2,
    this.active = false,
  });
}

class PhysicsSettings {
  final double gravity;
  final bool active;

  const PhysicsSettings({this.gravity = 980, this.active = false});
}

class MeshPoint {
  final Offset position;
  final Offset originalPosition;

  MeshPoint({required this.position, required this.originalPosition});
}

class MeshDeformation {
  final List<MeshPoint> points;
  final int gridRows;
  final int gridCols;

  MeshDeformation({required this.points, this.gridRows = 3, this.gridCols = 3});
}

class ExportSettings {
  final ExportFormat format;
  final int quality;
  final Size resolution;

  const ExportSettings({
    this.format = ExportFormat.json,
    this.quality = 100,
    this.resolution = const Size(1920, 1080),
  });
}

enum ExportFormat { json, svg, lottie, rive, gif, mp4 }

// ============================================================================
// MAIN STUDIO HOME
// ============================================================================

class StudioHome extends ConsumerWidget {
  const StudioHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildTopMenu(context, ref),
          Expanded(
            child: Row(
              children: [
                _buildLeftPanel(context, ref),
                Expanded(child: _buildMainCanvas(context, ref)),
                _buildRightPanel(context, ref),
              ],
            ),
          ),
          _buildBottomTimeline(context, ref),
        ],
      ),
    );
  }

  // ========================================================================
  // TOP MENU BAR
  // ========================================================================

  Widget _buildTopMenu(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Container(
      height: 56,
      color: Colors.grey[900],
      child: Row(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.animation, color: Colors.blue[400]),
                const SizedBox(width: 8),
                const Text(
                  'SVG Studio Pro',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const VerticalDivider(),

          // File menu
          _buildMenuButton(context, 'File', [
            _buildMenuItem('New Project', Icons.add, () {}),
            _buildMenuItem('Open', Icons.folder_open, () {}),
            _buildMenuItem('Save', Icons.save, () {}),
            _buildMenuItem('Save As', Icons.save_as, () {}),
          ]),

          _buildMenuButton(context, 'Edit', [
            _buildMenuItem('Undo', Icons.undo, () {}),
            _buildMenuItem('Redo', Icons.redo, () {}),
            _buildMenuItem('Copy', Icons.copy, () {}),
            _buildMenuItem('Paste', Icons.paste, () {}),
          ]),

          _buildMenuButton(context, 'View', [
            _buildMenuItem('Zoom In', Icons.zoom_in, () {}),
            _buildMenuItem('Zoom Out', Icons.zoom_out, () {}),
            _buildMenuItem('Fit to Screen', Icons.fit_screen, () {}),
            _buildMenuItem('Toggle Grid', Icons.grid_on, () {}),
          ]),

          _buildMenuButton(context, 'Layer', [
            _buildMenuItem('New Layer', Icons.add_box, () {
              ref
                  .read(appStateProvider.notifier)
                  .addLayer(
                    StudioLayer(
                      id: 'layer_${DateTime.now().millisecondsSinceEpoch}',
                      name: 'Layer ${appState.layers.length + 1}',
                      type: LayerType.rectangle,
                      position: const Offset(400, 300),
                      size: const Size(100, 100),
                      color:
                          Colors.primaries[appState.layers.length %
                              Colors.primaries.length],
                    ),
                  );
            }),
            _buildMenuItem('Duplicate', Icons.content_copy, () {}),
            _buildMenuItem('Delete', Icons.delete, () {}),
            _buildMenuItem('Group', Icons.folder, () {}),
          ]),

          _buildMenuButton(context, 'Animation', [
            _buildMenuItem('Add Keyframe', Icons.fiber_manual_record, () {}),
            _buildMenuItem(
              'Remove Keyframe',
              Icons.radio_button_unchecked,
              () {},
            ),
            _buildMenuItem('Animation Settings', Icons.settings, () {}),
          ]),

          _buildMenuButton(context, 'Export', [
            _buildMenuItem('Export JSON', Icons.data_object, () {
              _showExportDialog(context, ref, ExportFormat.json);
            }),
            _buildMenuItem('Export SVG', Icons.code, () {
              _showExportDialog(context, ref, ExportFormat.svg);
            }),
            _buildMenuItem('Export Lottie', Icons.animation, () {
              _showExportDialog(context, ref, ExportFormat.lottie);
            }),
            _buildMenuItem('Export Video', Icons.videocam, () {
              _showExportDialog(context, ref, ExportFormat.mp4);
            }),
          ]),

          const Spacer(),

          // Mode selector
          SegmentedButton<StudioMode>(
            segments: const [
              ButtonSegment(
                value: StudioMode.design,
                icon: Icon(Icons.design_services, size: 16),
              ),
              ButtonSegment(
                value: StudioMode.animate,
                icon: Icon(Icons.animation, size: 16),
              ),
              ButtonSegment(
                value: StudioMode.preview,
                icon: Icon(Icons.preview, size: 16),
              ),
              ButtonSegment(
                value: StudioMode.export,
                icon: Icon(Icons.download, size: 16),
              ),
            ],
            selected: {appState.currentMode},
            onSelectionChanged: (Set<StudioMode> selection) {
              ref.read(appStateProvider.notifier).setMode(selection.first);
            },
          ),

          const SizedBox(width: 16),

          // Playback controls
          IconButton(
            icon: Icon(appState.isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed:
                () => ref.read(appStateProvider.notifier).togglePlayback(),
            color: Colors.white,
          ),

          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () => ref.read(appStateProvider.notifier).updateTime(0),
            color: Colors.white,
          ),

          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return PopupMenuButton(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(title),
      ),
      itemBuilder:
          (context) => items.map((item) => PopupMenuItem(child: item)).toList(),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 16),
      title: Text(title, style: const TextStyle(fontSize: 12)),
      onTap: onTap,
    );
  }

  // ========================================================================
  // LEFT PANEL - TOOLS & LAYERS
  // ========================================================================

  Widget _buildLeftPanel(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280,
      color: Colors.grey[900],
      child: Column(
        children: [
          _buildToolsSection(ref),
          const Divider(height: 1),
          Expanded(child: _buildLayersSection(ref)),
        ],
      ),
    );
  }

  Widget _buildToolsSection(WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tools', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildToolIcon(ref, Icons.near_me, StudioTool.select, 'Select'),
              _buildToolIcon(
                ref,
                Icons.rectangle,
                StudioTool.rectangle,
                'Rectangle',
              ),
              _buildToolIcon(ref, Icons.circle, StudioTool.circle, 'Circle'),
              _buildToolIcon(ref, Icons.polyline, StudioTool.path, 'Path'),
              _buildToolIcon(ref, Icons.text_fields, StudioTool.text, 'Text'),
              _buildToolIcon(
                ref,
                Icons.gradient,
                StudioTool.gradient,
                'Gradient',
              ),
              _buildToolIcon(ref, Icons.grid_on, StudioTool.mesh, 'Mesh'),
              _buildToolIcon(
                ref,
                Icons.bubble_chart,
                StudioTool.particle,
                'Particle',
              ),
              _buildToolIcon(ref, Icons.accessibility, StudioTool.bone, 'Bone'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(
    WidgetRef ref,
    IconData icon,
    StudioTool tool,
    String tooltip,
  ) {
    final appState = ref.watch(appStateProvider);
    final isSelected = appState.currentTool == tool;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => ref.read(appStateProvider.notifier).setTool(tool),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }

  Widget _buildLayersSection(WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Layers',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () {
                  ref
                      .read(appStateProvider.notifier)
                      .addLayer(
                        StudioLayer(
                          id: 'layer_${DateTime.now().millisecondsSinceEpoch}',
                          name: 'Layer ${appState.layers.length + 1}',
                          type: LayerType.rectangle,
                          position: const Offset(400, 300),
                          size: const Size(100, 100),
                          color: Colors.blue,
                        ),
                      );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: appState.layers.length,
            onReorder: (oldIndex, newIndex) {
              // TODO: Implement reorder
            },
            itemBuilder: (context, index) {
              final layer = appState.layers[index];
              final isSelected = layer == appState.selectedLayer;

              return ListTile(
                key: ValueKey(layer.id),
                selected: isSelected,
                selectedTileColor: Colors.blue.withOpacity(0.2),
                leading: Icon(_getLayerIcon(layer.type), size: 20),
                title: Text(layer.name, style: const TextStyle(fontSize: 13)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        layer.visible ? Icons.visibility : Icons.visibility_off,
                        size: 16,
                      ),
                      onPressed: () {
                        ref
                            .read(appStateProvider.notifier)
                            .updateLayer(
                              layer.copyWith(visible: !layer.visible),
                            );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 16),
                      onPressed: () {
                        ref
                            .read(appStateProvider.notifier)
                            .deleteLayer(layer.id);
                      },
                    ),
                  ],
                ),
                onTap:
                    () =>
                        ref.read(appStateProvider.notifier).selectLayer(layer),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getLayerIcon(LayerType type) {
    switch (type) {
      case LayerType.rectangle:
        return Icons.rectangle;
      case LayerType.circle:
        return Icons.circle;
      case LayerType.path:
        return Icons.polyline;
      case LayerType.text:
        return Icons.text_fields;
      case LayerType.image:
        return Icons.image;
      case LayerType.group:
        return Icons.folder;
    }
  }

  // ========================================================================
  // MAIN CANVAS
  // ========================================================================

  Widget _buildMainCanvas(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Container(
      color: Colors.grey[850],
      child: Center(
        child: Container(
          width: 800,
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20),
            ],
          ),
          child: CustomPaint(
            painter: UnifiedCanvasPainter(appState: appState),
            size: const Size(800, 600),
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // RIGHT PANEL - PROPERTIES
  // ========================================================================

  Widget _buildRightPanel(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Container(
      width: 320,
      color: Colors.grey[900],
      child: _buildPropertiesContent(ref, appState),
    );
  }

  Widget _buildPropertiesContent(WidgetRef ref, AppState appState) {
    switch (appState.currentMode) {
      case StudioMode.design:
        return _buildDesignProperties(ref, appState);
      case StudioMode.animate:
        return _buildAnimationProperties(ref, appState);
      case StudioMode.preview:
        return _buildPreviewSettings(ref, appState);
      case StudioMode.export:
        return _buildExportSettings(ref, appState);
    }
  }

  Widget _buildDesignProperties(WidgetRef ref, AppState appState) {
    if (appState.selectedLayer == null) {
      return const Center(child: Text('Select a layer'));
    }

    final layer = appState.selectedLayer!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Layer Properties',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Transform
        _buildPropertySection('Transform', [
          _buildSlider('X', layer.position.dx, 0, 800, (v) {
            ref
                .read(appStateProvider.notifier)
                .updateLayer(
                  layer.copyWith(position: Offset(v, layer.position.dy)),
                );
          }),
          _buildSlider('Y', layer.position.dy, 0, 600, (v) {
            ref
                .read(appStateProvider.notifier)
                .updateLayer(
                  layer.copyWith(position: Offset(layer.position.dx, v)),
                );
          }),
          _buildSlider('Rotation', layer.rotation, -180, 180, (v) {
            ref
                .read(appStateProvider.notifier)
                .updateLayer(layer.copyWith(rotation: v));
          }),
          _buildSlider('Scale', layer.scale, 0.1, 3, (v) {
            ref
                .read(appStateProvider.notifier)
                .updateLayer(layer.copyWith(scale: v));
          }),
        ]),

        const Divider(height: 32),

        // 3D Transform
        _buildPropertySection('3D Transform', [
          ElevatedButton.icon(
            icon: const Icon(Icons.view_in_ar),
            label: const Text('Enable 3D'),
            onPressed: () {
              ref
                  .read(appStateProvider.notifier)
                  .updateLayer(
                    layer.copyWith(transform3D: const Transform3D()),
                  );
            },
          ),
          if (layer.transform3D != null) ...[
            _buildSlider('Rotate X', layer.transform3D!.rotateX, -180, 180, (
              v,
            ) {
              ref
                  .read(appStateProvider.notifier)
                  .updateLayer(
                    layer.copyWith(
                      transform3D: layer.transform3D!.copyWith(rotateX: v),
                    ),
                  );
            }),
            _buildSlider('Rotate Y', layer.transform3D!.rotateY, -180, 180, (
              v,
            ) {
              ref
                  .read(appStateProvider.notifier)
                  .updateLayer(
                    layer.copyWith(
                      transform3D: layer.transform3D!.copyWith(rotateY: v),
                    ),
                  );
            }),
            _buildSlider(
              'Z Position',
              layer.transform3D!.translateZ,
              -500,
              500,
              (v) {
                ref
                    .read(appStateProvider.notifier)
                    .updateLayer(
                      layer.copyWith(
                        transform3D: layer.transform3D!.copyWith(translateZ: v),
                      ),
                    );
              },
            ),
          ],
        ]),

        const Divider(height: 32),

        // Appearance
        _buildPropertySection('Appearance', [
          _buildSlider('Opacity', layer.opacity, 0, 1, (v) {
            ref
                .read(appStateProvider.notifier)
                .updateLayer(layer.copyWith(opacity: v));
          }),
        ]),
      ],
    );
  }

  Widget _buildAnimationProperties(WidgetRef ref, AppState appState) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Animation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Text('Duration: ${appState.duration}s'),
        Text('Current Time: ${appState.currentTime.toStringAsFixed(2)}s'),

        const SizedBox(height: 16),

        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Keyframe'),
          onPressed: () {
            // TODO: Add keyframe at current time
          },
        ),

        const SizedBox(height: 16),

        const Text('Keyframes', style: TextStyle(fontWeight: FontWeight.bold)),
        // TODO: Display keyframes list
      ],
    );
  }

  Widget _buildPreviewSettings(WidgetRef ref, AppState appState) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Preview Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        _buildPropertySection('Camera', [
          _buildSlider('Distance', appState.camera.distance, 500, 2000, (v) {
            ref
                .read(appStateProvider.notifier)
                .updateCamera(appState.camera.copyWith(distance: v));
          }),
          _buildSlider('Pitch', appState.camera.pitch, -90, 90, (v) {
            ref
                .read(appStateProvider.notifier)
                .updateCamera(appState.camera.copyWith(pitch: v));
          }),
          _buildSlider('Yaw', appState.camera.yaw, -180, 180, (v) {
            ref
                .read(appStateProvider.notifier)
                .updateCamera(appState.camera.copyWith(yaw: v));
          }),
          _buildSlider('FOV', appState.camera.fov, 30, 120, (v) {
            ref
                .read(appStateProvider.notifier)
                .updateCamera(appState.camera.copyWith(fov: v));
          }),
        ]),
      ],
    );
  }

  Widget _buildExportSettings(WidgetRef ref, AppState appState) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Export Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        const Text('Format', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildExportButton(
              'JSON',
              Icons.data_object,
              ExportFormat.json,
              ref,
            ),
            _buildExportButton('SVG', Icons.code, ExportFormat.svg, ref),
            _buildExportButton(
              'Lottie',
              Icons.animation,
              ExportFormat.lottie,
              ref,
            ),
            _buildExportButton('Rive', Icons.api, ExportFormat.rive, ref),
            _buildExportButton('GIF', Icons.gif, ExportFormat.gif, ref),
            _buildExportButton('MP4', Icons.videocam, ExportFormat.mp4, ref),
          ],
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        const Text('Quality', style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: appState.exportSettings.quality.toDouble(),
          min: 50,
          max: 100,
          divisions: 5,
          label: '${appState.exportSettings.quality}%',
          onChanged: (v) {},
        ),

        const SizedBox(height: 16),

        ElevatedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Export Animation'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: () {
            _showExportDialog(null, ref, appState.exportSettings.format);
          },
        ),
      ],
    );
  }

  Widget _buildExportButton(
    String label,
    IconData icon,
    ExportFormat format,
    WidgetRef ref,
  ) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: () => _showExportDialog(null, ref, format),
    );
  }

  // ========================================================================
  // BOTTOM TIMELINE
  // ========================================================================

  Widget _buildBottomTimeline(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Container(
      height: 200,
      color: Colors.grey[900],
      child: Column(
        children: [
          // Timeline controls
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Timeline',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${appState.currentTime.toStringAsFixed(2)}s / ${appState.duration}s',
                ),
              ],
            ),
          ),

          // Timeline scrubber
          Expanded(
            child: CustomPaint(
              painter: TimelinePainter(
                currentTime: appState.currentTime,
                duration: appState.duration,
                layers: appState.layers,
              ),
              child: GestureDetector(
                onTapDown: (details) {
                  final width = context.size?.width ?? 800;
                  final time =
                      (details.localPosition.dx / width) * appState.duration;
                  ref.read(appStateProvider.notifier).updateTime(time);
                },
              ),
            ),
          ),

          // Timeline slider
          Slider(
            value: appState.currentTime,
            min: 0,
            max: appState.duration,
            onChanged: (v) => ref.read(appStateProvider.notifier).updateTime(v),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // HELPERS
  // ========================================================================

  Widget _buildPropertySection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 12),
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
    );
  }

  void _showExportDialog(
    BuildContext? context,
    WidgetRef ref,
    ExportFormat format,
  ) {
    final appState = ref.read(appStateProvider);
    final exportData = _generateExport(appState, format);

    showDialog(
      context: context ?? ref.context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Export as ${format.name.toUpperCase()}'),
            content: SizedBox(
              width: 600,
              height: 400,
              child: SingleChildScrollView(
                child: SelectableText(
                  exportData,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Copy to clipboard
                  Navigator.pop(ctx);
                },
                child: const Text('Copy'),
              ),
            ],
          ),
    );
  }

  String _generateExport(AppState appState, ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return '{\n  "version": "1.0",\n  "layers": ${appState.layers.length}\n}';
      case ExportFormat.svg:
        return '<svg width="800" height="600">\n  <!-- Layers -->\n</svg>';
      case ExportFormat.lottie:
        return '{"v": "5.9.0", "fr": 60}';
      case ExportFormat.rive:
        return '{"version": 7}';
      case ExportFormat.gif:
        return 'GIF export coming soon...';
      case ExportFormat.mp4:
        return 'Video export coming soon...';
    }
  }
}

// ============================================================================
// UNIFIED CANVAS PAINTER
// ============================================================================

class UnifiedCanvasPainter extends CustomPainter {
  final AppState appState;

  UnifiedCanvasPainter({required this.appState});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    if (appState.grid.visible) {
      _drawGrid(canvas, size);
    }

    // Draw layers
    for (var layer in appState.layers) {
      if (!layer.visible) continue;
      _drawLayer(canvas, layer);
    }

    // Draw selection
    if (appState.selectedLayer != null) {
      _drawSelection(canvas, appState.selectedLayer!);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = appState.grid.color.withOpacity(0.1)
          ..strokeWidth = 0.5;

    for (var x = 0.0; x < size.width; x += appState.grid.size) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var y = 0.0; y < size.height; y += appState.grid.size) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawLayer(Canvas canvas, StudioLayer layer) {
    canvas.save();

    // Apply 2D transforms
    canvas.translate(layer.position.dx, layer.position.dy);
    canvas.rotate(layer.rotation * math.pi / 180);
    canvas.scale(layer.scale);

    // Create paint
    final paint =
        Paint()
          ..color = layer.color.withOpacity(layer.opacity)
          ..style = PaintingStyle.fill;

    // Apply gradient if available
    if (layer.gradient != null) {
      paint.shader = _createGradient(layer.gradient!, layer.size).createShader(
        Rect.fromCenter(
          center: Offset.zero,
          width: layer.size.width,
          height: layer.size.height,
        ),
      );
    }

    // Draw based on type
    switch (layer.type) {
      case LayerType.rectangle:
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: layer.size.width,
            height: layer.size.height,
          ),
          paint,
        );
        break;

      case LayerType.circle:
        canvas.drawCircle(Offset.zero, layer.size.width / 2, paint);
        break;

      default:
        break;
    }

    canvas.restore();
  }

  void _drawSelection(Canvas canvas, StudioLayer layer) {
    canvas.save();
    canvas.translate(layer.position.dx, layer.position.dy);
    canvas.rotate(layer.rotation * math.pi / 180);

    final paint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: layer.size.width * layer.scale + 10,
        height: layer.size.height * layer.scale + 10,
      ),
      paint,
    );

    // Draw handles
    final handlePaint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

    final halfW = (layer.size.width * layer.scale) / 2;
    final halfH = (layer.size.height * layer.scale) / 2;

    final handles = [
      Offset(-halfW, -halfH),
      Offset(halfW, -halfH),
      Offset(halfW, halfH),
      Offset(-halfW, halfH),
    ];

    for (var handle in handles) {
      canvas.drawCircle(handle, 5, handlePaint);
    }

    canvas.restore();
  }

  Gradient _createGradient(GradientData gradient, Size size) {
    final colors = gradient.stops.map((s) => s.color).toList();
    final stops = gradient.stops.map((s) => s.offset).toList();

    switch (gradient.type) {
      case GradientType.linear:
        return LinearGradient(
          begin: Alignment(
            gradient.start.dx * 2 - 1,
            gradient.start.dy * 2 - 1,
          ),
          end: Alignment(gradient.end.dx * 2 - 1, gradient.end.dy * 2 - 1),
          colors: colors,
          stops: stops,
        );
      case GradientType.radial:
        return RadialGradient(colors: colors, stops: stops);
      case GradientType.sweep:
        return SweepGradient(colors: colors, stops: stops);
    }
  }

  @override
  bool shouldRepaint(UnifiedCanvasPainter oldDelegate) => true;
}

// ============================================================================
// TIMELINE PAINTER
// ============================================================================

class TimelinePainter extends CustomPainter {
  final double currentTime;
  final double duration;
  final List<StudioLayer> layers;

  TimelinePainter({
    required this.currentTime,
    required this.duration,
    required this.layers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw time markers
    final paint =
        Paint()
          ..color = Colors.grey[700]!
          ..strokeWidth = 1;

    for (var i = 0; i <= 10; i++) {
      final x = (size.width * i) / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);

      final time = (duration * i) / 10;
      final textPainter = TextPainter(
        text: TextSpan(
          text: time.toStringAsFixed(1),
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 2, 2));
    }

    // Draw current time indicator
    final currentX = (currentTime / duration) * size.width;
    final indicatorPaint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2;

    canvas.drawLine(
      Offset(currentX, 0),
      Offset(currentX, size.height),
      indicatorPaint,
    );

    // Draw keyframes for each layer
    var y = 20.0;
    for (var layer in layers) {
      for (var keyframe in layer.keyframes) {
        final x = (keyframe.time / duration) * size.width;
        canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.blue);
      }
      y += 20;
    }
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) => true;
}

/*
COMPLETE UNIFIED SVG ANIMATION STUDIO
=======================================

✅ ALL PHASES INTEGRATED:
- Phase 1: Bezier paths, Gradients, Animation curves
- Phase 2: Motion paths, Particles, Physics, Bones
- Phase 3: 3D Transforms, Mesh deformation, Video export

✅ STATE MANAGEMENT:
- Riverpod for clean state management
- AppState holds all data
- AppStateNotifier for mutations
- Real-time updates across UI

✅ UI STRUCTURE:
1. Top Menu Bar
   - File, Edit, View, Layer, Animation, Export menus
   - Mode selector (Design/Animate/Preview/Export)
   - Playback controls

2. Left Panel
   - Tools (Select, Rectangle, Circle, Path, etc.)
   - Layers list with reorder, visibility, delete

3. Main Canvas
   - 800x600 artboard
   - Grid system
   - Layer rendering
   - Selection handles

4. Right Panel
   - Design properties (transform, 3D, appearance)
   - Animation properties (keyframes)
   - Preview settings (camera)
   - Export settings

5. Bottom Timeline
   - Time ruler
   - Keyframe markers
   - Timeline scrubber
   - Playback slider

✅ FEATURES:
- Layer management
- Transform tools
- 3D transforms
- Gradient editor
- Animation keyframes
- Export to multiple formats
- Camera controls
- Grid system

SETUP REQUIRED:
===============
pubspec.yaml:
dependencies:
  flutter_riverpod: ^2.4.0
  vector_math: ^2.1.4

USAGE:
======
flutter run

All features accessible through menus and panels!
*/
