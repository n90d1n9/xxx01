// parsers/clip_path_parser.dart
import 'package:xml/xml.dart';
import '../models/svg_clip_path.dart';
import '../models/svg_element.dart';
import '../models/svg_style.dart';
import 'element_parser.dart';

class ClipPathParser {
  static SvgClipPath parse(XmlElement element) {
    final elements = <SvgElement>[];
    ElementParser.parseElements(element, elements, SvgStyle(), {});
    return SvgClipPath(
      id: element.getAttribute('id') ?? '',
      elements: elements,
    );
  }
}
