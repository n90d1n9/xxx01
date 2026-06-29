import '../models/node.dart';

class CodeConverter {
  static String toYaml(WNode route) {
    final buffer = StringBuffer();
    buffer.writeln('camel:');
    buffer.writeln('  routes:');
    buffer.writeln('    - id: ${route.id}');
    if (route.description.isNotEmpty) {
      buffer.writeln('      description: ${route.description}');
    }

    if (route.nodes.isNotEmpty) {
      // Find source node (first node or node with no incoming connections)
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
}
