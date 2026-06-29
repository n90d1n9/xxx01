// svg_parser.dart
import 'package:xml/xml.dart';

import '../models/svg_data.dart';
import '../models/svg_definition.dart';
import '../models/svg_element.dart';
import '../models/svg_style.dart';
import 'defs_parser.dart';
import 'element_parser.dart';

class SvgParser {
  static SvgData parse(String svgCode) {
    final document = XmlDocument.parse(svgCode);
    final svgElement = document.findElements('svg').first;

    double? width = _parseDouble(svgElement.getAttribute('width'));
    double? height = _parseDouble(svgElement.getAttribute('height'));

    final viewBox = _parseViewBox(svgElement.getAttribute('viewBox'));
    if (width == null || height == null) {
      width = viewBox?[2] ?? 100;
      height = viewBox?[3] ?? 100;
    }

    final elements = <SvgElement>[];
    final defs = <String, SvgDefinition>{};

    // Parse defs first
    for (var defsElement in svgElement.findElements('defs')) {
      DefsParser.parseDefs(defsElement, defs);
    }

    ElementParser.parseElements(svgElement, elements, SvgStyle(), defs);

    return SvgData(
      width: width,
      height: height,
      viewBox: viewBox,
      elements: elements,
    );
  }

  static List<double>? _parseViewBox(String? viewBox) {
    if (viewBox == null) return null;
    final values = viewBox.trim().split(RegExp(r'[\s,]+'));
    if (values.length != 4) return null;
    return values.map((v) => double.tryParse(v) ?? 0).toList();
  }

  static double? _parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value.replaceAll(RegExp(r'[a-zA-Z%]'), ''));
  }
}
