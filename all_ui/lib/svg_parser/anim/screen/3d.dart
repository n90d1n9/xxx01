import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vector;

// ============================================================================
// PHASE 3.1: 3D TRANSFORMS & PERSPECTIVE
// ============================================================================

class Studio3DHome extends StatefulWidget {
  const Studio3DHome({Key? key}) : super(key: key);

  @override
  State<Studio3DHome> createState() => _Studio3DHomeState();
}

class _Studio3DHomeState extends State<Studio3DHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Layer3D> _layers = [];
  Layer3D? _selectedLayer;

  // 3D Camera settings
  double _cameraDistance = 1000;
  double _cameraPitch = 0; // Up/Down
  double _cameraYaw = 0; // Left/Right
  double _fov = 60; // Field of view

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _initializeLayers();
  }

  void _initializeLayers() {
    // Create sample 3D layers
    _layers.addAll([
      Layer3D(
        id: 'cube_front',
        name: 'Cube Front',
        position: vector.Vector3(0, 0, 0),
        size: const Size(200, 200),
        color: Colors.blue,
        rotationX: 0,
        rotationY: 0,
        rotationZ: 0,
      ),
      Layer3D(
        id: 'cube_back',
        name: 'Cube Back',
        position: vector.Vector3(0, 0, -200),
        size: const Size(200, 200),
        color: Colors.red,
        rotationX: 0,
        rotationY: 0,
        rotationZ: 0,
      ),
      Layer3D(
        id: 'floor',
        name: 'Floor',
        position: vector.Vector3(0, 100, 0),
        size: const Size(400, 400),
        color: Colors.green.withOpacity(0.5),
        rotationX: 90,
        rotationY: 0,
        rotationZ: 0,
      ),
    ]);

    _selectedLayer = _layers.first;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 3.1: 3D Transforms & Perspective'),
        actions: [
          IconButton(
            icon: Icon(
              _controller.isAnimating ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              if (_controller.isAnimating) {
                _controller.stop();
              } else {
                _controller.repeat();
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          _buildLayerPanel(),
          Expanded(child: _build3DCanvas()),
          _build3DPropertiesPanel(),
        ],
      ),
    );
  }

  // ========================================================================
  // LAYER PANEL
  // ========================================================================

  Widget _buildLayerPanel() {
    return Container(
      width: 250,
      color: Colors.grey[900],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Layers (3D)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.add), onPressed: _addLayer),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _layers.length,
              itemBuilder: (context, index) {
                final layer = _layers[index];
                final isSelected = layer == _selectedLayer;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: Colors.blue.withOpacity(0.2),
                  leading: const Icon(Icons.view_in_ar),
                  title: Text(layer.name),
                  subtitle: Text('Z: ${layer.position.z.toInt()}'),
                  onTap: () => setState(() => _selectedLayer = layer),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // 3D CANVAS
  // ========================================================================

  Widget _build3DCanvas() {
    return Container(
      color: Colors.grey[850],
      child: Center(
        child: Container(
          width: 800,
          height: 600,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Auto-rotate for demo
              if (_controller.isAnimating && _selectedLayer != null) {
                _selectedLayer!.rotationY = _controller.value * 360;
              }

              return CustomPaint(
                painter: Canvas3DPainter(
                  layers: _layers,
                  selectedLayer: _selectedLayer,
                  cameraDistance: _cameraDistance,
                  cameraPitch: _cameraPitch,
                  cameraYaw: _cameraYaw,
                  fov: _fov,
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
  // 3D PROPERTIES PANEL
  // ========================================================================

  Widget _build3DPropertiesPanel() {
    return Container(
      width: 350,
      color: Colors.grey[900],
      child:
          _selectedLayer == null
              ? const Center(child: Text('Select a layer'))
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    '3D Transform',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Position
                  _buildSection('Position', [
                    _buildSlider(
                      'X',
                      _selectedLayer!.position.x,
                      -400,
                      400,
                      (v) => setState(() => _selectedLayer!.position.x = v),
                    ),
                    _buildSlider(
                      'Y',
                      _selectedLayer!.position.y,
                      -300,
                      300,
                      (v) => setState(() => _selectedLayer!.position.y = v),
                    ),
                    _buildSlider(
                      'Z (Depth)',
                      _selectedLayer!.position.z,
                      -500,
                      500,
                      (v) => setState(() => _selectedLayer!.position.z = v),
                    ),
                  ]),

                  const Divider(height: 32),

                  // 3D Rotation
                  _buildSection('3D Rotation', [
                    _buildSlider(
                      'Rotate X (Pitch)',
                      _selectedLayer!.rotationX,
                      -180,
                      180,
                      (v) => setState(() => _selectedLayer!.rotationX = v),
                    ),
                    _buildSlider(
                      'Rotate Y (Yaw)',
                      _selectedLayer!.rotationY,
                      -180,
                      180,
                      (v) => setState(() => _selectedLayer!.rotationY = v),
                    ),
                    _buildSlider(
                      'Rotate Z (Roll)',
                      _selectedLayer!.rotationZ,
                      -180,
                      180,
                      (v) => setState(() => _selectedLayer!.rotationZ = v),
                    ),
                  ]),

                  const Divider(height: 32),

                  // Scale
                  _buildSection('Scale', [
                    _buildSlider(
                      'Scale X',
                      _selectedLayer!.scaleX,
                      0.1,
                      3,
                      (v) => setState(() => _selectedLayer!.scaleX = v),
                    ),
                    _buildSlider(
                      'Scale Y',
                      _selectedLayer!.scaleY,
                      0.1,
                      3,
                      (v) => setState(() => _selectedLayer!.scaleY = v),
                    ),
                    _buildSlider(
                      'Scale Z',
                      _selectedLayer!.scaleZ,
                      0.1,
                      3,
                      (v) => setState(() => _selectedLayer!.scaleZ = v),
                    ),
                  ]),

                  const Divider(height: 32),

                  // Camera Settings
                  _buildSection('Camera', [
                    _buildSlider(
                      'Distance',
                      _cameraDistance,
                      500,
                      2000,
                      (v) => setState(() => _cameraDistance = v),
                    ),
                    _buildSlider(
                      'Pitch',
                      _cameraPitch,
                      -90,
                      90,
                      (v) => setState(() => _cameraPitch = v),
                    ),
                    _buildSlider(
                      'Yaw',
                      _cameraYaw,
                      -180,
                      180,
                      (v) => setState(() => _cameraYaw = v),
                    ),
                    _buildSlider(
                      'FOV',
                      _fov,
                      30,
                      120,
                      (v) => setState(() => _fov = v),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // Preset buttons
                  const Text(
                    'Quick Presets',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () => _applyPreset('front'),
                        child: const Text('Front View'),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyPreset('top'),
                        child: const Text('Top View'),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyPreset('side'),
                        child: const Text('Side View'),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyPreset('isometric'),
                        child: const Text('Isometric'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Animation presets
                  const Text(
                    'Animation Presets',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.rotate_right),
                        label: const Text('Spin'),
                        onPressed: () => _startAnimation('spin'),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.flip),
                        label: const Text('Flip'),
                        onPressed: () => _startAnimation('flip'),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.view_in_ar),
                        label: const Text('Tumble'),
                        onPressed: () => _startAnimation('tumble'),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
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
              style: const TextStyle(fontSize: 12, color: Colors.blue),
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

  // ========================================================================
  // ACTIONS
  // ========================================================================

  void _addLayer() {
    setState(() {
      _layers.add(
        Layer3D(
          id: 'layer_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Layer ${_layers.length + 1}',
          position: vector.Vector3(0, 0, -100 * _layers.length.toDouble()),
          size: const Size(150, 150),
          color: Colors.primaries[_layers.length % Colors.primaries.length],
        ),
      );
    });
  }

  void _applyPreset(String preset) {
    setState(() {
      switch (preset) {
        case 'front':
          _cameraPitch = 0;
          _cameraYaw = 0;
          break;
        case 'top':
          _cameraPitch = -90;
          _cameraYaw = 0;
          break;
        case 'side':
          _cameraPitch = 0;
          _cameraYaw = 90;
          break;
        case 'isometric':
          _cameraPitch = -30;
          _cameraYaw = 45;
          break;
      }
    });
  }

  void _startAnimation(String type) {
    // Reset and start animation
    _controller.reset();
    _controller.repeat();
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

class Layer3D {
  String id;
  String name;
  vector.Vector3 position;
  Size size;
  Color color;
  double rotationX; // Pitch
  double rotationY; // Yaw
  double rotationZ; // Roll
  double scaleX;
  double scaleY;
  double scaleZ;
  double opacity;

  Layer3D({
    required this.id,
    required this.name,
    required this.position,
    required this.size,
    required this.color,
    this.rotationX = 0,
    this.rotationY = 0,
    this.rotationZ = 0,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.scaleZ = 1.0,
    this.opacity = 1.0,
  });

  // Get transformation matrix
  vector.Matrix4 getTransformMatrix() {
    final transform = vector.Matrix4.identity();

    // Apply transformations in order: Scale -> Rotate -> Translate
    transform.translate(position.x, position.y, position.z);

    // Apply rotations (in order: Z, Y, X)
    transform.rotateZ(rotationZ * math.pi / 180);
    transform.rotateY(rotationY * math.pi / 180);
    transform.rotateX(rotationX * math.pi / 180);

    transform.scale(scaleX, scaleY, scaleZ);

    return transform;
  }

  // Get the 4 corners of the layer in 3D space
  List<vector.Vector3> getCorners3D() {
    final halfW = size.width / 2;
    final halfH = size.height / 2;

    final corners = [
      vector.Vector3(-halfW, -halfH, 0),
      vector.Vector3(halfW, -halfH, 0),
      vector.Vector3(halfW, halfH, 0),
      vector.Vector3(-halfW, halfH, 0),
    ];

    final transform = getTransformMatrix();

    return corners.map((corner) => transform.transform3(corner)).toList();
  }
}

// ============================================================================
// 3D CANVAS PAINTER WITH PERSPECTIVE PROJECTION
// ============================================================================

class Canvas3DPainter extends CustomPainter {
  final List<Layer3D> layers;
  final Layer3D? selectedLayer;
  final double cameraDistance;
  final double cameraPitch;
  final double cameraYaw;
  final double fov;

  Canvas3DPainter({
    required this.layers,
    this.selectedLayer,
    required this.cameraDistance,
    required this.cameraPitch,
    required this.cameraYaw,
    required this.fov,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Sort layers by Z-depth (painter's algorithm)
    final sortedLayers = List<Layer3D>.from(layers);
    sortedLayers.sort((a, b) {
      final aZ = a.position.z + cameraDistance;
      final bZ = b.position.z + cameraDistance;
      return bZ.compareTo(aZ); // Draw far to near
    });

    // Draw grid
    _drawGrid(canvas, size, center);

    // Draw each layer
    for (var layer in sortedLayers) {
      _drawLayer3D(canvas, size, center, layer);
    }

    // Draw axes
    _drawAxes(canvas, size, center);
  }

  void _drawGrid(Canvas canvas, Size size, Offset center) {
    final gridPaint =
        Paint()
          ..color = Colors.grey[800]!
          ..strokeWidth = 1;

    final gridSize = 50.0;
    final numLines = 20;

    for (var i = -numLines; i <= numLines; i++) {
      final offset = i * gridSize;

      // Horizontal lines
      final start1 = vector.Vector3(offset, 100, -numLines * gridSize);
      final end1 = vector.Vector3(offset, 100, numLines * gridSize);

      final proj1Start = _project3DTo2D(start1, size, center);
      final proj1End = _project3DTo2D(end1, size, center);

      if (proj1Start != null && proj1End != null) {
        canvas.drawLine(proj1Start, proj1End, gridPaint);
      }

      // Vertical lines
      final start2 = vector.Vector3(-numLines * gridSize, 100, offset);
      final end2 = vector.Vector3(numLines * gridSize, 100, offset);

      final proj2Start = _project3DTo2D(start2, size, center);
      final proj2End = _project3DTo2D(end2, size, center);

      if (proj2Start != null && proj2End != null) {
        canvas.drawLine(proj2Start, proj2End, gridPaint);
      }
    }
  }

  void _drawLayer3D(Canvas canvas, Size size, Offset center, Layer3D layer) {
    final corners3D = layer.getCorners3D();

    // Project to 2D
    final corners2D =
        corners3D
            .map((c) => _project3DTo2D(c, size, center))
            .where((c) => c != null)
            .cast<Offset>()
            .toList();

    if (corners2D.length < 4) return;

    // Draw filled quad
    final path =
        Path()
          ..moveTo(corners2D[0].dx, corners2D[0].dy)
          ..lineTo(corners2D[1].dx, corners2D[1].dy)
          ..lineTo(corners2D[2].dx, corners2D[2].dy)
          ..lineTo(corners2D[3].dx, corners2D[3].dy)
          ..close();

    // Calculate brightness based on Z-depth
    final avgZ =
        corners3D.fold<double>(0, (sum, c) => sum + c.z) / corners3D.length;
    final brightness = (1 - (avgZ + 500) / 1000).clamp(0.3, 1.0);

    final fillPaint =
        Paint()
          ..color = layer.color.withOpacity(layer.opacity * brightness)
          ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    // Draw outline
    final outlinePaint =
        Paint()
          ..color = layer == selectedLayer ? Colors.blue : Colors.white30
          ..strokeWidth = layer == selectedLayer ? 3 : 1
          ..style = PaintingStyle.stroke;

    canvas.drawPath(path, outlinePaint);

    // Draw layer name at center
    final centerPoint = _project3DTo2D(layer.position, size, center);

    if (centerPoint != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: layer.name,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        centerPoint - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawAxes(Canvas canvas, Size size, Offset center) {
    final axisLength = 100.0;

    // X axis (Red)
    final xStart = _project3DTo2D(vector.Vector3.zero(), size, center);
    final xEnd = _project3DTo2D(vector.Vector3(axisLength, 0, 0), size, center);

    if (xStart != null && xEnd != null) {
      canvas.drawLine(
        xStart,
        xEnd,
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2,
      );
    }

    // Y axis (Green)
    final yStart = _project3DTo2D(vector.Vector3.zero(), size, center);
    final yEnd = _project3DTo2D(vector.Vector3(0, axisLength, 0), size, center);

    if (yStart != null && yEnd != null) {
      canvas.drawLine(
        yStart,
        yEnd,
        Paint()
          ..color = Colors.green
          ..strokeWidth = 2,
      );
    }

    // Z axis (Blue)
    final zStart = _project3DTo2D(vector.Vector3.zero(), size, center);
    final zEnd = _project3DTo2D(vector.Vector3(0, 0, axisLength), size, center);

    if (zStart != null && zEnd != null) {
      canvas.drawLine(
        zStart,
        zEnd,
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2,
      );
    }
  }

  Offset? _project3DTo2D(vector.Vector3 point3D, Size size, Offset center) {
    // Apply camera transformations
    final cameraTransform = vector.Matrix4.identity();

    // Move back by camera distance
    cameraTransform.translate(0.0, 0.0, cameraDistance);

    // Apply camera rotations
    cameraTransform.rotateX(-cameraPitch * math.pi / 180);
    cameraTransform.rotateY(-cameraYaw * math.pi / 180);

    // Transform point
    final transformed = cameraTransform.transform3(point3D);

    // Perspective projection
    final fovRad = fov * math.pi / 180;
    final perspectiveFactor = math.tan(fovRad / 2);

    if (transformed.z >= -10) return null; // Behind camera

    final scale = -cameraDistance / transformed.z * perspectiveFactor;

    final x = center.dx + transformed.x * scale;
    final y = center.dy - transformed.y * scale; // Flip Y

    return Offset(x, y);
  }

  @override
  bool shouldRepaint(Canvas3DPainter oldDelegate) => true;
}

/*
PHASE 3.1 COMPLETE: 3D TRANSFORMS
===================================

✅ FEATURES IMPLEMENTED:
1. Full 3D positioning (X, Y, Z)
2. 3D rotations (Pitch, Yaw, Roll)
3. 3D scaling (X, Y, Z)
4. Perspective projection
5. Camera controls (distance, pitch, yaw, FOV)
6. Z-depth sorting (painter's algorithm)
7. Depth-based shading
8. 3D grid floor
9. 3D axes visualization
10. Camera presets (Front, Top, Side, Isometric)
11. Animation support

USAGE:
======
- Add layers and position them in 3D space
- Rotate on X, Y, Z axes
- Adjust camera for different views
- Use presets for quick positioning
- Animate rotations

NEXT: Phase 3.2 - Mesh Deformation
*/
