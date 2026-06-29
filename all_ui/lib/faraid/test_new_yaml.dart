import 'dart:io';

import 'qonun/new/core.dart';
import 'qonun/new/rule_engine.dart';

import 'qonun/new/yaml_rule_loader.dart';
import 'services/faraid_action_registry.dart';

void main(List<String> args) {
  print('=== Faraid Rule Engine Demo ===');

  // 1) Load YAML rules
  final yamlPath =
      '/Users/bhangun/Workspace/workkayys/Products/Syirkah/Apps/all_ui/lib/faraid/faraid_rules.yaml';
  if (!File(yamlPath).existsSync()) {
    print('ERROR: $yamlPath not found.');
    return;
  }

  final yamlText = File(yamlPath).readAsStringSync();
  List<Rule> rules;
  try {
    rules = YamlRuleLoader.load(yamlText);
  } catch (e, st) {
    print('Failed to load/validate YAML rules: $e\n$st');
    return;
  }

  print('Loaded ${rules.length} rules');

  // 2) Create engine with Faraid actions
  final engine = RuleEngine(
    initialGlobals: {
      'totalEstate': 120000000,
      'shares': <String, dynamic>{},
      'remainingShare': 1.0,
    },
    additionalRegistries: [FaraidActionRegistry()],
  );

  // 3) Add rules to engine
  engine.addRules(rules); // Use addRules instead of loadRules

  // 4) Insert facts
  engine.insert(
    Fact('FamilyMember', {
      'id': 'deceased1',
      'name': 'Ahmad',
      'relationName': 'deceased',
      'genderName': 'male',
      'isDeceased': true,
    }),
  );

  engine.insert(
    Fact('FamilyMember', {
      'id': 'wife1',
      'name': 'Aisha',
      'relationName': 'wife', // Changed from 'spouse' to 'wife'
      'genderName': 'female',
      'isDeceased': false,
    }),
  );

  engine.insert(
    Fact('FamilyMember', {
      'id': 'son1',
      'name': 'Ali',
      'relationName': 'son',
      'genderName': 'male',
      'isDeceased': false,
    }),
  );

  // 5) Pre-calculate counts for the expressions in YAML
  final wifeCount =
      engine.getAllFacts().where((f) => f['relationName'] == 'wife').length;
  final daughterCount =
      engine.getAllFacts().where((f) => f['relationName'] == 'daughter').length;
  final sonCount =
      engine.getAllFacts().where((f) => f['relationName'] == 'son').length;

  engine.setGlobal('wifeCount', wifeCount);
  engine.setGlobal('daughterCount', daughterCount);
  engine.setGlobal('sonCount', sonCount);

  print('Counts - Wife: $wifeCount, Daughter: $daughterCount, Son: $sonCount');

  // 6) Enable logging and fire rules
  engine.logExecution = true;
  engine.fireAll();

  // 7) Print results
  print('\n=== RESULTS ===');
  print('shares: ${engine.getGlobal('shares')}');
  print('remainingShare: ${engine.getGlobal('remainingShare')}');

  print('\n=== EXECUTION LOG ===');
  for (final line in engine.getExecutionLog()) {
    print(line);
  }

  print('\n=== DONE ===');
}
