// parsers/marker_parser.dart
import 'package:xml/xml.dart';

import '../models/svg_element.dart';
import '../models/svg_marker.dart';
import '../models/svg_style.dart';
import 'element_parser.dart';

class MarkerParser {
  static SvgMarker parse(XmlElement element) {
    final elements = <SvgElement>[];
    ElementParser.parseElements(element, elements, SvgStyle(), {});

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

  static double? _parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value.replaceAll(RegExp(r'[a-zA-Z%]'), ''));
  }
}
