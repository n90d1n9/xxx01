// integration_helpers.dart

import '../qonun/deep/qonun.dart';

void wireCallHook(RuleEngine engine, String callName) {
  // The engine _executeAction currently only logs. Extend to call user hooks:
  // For simplicity: after loading YAML, when parsing actions detect call: "foo"
  // and register a mapping in your app to handle it:
}

// Example hook implementations (in your app)
void assign_spouse_with_children(RuleEngine engine) {
  // 1. Get all FamilyMember facts
  final facts = engine.getFactsByType('FamilyMember') ?? [];

  // 2. Find the spouse (female spouse, alive)
  final spouse = facts.firstWhere(
    (f) =>
        f.get('relationName') == 'spouse' &&
        f.get('genderName') == 'female' &&
        f.get('isDeceased') == false,
    orElse: () => Fact('__null__', {}),
  );

  if (spouse.type == '__null__') return;

  final id = spouse.get('id').toString();

  // 3. Safely get globals (ensures maps/lists exist)
  final shares = engine.getGlobal('shares') as Map? ?? <String, dynamic>{};
  final reasons = engine.getGlobal('reasons') as Map? ?? <String, dynamic>{};
  final log = engine.getGlobal('executionLog') as List? ?? <dynamic>[];

  // Ensure globals are set back (in case they were null initially)
  engine.setGlobal('shares', shares);
  engine.setGlobal('reasons', reasons);
  engine.setGlobal('executionLog', log);

  // 4. Assign share
  shares[id] = 0.125;

  // 5. Assign reason
  reasons[id] = 'Istri mendapat 1/8 (ada anak) - YAML hook';

  // 6. Log execution
  log.add('YAML: Wife gets 1/8 because children exist');
}

// Similarly implement other call hooks: assign_spouse_without_children, ...
