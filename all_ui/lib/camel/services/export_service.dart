// Export Formats
import 'dart:convert';

import '../models/node.dart';

enum ExportFormat {
  yaml,
  json,
  xml,
  springDsl,
  quarkusYaml,
  kubernetes,
  docker,
}

class ExportService {
  static String export(WNode route, ExportFormat format) {
    switch (format) {
      case ExportFormat.yaml:
        return _exportYaml(route);
      case ExportFormat.json:
        return jsonEncode(route.toJson());
      case ExportFormat.xml:
        return _exportXml(route);
      case ExportFormat.springDsl:
        return _exportSpringDsl(route);
      case ExportFormat.quarkusYaml:
        return _exportQuarkusYaml(route);
      case ExportFormat.kubernetes:
        return _exportKubernetes(route);
      case ExportFormat.docker:
        return _exportDocker(route);
    }
  }

  static String _exportYaml(WNode route) {
    final buffer = StringBuffer();
    buffer.writeln('camel:');
    buffer.writeln('  routes:');
    buffer.writeln('    - id: ${route.id}');
    if (route.description.isNotEmpty) {
      buffer.writeln('      description: ${route.description}');
    }

    if (route.nodes.isNotEmpty) {
      final sourceNode = route.nodes.first;
      buffer.writeln('      from:');
      buffer.writeln('        uri: ${sourceNode.type}');
      buffer.writeln('        parameters:');
      sourceNode.config.forEach((key, value) {
        buffer.writeln('          $key: $value');
      });

      if (route.nodes.length > 1) {
        buffer.writeln('      steps:');
        for (int i = 1; i < route.nodes.length; i++) {
          final node = route.nodes[i];
          buffer.writeln('        - ${node.type}:');
          node.config.forEach((key, value) {
            buffer.writeln('            $key: $value');
          });
        }
      }
    }

    return buffer.toString();
  }

  static String _exportXml(WNode route) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<routes xmlns="http://camel.apache.org/schema/spring">');
    buffer.writeln('  <route id="${route.id}">');

    if (route.nodes.isNotEmpty) {
      final sourceNode = route.nodes.first;
      buffer.writeln(
        '    <from uri="${sourceNode.type}:${sourceNode.config.values.first}"/>',
      );

      for (int i = 1; i < route.nodes.length; i++) {
        final node = route.nodes[i];
        buffer.writeln('    <${node.type}/>');
      }
    }

    buffer.writeln('  </route>');
    buffer.writeln('</routes>');
    return buffer.toString();
  }

  static String _exportSpringDsl(WNode route) {
    final buffer = StringBuffer();
    buffer.writeln('import org.apache.camel.builder.RouteBuilder;');
    buffer.writeln();
    buffer.writeln(
      'public class ${route.name.replaceAll(' ', '')}Route extends RouteBuilder {',
    );
    buffer.writeln('    @Override');
    buffer.writeln('    public void configure() throws Exception {');

    if (route.nodes.isNotEmpty) {
      final sourceNode = route.nodes.first;
      buffer.write(
        '        from("${sourceNode.type}:${sourceNode.config.values.first}")',
      );

      for (int i = 1; i < route.nodes.length; i++) {
        final node = route.nodes[i];
        buffer.writeln();
        buffer.write('            .${node.type}()');
      }
      buffer.writeln(';');
    }

    buffer.writeln('    }');
    buffer.writeln('}');
    return buffer.toString();
  }

  static String _exportQuarkusYaml(WNode route) {
    return _exportYaml(route); // Similar to standard YAML
  }

  static String _exportKubernetes(WNode route) {
    final buffer = StringBuffer();
    buffer.writeln('apiVersion: camel.apache.org/v1');
    buffer.writeln('kind: Integration');
    buffer.writeln('metadata:');
    buffer.writeln('  name: ${route.id}');
    buffer.writeln('spec:');
    buffer.writeln('  flows:');
    buffer.writeln('    - route:');
    buffer.writeln('        id: ${route.id}');
    buffer.writeln('        from:');
    if (route.nodes.isNotEmpty) {
      buffer.writeln('          uri: ${route.nodes.first.type}');
      buffer.writeln('        steps:');
      for (int i = 1; i < route.nodes.length; i++) {
        buffer.writeln('          - ${route.nodes[i].type}: {}');
      }
    }
    return buffer.toString();
  }

  static String _exportDocker(WNode route) {
    final buffer = StringBuffer();
    buffer.writeln('FROM quay.io/quarkus/quarkus-micro-image:2.0');
    buffer.writeln('WORKDIR /work/');
    buffer.writeln('COPY routes.yaml /work/routes.yaml');
    buffer.writeln('EXPOSE 8080');
    buffer.writeln('CMD ["java", "-jar", "camel-quarkus-runner.jar"]');
    return buffer.toString();
  }
}
