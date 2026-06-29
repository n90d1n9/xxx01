// yaml_loader.dart
import 'package:yaml/yaml.dart';
import 'rule_engine.dart';

class YamlRuleLoader {
  static List<Rule> load(String yamlString) {
    final doc = loadYaml(yamlString);
    final rules = <Rule>[];

    if (doc == null) return rules;
    final rulesNode = doc['rules'];
    if (rulesNode == null) return rules;

    for (var r in rulesNode) {
      rules.add(
        Rule(
          name: r['name'],
          group: r['group'] ?? 'default',
          salience: r['salience'] ?? 0,
          noLoop: r['no_loop'] ?? false,
          when: (r['when'] ?? []).cast<dynamic>().toList(),
          then: (r['then'] ?? []).cast<dynamic>().toList(),
        ),
      );
    }

    return rules;
  }
}
