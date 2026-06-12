import 'dependancy_resolver.dart';
import 'node_exceutor.dart';
import 'node_plugin.dart';
import 'plugin_context.dart';
import 'plugin_event.dart';
import 'plugin_eventbus.dart';
import 'plugin_health_status.dart';
import 'plugin_loader.dart';
import 'plugin_logger.dart';
import 'plugin_registration_exception.dart';
import 'plugin_status.dart';
import 'plugin_stoage.dart';
import 'registered_plugin.dart';
import 'secret_manager.dart';

abstract class PluginRegistryListener {
  void onPluginEvent(PluginEvent event);
}

class PluginRegistry {
  static final PluginRegistry _instance = PluginRegistry._internal();
  factory PluginRegistry() => _instance;
  PluginRegistry._internal();

  final Map<String, RegisteredPlugin> _plugins = {};
  final Map<String, NodeExecutor> _executors = {};
  final List<PluginRegistryListener> _listeners = [];
  final PluginLoader _loader = PluginLoader();
  final DependencyResolver _dependencyResolver = DependencyResolver();

  // Register plugin
  Future<void> registerPlugin(NodePlugin plugin) async {
    final metadata = plugin.metadata;

    // Check if already registered
    if (_plugins.containsKey(metadata.id)) {
      throw PluginRegistrationException(
        'Plugin ${metadata.id} is already registered',
      );
    }

    // Validate dependencies
    final depsValid = await _dependencyResolver.validateDependencies(
      plugin,
      _plugins,
    );
    if (!depsValid.isValid) {
      throw PluginRegistrationException(
        'Dependency validation failed: ${depsValid.errors.join(", ")}',
      );
    }

    // Create context
    final context = PluginContext(
      pluginId: metadata.id,
      config: plugin.getDefaultConfig(),
      secretManager: SecretManager(),
      logger: PluginLogger(metadata.id),
      storage: PluginStorage(metadata.id),
      eventBus: PluginEventBus(),
    );

    try {
      // Initialize plugin
      await plugin.initialize(context);

      // Register executors
      final executors = plugin.getExecutors();
      for (final executor in executors) {
        _executors[executor.nodeType] = executor;
      }

      // Store plugin
      _plugins[metadata.id] = RegisteredPlugin(
        plugin: plugin,
        context: context,
        status: PluginStatus.active,
        registeredAt: DateTime.now(),
      );

      // Call lifecycle hook
      await plugin.onInstall();

      // Notify listeners
      _notifyListeners(PluginEvent.registered(metadata.id));
    } catch (e) {
      throw PluginRegistrationException('Plugin initialization failed: $e');
    }
  }

  // Unregister plugin
  Future<void> unregisterPlugin(String pluginId) async {
    final registered = _plugins[pluginId];
    if (registered == null) {
      throw PluginNotFoundException('Plugin $pluginId not found');
    }

    try {
      // Check dependents
      final dependents = _getDependents(pluginId);
      if (dependents.isNotEmpty) {
        throw PluginRegistrationException(
          'Cannot unregister plugin: required by ${dependents.join(", ")}',
        );
      }

      // Call lifecycle hook
      await registered.plugin.onUninstall();

      // Remove executors
      final executors = registered.plugin.getExecutors();
      for (final executor in executors) {
        _executors.remove(executor.nodeType);
      }

      // Dispose plugin
      await registered.plugin.dispose();

      // Remove from registry
      _plugins.remove(pluginId);

      // Notify listeners
      _notifyListeners(PluginEvent.unregistered(pluginId));
    } catch (e) {
      throw PluginRegistrationException('Plugin unregistration failed: $e');
    }
  }

  // Update plugin
  Future<void> updatePlugin(String pluginId, NodePlugin newPlugin) async {
    final registered = _plugins[pluginId];
    if (registered == null) {
      throw PluginNotFoundException('Plugin $pluginId not found');
    }

    final oldVersion = registered.plugin.metadata.version;
    final newVersion = newPlugin.metadata.version;

    if (!_isNewerVersion(newVersion, oldVersion)) {
      throw PluginRegistrationException(
        'New version $newVersion is not newer than $oldVersion',
      );
    }

    try {
      // Disable old plugin
      await disablePlugin(pluginId);

      // Call update hook
      await newPlugin.onUpdate(oldVersion);

      // Replace plugin
      await unregisterPlugin(pluginId);
      await registerPlugin(newPlugin);

      // Enable new plugin
      await enablePlugin(pluginId);

      // Notify listeners
      _notifyListeners(PluginEvent.updated(pluginId, oldVersion, newVersion));
    } catch (e) {
      throw PluginRegistrationException('Plugin update failed: $e');
    }
  }

  // Enable/Disable plugin
  Future<void> enablePlugin(String pluginId) async {
    final registered = _plugins[pluginId];
    if (registered == null) {
      throw PluginNotFoundException('Plugin $pluginId not found');
    }

    if (registered.status == PluginStatus.active) return;

    await registered.plugin.onEnable();
    registered.status = PluginStatus.active;
    _notifyListeners(PluginEvent.enabled(pluginId));
  }

  Future<void> disablePlugin(String pluginId) async {
    final registered = _plugins[pluginId];
    if (registered == null) {
      throw PluginNotFoundException('Plugin $pluginId not found');
    }

    if (registered.status == PluginStatus.disabled) return;

    await registered.plugin.onDisable();
    registered.status = PluginStatus.disabled;
    _notifyListeners(PluginEvent.disabled(pluginId));
  }

  // Get executor
  NodeExecutor? getExecutor(String nodeType) {
    return _executors[nodeType];
  }

  // Get all executors
  Map<String, NodeExecutor> getAllExecutors() {
    return Map.unmodifiable(_executors);
  }

  // Get plugin
  RegisteredPlugin? getPlugin(String pluginId) {
    return _plugins[pluginId];
  }

  // Get all plugins
  List<RegisteredPlugin> getAllPlugins() {
    return _plugins.values.toList();
  }

  // Search plugins
  List<RegisteredPlugin> searchPlugins(String query) {
    final lowerQuery = query.toLowerCase();
    return _plugins.values.where((registered) {
      final metadata = registered.plugin.metadata;
      return metadata.name.toLowerCase().contains(lowerQuery) ||
          metadata.description.toLowerCase().contains(lowerQuery) ||
          metadata.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Health check
  Future<Map<String, PluginHealthStatus>> healthCheckAll() async {
    final results = <String, PluginHealthStatus>{};
    for (final entry in _plugins.entries) {
      results[entry.key] = await entry.value.plugin.healthCheck();
    }
    return results;
  }

  // Load plugins from directory/URL
  Future<void> loadPluginsFromDirectory(String path) async {
    final plugins = await _loader.loadFromDirectory(path);
    for (final plugin in plugins) {
      await registerPlugin(plugin);
    }
  }

  Future<void> loadPluginFromUrl(String url) async {
    final plugin = await _loader.loadFromUrl(url);
    await registerPlugin(plugin);
  }

  // Listeners
  void addListener(PluginRegistryListener listener) {
    _listeners.add(listener);
  }

  void removeListener(PluginRegistryListener listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners(PluginEvent event) {
    for (final listener in _listeners) {
      listener.onPluginEvent(event);
    }
  }

  // Helper methods
  List<String> _getDependents(String pluginId) {
    return _plugins.values
        .where(
          (registered) => registered.plugin.metadata.dependencies.any(
            (dep) => dep.pluginId == pluginId,
          ),
        )
        .map((registered) => registered.plugin.metadata.id)
        .toList();
  }

  bool _isNewerVersion(String newVersion, String oldVersion) {
    // Simple version comparison (can be enhanced)
    return newVersion.compareTo(oldVersion) > 0;
  }
}
