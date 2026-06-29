import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../painter/advanced_canvas_painter.dart';
import '../painter/curve_visualizer_painter.dart';
import '../schema/advanced_tool.dart';
import '../schema/layer/advanced_layer.dart';
import '../schema/anim/animation_curve_data.dart';
import '../schema/layer/layer.dart';
import '../schema/path/bezier_path_data.dart';
import '../schema/path/bezier_point.dart';
import '../schema/path/motion_path_data.dart';
import '../schema/path/point.dart';
import '../schema/physic/bone_data.dart';
import '../schema/physic/particle_emitter_data.dart';
import '../schema/physic/particle_system_data.dart';
import '../schema/physic/physic_word_data.dart';
import '../schema/physic/physics_body_data.dart';
import '../schema/theme/color_stop.dart';
import '../schema/theme/gradient_data.dart';

class AdvancedStudioHome extends StatefulWidget {
  const AdvancedStudioHome({super.key});

  @override
  State<AdvancedStudioHome> createState() => _AdvancedStudioHomeState();
}

class _AdvancedStudioHomeState extends State<AdvancedStudioHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<AdvancedLayer> _layers = [];
  AdvancedLayer? _selectedLayer;
  AdvancedTool _currentTool = AdvancedTool.select;

  // Advanced features
  BezierPathData? _currentPath;
  GradientData? _currentGradient;
  AnimationCurveData? _currentCurve;
  MotionPathData? _currentMotionPath;
  ParticleSystemData? _particleSystem;
  PhysicsWorldData? _physicsWorld;
  final List<BoneData> _skeleton = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Add sample layers
    _layers.add(
      AdvancedLayer(
        id: 'layer1',
        name: 'Background',
        type: LayerType.rectangle,
        position: const Offset(400, 300),
        size: const Size(800, 600),
        color: Colors.blue.shade900,
      ),
    );

    // Initialize particle system
    _particleSystem = ParticleSystemData(
      emitter: ParticleEmitterData(
        position: const Offset(400, 100),
        rate: 20,
        particleLifeSpan: 2.0,
        particleSize: 5.0,
        particleColor: Colors.yellow,
        spread: math.pi * 2,
        speed: 100,
      ),
    );

    // Initialize physics world
    _physicsWorld = PhysicsWorldData(
      gravity: const Offset(0, 980),
      bounds: const Rect.fromLTWH(0, 0, 800, 600),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced SVG Animation Studio'),
        actions: [
          IconButton(
            icon: Icon(
              _animController.isAnimating ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: _toggleAnimation,
          ),
          IconButton(icon: const Icon(Icons.stop), onPressed: _stopAnimation),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          _buildToolPanel(),
          Expanded(child: _buildCanvas()),
          _buildPropertiesPanel(),
        ],
      ),
    );
  }

  // ========================================================================
  // TOOL PANEL
  // ========================================================================

  Widget _buildToolPanel() {
    return Container(
      width: 250,
      color: Colors.grey[900],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildToolSection('Basic Tools', [
            _buildToolButton(Icons.near_me, AdvancedTool.select, 'Select'),
            _buildToolButton(
              Icons.rectangle,
              AdvancedTool.rectangle,
              'Rectangle',
            ),
            _buildToolButton(Icons.circle, AdvancedTool.circle, 'Circle'),
          ]),

          const Divider(height: 32),

          _buildToolSection('Advanced Tools', [
            _buildToolButton(
              Icons.polyline,
              AdvancedTool.bezierPath,
              'Bezier Path',
            ),
            _buildToolButton(Icons.gradient, AdvancedTool.gradient, 'Gradient'),
            _buildToolButton(
              Icons.timeline,
              AdvancedTool.animationCurve,
              'Curve Editor',
            ),
            _buildToolButton(
              Icons.route,
              AdvancedTool.motionPath,
              'Motion Path',
            ),
            _buildToolButton(
              Icons.bubble_chart,
              AdvancedTool.particles,
              'Particles',
            ),
            _buildToolButton(
              Icons.accessibility,
              AdvancedTool.bones,
              'Skeleton',
            ),
            _buildToolButton(
              Icons.sports_baseball,
              AdvancedTool.physics,
              'Physics',
            ),
          ]),

          const Divider(height: 32),

          _buildLayersList(),
        ],
      ),
    );
  }

  Widget _buildToolSection(String title, List<Widget> tools) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: tools),
      ],
    );
  }

  Widget _buildToolButton(IconData icon, AdvancedTool tool, String tooltip) {
    final isSelected = _currentTool == tool;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => setState(() => _currentTool = tool),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLayersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Layers',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, size: 16),
              onPressed: _addNewLayer,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._layers.map((layer) {
          final isSelected = layer == _selectedLayer;
          return ListTile(
            dense: true,
            selected: isSelected,
            selectedTileColor: Colors.blue.withOpacity(0.2),
            title: Text(layer.name, style: const TextStyle(fontSize: 12)),
            leading: Icon(_getLayerIcon(layer.type), size: 16),
            trailing: IconButton(
              icon: const Icon(Icons.delete, size: 16),
              onPressed: () => _deleteLayer(layer),
            ),
            onTap: () => setState(() => _selectedLayer = layer),
          );
        }).toList(),
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
      case LayerType.particle:
        return Icons.bubble_chart;
      case LayerType.bone:
        return Icons.accessibility;
      case LayerType.shape:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.image:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.text:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.group:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.ellipse:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  // ========================================================================
  // CANVAS
  // ========================================================================

  Widget _buildCanvas() {
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
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                painter: AdvancedCanvasPainter(
                  layers: _layers,
                  selectedLayer: _selectedLayer,
                  progress: _animController.value,
                  particleSystem: _particleSystem,
                  physicsWorld: _physicsWorld,
                  skeleton: _skeleton,
                  currentPath: _currentPath,
                  currentMotionPath: _currentMotionPath,
                ),
                size: const Size(800, 600),
              );
            },
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // PROPERTIES PANEL
  // ========================================================================

  Widget _buildPropertiesPanel() {
    return Container(
      width: 300,
      color: Colors.grey[900],
      child: _buildToolProperties(),
    );
  }

  Widget _buildToolProperties() {
    switch (_currentTool) {
      case AdvancedTool.bezierPath:
        return _buildBezierPathEditor();
      case AdvancedTool.gradient:
        return _buildGradientEditor();
      case AdvancedTool.animationCurve:
        return _buildAnimationCurveEditor();
      case AdvancedTool.motionPath:
        return _buildMotionPathEditor();
      case AdvancedTool.particles:
        return _buildParticleEditor();
      case AdvancedTool.physics:
        return _buildPhysicsEditor();
      case AdvancedTool.bones:
        return _buildBoneEditor();
      default:
        return _buildBasicProperties();
    }
  }

  Widget _buildBasicProperties() {
    if (_selectedLayer == null) {
      return const Center(child: Text('Select a layer or tool'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Transform', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSlider('X', _selectedLayer!.position.dx, 0, 800, (v) {
          setState(
            () =>
                _selectedLayer!.position = Offset(
                  v,
                  _selectedLayer!.position.dy,
                ),
          );
        }),
        _buildSlider('Y', _selectedLayer!.position.dy, 0, 600, (v) {
          setState(
            () =>
                _selectedLayer!.position = Offset(
                  _selectedLayer!.position.dx,
                  v,
                ),
          );
        }),
        _buildSlider('Rotation', _selectedLayer!.rotation, 0, 360, (v) {
          setState(() => _selectedLayer!.rotation = v);
        }),
        _buildSlider('Scale', _selectedLayer!.scale, 0.1, 3, (v) {
          setState(() => _selectedLayer!.scale = v);
        }),

        const SizedBox(height: 16),
        const Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSlider('Opacity', _selectedLayer!.opacity, 0, 1, (v) {
          setState(() => _selectedLayer!.opacity = v);
        }),
      ],
    );
  }

  // ========================================================================
  // BEZIER PATH EDITOR
  // ========================================================================

  Widget _buildBezierPathEditor() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Bezier Path Editor',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Point'),
          onPressed: () {
            setState(() {
              _currentPath ??= BezierPathData(points: []);
              _currentPath!.points.add(
                BezierPoint(
                  position: const Offset(400, 300),
                  handleIn: const Offset(-50, 0),
                  handleOut: const Offset(50, 0),
                  type: PointType.smooth,
                ),
              );
            });
          },
        ),

        if (_currentPath != null) ...[
          const SizedBox(height: 16),
          Text('Points: ${_currentPath!.points.length}'),

          const SizedBox(height: 8),
          ..._currentPath!.points.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;

            return Card(
              child: ListTile(
                title: Text('Point $index'),
                subtitle: Text('Type: ${point.type.name}'),
                trailing: PopupMenuButton<PointType>(
                  onSelected: (type) {
                    setState(() => _currentPath!.points[index].type = type);
                  },
                  itemBuilder:
                      (context) =>
                          PointType.values.map((type) {
                            return PopupMenuItem(
                              value: type,
                              child: Text(type.name),
                            );
                          }).toList(),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Apply to Layer'),
            onPressed: _applyPathToLayer,
          ),
        ],
      ],
    );
  }

  // ========================================================================
  // GRADIENT EDITOR
  // ========================================================================

  Widget _buildGradientEditor() {
    _currentGradient ??= GradientData(
      type: GradientType.linear,
      stops: [
        ColorStop(offset: 0.0, color: Colors.blue),
        ColorStop(offset: 1.0, color: Colors.red),
      ],
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Gradient Editor',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Gradient type
        SegmentedButton<GradientType>(
          segments: const [
            ButtonSegment(value: GradientType.linear, label: Text('Linear')),
            ButtonSegment(value: GradientType.radial, label: Text('Radial')),
            ButtonSegment(value: GradientType.sweep, label: Text('Sweep')),
          ],
          selected: {_currentGradient!.type},
          onSelectionChanged: (Set<GradientType> selection) {
            setState(() => _currentGradient!.type = selection.first);
          },
        ),

        const SizedBox(height: 16),

        // Preview
        Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: _buildGradientPreview(),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
        ),

        const SizedBox(height: 16),

        // Color stops
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Color Stops',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(icon: const Icon(Icons.add), onPressed: _addColorStop),
          ],
        ),

        ..._currentGradient!.stops.asMap().entries.map((entry) {
          final index = entry.key;
          final stop = entry.value;

          return Card(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: stop.color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white),
                ),
              ),
              title: Slider(
                value: stop.offset,
                onChanged: (v) {
                  setState(() => _currentGradient!.stops[index].offset = v);
                },
              ),
              subtitle: Text('${(stop.offset * 100).toInt()}%'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeColorStop(index),
              ),
            ),
          );
        }).toList(),

        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.brush),
          label: const Text('Apply Gradient'),
          onPressed: _applyGradient,
        ),
      ],
    );
  }

  Gradient _buildGradientPreview() {
    final colors = _currentGradient!.stops.map((s) => s.color).toList();
    final stops = _currentGradient!.stops.map((s) => s.offset).toList();

    switch (_currentGradient!.type) {
      case GradientType.linear:
        return LinearGradient(colors: colors, stops: stops);
      case GradientType.radial:
        return RadialGradient(colors: colors, stops: stops);
      case GradientType.sweep:
        return SweepGradient(colors: colors, stops: stops);
    }
  }

  // ========================================================================
  // ANIMATION CURVE EDITOR
  // ========================================================================

  Widget _buildAnimationCurveEditor() {
    _currentCurve ??= AnimationCurveData(
      p1: const Offset(0.25, 0.1),
      p2: const Offset(0.75, 0.9),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Animation Curve Editor',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Curve visualization
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: CurveVisualizerPainter(curveData: _currentCurve!),
          ),
        ),

        const SizedBox(height: 16),

        // Control points
        const Text(
          'Control Point 1',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        _buildSlider('X', _currentCurve!.p1.dx, 0, 1, (v) {
          setState(() => _currentCurve!.p1 = Offset(v, _currentCurve!.p1.dy));
        }),
        _buildSlider('Y', _currentCurve!.p1.dy, 0, 1, (v) {
          setState(() => _currentCurve!.p1 = Offset(_currentCurve!.p1.dx, v));
        }),

        const SizedBox(height: 8),
        const Text(
          'Control Point 2',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        _buildSlider('X', _currentCurve!.p2.dx, 0, 1, (v) {
          setState(() => _currentCurve!.p2 = Offset(v, _currentCurve!.p2.dy));
        }),
        _buildSlider('Y', _currentCurve!.p2.dy, 0, 1, (v) {
          setState(() => _currentCurve!.p2 = Offset(_currentCurve!.p2.dx, v));
        }),

        const SizedBox(height: 16),

        // Presets
        const Text('Presets', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildCurvePreset('Linear', const Offset(0, 0), const Offset(1, 1)),
            _buildCurvePreset(
              'Ease',
              const Offset(0.25, 0.1),
              const Offset(0.25, 1),
            ),
            _buildCurvePreset(
              'Ease In',
              const Offset(0.42, 0),
              const Offset(1, 1),
            ),
            _buildCurvePreset(
              'Ease Out',
              const Offset(0, 0),
              const Offset(0.58, 1),
            ),
            _buildCurvePreset(
              'Ease In Out',
              const Offset(0.42, 0),
              const Offset(0.58, 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurvePreset(String name, Offset p1, Offset p2) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _currentCurve!.p1 = p1;
          _currentCurve!.p2 = p2;
        });
      },
      child: Text(name),
    );
  }

  // ========================================================================
  // MOTION PATH EDITOR
  // ========================================================================

  Widget _buildMotionPathEditor() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Motion Path Animation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        const Text('Animate selected layer along a custom path'),
        const SizedBox(height: 16),

        ElevatedButton.icon(
          icon: const Icon(Icons.add_road),
          label: const Text('Create Motion Path'),
          onPressed: () {
            setState(() {
              _currentMotionPath = MotionPathData(
                path:
                    Path()
                      ..moveTo(100, 300)
                      ..quadraticBezierTo(400, 100, 700, 300),
                duration: 3.0,
                autoRotate: true,
              );
            });
          },
        ),

        if (_currentMotionPath != null) ...[
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Auto Rotate'),
            value: _currentMotionPath!.autoRotate,
            onChanged: (v) {
              setState(() => _currentMotionPath!.autoRotate = v);
            },
          ),

          _buildSlider(
            'Duration',
            _currentMotionPath!.duration,
            0.5,
            10,
            (v) => setState(() => _currentMotionPath!.duration = v),
          ),

          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Preview Motion'),
            onPressed: () {
              _animController.reset();
              _animController.repeat();
            },
          ),
        ],
      ],
    );
  }

  // ========================================================================
  // PARTICLE EDITOR
  // ========================================================================

  Widget _buildParticleEditor() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Particle System',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        _buildSlider(
          'Emission Rate',
          _particleSystem!.emitter.rate,
          1,
          100,
          (v) => setState(() => _particleSystem!.emitter.rate = v),
        ),

        _buildSlider(
          'Particle Size',
          _particleSystem!.emitter.particleSize,
          1,
          20,
          (v) => setState(() => _particleSystem!.emitter.particleSize = v),
        ),

        _buildSlider(
          'Life Span',
          _particleSystem!.emitter.particleLifeSpan,
          0.5,
          5,
          (v) => setState(() => _particleSystem!.emitter.particleLifeSpan = v),
        ),

        _buildSlider(
          'Speed',
          _particleSystem!.emitter.speed,
          10,
          500,
          (v) => setState(() => _particleSystem!.emitter.speed = v),
        ),

        _buildSlider(
          'Spread',
          _particleSystem!.emitter.spread,
          0,
          math.pi * 2,
          (v) => setState(() => _particleSystem!.emitter.spread = v),
        ),

        const SizedBox(height: 16),
        const Text(
          'Particle Color',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8,
          children:
              Colors.primaries.map((color) {
                return InkWell(
                  onTap: () {
                    setState(
                      () => _particleSystem!.emitter.particleColor = color,
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            _particleSystem!.emitter.particleColor == color
                                ? Colors.white
                                : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),

        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: Icon(_particleSystem!.active ? Icons.pause : Icons.play_arrow),
          label: Text(
            _particleSystem!.active ? 'Stop Emission' : 'Start Emission',
          ),
          onPressed: () {
            setState(() => _particleSystem!.active = !_particleSystem!.active);
          },
        ),
      ],
    );
  }

  // ========================================================================
  // PHYSICS EDITOR
  // ========================================================================

  Widget _buildPhysicsEditor() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Physics Simulation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        _buildSlider(
          'Gravity',
          _physicsWorld!.gravity.dy,
          0,
          2000,
          (v) => setState(() => _physicsWorld!.gravity = Offset(0, v)),
        ),

        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Physics Body'),
          onPressed: _addPhysicsBody,
        ),

        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: Icon(_physicsWorld!.active ? Icons.pause : Icons.play_arrow),
          label: Text(
            _physicsWorld!.active ? 'Pause Simulation' : 'Start Simulation',
          ),
          onPressed: () {
            setState(() => _physicsWorld!.active = !_physicsWorld!.active);
          },
        ),

        const SizedBox(height: 16),
        Text('Bodies: ${_physicsWorld!.bodies.length}'),
      ],
    );
  }

  // ========================================================================
  // BONE EDITOR
  // ========================================================================

  Widget _buildBoneEditor() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Skeleton & IK System',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Bone'),
          onPressed: _addBone,
        ),

        const SizedBox(height: 16),
        Text('Bones: ${_skeleton.length}'),

        ..._skeleton.asMap().entries.map((entry) {
          final index = entry.key;
          final bone = entry.value;

          return Card(
            child: ListTile(
              title: Text(bone.name),
              subtitle: Text('Length: ${bone.length.toInt()}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() => _skeleton.removeAt(index));
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // ========================================================================
  // HELPERS
  // ========================================================================

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
          children: [Text(label), Text(value.toStringAsFixed(1))],
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

  void _toggleAnimation() {
    if (_animController.isAnimating) {
      _animController.stop();
    } else {
      _animController.repeat();
    }
  }

  void _stopAnimation() {
    _animController.stop();
    _animController.reset();
  }

  void _addNewLayer() {
    setState(() {
      _layers.add(
        AdvancedLayer(
          id: 'layer_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Layer ${_layers.length + 1}',
          type: LayerType.rectangle,
          position: const Offset(400, 300),
          size: const Size(100, 100),
          color: Colors.primaries[_layers.length % Colors.primaries.length],
        ),
      );
    });
  }

  void _deleteLayer(AdvancedLayer layer) {
    setState(() {
      _layers.remove(layer);
      if (_selectedLayer == layer) _selectedLayer = null;
    });
  }

  void _applyPathToLayer() {
    if (_selectedLayer != null && _currentPath != null) {
      setState(() {
        _selectedLayer!.bezierPath = _currentPath;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Path applied to layer')));
    }
  }

  void _applyGradient() {
    if (_selectedLayer != null && _currentGradient != null) {
      setState(() {
        _selectedLayer!.gradient = _currentGradient;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gradient applied to layer')),
      );
    }
  }

  void _addColorStop() {
    setState(() {
      final newOffset = (_currentGradient!.stops.last.offset + 0.2).clamp(
        0.0,
        1.0,
      );
      _currentGradient!.stops.add(
        ColorStop(offset: newOffset, color: Colors.green),
      );
    });
  }

  void _removeColorStop(int index) {
    if (_currentGradient!.stops.length > 2) {
      setState(() => _currentGradient!.stops.removeAt(index));
    }
  }

  void _addPhysicsBody() {
    setState(() {
      _physicsWorld!.bodies.add(
        PhysicsBodyData(
          position: Offset(400 + math.Random().nextDouble() * 100 - 50, 100),
          velocity: Offset.zero,
          mass: 1.0,
          restitution: 0.8,
          radius: 20,
        ),
      );
    });
  }

  void _addBone() {
    setState(() {
      final index = _skeleton.length;
      _skeleton.add(
        BoneData(
          id: 'bone_$index',
          name: 'Bone $index',
          position: Offset(400, 200 + index * 80.0),
          length: 80,
          rotation: 0,
        ),
      );
    });
  }
}
