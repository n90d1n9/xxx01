// faraid_hooks.dart

import '../../qonun/old/qonun.dart';

void registerFaraidHooks(RuleEngine engine) {
  engine.setGlobal('shares', <String, dynamic>{});
  engine.setGlobal('remainingShare', 1.0); // whole estate = 1.0

  engine.registerHook('assign_spouse_with_children', (RuleEngine eng, [args]) {
    // Wife gets 1/8
    final shares = eng.getGlobal('shares') as Map<String, dynamic>;
    shares['spouse'] = (shares['spouse'] ?? 0) + (1 / 8);
    final rem = eng.getGlobal('remainingShare') as num;
    eng.setGlobal('remainingShare', rem - (1 / 8));
  });

  engine.registerHook('assign_spouse_without_children', (
    RuleEngine eng, [
    args,
  ]) {
    final shares = eng.getGlobal('shares') as Map<String, dynamic>;
    shares['spouse'] = (shares['spouse'] ?? 0) + (1 / 4);
    final rem = eng.getGlobal('remainingShare') as num;
    eng.setGlobal('remainingShare', rem - (1 / 4));
  });

  engine.registerHook('assign_husband_with_children', (RuleEngine eng, [args]) {
    final shares = eng.getGlobal('shares') as Map<String, dynamic>;
    shares['spouse'] = (shares['spouse'] ?? 0) + (1 / 4);
    final rem = eng.getGlobal('remainingShare') as num;
    eng.setGlobal('remainingShare', rem - (1 / 4));
  });

  engine.registerHook('assign_husband_without_children', (
    RuleEngine eng, [
    args,
  ]) {
    final shares = eng.getGlobal('shares') as Map<String, dynamic>;
    shares['spouse'] = (shares['spouse'] ?? 0) + (1 / 2);
    final rem = eng.getGlobal('remainingShare') as num;
    eng.setGlobal('remainingShare', rem - (1 / 2));
  });

  engine.registerHook('assign_mother_one_sixth', (RuleEngine eng, [args]) {
    final shares = eng.getGlobal('shares') as Map<String, dynamic>;
    shares['mother'] = (shares['mother'] ?? 0) + (1 / 6);
    final rem = eng.getGlobal('remainingShare') as num;
    eng.setGlobal('remainingShare', rem - (1 / 6));
  });

  engine.registerHook('assign_mother_one_third', (RuleEngine eng, [args]) {
    final shares = eng.getGlobal('shares') as Map<String, dynamic>;
    shares['mother'] = (shares['mother'] ?? 0) + (1 / 3);
    final rem = eng.getGlobal('remainingShare') as num;
    eng.setGlobal('remainingShare', rem - (1 / 3));
  });

  engine.registerHook('assign_father_one_sixth', (RuleEngine eng, [args]) {
    final shares = eng.getGlobal('shares') as Map<String, dynamic>;
    shares['father'] = (shares['father'] ?? 0) + (1 / 6);
    final rem = eng.getGlobal('remainingShare') as num;
    eng.setGlobal('remainingShare', rem - (1 / 6));
  });

  engine.registerHook('assign_single_daughter_half', (RuleEngine eng, [args]) {
    final shares = eng.getGlobal('shares') as Map<String, dynamic>;
    shares['daughter'] = (shares['daughter'] ?? 0) + (1 / 2);
    final rem = eng.getGlobal('remainingShare') as num;
    eng.setGlobal('remainingShare', rem - (1 / 2));
  });

  engine.registerHook('assign_multiple_daughters_two_thirds', (
    RuleEngine eng, [
    args,
  ]) {
    final shares = eng.getGlobal('shares') as Map<String, dynamic>;
    shares['daughter'] = (shares['daughter'] ?? 0) + (2 / 3);
    final rem = eng.getGlobal('remainingShare') as num;
    eng.setGlobal('remainingShare', rem - (2 / 3));
  });

  // placeholder for compute_remaining_share_programmatic
  engine.registerHook('compute_remaining_share_programmatic', (
    RuleEngine eng, [
    args,
  ]) {
    // everything assigned so far in global.shares, remainingShare already tracked
    // In complex cases, recompute from shares map if needed.
  });

  engine.registerHook('distribute_residual_to_children', (
    RuleEngine eng, [
    args,
  ]) {
    final rem = eng.getGlobal('remainingShare') as num;
    if (rem <= 0) return;
    final sons = eng.getFactsByType(
      'FamilyMember',
      predicate: 'relationName=="son" and isDeceased==false',
    );
    final daughters = eng.getFactsByType(
      'FamilyMember',
      predicate: 'relationName=="daughter" and isDeceased==false',
    );
    final totalUnits = sons.length * 2 + daughters.length * 1;
    if (totalUnits == 0) return;
    final perUnit = rem / totalUnits;
    final shares = eng.getGlobal('shares') as Map<String, dynamic>;
    for (var s in sons) {
      final id = s.data['id'] ?? s.data['name'] ?? 'son';
      shares[id] = (shares[id] ?? 0) + perUnit * 2;
    }
    for (var d in daughters) {
      final id = d.data['id'] ?? d.data['name'] ?? 'daughter';
      shares[id] = (shares[id] ?? 0) + perUnit;
    }
    eng.setGlobal('remainingShare', 0);
  });

  engine.registerHook('assign_residual_to_father', (RuleEngine eng, [args]) {
    final rem = eng.getGlobal('remainingShare') as num;
    if (rem <= 0) return;
    final shares = eng.getGlobal('shares') as Map<String, dynamic>;
    shares['father'] = (shares['father'] ?? 0) + rem;
    eng.setGlobal('remainingShare', 0);
  });

  engine.registerHook('apply_awl_programmatic', (RuleEngine eng, [args]) {
    // AWL: if fixed shares exceed estate, scale them proportionally.
    // Sum fixed shares, if >1 scale them to 1. Implementation is domain-specific.
    final shares = eng.getGlobal('shares') as Map<String, dynamic>;
    double total = 0.0;
    shares.forEach((k, v) {
      if (v is num) total += v.toDouble();
    });
    if (total > 1.0 && total > 0) {
      final scale = 1.0 / total;
      shares.forEach((k, v) {
        shares[k] = (v as num).toDouble() * scale;
      });
      eng.setGlobal('remainingShare', 0.0);
    }
  });

  engine.registerHook('apply_radd_programmatic', (RuleEngine eng, [args]) {
    // Radd: if remainingShare > 0, some schools add it back to eligible heirs proportionally.
    // Very domain specific: here we simply attempt to add remainingShare proportionally to fixed-share holders (excluding spouse maybe)
    final rem = eng.getGlobal('remainingShare') as num;
    if (rem <= 0) return;
    final shares = eng.getGlobal('shares') as Map<String, dynamic>;
    double totalFixed = 0.0;
    shares.forEach((k, v) {
      if (v is num) totalFixed += v.toDouble();
    });
    if (totalFixed <= 0) return;
    shares.forEach((k, v) {
      final add = (v as num).toDouble() / totalFixed * rem;
      shares[k] = (shares[k] ?? 0) + add;
    });
    eng.setGlobal('remainingShare', 0.0);
  });

  engine.registerHook('finish', (RuleEngine eng, [args]) {
    // optional finalization
    eng.setGlobal('calculationFinishedAt', DateTime.now().toIso8601String());
  });
}
