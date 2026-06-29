// run_faraid.dart
import 'dart:io';

import 'qonun/deep/eval.dart';
import 'qonun/deep/fully.dart';
import 'qonun/deep/qonun.dart';

void main() {
  // Create engine with enhanced components
  final engine = RuleEngine(
    evaluator: DefaultExpressionEvaluator(),
    executor: DefaultActionExecutor(DefaultExpressionEvaluator()),
  );

  engine.logExecution = true;

  // Load rules
  final yamlText =
      File(
        '/Users/bhangun/Workspace/workkayys/Products/Syirkah/Apps/all_ui/lib/faraid/faraid_rules.yaml',
      ).readAsStringSync();
  engine.loadRulesFromYaml(yamlText);

  // Insert facts
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

  //testCompleteFixedEvaluator();
  testCompleteFixedEvaluator();
  // Execute
  print('\n=== EXECUTING RULES ===');
  engine.fireAll();

  // Results
  print('\n=== RESULTS ===');
  print('Shares: ${engine.getGlobal('shares')}');
  print('Remaining: ${engine.getGlobal('remainingShare')}');
}

void testCompleteFixedEvaluator() {
  print('=== TESTING COMPLETE FIXED EVALUATOR ===');

  final engine = RuleEngine(
    evaluator: RobustExpressionEvaluator(),
    executor: DefaultActionExecutor(RobustExpressionEvaluator()),
  );

  // Add test facts
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

  // Test the problematic conditions
  final evaluator = RobustExpressionEvaluator();
  final context = RuleContext(
    initialFacts: engine.getAllFacts(),
    initialGlobals: {},
  );

  print('\n--- Testing Fixed Conditions ---');
  _testCondition(
    evaluator,
    context,
    'facts.FamilyMember.where(relationName=="deceased" and genderName=="male").count >= 1',
  );
  _testCondition(
    evaluator,
    context,
    'facts.FamilyMember.where(relationName=="spouse" and genderName=="female" and isDeceased==false).count >= 1',
  );
  _testCondition(
    evaluator,
    context,
    'facts.FamilyMember.where(relationName=="son" or relationName=="daughter").count > 0',
  );

  // Now test with actual rules
  print('\n--- Testing with Actual Rules ---');
  final testYaml = '''
rules:
  - name: "Wife With Children"
    group: "fixed-shares"
    salience: 200
    no_loop: true
    when:
      - 'facts.FamilyMember.where(relationName=="deceased" and genderName=="male").count >= 1'
      - 'facts.FamilyMember.where(relationName=="spouse" and genderName=="female" and isDeceased==false).count >= 1'
      - 'facts.FamilyMember.where(relationName=="son" or relationName=="daughter").count > 0'
    then:
      - log: "Wife With Children rule FIRED!"
      - assignShare:
          heir: "wife"
          share: "1/8"

  - name: "Father With Children"
    group: "fixed-shares"
    salience: 180
    no_loop: true
    when:
      - 'facts.FamilyMember.where(relationName=="father" and isDeceased==false).count >= 1'
      - 'facts.FamilyMember.where(relationName=="son" or relationName=="daughter").count > 0'
    then:
      - log: "Father With Children rule FIRED!"
      - assignShare:
          heir: "father"
          share: "1/6"
''';

  engine.loadRulesFromYaml(testYaml);
  engine.fireAll();

  print('\n=== RESULTS ===');
  print('Shares: ${engine.getGlobal('shares')}');
  print('Remaining: ${engine.getGlobal('remainingShare')}');
}

void _testCondition(
  ExpressionEvaluator evaluator,
  RuleContext context,
  String condition,
) {
  final result = evaluator.evalCondition(condition, context);
  print('Condition: "$condition" = $result');
}

void testFullyFixed() {
  print('=== TESTING FULLY FIXED VERSION ===');

  final engine = RuleEngine(
    evaluator: FullyFixedExpressionEvaluator(),
    executor: DefaultActionExecutor(FullyFixedExpressionEvaluator()),
  );

  // Add test facts
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

  // Test the problematic OR condition
  final evaluator = FullyFixedExpressionEvaluator();
  final context = RuleContext(
    initialFacts: engine.getAllFacts(),
    initialGlobals: {},
  );

  print('--- Testing OR Condition ---');
  final condition =
      'facts.FamilyMember.where(relationName=="son" or relationName=="daughter").count > 0';
  final result = evaluator.evalCondition(condition, context);
  print('Condition: "$condition" = $result');

  // Test with the original YAML rules
  print('\n--- Testing with Original YAML Rules ---');
  final originalYaml = '''
rules:
  - name: "Wife With Children"
    group: "fixed-shares"
    salience: 200
    no_loop: true
    when:
      - 'facts.FamilyMember.where(relationName=="deceased" and genderName=="male").count >= 1'
      - 'facts.FamilyMember.where(relationName=="spouse" and genderName=="female" and isDeceased==false).count >= 1'
      - 'facts.FamilyMember.where(relationName=="son" or relationName=="daughter").count > 0'
    then:
      - log: "Wife With Children rule FIRED!"
      - assignShare:
          heir: "wife"
          share: "1/8"
      - log: "Wife gets 1/8 because children exist"
''';

  engine.loadRulesFromYaml(originalYaml);
  engine.fireAll();

  print('\n=== FINAL RESULTS ===');
  print('Shares: ${engine.getGlobal('shares')}');
  print('Remaining: ${engine.getGlobal('remainingShare')}');
}
