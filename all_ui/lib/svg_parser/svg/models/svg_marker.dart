import 'svg_definition.dart';

/// Marker definition for path endpoints and vertices
class SvgMarker extends SvgDefinition {
  final double refX, refY;
  final double markerWidth, markerHeight;
  final String orient;
  final List<dynamic> elements; // List of SvgElement

  SvgMarker({
    required String id,
    required this.refX,
    required this.refY,
    required this.markerWidth,
    required this.markerHeight,
    this.orient = 'auto',
    required this.elements,
  }) : super(id);

  @override
  String toString() => 'SvgMarker(id: $id, ${markerWidth}x$markerHeight)';
}
