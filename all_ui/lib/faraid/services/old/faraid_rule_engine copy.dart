import 'package:queue_ui/faraid/services/utils.dart';

import '../models/estate.dart';
import '../models/family_member.dart';
import '../models/faraid.dart';
import 'engine5.dart';

class FaraidDrlEngine {
  final RuleEngine _engine = RuleEngine();
  bool _debugEnabled = false; // Control debug output

  FaraidDrlEngine() {
    _initializeEngine();
  }

  Future<void> _initializeEngine() async {
    _engine.clearRules();

    // Enable basic logging
    _engine.logExecution = true;

    try {
      // Load and parse DRL file
      final drlContent = await loadDrlFile('assets/rules/faraid_rules.drl');
      final rules = DrlParser.parse(drlContent);
      print('✅ Loaded ${rules.length} rules from DRL file');

      // Add parsed rules
      _engine.addRules(rules);

      // Add a simple debug rule to verify basic functionality
      _addBasicDebugRule();
    } catch (e) {
      print('❌ Error loading DRL rules: $e');
      // Add fallback rules
      _addFallbackRules();
    }

    _addChildrenResidualRule();

    _addBasicDebugRule();

    // Initialize globals
    _engine.setGlobal('shares', <String, double>{});
    _engine.setGlobal('reasons', <String, String>{});
    _engine.setGlobal('executionLog', <String>[]);
    _engine.setGlobal('calculationMethod', 'Hanafi');
    _engine.setGlobal('totalEstate', 1.0);
  }

  void _addBasicDebugRule() {
    final debugRule = Rule(
      name: "Basic Debug Rule",
      salience: 1000,
      when: [
        Pattern(
          'deceased',
          'FamilyMember',
          constraints: [
            Constraint('relationName', Operator.equals, 'deceased'),
          ],
        ),
      ],
      then: (bindings, engine) {
        final deceased = bindings['deceased']!;
        print(
          '🎯 BASIC DEBUG RULE FIRED for deceased: ${deceased.get("name")}',
        );
      },
    );

    _engine.addRule(debugRule);
  }

  void _addFallbackRules() {
    final fallbackRule = Rule(
      name: "Fallback Son Rule",
      salience: 100,
      agendaGroup: "fixed-shares",
      when: [
        Pattern(
          'deceased',
          'FamilyMember',
          constraints: [
            Constraint('relationName', Operator.equals, 'deceased'),
          ],
        ),
        Pattern(
          'son',
          'FamilyMember',
          constraints: [Constraint('relationName', Operator.equals, 'son')],
        ),
      ],
      then: (bindings, engine) {
        final son = bindings['son']!;
        print('✅ FALLBACK RULE: Son ${son.get("name")} gets inheritance');

        final shares = engine.getGlobal('shares') as Map<String, double>;
        shares[son.get('id')] = 1.0;
      },
    );

    _engine.addRule(fallbackRule);
  }

  Future<FaraidResult> calculate({
    required FamilyMember deceased,
    required List<FamilyMember> heirs,
    required Estate estate,
    String method = 'Hanafi',
  }) async {
    _debugFactStructure(heirs);
    _engine.clearFacts();

    // Re-initialize globals with proper types
    _engine.setGlobal('shares', <String, double>{});
    _engine.setGlobal('reasons', <String, String>{});
    _engine.setGlobal('executionLog', <String>[]);
    _engine.setGlobal('calculationMethod', method);
    _engine.setGlobal(
      'totalEstate',
      estate.netValue > 0 ? estate.netValue : 1.0,
    );

    _log('=== CALCULATION STARTED ===');
    _log('Deceased: ${deceased.name}, Gender: ${deceased.gender}');
    _log('Heirs count: ${heirs.length}');
    for (final heir in heirs) {
      _log(
        'Heir: ${heir.name}, Relation: ${heir.relation}, Gender: ${heir.gender}',
      );
    }

    // Insert deceased fact
    final deceasedFact = Fact(
      'FamilyMember',
      _sanitizeFactMap(deceased.toFactMap()),
    );

    _engine.insert(deceasedFact);
    _log('Inserted deceased fact: ${deceasedFact.attributes}');

    // Insert all heirs
    for (final heir in heirs) {
      final raw = Map<String, dynamic>.from(heir.toFactMap());

      // normalize relationName/genderName into plain lowercase strings
      if (raw.containsKey('relation')) {
        raw['relationName'] =
            raw['relation'].toString().split('.').last.toLowerCase();
      }
      if (raw.containsKey('relationName')) {
        raw['relationName'] = raw['relationName'].toString().toLowerCase();
      }
      if (raw.containsKey('gender')) {
        raw['genderName'] =
            raw['gender'].toString().split('.').last.toLowerCase();
      }
      if (raw.containsKey('genderName')) {
        raw['genderName'] = raw['genderName'].toString().toLowerCase();
      }

      // ensure id and isDeceased boolean are primitives
      raw['id'] = raw['id'].toString();
      raw['isDeceased'] = raw['isDeceased'] ?? false;

      final heirFact = Fact('FamilyMember', raw);

      _engine.insert(heirFact);
      _log('Inserted heir fact: ${heirFact.attributes}');
    }

    // Print all facts in working memory for debugging
    _log('Total facts in working memory: ${_engine.getAllFacts().length}');
    for (final fact in _engine.getAllFacts()) {
      _log('Fact: ${fact.type} - ${fact.attributes}');
    }

    // Execute rules in order
    final agendaGroups = [
      'fixed-shares',
      'siblings-shares',
      'residual-calculation',
      'residual-distribution',
      'exclusions',
      'school-specific',
      'validation',
      'completion',
    ];

    // In calculate method, replace the agenda group execution:
    for (final group in agendaGroups) {
      _log('Executing agenda group: $group');
      _engine.setFocus(group);

      // Use fireAllRules instead of fireUntilHalt to prevent infinite loops
      _engine.fireAllRules();

      final log = _engine.getExecutionLog();
      _log('Rules fired in $group: ${log.length}');
    }

    final result = _getResults();

    _log('=== CALCULATION COMPLETED ===');
    _log('Shares calculated: ${result.shares}');
    _log('Reasons: ${result.reasons}');
    _log('Rules executed: ${result.executedRules.length}');

    return result;
  }

  Map<String, dynamic> _sanitizeFactMap(Map<String, dynamic> raw) {
    final m = Map<String, dynamic>.from(raw);

    // Normalize relationName
    if (m.containsKey('relation')) {
      m['relationName'] =
          m['relation'].toString().split('.').last.toLowerCase();
    }
    if (m.containsKey('relationName')) {
      m['relationName'] = m['relationName'].toString().toLowerCase();
    }

    // Normalize genderName
    if (m.containsKey('gender')) {
      m['genderName'] = m['gender'].toString().split('.').last.toLowerCase();
    }
    if (m.containsKey('genderName')) {
      m['genderName'] = m['genderName'].toString().toLowerCase();
    }

    // Always ensure string ID
    m['id'] = m['id'].toString();

    // Default booleans
    m['isDeceased'] = m['isDeceased'] ?? false;

    return m;
  }

  void _addChildrenResidualRule() {
    final rule = Rule(
      name: 'Children Residual Distribution',
      salience: 90,
      agendaGroup: 'residual-distribution',
      noLoop: true,
      when: [
        Pattern(
          'deceased',
          'FamilyMember',
          constraints: [
            Constraint('relationName', Operator.equals, 'deceased'),
          ],
        ),
      ],
      then: (bindings, engine) {
        final remaining = engine.getGlobal('remainingShare') ?? 0.0;
        if ((remaining as num).toDouble() <= 0) return;

        final allFacts = engine.getFactsByType('FamilyMember');

        final sons = allFacts.where(
          (f) => f.get('relationName') == 'son' && f.get('isDeceased') == false,
        );

        final daughters = allFacts.where(
          (f) =>
              f.get('relationName') == 'daughter' &&
              f.get('isDeceased') == false,
        );

        if (sons.isEmpty && daughters.isEmpty) return;

        final shares = engine.getGlobal('shares') as Map<String, dynamic>;
        final execLog = engine.getGlobal('executionLog') as List<String>;

        final units = sons.length * 2 + daughters.length;
        final unitValue = (remaining as num).toDouble() / units;

        for (final s in sons) {
          final id = s.get('id');
          final current = (shares[id] ?? 0).toDouble();
          shares[id] = current + (unitValue * 2);
        }

        for (final d in daughters) {
          final id = d.get('id');
          final current = (shares[id] ?? 0).toDouble();
          shares[id] = current + unitValue;
        }

        execLog.add("Residual distributed to children (2:1).");

        engine.setGlobal('remainingShare', 0.0);
      },
    );

    _engine.addRule(rule);
  }

  FaraidResult _getResults() {
    final sharesDynamic =
        _engine.getGlobal('shares') as Map<dynamic, dynamic>? ?? {};
    final reasonsDynamic =
        _engine.getGlobal('reasons') as Map<dynamic, dynamic>? ?? {};
    final executionLogDynamic =
        _engine.getGlobal('executionLog') as List<dynamic>? ?? [];

    final shares = <String, double>{};
    final reasons = <String, String>{};

    // Safe casting
    sharesDynamic.forEach((key, value) {
      if (key is String) {
        if (value is double) {
          shares[key] = value;
        } else if (value is int) {
          shares[key] = value.toDouble();
        } else if (value is num) {
          shares[key] = value.toDouble();
        }
      }
    });

    reasonsDynamic.forEach((key, value) {
      if (key is String && value is String) {
        reasons[key] = value;
      }
    });

    final executionLog = executionLogDynamic.whereType<String>().toList();

    return FaraidResult(
      shares: shares,
      reasons: reasons,
      executedRules: executionLog,
      statistics: _engine.getStatistics(),
    );
  }

  void _log(String message) {
    // Always print for debugging; guard with _debugEnabled if you want to mute it.
    if (_debugEnabled) {
      print('[FaraidDrlEngine] $message');
    }
    // Also keep it in engine global execution log so rules can read it later:
    final log = _engine.getGlobal('executionLog');
    if (log is List) {
      log.add('[FaraidDrlEngine] $message');
    }
  }

  void _debugFactStructure(List<FamilyMember> heirs) {
    _log('=== FACT STRUCTURE DEBUG ===');
    for (final member in heirs) {
      final factMap = member.toFactMap();
      _log('Member: ${member.name}');
      _log('  relation: ${member.relation}');
      _log('  relationName: ${factMap['relationName']}');
      _log('  gender: ${member.gender}');
      _log('  genderName: ${factMap['genderName']}');
      _log('  isDeceased: ${member.isDeceased}');
      _log('  Full fact: $factMap');
      _log('---');
    }
  }

  void _addDebugMatchingRule() {
    final debugRule = Rule(
      name: "Debug Relation Matching",
      salience: 1000,
      when: [
        Pattern(
          'deceased',
          'FamilyMember',
          constraints: [
            Constraint('relationName', Operator.equals, 'deceased'),
          ],
        ),
        Pattern(
          'son',
          'FamilyMember',
          constraints: [Constraint('relationName', Operator.equals, 'son')],
        ),
      ],
      then: (bindings, engine) {
        final deceased = bindings['deceased']!;
        final son = bindings['son']!;

        _log('🎯 DEBUG RULE FIRED!');
        _log(
          '   Deceased: ${deceased.get("name")} - ${deceased.get("relationName")}',
        );
        _log('   Son: ${son.get("name")} - ${son.get("relationName")}');

        final shares = engine.getGlobal('shares') as Map<String, double>;
        final reasons = engine.getGlobal('reasons') as Map<String, String>;

        shares[son.get('id')] = 1.0;
        reasons[son.get('id')] = 'Debug rule matched successfully!';
      },
    );

    _engine.addRule(debugRule);
    _log('Added debug relation matching rule');
  }

  void _addTestRule() {
    final testRule = Rule(
      name: "Test String Matching",
      salience: 1000,
      when: [
        Pattern(
          'deceased',
          'FamilyMember',
          constraints: [
            Constraint('relationName', Operator.equals, 'deceased'),
          ],
        ),
        Pattern(
          'son',
          'FamilyMember',
          constraints: [Constraint('relationName', Operator.equals, 'son')],
        ),
      ],
      then: (bindings, engine) {
        final deceased = bindings['deceased']!;
        final son = bindings['son']!;
        _log(
          '✅ STRING MATCHING WORKS! Deceased: ${deceased.get("name")}, Son: ${son.get("name")}',
        );

        final shares = engine.getGlobal('shares') as Map<String, double>;
        final reasons = engine.getGlobal('reasons') as Map<String, String>;

        shares[son.get('id')] = 1.0;
        reasons[son.get('id')] = 'Test: String matching works!';
      },
    );

    _engine.addRule(testRule);
  }

  void _addSimplifiedRules() {
    // Simple son-only rule
    final sonRule = Rule(
      name: "Simple Son Inheritance",
      salience: 100,
      agendaGroup: "fixed-shares",
      noLoop: true,
      when: [
        Pattern(
          'deceased',
          'FamilyMember',
          constraints: [
            Constraint('relationName', Operator.equals, 'deceased'),
          ],
        ),
        Pattern(
          'son',
          'FamilyMember',
          constraints: [Constraint('relationName', Operator.equals, 'son')],
        ),
        Pattern(
          'noSpouse',
          'FamilyMember',
          constraints: [
            Constraint('relationName', Operator.equals, 'spouse'),
            Constraint('isDeceased', Operator.equals, true),
          ],
          customPredicate: (fact, bindings) {
            // This pattern should NOT match (no spouse exists)
            return false;
          },
        ),
      ],
      then: (bindings, engine) {
        final son = bindings['son']!;

        _log('✅ SIMPLE SON RULE FIRED!');

        final shares = engine.getGlobal('shares') as Map<String, double>;
        final reasons = engine.getGlobal('reasons') as Map<String, String>;

        shares[son.get('id')] = 1.0;
        reasons[son.get('id')] = 'Anak laki-laki mendapatkan semua warisan';

        final log = engine.getGlobal('executionLog') as List<String>;
        log.add('SimpleSonRule: ${son.get("name")} gets all inheritance');
      },
    );

    _engine.addRule(sonRule);
  }

  void _addRelationNameTestRule() {
    final testRule = Rule(
      name: "RelationName Field Test",
      salience: 1000,
      when: [
        Pattern(
          'deceased',
          'FamilyMember',
          constraints: [
            Constraint('relationName', Operator.equals, 'deceased'),
          ],
        ),
        Pattern(
          'son',
          'FamilyMember',
          constraints: [Constraint('relationName', Operator.equals, 'son')],
        ),
      ],
      then: (bindings, engine) {
        final deceased = bindings['deceased']!;
        final son = bindings['son']!;

        _log('🎯 RELATIONNAME TEST SUCCESS!');
        _log('   Deceased relationName: ${deceased.get("relationName")}');
        _log('   Son relationName: ${son.get("relationName")}');

        final shares = engine.getGlobal('shares') as Map<String, double>;
        final reasons = engine.getGlobal('reasons') as Map<String, String>;

        shares[son.get('id')] = 1.0;
        reasons[son.get('id')] = 'RelationName field test passed!';
      },
    );

    _engine.addRule(testRule);
    _log('Added relationName field test rule');
  }
}
