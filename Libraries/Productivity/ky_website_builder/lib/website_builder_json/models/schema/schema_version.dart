/// Helper class for version management
class SchemaVersion {
  static const String current = '1.0.0';

  static bool isCompatible(String version) {
    // Simple major version check
    final currentMajor = int.parse(current.split('.')[0]);
    final versionMajor = int.parse(version.split('.')[0]);
    return currentMajor == versionMajor;
  }
}
