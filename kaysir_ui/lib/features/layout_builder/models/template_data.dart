import 'component.dart';
import 'grid_setting.dart';

class TemplateData {
  final String id;
  final String name;
  final List<ComponentData> components;
  final GridSettings gridSettings;
  final String? description;
  final String? thumbnail;

  const TemplateData({
    required this.id,
    required this.name,
    required this.components,
    required this.gridSettings,
    this.description,
    this.thumbnail,
  });

  TemplateData copyWith({
    String? id,
    String? name,
    List<ComponentData>? components,
    GridSettings? gridSettings,
    String? description,
    String? thumbnail,
  }) {
    return TemplateData(
      id: id ?? this.id,
      name: name ?? this.name,
      components: components ?? this.components,
      gridSettings: gridSettings ?? this.gridSettings,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}
