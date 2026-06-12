import '../models/component_type.dart';
import '../models/design_component.dart';

class CodeGenerator {
  static String generate(String framework, List<DesignComponent> components) {
    switch (framework) {
      case 'Flutter':
        return _generateFlutter(components);
      case 'React':
        return _generateReact(components);
      case 'Vue.js':
        return _generateVue(components);
      case 'HTML/CSS':
        return _generateHTML(components);
      case 'Jinja2 Template':
        return _generateJinja2(components);
      case 'Mustache Template':
        return _generateMustache(components);
      default:
        return '// Framework not supported';
    }
  }

  static String _generateFlutter(List<DesignComponent> components) {
    final buffer = StringBuffer();
    buffer.writeln('import \'package:flutter/material.dart\';');
    buffer.writeln('');
    buffer.writeln('class GeneratedPage extends StatelessWidget {');
    buffer.writeln('  const GeneratedPage({Key? key}) : super(key: key);');
    buffer.writeln('');
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln('    return Scaffold(');
    buffer.writeln('      body: Stack(');
    buffer.writeln('        children: [');

    final sorted = List<DesignComponent>.from(components)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    for (var component in sorted) {
      buffer.writeln('          Positioned(');
      buffer.writeln(
        '            left: ${component.position.dx.toStringAsFixed(1)},',
      );
      buffer.writeln(
        '            top: ${component.position.dy.toStringAsFixed(1)},',
      );
      buffer.writeln(
        '            child: ${_generateFlutterWidget(component)},',
      );
      buffer.writeln('          ),');
    }

    buffer.writeln('        ],');
    buffer.writeln('      ),');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  static String _generateFlutterWidget(DesignComponent component) {
    switch (component.type) {
      case ComponentType.text:
        return 'Text(\'${component.properties['text']}\', style: TextStyle(fontSize: ${component.properties['fontSize']}, color: Color(${component.properties['color']})))';
      case ComponentType.button:
        return 'ElevatedButton(onPressed: () {}, child: Text(\'${component.properties['text']}\'))';
      case ComponentType.container:
        return 'Container(width: ${component.size.width}, height: ${component.size.height}, decoration: BoxDecoration(color: Color(${component.properties['backgroundColor']}), borderRadius: BorderRadius.circular(${component.properties['borderRadius']})))';
      case ComponentType.icon:
        return 'Icon(Icons.${component.properties['icon']}, size: ${component.properties['size']}, color: Color(${component.properties['color']}))';
      default:
        return 'Container()';
    }
  }

  static String _generateReact(List<DesignComponent> components) {
    final buffer = StringBuffer();
    buffer.writeln('import React from \'react\';');
    buffer.writeln('');
    buffer.writeln('const GeneratedPage = () => {');
    buffer.writeln('  return (');
    buffer.writeln(
      '    <div style={{ position: \'relative\', width: \'100%\', minHeight: \'100vh\' }}>',
    );

    for (var component in components) {
      buffer.writeln(
        '      <div style={{ position: \'absolute\', left: \'${component.position.dx}px\', top: \'${component.position.dy}px\' }}>',
      );
      buffer.writeln('        {/* ${component.type.name} */}');
      buffer.writeln('      </div>');
    }

    buffer.writeln('    </div>');
    buffer.writeln('  );');
    buffer.writeln('};');
    buffer.writeln('');
    buffer.writeln('export default GeneratedPage;');

    return buffer.toString();
  }

  static String _generateVue(List<DesignComponent> components) {
    return '<template>\n  <div class="container">\n    <!-- Components here -->\n  </div>\n</template>';
  }

  static String _generateHTML(List<DesignComponent> components) {
    return '<!DOCTYPE html>\n<html>\n<head>\n  <title>Generated Page</title>\n</head>\n<body>\n  <!-- Components here -->\n</body>\n</html>';
  }

  static String _generateJinja2(List<DesignComponent> components) {
    return '{% extends "base.html" %}\n{% block content %}\n  <!-- Components here -->\n{% endblock %}';
  }

  static String _generateMustache(List<DesignComponent> components) {
    return '{{#components}}\n  <div>{{name}}</div>\n{{/components}}';
  }
}
