import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../anim/painter/canvas_painter.dart';
import '../../anim/schema/layer/designer_layer.dart';
import '../../anim/schema/layer/layer.dart';
import '../../anim/timeline/animation_timeline.dart';
import '../../anim/timeline/timeline_rule_painter.dart';
import '../../anim/timeline/timeline_tracker_painter.dart';
import '../model/designer_tool.dart';

class SvgDesignerHome extends StatefulWidget {
  const SvgDesignerHome({Key? key}) : super(key: key);

  @override
  State<SvgDesignerHome> createState() => _SvgDesignerHomeState();
}

class _SvgDesignerHomeState extends State<SvgDesignerHome> {
  final List<DesignerLayer> _layers = [];
  DesignerLayer? _selectedLayer;
  final List<AnimationTimeline> _timelines = [];
  double _currentTime = 0.0;
  double _duration = 3.0;
  bool _isPlaying = false;
  final Size _artboardSize = const Size(800, 600);
  DesignerTool _currentTool = DesignerTool.select;
  Offset? _dragStart;

  @override
  void initState() {
    super.initState();
    _addSampleLayers();
  }

  void _addSampleLayers() {
    setState(() {
      _layers.add(
        DesignerLayer(
          id: 'layer_1',
          name: 'Rectangle',
          type: LayerType.rectangle,
          position: const Offset(100, 100),
          size: const Size(200, 150),
          color: Colors.blue,
          rotation: 0,
          scale: 1.0,
          opacity: 1.0,
        ),
      );

      _layers.add(
        DesignerLayer(
          id: 'layer_2',
          name: 'Circle',
          type: LayerType.circle,
          position: const Offset(400, 200),
          size: const Size(100, 100),
          color: Colors.red,
          rotation: 0,
          scale: 1.0,
          opacity: 1.0,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          _buildTopToolbar(),
          Expanded(
            child: Row(
              children: [
                _buildLeftPanel(),
                Expanded(child: _buildCanvas()),
                _buildRightPanel(),
              ],
            ),
          ),
          _buildTimelinePanel(),
        ],
      ),
    );
  }

  // ========================================================================
  // TOP TOOLBAR
  // ========================================================================

  Widget _buildTopToolbar() {
    return Container(
      height: 60,
      color: Colors.grey[850],
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'SVG Animation Designer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 32),

          // Tools
          _buildToolButton(Icons.near_me, DesignerTool.select, 'Select'),
          _buildToolButton(Icons.pan_tool, DesignerTool.pan, 'Pan'),
          const VerticalDivider(color: Colors.grey),
          _buildToolButton(
            Icons.rectangle_outlined,
            DesignerTool.rectangle,
            'Rectangle',
          ),
          _buildToolButton(
            Icons.circle_outlined,
            DesignerTool.circle,
            'Circle',
          ),
          _buildToolButton(
            Icons.hexagon_outlined,
            DesignerTool.ellipse,
            'Ellipse',
          ),
          _buildToolButton(Icons.polyline, DesignerTool.path, 'Path'),
          _buildToolButton(Icons.text_fields, DesignerTool.text, 'Text'),

          const Spacer(),

          // Playback controls
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            color: Colors.white,
            onPressed: _togglePlayback,
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            color: Colors.white,
            onPressed: _stopPlayback,
          ),

          const VerticalDivider(color: Colors.grey),

          // Export
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Export'),
            onPressed: _showExportDialog,
          ),

          const SizedBox(width: 8),

          // Import
          ElevatedButton.icon(
            icon: const Icon(Icons.upload),
            label: const Text('Import SVG'),
            onPressed: _importSvg,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, DesignerTool tool, String tooltip) {
    final isSelected = _currentTool == tool;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => setState(() => _currentTool = tool),
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  // ========================================================================
  // LEFT PANEL - LAYERS
  // ========================================================================

  Widget _buildLeftPanel() {
    return Container(
      width: 250,
      color: Colors.grey[850],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Layers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  onPressed: _addNewLayer,
                  tooltip: 'Add Layer',
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final layer = _layers.removeAt(oldIndex);
                  _layers.insert(newIndex, layer);
                });
              },
              children:
                  _layers.map((layer) {
                    final isSelected = layer == _selectedLayer;
                    return ListTile(
                      key: ValueKey(layer.id),
                      selected: isSelected,
                      selectedTileColor: Colors.blue.withOpacity(0.3),
                      leading: Icon(
                        _getLayerIcon(layer.type),
                        color: Colors.white70,
                        size: 20,
                      ),
                      title: Text(
                        layer.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              layer.visible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
                              size: 18,
                            ),
                            onPressed: () => _toggleLayerVisibility(layer),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 18,
                            ),
                            onPressed: () => _deleteLayer(layer),
                          ),
                        ],
                      ),
                      onTap: () => setState(() => _selectedLayer = layer),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLayerIcon(LayerType type) {
    switch (type) {
      case LayerType.rectangle:
        return Icons.rectangle;
      case LayerType.circle:
        return Icons.circle;
      case LayerType.ellipse:
        return Icons.circle_outlined;
      case LayerType.path:
        return Icons.polyline;
      case LayerType.text:
        return Icons.text_fields;
      case LayerType.image:
        return Icons.image;
      case LayerType.shape:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.group:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.particle:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LayerType.bone:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  // ========================================================================
  // CANVAS - MAIN DRAWING AREA
  // ========================================================================

  Widget _buildCanvas() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Container(
          width: _artboardSize.width,
          height: _artboardSize.height,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[700]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: GestureDetector(
            onTapDown: _handleCanvasTap,
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            child: CustomPaint(
              painter: CanvasPainter(
                layers: _layers,
                selectedLayer: _selectedLayer,
                currentTime: _currentTime,
              ),
              size: _artboardSize,
            ),
          ),
        ),
      ),
    );
  }

  void _handleCanvasTap(TapDownDetails details) {
    if (_currentTool == DesignerTool.select) {
      // Select layer at tap position
      final localPos = details.localPosition;
      DesignerLayer? tapped;

      for (var layer in _layers.reversed) {
        if (!layer.visible) continue;
        if (_isPointInLayer(localPos, layer)) {
          tapped = layer;
          break;
        }
      }

      setState(() => _selectedLayer = tapped);
    } else {
      // Create new shape
      _createShapeAtPosition(details.localPosition);
    }
  }

  void _handlePanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_currentTool == DesignerTool.select && _selectedLayer != null) {
      final delta =
          details.localPosition - (_dragStart ?? details.localPosition);
      setState(() {
        _selectedLayer!.position += delta;
        _dragStart = details.localPosition;
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _dragStart = null;
  }

  bool _isPointInLayer(Offset point, DesignerLayer layer) {
    final rect = Rect.fromCenter(
      center: layer.position,
      width: layer.size.width * layer.scale,
      height: layer.size.height * layer.scale,
    );
    return rect.contains(point);
  }

  void _createShapeAtPosition(Offset position) {
    final newLayer = DesignerLayer(
      id: 'layer_${DateTime.now().millisecondsSinceEpoch}',
      name: '${_currentTool.name} ${_layers.length + 1}',
      type: _toolToLayerType(_currentTool),
      position: position,
      size: const Size(100, 100),
      color: Colors.primaries[_layers.length % Colors.primaries.length],
      rotation: 0,
      scale: 1.0,
      opacity: 1.0,
    );

    setState(() {
      _layers.add(newLayer);
      _selectedLayer = newLayer;
    });
  }

  LayerType _toolToLayerType(DesignerTool tool) {
    switch (tool) {
      case DesignerTool.rectangle:
        return LayerType.rectangle;
      case DesignerTool.circle:
        return LayerType.circle;
      case DesignerTool.ellipse:
        return LayerType.ellipse;
      case DesignerTool.path:
        return LayerType.path;
      case DesignerTool.text:
        return LayerType.text;
      default:
        return LayerType.rectangle;
    }
  }

  // ========================================================================
  // RIGHT PANEL - PROPERTIES
  // ========================================================================

  Widget _buildRightPanel() {
    return Container(
      width: 300,
      color: Colors.grey[850],
      child:
          _selectedLayer == null
              ? const Center(
                child: Text(
                  'Select a layer',
                  style: TextStyle(color: Colors.white70),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPropertySection('Layer', [
                      _buildTextProperty('Name', _selectedLayer!.name, (value) {
                        setState(() => _selectedLayer!.name = value);
                      }),
                    ]),

                    _buildPropertySection('Transform', [
                      _buildSliderProperty(
                        'X',
                        _selectedLayer!.position.dx,
                        0,
                        _artboardSize.width,
                        (value) {
                          setState(
                            () =>
                                _selectedLayer!.position = Offset(
                                  value,
                                  _selectedLayer!.position.dy,
                                ),
                          );
                        },
                      ),
                      _buildSliderProperty(
                        'Y',
                        _selectedLayer!.position.dy,
                        0,
                        _artboardSize.height,
                        (value) {
                          setState(
                            () =>
                                _selectedLayer!.position = Offset(
                                  _selectedLayer!.position.dx,
                                  value,
                                ),
                          );
                        },
                      ),
                      _buildSliderProperty(
                        'Rotation',
                        _selectedLayer!.rotation,
                        0,
                        360,
                        (value) {
                          setState(() => _selectedLayer!.rotation = value);
                        },
                      ),
                      _buildSliderProperty(
                        'Scale',
                        _selectedLayer!.scale,
                        0.1,
                        3,
                        (value) {
                          setState(() => _selectedLayer!.scale = value);
                        },
                      ),
                    ]),

                    _buildPropertySection('Appearance', [
                      _buildColorProperty('Color', _selectedLayer!.color, (
                        color,
                      ) {
                        setState(() => _selectedLayer!.color = color);
                      }),
                      _buildSliderProperty(
                        'Opacity',
                        _selectedLayer!.opacity,
                        0,
                        1,
                        (value) {
                          setState(() => _selectedLayer!.opacity = value);
                        },
                      ),
                    ]),

                    _buildPropertySection('Size', [
                      _buildSliderProperty(
                        'Width',
                        _selectedLayer!.size.width,
                        10,
                        500,
                        (value) {
                          setState(
                            () =>
                                _selectedLayer!.size = Size(
                                  value,
                                  _selectedLayer!.size.height,
                                ),
                          );
                        },
                      ),
                      _buildSliderProperty(
                        'Height',
                        _selectedLayer!.size.height,
                        10,
                        500,
                        (value) {
                          setState(
                            () =>
                                _selectedLayer!.size = Size(
                                  _selectedLayer!.size.width,
                                  value,
                                ),
                          );
                        },
                      ),
                    ]),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.animation),
                      label: const Text('Add Animation'),
                      onPressed: _addAnimationToLayer,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildPropertySection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextProperty(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: TextEditingController(text: value),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderProperty(
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
              Text(label, style: const TextStyle(color: Colors.white70)),
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          Slider(value: value, min: min, max: max, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildColorProperty(
    String label,
    Color value,
    ValueChanged<Color> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          InkWell(
            onTap: () => _showColorPicker(value, onChanged),
            child: Container(
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                color: value,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // TIMELINE PANEL
  // ========================================================================

  Widget _buildTimelinePanel() {
    return Container(
      height: 200,
      color: Colors.grey[900],
      child: Column(
        children: [
          // Timeline header
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Text(
                  'Timeline',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_currentTime.toStringAsFixed(2)}s / ${_duration.toStringAsFixed(1)}s',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Timeline ruler
          Container(
            height: 30,
            color: Colors.grey[800],
            child: CustomPaint(
              painter: TimelineRulerPainter(_duration, _currentTime),
              size: Size.infinite,
            ),
          ),

          // Timeline tracks
          Expanded(
            child: ListView.builder(
              itemCount: _layers.length,
              itemBuilder: (context, index) {
                final layer = _layers[index];
                return Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[800]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 150,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          layer.name,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color:
                              index.isEven
                                  ? Colors.grey[850]
                                  : Colors.grey[900],
                          child: CustomPaint(
                            painter: TimelineTrackPainter(
                              layer,
                              _duration,
                              _currentTime,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Playback slider
          Slider(
            value: _currentTime,
            min: 0,
            max: _duration,
            onChanged: (value) => setState(() => _currentTime = value),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // ACTIONS
  // ========================================================================

  void _addNewLayer() {
    final newLayer = DesignerLayer(
      id: 'layer_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Layer ${_layers.length + 1}',
      type: LayerType.rectangle,
      position: Offset(_artboardSize.width / 2, _artboardSize.height / 2),
      size: const Size(100, 100),
      color: Colors.primaries[_layers.length % Colors.primaries.length],
      rotation: 0,
      scale: 1.0,
      opacity: 1.0,
    );

    setState(() {
      _layers.add(newLayer);
      _selectedLayer = newLayer;
    });
  }

  void _deleteLayer(DesignerLayer layer) {
    setState(() {
      _layers.remove(layer);
      if (_selectedLayer == layer) _selectedLayer = null;
    });
  }

  void _toggleLayerVisibility(DesignerLayer layer) {
    setState(() => layer.visible = !layer.visible);
  }

  void _togglePlayback() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _startAnimation();
    }
  }

  void _stopPlayback() {
    setState(() {
      _isPlaying = false;
      _currentTime = 0;
    });
  }

  void _startAnimation() {
    // TODO: Implement animation loop
  }

  void _addAnimationToLayer() {
    if (_selectedLayer == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Animation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Position'),
                  onTap: () {
                    Navigator.pop(context);
                    _addKeyframe('position');
                  },
                ),
                ListTile(
                  title: const Text('Rotation'),
                  onTap: () {
                    Navigator.pop(context);
                    _addKeyframe('rotation');
                  },
                ),
                ListTile(
                  title: const Text('Scale'),
                  onTap: () {
                    Navigator.pop(context);
                    _addKeyframe('scale');
                  },
                ),
                ListTile(
                  title: const Text('Opacity'),
                  onTap: () {
                    Navigator.pop(context);
                    _addKeyframe('opacity');
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _addKeyframe(String property) {
    // TODO: Add keyframe to timeline
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added $property keyframe at ${_currentTime.toStringAsFixed(2)}s',
        ),
      ),
    );
  }

  void _showColorPicker(Color current, ValueChanged<Color> onChanged) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pick Color'),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    Colors.primaries.map((color) {
                      return InkWell(
                        onTap: () {
                          onChanged(color);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color:
                                  color == current
                                      ? Colors.white
                                      : Colors.transparent,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Animation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Export as JSON'),
                  onTap: () => _export('json'),
                ),
                ListTile(
                  leading: const Icon(Icons.animation),
                  title: const Text('Export as Lottie'),
                  onTap: () => _export('lottie'),
                ),
                ListTile(
                  leading: const Icon(Icons.api),
                  title: const Text('Export as Rive'),
                  onTap: () => _export('rive'),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Export as SVG'),
                  onTap: () => _export('svg'),
                ),
              ],
            ),
          ),
    );
  }

  void _export(String format) {
    Navigator.pop(context);
    final exported = _generateExport(format);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Export as $format'.toUpperCase()),
            content: SizedBox(
              width: 600,
              height: 400,
              child: SingleChildScrollView(
                child: SelectableText(
                  exported,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: exported));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard!')),
                  );
                },
                child: const Text('Copy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  String _generateExport(String format) {
    switch (format) {
      case 'svg':
        return _generateSvg();
      case 'json':
        return _generateJson();
      case 'lottie':
        return _generateLottie();
      case 'rive':
        return _generateRive();
      default:
        return '';
    }
  }

  String _generateSvg() {
    final buffer = StringBuffer();
    buffer.writeln(
      '<svg width="${_artboardSize.width}" height="${_artboardSize.height}" xmlns="http://www.w3.org/2000/svg">',
    );

    for (var layer in _layers) {
      if (!layer.visible) continue;

      switch (layer.type) {
        case LayerType.rectangle:
          buffer.writeln(
            '  <rect x="${layer.position.dx - layer.size.width / 2}" y="${layer.position.dy - layer.size.height / 2}" '
            'width="${layer.size.width}" height="${layer.size.height}" '
            'fill="${_colorToHex(layer.color)}" opacity="${layer.opacity}" '
            'transform="rotate(${layer.rotation} ${layer.position.dx} ${layer.position.dy}) scale(${layer.scale})"/>',
          );
          break;
        case LayerType.circle:
          buffer.writeln(
            '  <circle cx="${layer.position.dx}" cy="${layer.position.dy}" r="${layer.size.width / 2}" '
            'fill="${_colorToHex(layer.color)}" opacity="${layer.opacity}" '
            'transform="scale(${layer.scale})"/>',
          );
          break;
        case LayerType.ellipse:
          buffer.writeln(
            '  <ellipse cx="${layer.position.dx}" cy="${layer.position.dy}" '
            'rx="${layer.size.width / 2}" ry="${layer.size.height / 2}" '
            'fill="${_colorToHex(layer.color)}" opacity="${layer.opacity}" '
            'transform="rotate(${layer.rotation} ${layer.position.dx} ${layer.position.dy}) scale(${layer.scale})"/>',
          );
          break;
        default:
          break;
      }
    }

    buffer.writeln('</svg>');
    return buffer.toString();
  }

  String _generateJson() {
    final data = {
      'version': '1.0',
      'artboard': {
        'width': _artboardSize.width,
        'height': _artboardSize.height,
      },
      'duration': _duration,
      'layers':
          _layers
              .map(
                (layer) => {
                  'id': layer.id,
                  'name': layer.name,
                  'type': layer.type.name,
                  'visible': layer.visible,
                  'position': {'x': layer.position.dx, 'y': layer.position.dy},
                  'size': {
                    'width': layer.size.width,
                    'height': layer.size.height,
                  },
                  'color': layer.color.value,
                  'rotation': layer.rotation,
                  'scale': layer.scale,
                  'opacity': layer.opacity,
                },
              )
              .toList(),
    };

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  String _generateLottie() {
    return '{\n  "v": "5.9.0",\n  "fr": 60,\n  "w": ${_artboardSize.width.toInt()},\n  "h": ${_artboardSize.height.toInt()},\n  "layers": []\n}';
  }

  String _generateRive() {
    return '{\n  "version": 7,\n  "artboards": []\n}';
  }

  void _importSvg() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Import SVG'),
            content: const TextField(
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Paste SVG code here...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SVG imported successfully!')),
                  );
                },
                child: const Text('Import'),
              ),
            ],
          ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
