class PluginRegistrationException implements Exception {
  final String message;
  PluginRegistrationException(this.message);

  @override
  String toString() => 'PluginRegistrationException: $message';
}

class PluginNotFoundException implements Exception {
  final String message;
  PluginNotFoundException(this.message);

  @override
  String toString() => 'PluginNotFoundException: $message';
}
