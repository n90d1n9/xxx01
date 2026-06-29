import 'package:flutter/material.dart';

class MobileGestureDetector extends StatefulWidget {
  final Widget child;
  final Function(ScaleStartDetails) onPinchStart;
  final Function(ScaleUpdateDetails) onPinchUpdate;
  final Function(ScaleEndDetails) onPinchEnd;
  final Function(Offset) onDoubleTap;
  final Function(Offset) onLongPress;
  final Function(PointerDownEvent) onPointerDown;
  final Function(PointerMoveEvent) onPointerMove;
  final Function(PointerUpEvent) onPointerUp;

  const MobileGestureDetector({
    super.key,
    required this.child,
    required this.onPinchStart,
    required this.onPinchUpdate,
    required this.onPinchEnd,
    required this.onDoubleTap,
    required this.onLongPress,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerUp,
  });

  @override
  State<MobileGestureDetector> createState() => _MobileGestureDetectorState();
}

class _MobileGestureDetectorState extends State<MobileGestureDetector> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.onPointerDown,
      onPointerMove: widget.onPointerMove,
      onPointerUp: widget.onPointerUp,
      child: GestureDetector(
        onScaleStart: widget.onPinchStart,
        onScaleUpdate: widget.onPinchUpdate,
        onScaleEnd: widget.onPinchEnd,
        onDoubleTap: (() => widget.onDoubleTap(Offset.zero)),
        onLongPress: (() => widget.onLongPress(Offset.zero)),
        behavior: HitTestBehavior.opaque,
        child: widget.child,
      ),
    );
  }
}
