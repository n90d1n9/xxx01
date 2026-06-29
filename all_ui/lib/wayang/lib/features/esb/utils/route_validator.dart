import '../model/component_type.dart';
import '../model/integration_route.dart';
import '../model/validation_result.dart';

class RouteValidator {
  static ValidationResult validate(IntegrationRoute route) {
    final errors = <String>[];

    if (route.components.isEmpty) {
      errors.add('Route has no components');
      return ValidationResult(isValid: false, errors: errors);
    }

    // Check for "from" component
    final hasFrom = route.components.any((c) => c.type == ComponentType.from);
    if (!hasFrom) {
      errors.add('Route must have at least one "from" component');
    }

    // Check for orphaned components
    for (final component in route.components) {
      if (component.type != ComponentType.from) {
        final hasIncoming = route.connections.any(
          (c) => c.toId == component.id,
        );
        if (!hasIncoming) {
          errors.add(
            'Component "${component.label}" has no incoming connections',
          );
        }
      }
    }

    // Validate component properties
    for (final component in route.components) {
      switch (component.type) {
        case ComponentType.from:
        case ComponentType.to:
          if (component.properties['uri'] == null ||
              component.properties['uri'].isEmpty) {
            errors.add('Component "${component.label}" missing URI');
          }
          break;
        case ComponentType.setHeader:
          if (component.properties['name'] == null ||
              component.properties['name'].isEmpty) {
            errors.add('Component "${component.label}" missing header name');
          }
          break;
        case ComponentType.transform:
        case ComponentType.filter:
          if (component.properties['expression'] == null ||
              component.properties['expression'].isEmpty) {
            errors.add('Component "${component.label}" missing expression');
          }
          break;
        default:
          break;
      }
    }

    // Check for circular dependencies
    if (_hasCircularDependencies(route)) {
      errors.add('Route contains circular dependencies');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  static bool _hasCircularDependencies(IntegrationRoute route) {
    final visited = <String>{};
    final stack = <String>{};

    bool hasCycle(String componentId) {
      if (stack.contains(componentId)) return true;
      if (visited.contains(componentId)) return false;

      visited.add(componentId);
      stack.add(componentId);

      final outgoing = route.connections.where((c) => c.fromId == componentId);
      for (final conn in outgoing) {
        if (hasCycle(conn.toId)) return true;
      }

      stack.remove(componentId);
      return false;
    }

    for (final component in route.components) {
      if (hasCycle(component.id)) return true;
    }

    return false;
  }
}
