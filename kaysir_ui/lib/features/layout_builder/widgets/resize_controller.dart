import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/template.dart';

/// Displays draggable resize handles around a bounded layout component.
class ResizeController extends StatefulWidget {
  final Size initialSize;
  final Size minSize;
  final ValueChanged<Size> onResize;

  const ResizeController({
    super.key,
    required this.initialSize,
    required this.minSize,
    required this.onResize,
  });

  @override
  ResizeControllerState createState() => ResizeControllerState();
}

/// Maintains resize dimensions and maps handle drags to size changes.
class ResizeControllerState extends State<ResizeController> {
  static const _handleSize = 10.0;
  static const _visibleDirections = [
    ResizeDirection.topLeft,
    ResizeDirection.top,
    ResizeDirection.topRight,
    ResizeDirection.right,
    ResizeDirection.bottomRight,
    ResizeDirection.bottom,
    ResizeDirection.bottomLeft,
    ResizeDirection.left,
  ];

  late Size _currentSize;

  @override
  void initState() {
    super.initState();
    _currentSize = widget.initialSize;
  }

  void _handleResize(DragUpdateDetails details, ResizeDirection direction) {
    final delta = _sizeDeltaFor(direction, details.delta);
    if (delta == Offset.zero) return;

    final newSize = Size(
      max(_currentSize.width + delta.dx, widget.minSize.width),
      max(_currentSize.height + delta.dy, widget.minSize.height),
    );

    setState(() => _currentSize = newSize);
    widget.onResize(newSize);
  }

  Offset _sizeDeltaFor(ResizeDirection direction, Offset delta) {
    return switch (direction) {
      ResizeDirection.topLeft => Offset(-delta.dx, -delta.dy),
      ResizeDirection.topRight => Offset(delta.dx, -delta.dy),
      ResizeDirection.bottomLeft => Offset(-delta.dx, delta.dy),
      ResizeDirection.bottomRight => Offset(delta.dx, delta.dy),
      ResizeDirection.left => Offset(-delta.dx, 0),
      ResizeDirection.right ||
      ResizeDirection.horizontal => Offset(delta.dx, 0),
      ResizeDirection.top => Offset(0, -delta.dy),
      ResizeDirection.bottom || ResizeDirection.vertical => Offset(0, delta.dy),
      ResizeDirection.diagonal => Offset(delta.dx, delta.dy),
      ResizeDirection.none => Offset.zero,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _currentSize.width,
      height: _currentSize.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 1),
              ),
            ),
          ),
          for (final direction in _visibleDirections)
            _buildResizeHandle(direction),
        ],
      ),
    );
  }

  Widget _buildResizeHandle(ResizeDirection direction) {
    return Positioned(
      left:
          direction.isLeft
              ? 0
              : direction.isRight
              ? null
              : _currentSize.width / 2 - _handleSize / 2,
      top:
          direction.isTop
              ? 0
              : direction.isBottom
              ? null
              : _currentSize.height / 2 - _handleSize / 2,
      right: direction.isRight ? 0 : null,
      bottom: direction.isBottom ? 0 : null,
      child: GestureDetector(
        key: ValueKey('resize-controller-handle-${direction.name}'),
        onPanUpdate: (details) => _handleResize(details, direction),
        child: Container(
          width: _handleSize,
          height: _handleSize,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Shows the resize controller with every side and corner handle.
@Preview(name: 'Resize controller')
Widget resizeControllerPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ResizeController(
          initialSize: const Size(180, 96),
          minSize: const Size(80, 48),
          onResize: (_) {},
        ),
      ),
    ),
  );
}
