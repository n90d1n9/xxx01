class PluginStorage {
  final String pluginId;
  final Map<String, dynamic> _data = {};

  PluginStorage(this.pluginId);

  Future<void> set(String key, dynamic value) async {
    _data[key] = value;
  }

  Future<dynamic> get(String key) async {
    return _data[key];
  }

  Future<void> delete(String key) async {
    _data.remove(key);
  }

  Future<void> clear() async {
    _data.clear();
  }
}
