import 'package:uuid/uuid.dart';

import 'component.dart';
import 'grid_setting.dart';
import 'layout_config.dart';

class LayoutVersion {
  final String id;
  final DateTime timestamp;
  final String? name;
  final List<ComponentData> components;
  final GridSettings gridSettings;
  final LayoutConfig config;

  const LayoutVersion({
    required this.id,
    required this.timestamp,
    this.name,
    required this.components,
    required this.gridSettings,
    required this.config,
  });

  factory LayoutVersion.create(
    List<ComponentData> components, {
    GridSettings gridSettings = const GridSettings(),
    LayoutConfig config = const LayoutConfig(),
    String? name,
  }) {
    final uuid = Uuid();
    return LayoutVersion(
      id: uuid.v4(),
      timestamp: DateTime.now(),
      name: name,
      components: List<ComponentData>.unmodifiable(components),
      gridSettings: gridSettings,
      config: config,
    );
  }

  LayoutVersion copyWith({
    String? id,
    DateTime? timestamp,
    String? name,
    List<ComponentData>? components,
    GridSettings? gridSettings,
    LayoutConfig? config,
  }) {
    return LayoutVersion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      name: name ?? this.name,
      components: components ?? this.components,
      gridSettings: gridSettings ?? this.gridSettings,
      config: config ?? this.config,
    );
  }
}
