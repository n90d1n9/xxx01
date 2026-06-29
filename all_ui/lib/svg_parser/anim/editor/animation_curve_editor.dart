import 'package:flutter/material.dart';

import '../painter/curve_editor_painter.dart';

class AnimationCurveEditor extends StatefulWidget {
  final Curve initialCurve;
  final ValueChanged<Curve> onCurveChanged;

  const AnimationCurveEditor({
    Key? key,
    required this.initialCurve,
    required this.onCurveChanged,
  }) : super(key: key);

  @override
  State<AnimationCurveEditor> createState() => _AnimationCurveEditorState();
}

class _AnimationCurveEditorState extends State<AnimationCurveEditor> {
  late Offset _controlPoint1;
  late Offset _controlPoint2;

  @override
  void initState() {
    super.initState();
    _controlPoint1 = const Offset(0.25, 0.1);
    _controlPoint2 = const Offset(0.75, 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Curve visualization
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.white,
          ),
          child: GestureDetector(
            onPanUpdate: _handleDrag,
            child: CustomPaint(
              painter: CurveEditorPainter(
                controlPoint1: _controlPoint1,
                controlPoint2: _controlPoint2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Preset curves
        Wrap(
          spacing: 8,
          children: [
            _buildPresetButton('Linear', Curves.linear),
            _buildPresetButton('Ease', Curves.ease),
            _buildPresetButton('Ease In', Curves.easeIn),
            _buildPresetButton('Ease Out', Curves.easeOut),
            _buildPresetButton('Ease In Out', Curves.easeInOut),
            _buildPresetButton('Bounce', Curves.bounceOut),
            _buildPresetButton('Elastic', Curves.elasticOut),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton(String label, Curve curve) {
    return ElevatedButton(
      onPressed: () {
        widget.onCurveChanged(curve);
      },
      child: Text(label),
    );
  }

  void _handleDrag(DragUpdateDetails details) {
    // Update control points based on drag
  }
}
