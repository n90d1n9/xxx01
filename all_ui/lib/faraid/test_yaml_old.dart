// run_faraid.dart
import 'dart:io';

import 'qonun/old/qonun.dart';
import 'services/old/faraid_register.dart';

void main() {
  final engine = RuleEngine();
  engine.logExecution = true;

  // register hooks
  registerFaraidHooks(engine);

  // load YAML rules (you provided the YAML)
  final yamlText =
      File(
        '/Users/bhangun/Workspace/workkayys/Products/Syirkah/Apps/all_ui/lib/faraid/faraid_rules.yaml',
      ).readAsStringSync();
  engine.loadRulesFromYamlString(yamlText);

  // insert facts: sample deceased male with spouse and children
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
      'relationName': 'spouse',
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

  // fire
  engine.fireAll();

  print('Shares: ${engine.getGlobal('shares')}');
  print('Remaining: ${engine.getGlobal('remainingShare')}');
  print('Log: ${engine.getGlobal('executionLog')}');
}
