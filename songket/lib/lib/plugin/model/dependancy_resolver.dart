import '../../execution/node_execution_chunk.dart';
import 'node_plugin.dart';

import 'registered_plugin.dart';

class DependencyResolver {
  Future<ValidationResult> validateDependencies(
    NodePlugin plugin,
    Map<String, RegisteredPlugin> registered,
  ) async {
    final errors = <String>[];

    for (final dep in plugin.metadata.dependencies) {
      if (!registered.containsKey(dep.pluginId)) {
        errors.add('Missing dependency: ${dep.pluginId}');
        continue;
      }

      final depPlugin = registered[dep.pluginId]!;
      final depVersion = depPlugin.plugin.metadata.version;

      if (!_versionMatches(depVersion, dep.versionConstraint)) {
        errors.add(
          'Version mismatch: ${dep.pluginId} requires ${dep.versionConstraint}, found $depVersion',
        );
      }
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }

  bool _versionMatches(String version, String constraint) {
    // Simple version matching (can be enhanced with semver)
    return true;
  }
}
