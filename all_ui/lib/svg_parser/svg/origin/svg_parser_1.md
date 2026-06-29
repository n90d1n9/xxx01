// Main parser class with comprehensive SVG support
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import '../models/svg_circle.dart';
import '../models/svg_data.dart';
import '../models/svg_element.dart';
import '../models/svg_group.dart';
import '../models/svg_line.dart';
import '../models/svg_paint.dart';
import '../models/svg_path.dart';
import '../models/svg_polygon.dart';
import '../models/svg_polyline.dart';
import '../models/svg_rect.dart';
import '../models/svg_style.dart';
import '../models/svg_text.dart';
import '../models/svg_ellipse.dart';

class SvgParser {
  static SvgData parse(String svgCode) {
    final document = XmlDocument.parse(svgCode);
    final svgElement = document.findElements('svg').first;

    double? width = _parseDouble(svgElement.getAttribute('width'));
    double? height = _parseDouble(svgElement.getAttribute('height'));

    // Parse viewBox if width/height not specified
    final viewBox = _parseViewBox(svgElement.getAttribute('viewBox'));
    if (width == null || height == null) {
      width = viewBox?[2] ?? 100;
      height = viewBox?[3] ?? 100;
    }

    final elements = <SvgElement>[];
    final defs = <String, XmlElement>{};

    // Parse defs first
    for (var defsElement in svgElement.findElements('defs')) {
      _parseDefs(defsElement, defs);
    }

    _parseElements(svgElement, elements, SvgStyle(), defs);

    return SvgData(
      width: width,
      height: height,
      viewBox: viewBox,
      elements: elements,
    );
  }

  static void _parseDefs(
    XmlElement defsElement,
    Map<String, SvgDefinition> defs,
  ) {
    for (var child in defsElement.children.whereType<XmlElement>()) {
      final id = child.getAttribute('id');
      if (id == null) continue;

      switch (child.name.local) {
        case 'linearGradient':
          defs[id] = _parseLinearGradient(child);
          break;
        case 'radialGradient':
          defs[id] = _parseRadialGradient(child);
          break;
        case 'clipPath':
          defs[id] = _parseClipPath(child);
          break;
        case 'pattern':
          defs[id] = _parsePattern(child);
          break;
        case 'mask':
          defs[id] = _parseMask(child);
          break;
        case 'symbol':
          defs[id] = _parseSymbol(child);
          break;
        case 'marker':
          defs[id] = _parseMarker(child);
          break;
        case 'filter':
          defs[id] = _parseFilter(child);
          break;
      }
    }
  }

  static SvgLinearGradient _parseLinearGradient(XmlElement element) {
    final stops = <GradientStop>[];

    for (var stop in element.findElements('stop')) {
      final offset =
          _parseDouble(stop.getAttribute('offset')?.replaceAll('%', '')) ?? 0.0;
      final stopColor = stop.getAttribute('stop-color');
      final stopOpacity =
          _parseDouble(stop.getAttribute('stop-opacity')) ?? 1.0;

      // Check style attribute for stop-color
      final style = stop.getAttribute('style');
      Color? color;

      if (style != null) {
        final colorMatch = RegExp(r'stop-color:\s*([^;]+)').firstMatch(style);
        if (colorMatch != null) {
          color = _parseColor(colorMatch.group(1)!.trim());
        }
      }

      color ??= _parseColor(stopColor);

      if (color != null) {
        stops.add(
          GradientStop(
            offset: offset / 100.0,
            color: color.withOpacity(color.opacity * stopOpacity),
          ),
        );
      }
    }

    return SvgLinearGradient(
      id: element.getAttribute('id') ?? '',
      x1: _parsePercentage(element.getAttribute('x1')) ?? 0.0,
      y1: _parsePercentage(element.getAttribute('y1')) ?? 0.0,
      x2: _parsePercentage(element.getAttribute('x2')) ?? 1.0,
      y2: _parsePercentage(element.getAttribute('y2')) ?? 0.0,
      stops: stops,
      gradientUnits:
          element.getAttribute('gradientUnits') ?? 'objectBoundingBox',
      gradientTransform: _parseTransform(
        element.getAttribute('gradientTransform'),
      ),
    );
  }

  static SvgRadialGradient _parseRadialGradient(XmlElement element) {
    final stops = <GradientStop>[];

    for (var stop in element.findElements('stop')) {
      final offset =
          _parseDouble(stop.getAttribute('offset')?.replaceAll('%', '')) ?? 0.0;
      final stopColor = stop.getAttribute('stop-color');
      final stopOpacity =
          _parseDouble(stop.getAttribute('stop-opacity')) ?? 1.0;

      final style = stop.getAttribute('style');
      Color? color;

      if (style != null) {
        final colorMatch = RegExp(r'stop-color:\s*([^;]+)').firstMatch(style);
        if (colorMatch != null) {
          color = _parseColor(colorMatch.group(1)!.trim());
        }
      }

      color ??= _parseColor(stopColor);

      if (color != null) {
        stops.add(
          GradientStop(
            offset: offset / 100.0,
            color: color.withOpacity(color.opacity * stopOpacity),
          ),
        );
      }
    }

    return SvgRadialGradient(
      id: element.getAttribute('id') ?? '',
      cx: _parsePercentage(element.getAttribute('cx')) ?? 0.5,
      cy: _parsePercentage(element.getAttribute('cy')) ?? 0.5,
      r: _parsePercentage(element.getAttribute('r')) ?? 0.5,
      fx: _parsePercentage(element.getAttribute('fx')),
      fy: _parsePercentage(element.getAttribute('fy')),
      stops: stops,
      gradientUnits:
          element.getAttribute('gradientUnits') ?? 'objectBoundingBox',
      gradientTransform: _parseTransform(
        element.getAttribute('gradientTransform'),
      ),
    );
  }

  static SvgClipPath _parseClipPath(XmlElement element) {
    final elements = <SvgElement>[];
    _parseElements(element, elements, SvgStyle(), {});
    return SvgClipPath(
      id: element.getAttribute('id') ?? '',
      elements: elements,
    );
  }

  static SvgPattern _parsePattern(XmlElement element) {
    final elements = <SvgElement>[];
    _parseElements(element, elements, SvgStyle(), {});
    return SvgPattern(
      id: element.getAttribute('id') ?? '',
      x: _parseDouble(element.getAttribute('x')) ?? 0,
      y: _parseDouble(element.getAttribute('y')) ?? 0,
      width: _parseDouble(element.getAttribute('width')) ?? 0,
      height: _parseDouble(element.getAttribute('height')) ?? 0,
      patternUnits: element.getAttribute('patternUnits') ?? 'objectBoundingBox',
      patternTransform: _parseTransform(
        element.getAttribute('patternTransform'),
      ),
      elements: elements,
    );
  }

  static SvgMask _parseMask(XmlElement element) {
    final elements = <SvgElement>[];
    _parseElements(element, elements, SvgStyle(), {});
    return SvgMask(id: element.getAttribute('id') ?? '', elements: elements);
  }

  static SvgSymbol _parseSymbol(XmlElement element) {
    final elements = <SvgElement>[];
    final viewBox = _parseViewBox(element.getAttribute('viewBox'));
    _parseElements(element, elements, SvgStyle(), {});
    return SvgSymbol(
      id: element.getAttribute('id') ?? '',
      viewBox: viewBox,
      elements: elements,
    );
  }

  static SvgMarker _parseMarker(XmlElement element) {
    final elements = <SvgElement>[];
    _parseElements(element, elements, SvgStyle(), {});
    return SvgMarker(
      id: element.getAttribute('id') ?? '',
      refX: _parseDouble(element.getAttribute('refX')) ?? 0,
      refY: _parseDouble(element.getAttribute('refY')) ?? 0,
      markerWidth: _parseDouble(element.getAttribute('markerWidth')) ?? 3,
      markerHeight: _parseDouble(element.getAttribute('markerHeight')) ?? 3,
      orient: element.getAttribute('orient') ?? 'auto',
      elements: elements,
    );
  }

  static List<double>? _parseViewBox(String? viewBox) {
    if (viewBox == null) return null;
    final values = viewBox.trim().split(RegExp(r'[\s,]+'));
    if (values.length != 4) return null;
    return values.map((v) => double.tryParse(v) ?? 0).toList();
  }

  static void _parseElements(
    XmlElement parent,
    List<SvgElement> elements,
    SvgStyle inheritedStyle,
    Map<String, XmlElement> defs,
  ) {
    for (var node in parent.children) {
      if (node is XmlElement) {
        final style = _mergeStyles(inheritedStyle, node);

        switch (node.name.local) {
          case 'path':
            elements.add(_parsePath(node, style));
            break;
          case 'rect':
            elements.add(_parseRect(node, style));
            break;
          case 'circle':
            elements.add(_parseCircle(node, style));
            break;
          case 'ellipse':
            elements.add(_parseEllipse(node, style));
            break;
          case 'line':
            elements.add(_parseLine(node, style));
            break;
          case 'polyline':
            elements.add(_parsePolyline(node, style));
            break;
          case 'polygon':
            elements.add(_parsePolygon(node, style));
            break;
          case 'text':
            elements.add(_parseText(node, style));
            break;
          case 'g':
            final transform = _parseTransform(node.getAttribute('transform'));
            final group = SvgGroup(transform: transform, style: style);
            _parseElements(node, group.children, style, defs);
            elements.add(group);
            break;
          case 'use':
            final href =
                node.getAttribute('href') ?? node.getAttribute('xlink:href');
            if (href != null && href.startsWith('#')) {
              final refId = href.substring(1);
              if (defs.containsKey(refId)) {
                _parseElements(defs[refId]!, elements, style, defs);
              }
            }
            break;
          case 'defs':
          case 'style':
            // Skip, already processed
            break;
          default:
            // Try to parse unknown elements recursively
            _parseElements(node, elements, style, defs);
        }
      }
    }
  }

  static void _parseStyleAttribute(String styleAttr, SvgStyle style) {
    final declarations = styleAttr.split(';');
    for (var decl in declarations) {
      final parts = decl.split(':');
      if (parts.length != 2) continue;

      final property = parts[0].trim();
      final value = parts[1].trim();

      switch (property) {
        case 'fill':
          style.fill = _parsePaint(value);
          break;
        case 'stroke':
          style.stroke = _parsePaint(value);
          break;
        case 'stroke-width':
          style.strokeWidth = _parseDouble(value);
          break;
        case 'opacity':
          style.opacity = _parseDouble(value);
          break;
        case 'fill-opacity':
          style.fillOpacity = _parseDouble(value);
          break;
        case 'stroke-opacity':
          style.strokeOpacity = _parseDouble(value);
          break;
        case 'stroke-linecap':
          style.strokeLinecap = _parseLineCap(value);
          break;
        case 'stroke-linejoin':
          style.strokeLinejoin = _parseLineJoin(value);
          break;
        case 'stroke-dasharray':
          if (value != 'none') style.strokeDasharray = _parseDashArray(value);
          break;
        case 'fill-rule':
          style.fillRule = _parseFillRule(value);
          break;
      }
    }
  }

  static Matrix4? _parseTransform(String? transform) {
    if (transform == null || transform.isEmpty) return null;

    final matrix = Matrix4.identity();
    final regex = RegExp(r'(\w+)\s*\(([^)]+)\)');
    final matches = regex.allMatches(transform);

    for (var match in matches) {
      final type = match.group(1);
      final values =
          match
              .group(2)!
              .split(RegExp(r'[\s,]+'))
              .map((v) => double.tryParse(v) ?? 0)
              .toList();

      switch (type) {
        case 'translate':
          final tx = values[0];
          final ty = values.length > 1 ? values[1] : 0.0;
          matrix.translate(tx, ty);
          break;
        case 'scale':
          final sx = values[0];
          final sy = values.length > 1 ? values[1] : sx;
          matrix.scale(sx, sy);
          break;
        case 'rotate':
          final angle = values[0] * math.pi / 180;
          if (values.length > 2) {
            final cx = values[1];
            final cy = values[2];
            matrix.translate(cx, cy);
            matrix.rotateZ(angle);
            matrix.translate(-cx, -cy);
          } else {
            matrix.rotateZ(angle);
          }
          break;
        case 'skewX':
          final angle = values[0] * math.pi / 180;
          matrix.multiply(
            Matrix4(
              1,
              math.tan(angle),
              0,
              0,
              0,
              1,
              0,
              0,
              0,
              0,
              1,
              0,
              0,
              0,
              0,
              1,
            ),
          );
          break;
        case 'skewY':
          final angle = values[0] * math.pi / 180;
          matrix.multiply(
            Matrix4(
              1,
              0,
              0,
              0,
              math.tan(angle),
              1,
              0,
              0,
              0,
              0,
              1,
              0,
              0,
              0,
              0,
              1,
            ),
          );
          break;
        case 'matrix':
          if (values.length == 6) {
            matrix.multiply(
              Matrix4(
                values[0],
                values[2],
                0,
                values[4],
                values[1],
                values[3],
                0,
                values[5],
                0,
                0,
                1,
                0,
                0,
                0,
                0,
                1,
              ),
            );
          }
          break;
      }
    }

    return matrix;
  }

  static SvgPath _parsePath(XmlElement element, SvgStyle style) {
    return SvgPath(
      d: element.getAttribute('d') ?? '',
      style: style,
      transform: _parseTransform(element.getAttribute('transform')),
    );
  }

  static SvgRect _parseRect(XmlElement element, SvgStyle style) {
    return SvgRect(
      x: _parseDouble(element.getAttribute('x')) ?? 0,
      y: _parseDouble(element.getAttribute('y')) ?? 0,
      width: _parseDouble(element.getAttribute('width')) ?? 0,
      height: _parseDouble(element.getAttribute('height')) ?? 0,
      rx: _parseDouble(element.getAttribute('rx')) ?? 0,
      ry: _parseDouble(element.getAttribute('ry')) ?? 0,
      style: style,
      transform: _parseTransform(element.getAttribute('transform')),
    );
  }

  static SvgFilter _parseFilter(XmlElement element) {
    final primitives = <FilterPrimitive>[];

    for (var child in element.children.whereType<XmlElement>()) {
      switch (child.name.local) {
        case 'feGaussianBlur':
          primitives.add(
            FeGaussianBlur(
              stdDeviation:
                  _parseDouble(child.getAttribute('stdDeviation')) ?? 0,
              input: child.getAttribute('in'),
              result: child.getAttribute('result'),
            ),
          );
          break;
        case 'feDropShadow':
          primitives.add(
            FeDropShadow(
              dx: _parseDouble(child.getAttribute('dx')) ?? 2,
              dy: _parseDouble(child.getAttribute('dy')) ?? 2,
              stdDeviation:
                  _parseDouble(child.getAttribute('stdDeviation')) ?? 2,
              floodColor: _parseColor(child.getAttribute('flood-color')),
              floodOpacity:
                  _parseDouble(child.getAttribute('flood-opacity')) ?? 1,
            ),
          );
          break;
        case 'feOffset':
          primitives.add(
            FeOffset(
              dx: _parseDouble(child.getAttribute('dx')) ?? 0,
              dy: _parseDouble(child.getAttribute('dy')) ?? 0,
              input: child.getAttribute('in'),
              result: child.getAttribute('result'),
            ),
          );
          break;
        case 'feColorMatrix':
          primitives.add(
            FeColorMatrix(
              type: child.getAttribute('type') ?? 'matrix',
              values: child.getAttribute('values'),
              input: child.getAttribute('in'),
              result: child.getAttribute('result'),
            ),
          );
          break;
        case 'feBlend':
          primitives.add(
            FeBlend(
              mode: child.getAttribute('mode') ?? 'normal',
              in1: child.getAttribute('in'),
              in2: child.getAttribute('in2'),
              result: child.getAttribute('result'),
            ),
          );
          break;
      }
    }

    return SvgFilter(
      id: element.getAttribute('id') ?? '',
      primitives: primitives,
    );
  }

  static SvgStyle _mergeStyles(SvgStyle inherited, XmlElement element) {
    final style = SvgStyle.from(inherited);

    // Parse style attribute
    final styleAttr = element.getAttribute('style');
    if (styleAttr != null) {
      _parseStyleAttribute(styleAttr, style);
    }

    // Override with individual attributes
    final fill = element.getAttribute('fill');
    if (fill != null) style.fill = _parsePaint(fill);

    final stroke = element.getAttribute('stroke');
    if (stroke != null) style.stroke = _parsePaint(stroke);

    final strokeWidth = element.getAttribute('stroke-width');
    if (strokeWidth != null) style.strokeWidth = _parseDouble(strokeWidth);

    final opacity = element.getAttribute('opacity');
    if (opacity != null) style.opacity = _parseDouble(opacity);

    final fillOpacity = element.getAttribute('fill-opacity');
    if (fillOpacity != null) style.fillOpacity = _parseDouble(fillOpacity);

    final strokeOpacity = element.getAttribute('stroke-opacity');
    if (strokeOpacity != null) {
      style.strokeOpacity = _parseDouble(strokeOpacity);
    }

    final strokeLinecap = element.getAttribute('stroke-linecap');
    if (strokeLinecap != null) {
      style.strokeLinecap = _parseLineCap(strokeLinecap);
    }

    final strokeLinejoin = element.getAttribute('stroke-linejoin');
    if (strokeLinejoin != null) {
      style.strokeLinejoin = _parseLineJoin(strokeLinejoin);
    }

    final strokeMiterlimit = element.getAttribute('stroke-miterlimit');
    if (strokeMiterlimit != null) {
      style.strokeMiterlimit = _parseDouble(strokeMiterlimit);
    }

    final strokeDasharray = element.getAttribute('stroke-dasharray');
    if (strokeDasharray != null && strokeDasharray != 'none') {
      style.strokeDasharray = _parseDashArray(strokeDasharray);
    }

    final fillRule = element.getAttribute('fill-rule');
    if (fillRule != null) style.fillRule = _parseFillRule(fillRule);

    return style;
  }

  static SvgCircle _parseCircle(XmlElement element, SvgStyle style) {
    return SvgCircle(
      cx: _parseDouble(element.getAttribute('cx')) ?? 0,
      cy: _parseDouble(element.getAttribute('cy')) ?? 0,
      r: _parseDouble(element.getAttribute('r')) ?? 0,
      style: style,
      transform: _parseTransform(element.getAttribute('transform')),
    );
  }

  static SvgEllipse _parseEllipse(XmlElement element, SvgStyle style) {
    return SvgEllipse(
      cx: _parseDouble(element.getAttribute('cx')) ?? 0,
      cy: _parseDouble(element.getAttribute('cy')) ?? 0,
      rx: _parseDouble(element.getAttribute('rx')) ?? 0,
      ry: _parseDouble(element.getAttribute('ry')) ?? 0,
      style: style,
      transform: _parseTransform(element.getAttribute('transform')),
    );
  }

  static SvgLine _parseLine(XmlElement element, SvgStyle style) {
    return SvgLine(
      x1: _parseDouble(element.getAttribute('x1')) ?? 0,
      y1: _parseDouble(element.getAttribute('y1')) ?? 0,
      x2: _parseDouble(element.getAttribute('x2')) ?? 0,
      y2: _parseDouble(element.getAttribute('y2')) ?? 0,
      style: style,
      transform: _parseTransform(element.getAttribute('transform')),
    );
  }

  static SvgPolyline _parsePolyline(XmlElement element, SvgStyle style) {
    return SvgPolyline(
      points: _parsePoints(element.getAttribute('points') ?? ''),
      style: style,
      transform: _parseTransform(element.getAttribute('transform')),
    );
  }

  static SvgPolygon _parsePolygon(XmlElement element, SvgStyle style) {
    return SvgPolygon(
      points: _parsePoints(element.getAttribute('points') ?? ''),
      style: style,
      transform: _parseTransform(element.getAttribute('transform')),
    );
  }

  static SvgText _parseText(XmlElement element, SvgStyle style) {
    return SvgText(
      x: _parseDouble(element.getAttribute('x')) ?? 0,
      y: _parseDouble(element.getAttribute('y')) ?? 0,
      text: element.text.trim(),
      fontSize: _parseDouble(element.getAttribute('font-size')) ?? 16,
      fontFamily: element.getAttribute('font-family') ?? 'sans-serif',
      fontWeight: element.getAttribute('font-weight'),
      textAnchor: element.getAttribute('text-anchor'),
      style: style,
      transform: _parseTransform(element.getAttribute('transform')),
    );
  }

  static List<Offset> _parsePoints(String pointsStr) {
    final points = <Offset>[];
    final coords = pointsStr.trim().split(RegExp(r'[\s,]+'));

    for (var i = 0; i < coords.length - 1; i += 2) {
      final x = double.tryParse(coords[i]) ?? 0;
      final y = double.tryParse(coords[i + 1]) ?? 0;
      points.add(Offset(x, y));
    }

    return points;
  }

  static SvgPaint? _parsePaint(String? paintStr) {
    if (paintStr == null || paintStr.isEmpty || paintStr == 'none') {
      return SvgPaint.none();
    }

    // Check for url reference (gradient, pattern, etc.)
    if (paintStr.startsWith('url(')) {
      final match = RegExp(r'url\(#([^)]+)\)').firstMatch(paintStr);
      if (match != null) {
        return SvgPaint.reference(match.group(1)!);
      }
    }

    final color = _parseColor(paintStr);
    return color != null ? SvgPaint.color(color) : null;
  }

  static Color? _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty || colorStr == 'none') return null;

    colorStr = colorStr.trim().toLowerCase();

    // RGB/RGBA
    if (colorStr.startsWith('rgb')) {
      final match = RegExp(r'rgba?\(([^)]+)\)').firstMatch(colorStr);
      if (match != null) {
        final values = match.group(1)!.split(',').map((v) => v.trim()).toList();
        final r = int.tryParse(values[0]) ?? 0;
        final g = int.tryParse(values[1]) ?? 0;
        final b = int.tryParse(values[2]) ?? 0;
        final a = values.length > 3 ? (double.tryParse(values[3]) ?? 1.0) : 1.0;
        return Color.fromRGBO(r, g, b, a);
      }
    }

    // Hex colors
    if (colorStr.startsWith('#')) {
      colorStr = colorStr.substring(1);
      if (colorStr.length == 3) {
        colorStr = colorStr.split('').map((c) => c + c).join();
      }
      if (colorStr.length == 6) {
        return Color(int.parse('FF$colorStr', radix: 16));
      }
      if (colorStr.length == 8) {
        return Color(int.parse(colorStr, radix: 16));
      }
    }

    // Named colors (extended list)
    return _namedColors[colorStr];
  }

  static final Map<String, Color> _namedColors = {
    'black': Color(0xFF000000),
    'white': Color(0xFFFFFFFF),
    'red': Color(0xFFFF0000),
    'green': Color(0xFF008000),
    'blue': Color(0xFF0000FF),
    'yellow': Color(0xFFFFFF00),
    'cyan': Color(0xFF00FFFF),
    'magenta': Color(0xFFFF00FF),
    'gray': Color(0xFF808080),
    'grey': Color(0xFF808080),
    'orange': Color(0xFFFFA500),
    'purple': Color(0xFF800080),
    'brown': Color(0xFFA52A2A),
    'pink': Color(0xFFFFC0CB),
    'lime': Color(0xFF00FF00),
    'navy': Color(0xFF000080),
    'teal': Color(0xFF008080),
    'olive': Color(0xFF808000),
    'maroon': Color(0xFF800000),
    'silver': Color(0xFFC0C0C0),
    'transparent': Color(0x00000000),
  };

  static StrokeCap _parseLineCap(String? value) {
    switch (value?.toLowerCase()) {
      case 'round':
        return StrokeCap.round;
      case 'square':
        return StrokeCap.square;
      default:
        return StrokeCap.butt;
    }
  }

  static StrokeJoin _parseLineJoin(String? value) {
    switch (value?.toLowerCase()) {
      case 'round':
        return StrokeJoin.round;
      case 'bevel':
        return StrokeJoin.bevel;
      default:
        return StrokeJoin.miter;
    }
  }

  static PathFillType _parseFillRule(String? value) {
    return value?.toLowerCase() == 'evenodd'
        ? PathFillType.evenOdd
        : PathFillType.nonZero;
  }

  static List<double>? _parseDashArray(String value) {
    final values = value.split(RegExp(r'[\s,]+'));
    return values.map((v) => double.tryParse(v) ?? 0).toList();
  }

  static double? _parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value.replaceAll(RegExp(r'[a-zA-Z%]'), ''));
  }
}
