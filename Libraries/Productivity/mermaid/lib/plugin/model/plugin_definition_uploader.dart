import 'dart:convert';

import 'low_code_plugin.dart';
import 'plugin_definition.dart';
import 'plugin_registry.dart';

class PluginDefinitionUploader {
  final PluginRegistry registry;

  PluginDefinitionUploader(this.registry);

  Future<void> uploadDefinition(PluginDefinition definition) async {
    // Convert definition to actual plugin
    final plugin = LowCodePlugin(definition);

    // Register with plugin registry
    await registry.registerPlugin(plugin);
  }

  Future<void> uploadFromJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final definition = PluginDefinition.fromJson(data);
    await uploadDefinition(definition);
  }

  Future<void> uploadFromFile(String filePath) async {
    // Read file and upload
  }
}
