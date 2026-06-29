import 'dart:convert';

import '../model/low_code_plugin.dart';
import '../model/plugin_definition.dart';
import '../model/plugin_registry.dart';

class PluginUploadService {
  final PluginRegistry registry;

  PluginUploadService(this.registry);

  Future<void> uploadPlugin(PluginDefinition definition) async {
    try {
      final plugin = LowCodePlugin(definition);
      await registry.registerPlugin(plugin);
    } catch (e) {
      throw Exception('Failed to upload plugin: $e');
    }
  }

  Future<void> uploadFromJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final definition = PluginDefinition.fromJson(data);
    await uploadPlugin(definition);
  }
}
