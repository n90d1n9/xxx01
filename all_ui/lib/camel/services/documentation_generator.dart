import '../models/node.dart';
import 'template_engine.dart';

class DocumentationGenerator {
  static final TemplateEngine _templateEngine = TemplateEngine(
    templateDirectory: 'templates/docs',
  );

  static String generateMarkdown(WNode route) {
    return _templateEngine.render('documentation', _buildContext(route));
  }

  static String generateHTML(WNode route) {
    final context = _buildContext(route);
    return _templateEngine.render('html_documentation', context);
  }

  static Map<String, dynamic> _buildContext(WNode route) {
    return {
      'route': {
        'name': route.name,
        'description': route.description,
        'nodes':
            route.nodes.asMap().entries.map((entry) {
              final index = entry.key;
              final node = entry.value;

              return {
                'index': index + 1,
                'name': node.name,
                'type': node.type,
                'config':
                    node.config.entries
                        .map((e) => {'key': e.key, 'value': e.value})
                        .toList(),
                'hasConnections': node.connections.isNotEmpty,
                'connections':
                    node.connections.map((connId) {
                      final connNode = route.nodes.firstWhere(
                        (n) => n.id == connId.id,
                      );
                      return {'targetName': connNode.name};
                    }).toList(),
                'configCount': node.config.length,
                'connectionCount': node.connections.length,
              };
            }).toList(),
        'nodeCount': route.nodes.length,
        'createdAt': route.createdAt.toString().substring(0, 19),
        'modifiedAt': route.modifiedAt?.toString().substring(0, 19),
        'hasDescription': route.description.isNotEmpty,
        'hasModifiedDate': route.modifiedAt != null,
      },
      'asciiFlow': _generateAsciiFlow(route),
      'generatedAt': DateTime.now().toString().substring(0, 19),
    };
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
}
