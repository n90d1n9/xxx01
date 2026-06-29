// yaml_loader.dart
import 'package:yaml/yaml.dart';
import 'rule_engine.dart';

class YamlRuleLoader {
  static List<Rule> load(String yamlString) {
    final doc = loadYaml(yamlString);
    final rules = <Rule>[];

    if (doc == null) return rules;

    final rulesNode = doc['rules'];
    if (rulesNode is! List) return rules;

    for (final ruleData in rulesNode) {
      if (ruleData is Map) {
        rules.add(
          Rule(
            name: ruleData['name']?.toString() ?? 'Unnamed Rule',
            group: ruleData['group']?.toString() ?? 'default',
            salience: (ruleData['salience'] as num?)?.toInt() ?? 0,
            noLoop: ruleData['no_loop'] == true,
            when: (ruleData['when'] as List?)?.cast<dynamic>() ?? [],
            then: (ruleData['then'] as List?)?.cast<dynamic>() ?? [],
          ),
        );
      }
    }

    return rules;
  }
}
