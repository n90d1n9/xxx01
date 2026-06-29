// parsers/element_parser.dart
import 'package:xml/xml.dart';
import '../models/svg_element.dart';
import '../models/svg_group.dart';
import '../models/svg_style.dart';
import '../models/svg_definition.dart';
import 'image_parser.dart';
import 'shape_parser.dart';
import 'style_parser.dart';
import 'transform_parser.dart';

class ElementParser {
  static void parseElements(
    XmlElement parent,
    List<SvgElement> elements,
    SvgStyle inheritedStyle,
    Map<String, SvgDefinition> defs,
  ) {
    for (var node in parent.children) {
      if (node is XmlElement) {
        final style = StyleParser.mergeStyles(inheritedStyle, node);

        switch (node.name.local) {
          case 'path':
            elements.add(PathParser.parse(node, style));
            break;
          case 'rect':
            elements.add(RectParser.parse(node, style));
            break;
          case 'circle':
            elements.add(CircleParser.parse(node, style));
            break;
          case 'ellipse':
            elements.add(EllipseParser.parse(node, style));
            break;
          case 'line':
            elements.add(LineParser.parse(node, style));
            break;
          case 'polyline':
            elements.add(PolylineParser.parse(node, style));
            break;
          case 'polygon':
            elements.add(PolygonParser.parse(node, style));
            break;
          case 'text':
            elements.add(TextParser.parse(node, style));
            break;
          case 'image':
            elements.add(ImageParser.parseImage(node, style));
            break;
          case 'g':
            final transform = TransformParser.parse(
              node.getAttribute('transform'),
            );
            final group = SvgGroup(transform: transform, style: style);
            parseElements(node, group.children, style, defs);
            elements.add(group);
            break;
          case 'use':
            _parseUseElement(node, elements, style, defs);
            break;
          case 'defs':
          case 'style':
            // Skip, already processed
            break;
          default:
            // Try to parse unknown elements recursively
            parseElements(node, elements, style, defs);
        }
      }
    }
  }

  static void _parseUseElement(
    XmlElement element,
    List<SvgElement> elements,
    SvgStyle style,
    Map<String, SvgDefinition> defs,
  ) {
    final href =
        element.getAttribute('href') ?? element.getAttribute('xlink:href');
    if (href != null && href.startsWith('#')) {
      final refId = href.substring(1);
      if (defs.containsKey(refId)) {
        // Handle use element - this would need additional logic to handle transformations
        // and styling inheritance for the used element
      }
    }
  }
}
