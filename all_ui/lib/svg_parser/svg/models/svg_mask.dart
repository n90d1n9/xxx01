import 'svg_definition.dart';

/// Mask definition for alpha masking
class SvgMask extends SvgDefinition {
  final List<dynamic> elements; // List of SvgElement
  final double? x, y, width, height;
  final String maskUnits;
  final String maskContentUnits;

  SvgMask({
    required String id,
    required this.elements,
    this.x,
    this.y,
    this.width,
    this.height,
    this.maskUnits = 'objectBoundingBox',
    this.maskContentUnits = 'userSpaceOnUse',
  }) : super(id);

  @override
  String toString() => 'SvgMask(id: $id, elements: ${elements.length})';
}
