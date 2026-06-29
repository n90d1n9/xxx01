// parsers/pattern_parser.dart
import 'package:xml/xml.dart';

import '../models/svg_element.dart';
import '../models/svg_pattern.dart';
import '../models/svg_style.dart';
import 'element_parser.dart';
import 'transform_parser.dart';

class PatternParser {
  static SvgPattern parse(XmlElement element) {
    final elements = <SvgElement>[];
    ElementParser.parseElements(element, elements, SvgStyle(), {});

    return SvgPattern(
      id: element.getAttribute('id') ?? '',
      x: _parseDouble(element.getAttribute('x')) ?? 0,
      y: _parseDouble(element.getAttribute('y')) ?? 0,
      width: _parseDouble(element.getAttribute('width')) ?? 0,
      height: _parseDouble(element.getAttribute('height')) ?? 0,
      patternUnits: element.getAttribute('patternUnits') ?? 'objectBoundingBox',
      patternTransform: TransformParser.parse(
        element.getAttribute('patternTransform'),
      ),
      elements: elements,
    );
  }

  static double? _parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value.replaceAll(RegExp(r'[a-zA-Z%]'), ''));
  }
}
