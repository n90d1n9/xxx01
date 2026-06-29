import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/svg_element.dart';

/// Interactive SVG widget with gesture support
class InteractiveSvgWidget extends StatefulWidget {
  final List<SvgElement> elements;
  final Size size;
  final Color? backgroundColor;
  final bool enablePanZoom;

  const InteractiveSvgWidget({
    super.key,
    required this.elements,
    required this.size,
    this.backgroundColor,
    this.enablePanZoom = false,
  });

  @override
  State<InteractiveSvgWidget> createState() => _InteractiveSvgWidgetState();
}

class _InteractiveSvgWidgetState extends State<InteractiveSvgWidget> {
  SvgElement? _hoveredElement;
  Offset _panOffset = Offset.zero;
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _handleTapDown(details.localPosition),
      onTap: () => _handleTap(),
      onLongPress: () => _handleLongPress(),
      onScaleStart: widget.enablePanZoom ? _handleScaleStart : null,
      onScaleUpdate: widget.enablePanZoom ? _handleScaleUpdate : null,
      child: MouseRegion(
        onHover: (event) => _handleHover(event.localPosition),
        onExit: (event) => _handleHoverExit(),
        child: Container(
          width: widget.size.width,
          height: widget.size.height,
          color: widget.backgroundColor,
          child: CustomPaint(
            painter: _InteractiveSvgPainter(
              elements: widget.elements,
              hoveredElement: _hoveredElement,
              panOffset: _panOffset,
              scale: _scale,
            ),
            size: widget.size,
          ),
        ),
      ),
    );
  }

  void _handleTapDown(Offset position) {
    final element = _findElementAt(position);
    if (element?.onTapDown != null) {
      element!.onTapDown!(
        TapDownDetails(globalPosition: position, localPosition: position),
      );
    }
  }

  void _handleTap() {
    if (_hoveredElement?.onClick != null) {
      _hoveredElement!.onClick!();
    }
    if (_hoveredElement?.onTap != null) {
      // onTap expects no arguments, so call it directly.
      _hoveredElement!.onTap!();
    }
  }

  void _handleLongPress() {
    if (_hoveredElement?.onLongPress != null) {
      _hoveredElement!.onLongPress!();
    }
  }

  void _handleHover(Offset position) {
    final element = _findElementAt(position);

    if (element != _hoveredElement) {
      // Exit previous element
      if (_hoveredElement?.onHoverExit != null) {
        _hoveredElement!.onHoverExit!();
      }

      // Enter new element
      setState(() {
        _hoveredElement = element;
      });

      if (element?.onHover != null) {
        element!.onHover!();
      }
    }
  }

  void _handleHoverExit() {
    if (_hoveredElement?.onHoverExit != null) {
      _hoveredElement!.onHoverExit!();
    }
    setState(() {
      _hoveredElement = null;
    });
  }

  void _handleScaleStart(ScaleStartDetails details) {
    // Store initial values
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = details.scale;
      _panOffset = details.focalPoint;
    });
  }

  SvgElement? _findElementAt(Offset position) {
    // Adjust for pan and zoom
    final adjustedPosition = (position - _panOffset) / _scale;

    // Find element at position (reverse order for top-most element)
    for (var i = widget.elements.length - 1; i >= 0; i--) {
      if (widget.elements[i].hitTest(adjustedPosition)) {
        return widget.elements[i];
      }
    }
    return null;
  }
}

// ============================================================================
// INTERACTIVE SVG PAINTER
// ============================================================================

class _InteractiveSvgPainter extends CustomPainter {
  final List<SvgElement> elements;
  final SvgElement? hoveredElement;
  final Offset panOffset;
  final double scale;

  _InteractiveSvgPainter({
    required this.elements,
    this.hoveredElement,
    required this.panOffset,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Apply pan and zoom
    canvas.translate(panOffset.dx, panOffset.dy);
    canvas.scale(scale);

    // Paint all elements
    for (var element in elements) {
      element.paint(canvas, size, {});

      // Highlight hovered element
      if (element == hoveredElement) {
        _paintHighlight(canvas, element);
      }
    }

    canvas.restore();
  }

  void _paintHighlight(Canvas canvas, SvgElement element) {
    final bounds = element.getBounds();
    final paint =
        Paint()
          ..color = Colors.blue.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawRect(bounds, paint);
  }

  @override
  bool shouldRepaint(_InteractiveSvgPainter oldDelegate) {
    return oldDelegate.hoveredElement != hoveredElement ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.scale != scale ||
        oldDelegate.elements != elements;
  }
}
