class SecretManager {
  final Map<String, String> _secrets = {};

  void setSecret(String key, String value) {
    _secrets[key] = value;
  }

  String? getSecret(String key) {
    return _secrets[key];
  }
}
