import 'package:flutter/material.dart';

import '../model/theme/gradient_color_stop.dart';

class GradientEditor extends StatefulWidget {
  final Gradient? initialGradient;
  final ValueChanged<Gradient> onGradientChanged;

  const GradientEditor({
    super.key,
    this.initialGradient,
    required this.onGradientChanged,
  });

  @override
  State<GradientEditor> createState() => _GradientEditorState();
}

class _GradientEditorState extends State<GradientEditor> {
  GradientType _type = GradientType.linear;
  final List<GradientColorStop> _stops = [
    GradientColorStop(offset: 0.0, color: Colors.blue),
    GradientColorStop(offset: 1.0, color: Colors.red),
  ];
  Offset _startPoint = const Offset(0, 0);
  Offset _endPoint = const Offset(1, 1);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gradient type selector
        SegmentedButton<GradientType>(
          segments: const [
            ButtonSegment(value: GradientType.linear, label: Text('Linear')),
            ButtonSegment(value: GradientType.radial, label: Text('Radial')),
            ButtonSegment(value: GradientType.sweep, label: Text('Sweep')),
          ],
          selected: {_type},
          onSelectionChanged: (Set<GradientType> selection) {
            setState(() => _type = selection.first);
          },
        ),

        const SizedBox(height: 16),

        // Gradient preview
        Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: _buildGradient(),
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        const SizedBox(height: 16),

        // Color stops editor
        _buildColorStopsEditor(),

        const SizedBox(height: 16),

        // Position controls (for linear gradient)
        if (_type == GradientType.linear) _buildPositionControls(),
      ],
    );
  }

  Widget _buildColorStopsEditor() {
    return Column(
      children: [
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
        ..._stops.asMap().entries.map((entry) {
          final index = entry.key;
          final stop = entry.value;

          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: stop.color,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            title: Slider(
              value: stop.offset,
              onChanged: (value) {
                setState(() => _stops[index].offset = value);
                widget.onGradientChanged(_buildGradient());
              },
              label: '${(stop.offset * 100).toInt()}%',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeColorStop(index),
            ),
            onTap: () => _editStopColor(index),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPositionControls() {
    return Column(
      children: [
        const Text(
          'Gradient Direction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('Start'),
                  Slider(
                    value: _startPoint.dx,
                    onChanged: (value) {
                      setState(
                        () => _startPoint = Offset(value, _startPoint.dy),
                      );
                      widget.onGradientChanged(_buildGradient());
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text('End'),
                  Slider(
                    value: _endPoint.dx,
                    onChanged: (value) {
                      setState(() => _endPoint = Offset(value, _endPoint.dy));
                      widget.onGradientChanged(_buildGradient());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Gradient _buildGradient() {
    final colors = _stops.map((s) => s.color).toList();
    final stops = _stops.map((s) => s.offset).toList();

    switch (_type) {
      case GradientType.linear:
        return LinearGradient(
          begin: Alignment(_startPoint.dx * 2 - 1, _startPoint.dy * 2 - 1),
          end: Alignment(_endPoint.dx * 2 - 1, _endPoint.dy * 2 - 1),
          colors: colors,
          stops: stops,
        );
      case GradientType.radial:
        return RadialGradient(colors: colors, stops: stops);
      case GradientType.sweep:
        return SweepGradient(colors: colors, stops: stops);
    }
  }

  void _addColorStop() {
    setState(() {
      final newOffset =
          _stops.isEmpty ? 0.5 : (_stops.last.offset + 0.1).clamp(0.0, 1.0);
      _stops.add(GradientColorStop(offset: newOffset, color: Colors.blue));
    });
    widget.onGradientChanged(_buildGradient());
  }

  void _removeColorStop(int index) {
    if (_stops.length > 2) {
      setState(() => _stops.removeAt(index));
      widget.onGradientChanged(_buildGradient());
    }
  }

  void _editStopColor(int index) {
    // Show color picker dialog
  }
}
