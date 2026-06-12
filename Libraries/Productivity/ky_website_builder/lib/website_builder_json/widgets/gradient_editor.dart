import 'package:flutter/material.dart';

import '../models/schema/styles/gradient.dart' as g;
import '../models/schema/styles/gradient_stop.dart';
import 'advanced_color_picker.dart';

class GradientEditor extends StatefulWidget {
  final g.Gradient? initialGradient;
  final ValueChanged<g.Gradient> onGradientChanged;

  const GradientEditor({
    super.key,
    this.initialGradient,
    required this.onGradientChanged,
  });

  @override
  State<GradientEditor> createState() => _GradientEditorState();
}

class _GradientEditorState extends State<GradientEditor> {
  String _gradientType = 'linear';
  List<GradientStop> _stops = [
    GradientStop(color: '#667eea', position: '0%'),
    GradientStop(color: '#764ba2', position: '100%'),
  ];
  String _angle = '45deg';

  @override
  void initState() {
    super.initState();
    if (widget.initialGradient != null) {
      _gradientType = widget.initialGradient!.type;
      _stops = widget.initialGradient!.stops;
      _angle = widget.initialGradient!.angle ?? '45deg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gradient Editor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Gradient preview
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: _buildFlutterGradient(),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
          const SizedBox(height: 16),

          // Gradient type
          const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'linear', label: Text('Linear')),
              ButtonSegment(value: 'radial', label: Text('Radial')),
              ButtonSegment(value: 'conic', label: Text('Conic')),
            ],
            selected: {_gradientType},
            onSelectionChanged: (selected) {
              setState(() => _gradientType = selected.first);
              _emitGradient();
            },
          ),
          const SizedBox(height: 16),

          // Angle (for linear)
          if (_gradientType == 'linear') ...[
            const Text('Angle', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: double.parse(_angle.replaceAll('deg', '')),
              min: 0,
              max: 360,
              divisions: 36,
              label: _angle,
              onChanged: (value) {
                setState(() => _angle = '${value.toInt()}deg');
                _emitGradient();
              },
            ),
            const SizedBox(height: 16),
          ],

          // Color stops
          const Text(
            'Color Stops',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._stops.asMap().entries.map((entry) {
            final index = entry.key;
            final stop = entry.value;
            return _buildStopEditor(index, stop);
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addStop,
            icon: const Icon(Icons.add),
            label: const Text('Add Color Stop'),
          ),
        ],
      ),
    );
  }

  Widget _buildStopEditor(int index, GradientStop stop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        content: AdvancedColorPicker(
                          initialColor: stop.color,
                          onColorChanged: (color) {
                            setState(() {
                              _stops[index] = GradientStop(
                                color: color,
                                position: stop.position,
                              );
                            });
                            _emitGradient();
                          },
                        ),
                      ),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _parseColor(stop.color),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Position: ${stop.position}'),
                  Slider(
                    value: double.parse(stop.position.replaceAll('%', '')),
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      setState(() {
                        _stops[index] = GradientStop(
                          color: stop.color,
                          position: '${value.toInt()}%',
                        );
                      });
                      _emitGradient();
                    },
                  ),
                ],
              ),
            ),
            if (_stops.length > 2)
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () {
                  setState(() => _stops.removeAt(index));
                  _emitGradient();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _addStop() {
    setState(() {
      _stops.add(
        GradientStop(
          color:
              '#${DateTime.now().millisecondsSinceEpoch.toRadixString(16).substring(0, 6)}',
          position: '50%',
        ),
      );
      _stops.sort((a, b) {
        final posA = double.parse(a.position.replaceAll('%', ''));
        final posB = double.parse(b.position.replaceAll('%', ''));
        return posA.compareTo(posB);
      });
    });
    _emitGradient();
  }

  void _emitGradient() {
    widget.onGradientChanged(
      g.Gradient(
        type: _gradientType,
        stops: _stops,
        angle: _gradientType == 'linear' ? _angle : null,
      ),
    );
  }

  LinearGradient _buildFlutterGradient() {
    return LinearGradient(
      colors: _stops.map((s) => _parseColor(s.color)).toList(),
      stops:
          _stops
              .map((s) => double.parse(s.position.replaceAll('%', '')) / 100)
              .toList(),
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color _parseColor(String color) {
    color = color.replaceAll('#', '');
    if (color.length == 6) {
      return Color(int.parse('FF$color', radix: 16));
    }
    return Colors.black;
  }
}
