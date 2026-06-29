import 'svg_definition.dart';

/// Symbol definition for reusable graphics
class SvgSymbol extends SvgDefinition {
  final List<double>? viewBox;
  final List<dynamic> elements; // List of SvgElement
  final double? width, height;
  final String? preserveAspectRatio;

  SvgSymbol({
    required String id,
    this.viewBox,
    required this.elements,
    this.width,
    this.height,
    this.preserveAspectRatio,
  }) : super(id);

  @override
  String toString() => 'SvgSymbol(id: $id, elements: ${elements.length})';
}
