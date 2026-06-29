import 'node_exceutor.dart';
import 'plugin_context.dart';
import 'plugin_health_status.dart';
import 'plugin_metadata.dart';

abstract class NodePlugin {
  PluginMetadata get metadata;

  Future<void> initialize(PluginContext context);
  Future<void> dispose();

  List<NodeExecutor> getExecutors();

  // Lifecycle hooks
  Future<void> onInstall() async {}
  Future<void> onUninstall() async {}
  Future<void> onUpdate(String oldVersion) async {}
  Future<void> onEnable() async {}
  Future<void> onDisable() async {}

  // Health check
  Future<PluginHealthStatus> healthCheck() async {
    return PluginHealthStatus.healthy();
  }

  // Configuration
  Map<String, dynamic> getDefaultConfig() => {};
  Future<bool> validateConfig(Map<String, dynamic> config) async => true;
}


/* class NodePlugin {
  PluginMetadata get metadata => throw UnimplementedError();
  Future<void> initialize(PluginContext context) async {}
  Future<void> dispose() async {}
  List<NodeExecutor> getExecutors() => [];
}
 */