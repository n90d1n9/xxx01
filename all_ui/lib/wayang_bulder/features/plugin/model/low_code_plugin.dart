import 'package:wayang_builder/features/plugin/model/plugin_health_status.dart';

import '../widget/lowcode_node_executor.dart';
import 'node_exceutor.dart';
import 'node_plugin.dart';
import 'plugin_capabilities.dart';
import 'plugin_context.dart';
import 'plugin_definition.dart';
import 'plugin_metadata.dart';

class LowCodePlugin implements NodePlugin {
  final PluginDefinition definition;

  LowCodePlugin(this.definition);

  @override
  PluginMetadata get metadata => PluginMetadata(
    id: definition.id,
    name: definition.name,
    version: definition.version,
    description: definition.description,
    author: definition.author,
    tags: definition.tags,
    capabilities: PluginCapabilities(
      supportsAsync: true,
      supportsStreaming: false,
      supportsBatch: false,
      requiresAuth: definition.nodes.any((n) => n.requiredSecrets.isNotEmpty),
    ),
    createdAt: definition.createdAt,
    updatedAt: definition.updatedAt,
  );

  @override
  Future<void> initialize(PluginContext context) async {
    context.logger.info('Initializing low-code plugin: ${definition.name}');
  }

  @override
  Future<void> dispose() async {}

  @override
  List<NodeExecutor> getExecutors() {
    return definition.nodes.map((node) => LowCodeNodeExecutor(node)).toList();
  }

  @override
  Map<String, dynamic> getDefaultConfig() {
    // TODO: implement getDefaultConfig
    throw UnimplementedError();
  }

  @override
  Future<PluginHealthStatus> healthCheck() {
    // TODO: implement healthCheck
    throw UnimplementedError();
  }

  @override
  Future<void> onDisable() {
    // TODO: implement onDisable
    throw UnimplementedError();
  }

  @override
  Future<void> onEnable() {
    // TODO: implement onEnable
    throw UnimplementedError();
  }

  @override
  Future<void> onInstall() {
    // TODO: implement onInstall
    throw UnimplementedError();
  }

  @override
  Future<void> onUninstall() {
    // TODO: implement onUninstall
    throw UnimplementedError();
  }

  @override
  Future<void> onUpdate(String oldVersion) {
    // TODO: implement onUpdate
    throw UnimplementedError();
  }

  @override
  Future<bool> validateConfig(Map<String, dynamic> config) {
    // TODO: implement validateConfig
    throw UnimplementedError();
  }
}
