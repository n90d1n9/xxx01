import 'node_plugin.dart';

class PluginLoader {
  Future<List<NodePlugin>> loadFromDirectory(String path) async {
    // Implementation for loading plugins from filesystem
    // In production, this would scan directory and load plugin files
    return [];
  }

  Future<NodePlugin> loadFromUrl(String url) async {
    // Implementation for downloading and loading plugin from URL
    throw UnimplementedError('Load from URL not implemented');
  }
}
