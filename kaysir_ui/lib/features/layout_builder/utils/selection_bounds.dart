import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/component.dart';

enum LayoutBoundsCopyFormat {
  text('Plain text'),
  json('JSON'),
  flutterRect('Flutter Rect'),
  css('CSS');

  final String label;

  const LayoutBoundsCopyFormat(this.label);
}

Rect? layoutSelectionBounds(Iterable<ComponentData> components) {
  final visibleComponents =
      components.where((component) => component.isVisible).toList();
  if (visibleComponents.isEmpty) return null;

  final first = visibleComponents.first;
  var left = first.position.dx;
  var top = first.position.dy;
  var right = first.position.dx + first.size.width;
  var bottom = first.position.dy + first.size.height;

  for (final component in visibleComponents.skip(1)) {
    left = math.min(left, component.position.dx);
    top = math.min(top, component.position.dy);
    right = math.max(right, component.position.dx + component.size.width);
    bottom = math.max(bottom, component.position.dy + component.size.height);
  }

  return Rect.fromLTRB(left, top, right, bottom);
}

String layoutBoundsLabel(Rect bounds, {bool compact = false}) {
  final x = bounds.left.round();
  final y = bounds.top.round();
  final width = bounds.width.round();
  final height = bounds.height.round();

  if (compact) return 'X $x Y $y - ${width}x$height';
  return 'X $x  Y $y  ${width}x$height';
}

String layoutBoundsClipboardText(
  Rect bounds, {
  int? count,
  LayoutBoundsCopyFormat format = LayoutBoundsCopyFormat.text,
}) {
  final x = bounds.left.round();
  final y = bounds.top.round();
  final width = bounds.width.round();
  final height = bounds.height.round();
  final label = count == null ? 'Selection bounds' : '$count selected bounds';

  return switch (format) {
    LayoutBoundsCopyFormat.text =>
      '$label: x=$x, y=$y, width=$width, height=$height',
    LayoutBoundsCopyFormat.json => const JsonEncoder.withIndent(
      '  ',
    ).convert({'x': x, 'y': y, 'width': width, 'height': height}),
    LayoutBoundsCopyFormat.flutterRect =>
      'Rect.fromLTWH($x, $y, $width, $height)',
    LayoutBoundsCopyFormat.css =>
      'left: ${x}px;\ntop: ${y}px;\nwidth: ${width}px;\nheight: ${height}px;',
  };
}

void copyLayoutSelectionBounds(
  BuildContext context,
  Iterable<ComponentData> components, {
  LayoutBoundsCopyFormat format = LayoutBoundsCopyFormat.text,
}) {
  final visibleComponents =
      components.where((component) => component.isVisible).toList();
  final bounds = layoutSelectionBounds(visibleComponents);
  if (bounds == null) return;

  final count = visibleComponents.length == 1 ? null : visibleComponents.length;
  Clipboard.setData(
    ClipboardData(
      text: layoutBoundsClipboardText(bounds, count: count, format: format),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        format == LayoutBoundsCopyFormat.text
            ? count == null
                ? 'Copied bounds'
                : 'Copied $count bounds'
            : 'Copied bounds as ${format.label}',
      ),
      duration: const Duration(milliseconds: 1200),
    ),
  );
}
