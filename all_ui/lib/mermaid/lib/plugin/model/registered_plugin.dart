import 'node_plugin.dart';
import 'plugin_context.dart';
import 'plugin_registry.dart';
import 'plugin_status.dart';

class RegisteredPlugin {
  final NodePlugin plugin;
  final PluginContext context;
  PluginStatus status;
  final DateTime registeredAt;

  RegisteredPlugin({
    required this.plugin,
    required this.context,
    required this.status,
    required this.registeredAt,
  });
}
