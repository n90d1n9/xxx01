// ============================================================================
// IMPROVED EXAMPLE USAGE
// ============================================================================

import 'dart:math';

import 'services/engine5.dart';
import 'dart:io';

Future<void> testDrlContent(String drlContent, String testName) async {
  print('\n--- Testing: $testName ---');
  print('-' * 40);

  final engine = RuleEngine();
  engine.logExecution = true;

  final shares = <String, double>{};
  final reasons = <String, String>{};
  final executionLog = <String>[];

  engine.setGlobal('shares', shares);
  engine.setGlobal('reasons', reasons);
  engine.setGlobal('executionLog', executionLog);

  try {
    // First, let's manually check what's in the DRL content
    print('\n📄 DRL CONTENT ANALYSIS:');
    print('First 500 chars of DRL:');
    print(drlContent.substring(0, min(500, drlContent.length)));

    // Check if it contains rule definitions
    if (!drlContent.contains('rule ')) {
      print('❌ No "rule " keyword found in DRL!');
      return;
    }

    // Count rules
    final ruleCount = RegExp(r'rule\s+"[^"]+"').allMatches(drlContent).length;
    print('Found $ruleCount rule definitions by regex');

    final stopwatch = Stopwatch()..start();
    final rules = DrlParser.parse(drlContent);
    stopwatch.stop();

    print(
      '\n✅ Parsing result: ${rules.length} rules parsed in ${stopwatch.elapsedMilliseconds}ms',
    );

    // DEBUG: Check what was actually parsed
    if (rules.isEmpty) {
      print('\n❌ NO RULES PARSED! Checking why...');

      // Let's try to manually parse one rule to see what's wrong
      final firstRuleMatch = RegExp(
        r'rule\s+"[^"]+"(.|\n)*?end',
      ).firstMatch(drlContent);
      if (firstRuleMatch != null) {
        print('First rule block found:');
        print(firstRuleMatch.group(0));
      } else {
        print('No complete rule blocks found (rule...end)');
      }
    } else {
      print('\n📝 PARSED RULES DETAIL:');
      for (final rule in rules) {
        print('  ${rule.name}:');
        print('    Patterns: ${rule.when.length}');
        for (final pattern in rule.when) {
          print('      - ${pattern.alias}:${pattern.type}');
          print('        Constraints: ${pattern.constraints.length}');
          for (final constraint in pattern.constraints) {
            print(
              '          ${constraint.field} ${constraint.operator} ${constraint.value}',
            );
          }
        }
      }
    }

    engine.addRules(rules);

    if (rules.isNotEmpty) {
      engine.setFocus('fixed-shares');
    }

    // Test with sample facts
    final testFacts = [
      Fact('FamilyMember', {
        'id': 'deceased1',
        'name': 'Ahmad',
        'relationName': 'deceased',
        'genderName': 'male',
        'isDeceased': true,
      }),
      Fact('FamilyMember', {
        'id': 'son1',
        'name': 'Ali',
        'relationName': 'son',
        'genderName': 'male',
        'isDeceased': false,
      }),
      Fact('FamilyMember', {
        'id': 'daughter1',
        'name': 'Aisha',
        'relationName': 'daughter',
        'genderName': 'female',
        'isDeceased': false,
      }),
    ];

    for (final fact in testFacts) {
      engine.insert(fact);
      print(
        'Inserted: ${fact["name"]} - relation: ${fact["relationName"]}, isDeceased: ${fact["isDeceased"]}',
      );
    }

    final fireStopwatch = Stopwatch()..start();
    engine.fireAllRules();
    fireStopwatch.stop();

    print('\n📊 Execution Results:');
    print('  - Shares calculated: ${shares.length}');
    print('  - Execution log entries: ${executionLog.length}');

    if (shares.isNotEmpty) {
      print('\n💼 Inheritance Shares:');
      shares.forEach((id, share) {
        final allFacts = engine.getAllFacts();
        final fact = allFacts.firstWhere((f) => f['id'] == id);
        print(
          '  - ${fact['name']} (${fact['relationName']}): ${(share * 100).toStringAsFixed(1)}% - ${reasons[id]}',
        );
      });
    }
  } catch (e, stack) {
    print('❌ Error: $e');
    print('Stack trace: $stack');
  }
}

void main() async {
  print('=== Testing DRL File Loading ===\n');

  //testMinimalDrl();

  //testFixedDrl();

  //testCleanDrl();

  //testAbsoluteMinimalDrl();
  // Method 1A: Load from file system
  await testDrlFromFile(
    '/Users/bhangun/Workspace/workkayys/Products/Syirkah/Apps/all_ui/assets/rules/faraid_rules.drl',
  );
}

Future<void> testDrlFromFile(String filePath) async {
  print('--- Testing DRL from File: $filePath ---');

  try {
    final file = File(filePath);
    if (await file.exists()) {
      final drlContent = await file.readAsString();

      // First, let's examine the exact content around the first rule's when section
      print('\n📁 EXACT FILE CONTENT ANALYSIS:');

      // Find the first rule's when section
      final firstWhenIndex = drlContent.indexOf('when');
      if (firstWhenIndex != -1) {
        // Find the then section after when
        final thenIndex = drlContent.indexOf('then', firstWhenIndex);
        if (thenIndex != -1) {
          final whenSection = drlContent.substring(firstWhenIndex, thenIndex);
          print('First when section content:');
          print('---');
          print(whenSection);
          print('---');

          // Check for specific characters
          print('Contains r\\\$: ${whenSection.contains(r'$')}');
          print('Contains \\\$: ${whenSection.contains('\$')}');
          print(
            'Contains actual \$ character: ${whenSection.contains(RegExp(r'[^\\]\$'))}',
          );
        }
      }

      await testDrlContent(drlContent, 'File: $filePath');
    } else {
      print('❌ File not found: $filePath');
    }
  } catch (e) {
    print('❌ Error reading file: $e');
  }
}
