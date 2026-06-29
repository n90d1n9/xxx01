// parsers/filter_parser.dart
import 'package:xml/xml.dart';
import '../models/filter.dart';
import '../models/filter_primitive.dart';
import 'color_parser.dart';

class FilterParser {
  static SvgFilter parse(XmlElement element) {
    final primitives = <FilterPrimitive>[];

    for (var child in element.children.whereType<XmlElement>()) {
      switch (child.name.local) {
        case 'feGaussianBlur':
          primitives.add(
            FeGaussianBlur(
              stdDeviation:
                  _parseDouble(child.getAttribute('stdDeviation')) ?? 0,
              input: child.getAttribute('in'),
              result: child.getAttribute('result'),
            ),
          );
          break;
        case 'feDropShadow':
          primitives.add(
            FeDropShadow(
              dx: _parseDouble(child.getAttribute('dx')) ?? 2,
              dy: _parseDouble(child.getAttribute('dy')) ?? 2,
              stdDeviation:
                  _parseDouble(child.getAttribute('stdDeviation')) ?? 2,
              floodColor: ColorParser.parse(child.getAttribute('flood-color')),
              floodOpacity:
                  _parseDouble(child.getAttribute('flood-opacity')) ?? 1,
            ),
          );
          break;
        case 'feOffset':
          primitives.add(
            FeOffset(
              dx: _parseDouble(child.getAttribute('dx')) ?? 0,
              dy: _parseDouble(child.getAttribute('dy')) ?? 0,
              input: child.getAttribute('in'),
              result: child.getAttribute('result'),
            ),
          );
          break;
        case 'feColorMatrix':
          primitives.add(
            FeColorMatrix(
              type: child.getAttribute('type') ?? 'matrix',
              values: child.getAttribute('values'),
              input: child.getAttribute('in'),
              result: child.getAttribute('result'),
            ),
          );
          break;
        case 'feBlend':
          primitives.add(
            FeBlend(
              mode: child.getAttribute('mode') ?? 'normal',
              in1: child.getAttribute('in'),
              in2: child.getAttribute('in2'),
              result: child.getAttribute('result'),
            ),
          );
          break;
      }
    }

    return SvgFilter(
      id: element.getAttribute('id') ?? '',
      primitives: primitives,
    );
  }

  static double? _parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value.replaceAll(RegExp(r'[a-zA-Z%]'), ''));
  }
}
