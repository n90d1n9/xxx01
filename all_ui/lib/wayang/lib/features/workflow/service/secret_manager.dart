class SecretManager {
  final Map<String, String> _secrets = {};

  void setSecret(String key, String value) {
    _secrets[key] = value;
  }

  String? getSecret(String key) {
    return _secrets[key];
  }

  void removeSecret(String key) {
    _secrets.remove(key);
  }

  bool hasSecret(String key) {
    return _secrets.containsKey(key);
  }

  List<String> getAllKeys() {
    return _secrets.keys.toList();
  }

  void clearAll() {
    _secrets.clear();
  }

  // Encrypt/decrypt in production
  Map<String, String> exportEncrypted() {
    return Map.from(_secrets);
  }

  void importEncrypted(Map<String, String> secrets) {
    _secrets.addAll(secrets);
  }
}
