import 'plugin_eventbus.dart';
import 'plugin_logger.dart';
import 'plugin_stoage.dart';
import 'secret_manager.dart';

class PluginContext {
  final String pluginId;
  final Map<String, dynamic> config;
  final SecretManager secretManager;
  final PluginLogger logger;
  final PluginStorage storage;
  final PluginEventBus eventBus;

  PluginContext({
    required this.pluginId,
    required this.config,
    required this.secretManager,
    required this.logger,
    required this.storage,
    required this.eventBus,
  });
}
