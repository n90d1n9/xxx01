// parsers/symbol_parser.dart
import 'package:xml/xml.dart';

import '../models/svg_element.dart';
import '../models/svg_style.dart';
import '../models/svg_symbol.dart';
import 'element_parser.dart';

class SymbolParser {
  static SvgSymbol parse(XmlElement element) {
    final elements = <SvgElement>[];
    final viewBox = _parseViewBox(element.getAttribute('viewBox'));
    ElementParser.parseElements(element, elements, SvgStyle(), {});

    return SvgSymbol(
      id: element.getAttribute('id') ?? '',
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
}
