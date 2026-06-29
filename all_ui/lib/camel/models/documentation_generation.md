// Documentation Generator
import 'node.dart';

class DocumentationGenerator {
  static String generateMarkdown(WNode route) {
    final buffer = StringBuffer();

    buffer.writeln('# ${route.name}');
    buffer.writeln();

    if (route.description.isNotEmpty) {
      buffer.writeln('## Description');
      buffer.writeln(route.description);
      buffer.writeln();
    }

    buffer.writeln('## Overview');
    buffer.writeln('- **Total Nodes**: ${route.nodes.length}');
    buffer.writeln(
      '- **Created**: ${route.createdAt.toString().substring(0, 19)}',
    );
    if (route.modifiedAt != null) {
      buffer.writeln(
        '- **Modified**: ${route.modifiedAt.toString().substring(0, 19)}',
      );
    }
    buffer.writeln();

    buffer.writeln('## Flow Diagram');
    buffer.writeln('```');
    buffer.writeln(_generateAsciiFlow(route));
    buffer.writeln('```');
    buffer.writeln();

    buffer.writeln('## Components');
    buffer.writeln();

    for (int i = 0; i < route.nodes.length; i++) {
      final node = route.nodes[i];
      buffer.writeln('### ${i + 1}. ${node.name} (${node.type})');
      buffer.writeln();
      buffer.writeln('**Configuration:**');
      node.config.forEach((key, value) {
        buffer.writeln('- `$key`: $value');
      });

      if (node.connections.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('**Connects to:**');
        for (final connId in node.connections) {
          final connNode = route.nodes.firstWhere((n) => n.id == connId);
          buffer.writeln('- ${connNode.name}');
        }
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  static String _generateAsciiFlow(WNode route) {
    if (route.nodes.isEmpty) return 'Empty route';

    final buffer = StringBuffer();
    for (final node in route.nodes) {
      buffer.writeln('[${node.name}]');
      if (node.connections.isNotEmpty) {
        buffer.writeln('    |');
        buffer.writeln('    v');
      }
    }
    return buffer.toString();
  }

  static String generateHTML(WNode route) {
    final markdown = generateMarkdown(route);
    // In a real app, convert markdown to HTML
    return '<html><body><pre>$markdown</pre></body></html>';
  }
}
