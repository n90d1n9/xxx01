import 'package:uuid/uuid.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class LayoutElement {
  final String id;
  final String type; // 'container', 'text', 'image', etc.
  final Map<String, dynamic> properties;
  final List<LayoutElement> children;

  LayoutElement({
    String? id,
    required this.type,
    this.properties = const {},
    this.children = const [],
  }) : id = id ?? const Uuid().v4();

  LayoutElement copyWith({
    String? type,
    Map<String, dynamic>? properties,
    List<LayoutElement>? children,
  }) {
    return LayoutElement(
      id: this.id,
      type: type ?? this.type,
      properties: properties ?? Map.from(this.properties),
      children: children ?? List.from(this.children),
    );
  }
}
