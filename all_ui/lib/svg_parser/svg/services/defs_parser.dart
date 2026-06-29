// parsers/defs_parser.dart
import 'package:xml/xml.dart';
import '../models/svg_definition.dart';
import 'clip_path_parser.dart';
import 'filter_parser.dart';
import 'gradient_parser.dart';
import 'marker_parser.dart';
import 'mask_parser.dart';
import 'pattern_parser.dart';
import 'symbol_parser.dart';

class DefsParser {
  static void parseDefs(
    XmlElement defsElement,
    Map<String, SvgDefinition> defs,
  ) {
    for (var child in defsElement.children.whereType<XmlElement>()) {
      final id = child.getAttribute('id');
      if (id == null) continue;

      switch (child.name.local) {
        case 'linearGradient':
          defs[id] = GradientParser.parseLinearGradient(child);
          break;
        case 'radialGradient':
          defs[id] = GradientParser.parseRadialGradient(child);
          break;
        case 'clipPath':
          defs[id] = ClipPathParser.parse(child);
          break;
        case 'pattern':
          defs[id] = PatternParser.parse(child);
          break;
        case 'mask':
          defs[id] = MaskParser.parse(child);
          break;
        case 'symbol':
          defs[id] = SymbolParser.parse(child);
          break;
        case 'marker':
          defs[id] = MarkerParser.parse(child);
          break;
        case 'filter':
          defs[id] = FilterParser.parse(child);
          break;
      }
    }
  }
}
