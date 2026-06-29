// utils/yaml_converter.dart
import 'package:yaml/yaml.dart';

class YamlConverter {
  /// Convert YamlMap to Map<String, dynamic>
  static Map<String, dynamic> yamlToMap(YamlMap yaml) {
    return _convertYamlNode(yaml) as Map<String, dynamic>;
  }

  /// Convert YamlList to List<dynamic>
  static List<dynamic> yamlToList(YamlList yaml) {
    return _convertYamlNode(yaml) as List<dynamic>;
  }

  static dynamic _convertYamlNode(dynamic node) {
    if (node is YamlMap) {
      final map = <String, dynamic>{};
      for (final key in node.keys) {
        map[key.toString()] = _convertYamlNode(node[key]);
      }
      return map;
    } else if (node is YamlList) {
      return node.map(_convertYamlNode).toList();
    } else if (node is YamlScalar) {
      return node.value;
    } else {
      return node;
    }
  }

  /// Safe YAML loading with conversion
  static Map<String, dynamic> loadYamlToMap(String yamlString) {
    try {
      final yaml = loadYaml(yamlString);
      if (yaml is YamlMap) {
        return yamlToMap(yaml);
      } else {
        return {'content': yaml};
      }
    } catch (e) {
      print('YAML parsing error: $e');
      return {};
    }
  }
}
