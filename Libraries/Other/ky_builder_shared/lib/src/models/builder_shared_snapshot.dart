import 'builder_canvas_config.dart';
import 'builder_component_geometry.dart';

class BuilderSharedSnapshot {
  static const schemaId = 'kaysir.layout.shared_builder_snapshot';

  final String schema;
  final String id;
  final String name;
  final BuilderCanvasConfig canvasConfig;
  final List<BuilderComponentGeometry> components;
  final String? selectedComponentId;

  const BuilderSharedSnapshot({
    this.schema = schemaId,
    required this.id,
    required this.name,
    required this.canvasConfig,
    required this.components,
    this.selectedComponentId,
  });

  int get componentCount => components.length;

  Map<String, dynamic> toJson() {
    return {
      'schema': schema,
      'id': id,
      'name': name,
      'canvasConfig': canvasConfig.toJson(),
      'selectedComponentId': selectedComponentId,
      'components': components.map((component) => component.toJson()).toList(),
    };
  }

  factory BuilderSharedSnapshot.fromJson(Map<String, dynamic> json) {
    return BuilderSharedSnapshot(
      schema: json['schema'] as String? ?? schemaId,
      id: json['id'] as String? ?? 'shared-snapshot',
      name: json['name'] as String? ?? 'Imported Builder Snapshot',
      canvasConfig: BuilderCanvasConfig.fromJson(
        Map<String, dynamic>.from(json['canvasConfig'] as Map? ?? const {}),
      ),
      selectedComponentId: json['selectedComponentId'] as String?,
      components: [
        for (final item in json['components'] as List? ?? const [])
          BuilderComponentGeometry.fromJson(
            Map<String, dynamic>.from(item as Map? ?? const {}),
          ),
      ],
    );
  }
}
