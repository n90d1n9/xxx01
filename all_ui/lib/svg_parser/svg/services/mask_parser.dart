// parsers/mask_parser.dart
import 'package:xml/xml.dart';
import '../models/svg_element.dart';
import '../models/svg_mask.dart';
import '../models/svg_style.dart';
import 'element_parser.dart';

class MaskParser {
  static SvgMask parse(XmlElement element) {
    final elements = <SvgElement>[];
    ElementParser.parseElements(element, elements, SvgStyle(), {});
    return SvgMask(id: element.getAttribute('id') ?? '', elements: elements);
  }
}
