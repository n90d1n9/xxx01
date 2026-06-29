import 'package:flutter/widgets.dart';

import '../model/path/path_point.dart';
import '../painter/path_editor_painter.dart';

class BezierPathEditor extends StatefulWidget {
  final Path initialPath;
  final ValueChanged<Path> onPathChanged;

  const BezierPathEditor({
    Key? key,
    required this.initialPath,
    required this.onPathChanged,
  }) : super(key: key);

  @override
  State<BezierPathEditor> createState() => _BezierPathEditorState();
}

class _BezierPathEditorState extends State<BezierPathEditor> {
  final List<PathPoint> _points = [];
  PathPoint? _selectedPoint;
  PathPoint? _selectedHandle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTap,
      onPanUpdate: _handleDrag,
      child: CustomPaint(
        painter: PathEditorPainter(
          points: _points,
          selectedPoint: _selectedPoint,
          selectedHandle: _selectedHandle,
        ),
      ),
    );
  }

  void _handleTap(TapDownDetails details) {
    // Add or select point
  }

  void _handleDrag(DragUpdateDetails details) {
    // Move point or handle
  }
}
