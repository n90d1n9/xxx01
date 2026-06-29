// parsers/style_parser.dart
import 'package:xml/xml.dart';
import '../models/svg_style.dart';
import '../models/svg_paint.dart';
import 'color_parser.dart';
import 'utils_parser.dart';

class StyleParser {
  static SvgStyle mergeStyles(SvgStyle inherited, XmlElement element) {
    final style = SvgStyle.from(inherited);

    // Parse style attribute
    final styleAttr = element.getAttribute('style');
    if (styleAttr != null) {
      _parseStyleAttribute(styleAttr, style);
    }

    // Override with individual attributes
    _parseIndividualAttributes(element, style);

    return style;
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
          style.strokeWidth = parseDouble(value);
          break;
        case 'opacity':
          style.opacity = parseDouble(value);
          break;
        case 'fill-opacity':
          style.fillOpacity = parseDouble(value);
          break;
        case 'stroke-opacity':
          style.strokeOpacity = parseDouble(value);
          break;
        case 'stroke-linecap':
          style.strokeLinecap = parseLineCap(value);
          break;
        case 'stroke-linejoin':
          style.strokeLinejoin = parseLineJoin(value);
          break;
        case 'stroke-dasharray':
          if (value != 'none') style.strokeDasharray = parseDashArray(value);
          break;
        case 'fill-rule':
          style.fillRule = parseFillRule(value);
          break;
      }
    }
  }

  static void _parseIndividualAttributes(XmlElement element, SvgStyle style) {
    final fill = element.getAttribute('fill');
    if (fill != null) style.fill = _parsePaint(fill);

    final stroke = element.getAttribute('stroke');
    if (stroke != null) style.stroke = _parsePaint(stroke);

    final strokeWidth = element.getAttribute('stroke-width');
    if (strokeWidth != null) style.strokeWidth = parseDouble(strokeWidth);

    final opacity = element.getAttribute('opacity');
    if (opacity != null) style.opacity = parseDouble(opacity);

    final fillOpacity = element.getAttribute('fill-opacity');
    if (fillOpacity != null) style.fillOpacity = parseDouble(fillOpacity);

    final strokeOpacity = element.getAttribute('stroke-opacity');
    if (strokeOpacity != null) {
      style.strokeOpacity = parseDouble(strokeOpacity);
    }

    final strokeLinecap = element.getAttribute('stroke-linecap');
    if (strokeLinecap != null) {
      style.strokeLinecap = parseLineCap(strokeLinecap);
    }

    final strokeLinejoin = element.getAttribute('stroke-linejoin');
    if (strokeLinejoin != null) {
      style.strokeLinejoin = parseLineJoin(strokeLinejoin);
    }

    final strokeMiterlimit = element.getAttribute('stroke-miterlimit');
    if (strokeMiterlimit != null) {
      style.strokeMiterlimit = parseDouble(strokeMiterlimit);
    }

    final strokeDasharray = element.getAttribute('stroke-dasharray');
    if (strokeDasharray != null && strokeDasharray != 'none') {
      style.strokeDasharray = parseDashArray(strokeDasharray);
    }

    final fillRule = element.getAttribute('fill-rule');
    if (fillRule != null) style.fillRule = parseFillRule(fillRule);
  }

  static SvgPaint? _parsePaint(String? paintStr) {
    if (paintStr == null || paintStr.isEmpty || paintStr == 'none') {
      return SvgPaint.none();
    }

    if (paintStr.startsWith('url(')) {
      final match = RegExp(r'url\(#([^)]+)\)').firstMatch(paintStr);
      if (match != null) {
        return SvgPaint.reference(match.group(1)!);
      }
    }

    final color = ColorParser.parse(paintStr);
    return color != null ? SvgPaint.color(color) : null;
  }

  // ... (include the remaining helper methods for line cap, join, etc.)
}
