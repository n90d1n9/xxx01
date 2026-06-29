import '../generator/camel_xml_generator.dart';
import '../generator/camel_yaml_generator.dart';
import '../generator/flutter_generator.dart';
import '../generator/nodejs_generator.dart';
import '../generator/python_generator.dart';
import '../generator/springboot_generator.dart';
import 'code_generator.dart';
import 'template_engine.dart';

class CodeGeneratorFactory {
  static CodeGenerator create({
    required String type,
    required String templateDirectory,
    required String outputDirectory,
  }) {
    final templateEngine = TemplateEngine(templateDirectory: templateDirectory);

    switch (type.toLowerCase()) {
      case 'camel_xml':
        return CamelXmlGenerator(
          templateEngine: templateEngine,
          outputDirectory: outputDirectory,
        );
      case 'camel_yaml':
        return CamelYamlGenerator(
          templateEngine: templateEngine,
          outputDirectory: outputDirectory,
        );
      case 'flutter':
        return FlutterGenerator(
          templateEngine: templateEngine,
          outputDirectory: outputDirectory,
        );
      case 'spring_boot':
        return SpringBootGenerator(
          templateEngine: templateEngine,
          outputDirectory: outputDirectory,
        );
      case 'nodejs':
        return NodeJsGenerator(
          templateEngine: templateEngine,
          outputDirectory: outputDirectory,
        );
      case 'python':
        return PythonGenerator(
          templateEngine: templateEngine,
          outputDirectory: outputDirectory,
        );
      default:
        throw Exception('Unknown generator type: $type');
    }
  }
}
