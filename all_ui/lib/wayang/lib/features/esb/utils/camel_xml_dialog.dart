import '../model/component_type.dart';
import '../model/integration_component.dart';
import '../model/integration_route.dart';

class CamelXMLGenerator {
  static String generate(IntegrationRoute route) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<routes xmlns="http://camel.apache.org/schema/spring">');
    buffer.writeln('  <route id="${route.id}">');
    buffer.writeln('    <description>${route.description}</description>');

    for (final component in route.components) {
      if (!component.enabled) continue;
      buffer.writeln(_componentToXML(component));
    }

    buffer.writeln('  </route>');
    buffer.writeln('</routes>');
    return buffer.toString();
  }

  static String _componentToXML(IntegrationComponent component) {
    final indent = '    ';

    switch (component.type) {
      case ComponentType.from:
        return '$indent<from uri="${component.properties['uri'] ?? 'direct:start'}"/>';
      case ComponentType.to:
        return '$indent<to uri="${component.properties['uri'] ?? 'direct:end'}"/>';
      case ComponentType.log:
        return '$indent<log message="${component.properties['message'] ?? 'Processing'}" loggingLevel="${component.properties['level'] ?? 'INFO'}"/>';
      case ComponentType.setHeader:
        return '$indent<setHeader name="${component.properties['name']}">\n$indent  <constant>${component.properties['value']}</constant>\n$indent</setHeader>';
      case ComponentType.setBody:
        return '$indent<setBody>\n$indent  <constant>${component.properties['value']}</constant>\n$indent</setBody>';
      case ComponentType.transform:
        return '$indent<transform>\n$indent  <${component.properties['language'] ?? 'simple'}>${component.properties['expression']}</${component.properties['language'] ?? 'simple'}>\n$indent</transform>';
      case ComponentType.filter:
        return '$indent<filter>\n$indent  <simple>${component.properties['expression']}</simple>\n$indent</filter>';
      case ComponentType.split:
        return '$indent<split ${component.properties['parallel'] == true ? 'parallelProcessing="true"' : ''}>\n$indent  <simple>${component.properties['expression']}</simple>\n$indent</split>';
      case ComponentType.delay:
        return '$indent<delay>\n$indent  <constant>${component.properties['delay']}</constant>\n$indent</delay>';
      case ComponentType.throttle:
        return '$indent<throttle timePeriodMillis="${component.properties['timePeriodMillis']}">\n$indent  <constant>${component.properties['maximumRequests']}</constant>\n$indent</throttle>';
      case ComponentType.marshal:
        return '$indent<marshal>\n$indent  <${component.properties['format'] ?? 'json'}/>\n$indent</marshal>';
      case ComponentType.unmarshal:
        return '$indent<unmarshal>\n$indent  <${component.properties['format'] ?? 'json'}/>\n$indent</unmarshal>';
      default:
        return '$indent<!-- ${component.type.name} -->';
    }
  }
}
