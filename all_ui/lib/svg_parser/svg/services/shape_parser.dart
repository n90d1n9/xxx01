// parsers/shape_parsers.dart
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import '../models/svg_path.dart';
import '../models/svg_rect.dart';
import '../models/svg_circle.dart';

import '../models/svg_line.dart';
import '../models/svg_polygon.dart';
import '../models/svg_polyline.dart';
import '../models/svg_text.dart';
import '../models/svg_style.dart';
import '../models/svg_ellipse.dart';
import 'transform_parser.dart';

class PathParser {
  static SvgPath parse(XmlElement element, SvgStyle style) {
    return SvgPath(
      d: element.getAttribute('d') ?? '',
      style: style,
      transform: TransformParser.parse(element.getAttribute('transform')),
    );
  }
}

class RectParser {
  static SvgRect parse(XmlElement element, SvgStyle style) {
    return SvgRect(
      x: _parseDouble(element.getAttribute('x')) ?? 0,
      y: _parseDouble(element.getAttribute('y')) ?? 0,
      width: _parseDouble(element.getAttribute('width')) ?? 0,
      height: _parseDouble(element.getAttribute('height')) ?? 0,
      rx: _parseDouble(element.getAttribute('rx')) ?? 0,
      ry: _parseDouble(element.getAttribute('ry')) ?? 0,
      style: style,
      transform: TransformParser.parse(element.getAttribute('transform')),
    );
  }
}

class CircleParser {
  static SvgCircle parse(XmlElement element, SvgStyle style) {
    return SvgCircle(
      cx: _parseDouble(element.getAttribute('cx')) ?? 0,
      cy: _parseDouble(element.getAttribute('cy')) ?? 0,
      r: _parseDouble(element.getAttribute('r')) ?? 0,
      style: style,
      transform: TransformParser.parse(element.getAttribute('transform')),
    );
  }
}

class EllipseParser {
  static SvgEllipse parse(XmlElement element, SvgStyle style) {
    return SvgEllipse(
      cx: _parseDouble(element.getAttribute('cx')) ?? 0,
      cy: _parseDouble(element.getAttribute('cy')) ?? 0,
      rx: _parseDouble(element.getAttribute('rx')) ?? 0,
      ry: _parseDouble(element.getAttribute('ry')) ?? 0,
      style: style,
      transform: TransformParser.parse(element.getAttribute('transform')),
    );
  }
}

class LineParser {
  static SvgLine parse(XmlElement element, SvgStyle style) {
    return SvgLine(
      x1: _parseDouble(element.getAttribute('x1')) ?? 0,
      y1: _parseDouble(element.getAttribute('y1')) ?? 0,
      x2: _parseDouble(element.getAttribute('x2')) ?? 0,
      y2: _parseDouble(element.getAttribute('y2')) ?? 0,
      style: style,
      transform: TransformParser.parse(element.getAttribute('transform')),
    );
  }
}

class PolylineParser {
  static SvgPolyline parse(XmlElement element, SvgStyle style) {
    return SvgPolyline(
      points: _parsePoints(element.getAttribute('points') ?? ''),
      style: style,
      transform: TransformParser.parse(element.getAttribute('transform')),
    );
  }
}

class PolygonParser {
  static SvgPolygon parse(XmlElement element, SvgStyle style) {
    return SvgPolygon(
      points: _parsePoints(element.getAttribute('points') ?? ''),
      style: style,
      transform: TransformParser.parse(element.getAttribute('transform')),
    );
  }
}

class TextParser {
  static SvgText parse(XmlElement element, SvgStyle style) {
    return SvgText(
      x: _parseDouble(element.getAttribute('x')) ?? 0,
      y: _parseDouble(element.getAttribute('y')) ?? 0,
      text: element.text.trim(),
      fontSize: _parseDouble(element.getAttribute('font-size')) ?? 16,
      fontFamily: element.getAttribute('font-family') ?? 'sans-serif',
      fontWeight: element.getAttribute('font-weight'),
      textAnchor: element.getAttribute('text-anchor'),
      style: style,
      transform: TransformParser.parse(element.getAttribute('transform')),
    );
  }
}

// Helper methods
List<Offset> _parsePoints(String pointsStr) {
  final points = <Offset>[];
  final coords = pointsStr.trim().split(RegExp(r'[\s,]+'));

  for (var i = 0; i < coords.length - 1; i += 2) {
    final x = double.tryParse(coords[i]) ?? 0;
    final y = double.tryParse(coords[i + 1]) ?? 0;
    points.add(Offset(x, y));
  }
  return points;
}

double? _parseDouble(String? value) {
  if (value == null || value.isEmpty) return null;
  return double.tryParse(value.replaceAll(RegExp(r'[a-zA-Z%]'), ''));
}
