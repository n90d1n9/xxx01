import '../model/component_type.dart';
import '../model/integration_component.dart';
import '../model/integration_route.dart';

class CamelYAMLGenerator {
  static String generate(IntegrationRoute route) {
    final buffer = StringBuffer();
    buffer.writeln('- route:');
    buffer.writeln('    id: ${route.id}');
    buffer.writeln('    description: ${route.description}');
    buffer.writeln('    from:');

    for (var i = 0; i < route.components.length; i++) {
      final component = route.components[i];
      if (!component.enabled) continue;

      buffer.writeln(_componentToYAML(component, i == 0));
    }

    return buffer.toString();
  }

  static String _componentToYAML(IntegrationComponent component, bool isFirst) {
    final indent = isFirst ? '      ' : '        ';

    switch (component.type) {
      case ComponentType.from:
        return '${indent}uri: ${component.properties['uri'] ?? 'direct:start'}';
      case ComponentType.to:
        return '${indent}- to:\n$indent    uri: ${component.properties['uri'] ?? 'direct:end'}';
      case ComponentType.log:
        return '${indent}- log: "${component.properties['message'] ?? 'Processing'}"';
      case ComponentType.setHeader:
        return '${indent}- setHeader:\n$indent    name: ${component.properties['name']}\n$indent    constant: ${component.properties['value']}';
      case ComponentType.setBody:
        return '${indent}- setBody:\n$indent    constant: ${component.properties['value']}';
      default:
        return '${indent}- # ${component.type.name}';
    }
  }
}
