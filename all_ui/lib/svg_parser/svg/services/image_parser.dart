import 'package:xml/xml.dart';

import '../models/svg_image.dart';
import '../models/svg_style.dart';
import 'svg_transformer_parser.dart';
import 'utils_parser.dart';

class ImageParser {
  static SvgImage parseImage(XmlElement element, SvgStyle style) {
    return SvgImage(
      href:
          element.getAttribute('href') ??
          element.getAttribute('xlink:href') ??
          '',
      x: parseDouble(element.getAttribute('x')) ?? 0,
      y: parseDouble(element.getAttribute('y')) ?? 0,
      width: parseDouble(element.getAttribute('width')) ?? 0,
      height: parseDouble(element.getAttribute('height')) ?? 0,
      style: style,
      transform: SvgTransformParser.parseTransform(
        element.getAttribute('transform'),
      ),
    );
  }
}
