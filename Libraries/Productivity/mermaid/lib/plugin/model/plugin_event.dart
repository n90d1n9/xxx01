abstract class PluginEvent {
  final String pluginId;
  final DateTime timestamp;

  PluginEvent(this.pluginId) : timestamp = DateTime.now();

  factory PluginEvent.registered(String pluginId) = PluginRegisteredEvent;
  factory PluginEvent.unregistered(String pluginId) = PluginUnregisteredEvent;
  factory PluginEvent.enabled(String pluginId) = PluginEnabledEvent;
  factory PluginEvent.disabled(String pluginId) = PluginDisabledEvent;
  factory PluginEvent.updated(
    String pluginId,
    String oldVersion,
    String newVersion,
  ) = PluginUpdatedEvent;
}

class PluginRegisteredEvent extends PluginEvent {
  PluginRegisteredEvent(String pluginId) : super(pluginId);
}

class PluginUnregisteredEvent extends PluginEvent {
  PluginUnregisteredEvent(String pluginId) : super(pluginId);
}

class PluginEnabledEvent extends PluginEvent {
  PluginEnabledEvent(String pluginId) : super(pluginId);
}

class PluginDisabledEvent extends PluginEvent {
  PluginDisabledEvent(String pluginId) : super(pluginId);
}

class PluginUpdatedEvent extends PluginEvent {
  final String oldVersion;
  final String newVersion;

  PluginUpdatedEvent(String pluginId, this.oldVersion, this.newVersion)
    : super(pluginId);
}
