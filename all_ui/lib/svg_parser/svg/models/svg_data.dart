// Data models
import 'svg_element.dart';

class SvgData {
  final double width;
  final double height;
  final List<double>? viewBox;
  final List<SvgElement> elements;

  SvgData({
    required this.width,
    required this.height,
    this.viewBox,
    required this.elements,
  });
}
