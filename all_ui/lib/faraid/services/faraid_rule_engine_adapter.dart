// faraid/faraid_rule_engine_adapter.dart

import 'package:flutter/services.dart';

import '../models/estate.dart';
import '../models/family_member.dart';
import '../models/relation_type.dart';
import '../qonun/new/core.dart';
import '../qonun/new/rule_engine.dart';
import '../qonun/new/yaml_rule_loader.dart';
import 'faraid_action_registry.dart';

class FaraidRuleEngineAdapter {
  final RuleEngine _engine;
  List<Rule>? _rules;

  FaraidRuleEngineAdapter()
    : _engine = RuleEngine(
        initialGlobals: {'shares': <String, dynamic>{}, 'remainingShare': 1.0},
        additionalRegistries: [FaraidActionRegistry()],
      );

  Future<void> _ensureRulesLoaded() async {
    if (_rules == null) {
      _rules = await _loadRules();
    }
  }

  static Future<List<Rule>> _loadRules() async {
    try {
      const yamlPath = 'assets/rules/faraid_rules.yaml';
      final yamlText = await rootBundle.loadString(yamlPath);
      return YamlRuleLoader.load(yamlText);
    } catch (e) {
      print('Error loading Faraid rules: $e');
      return [];
    }
  }

  Future<FaraidCalculationResult> calculate({
    required FamilyMember deceased,
    required List<FamilyMember> heirs,
    required Estate estate,
    required String method,
  }) async {
    // Ensure rules are loaded first
    await _ensureRulesLoaded();

    // RESET EVERYTHING - Clear all state
    _engine.clearFacts();
    _engine.clearRules();
    _engine.addRules(_rules!);

    // Reset all rule fired states
    for (final rule in _rules!) {
      rule.hasFired = false;
    }

    // Set initial globals - including reset flag
    _engine.setGlobal('calculationReset', true);
    _engine.setGlobal('netEstate', estate.netEstate);
    _engine.setGlobal('calculationMethod', method);

    // Add deceased as fact
    _engine.insert(Fact('Deceased', deceased.toFactMap()));

    // Add heirs as facts
    for (final heir in heirs) {
      _engine.insert(Fact('Heir', heir.toFactMap()));
    }

    // Add estate information
    _engine.insert(
      Fact('Estate', {
        'netValue': estate.netEstate,
        'totalAssets': estate.totalAssets,
        'totalDebts': estate.totalDebts,
        'totalExpenses': estate.totalExpenses,
      }),
    );

    // Calculate counts for simplified expressions
    _calculateCounts(heirs);

    // Execute rules with MAX iterations
    _engine.logExecution = true;
    _engine.maxIterations = 50; // Increase to handle multiple rule passes
    _engine.fireAll();

    // Extract results
    return _extractResults(heirs);
  }

  void _calculateCounts(List<FamilyMember> heirs) {
    final wifeCount =
        heirs
            .where(
              (h) =>
                  h.relation == RelationType.spouse &&
                  h.gender == Gender.female,
            )
            .length;
    final husbandCount =
        heirs
            .where(
              (h) =>
                  h.relation == RelationType.spouse && h.gender == Gender.male,
            )
            .length;
    final daughterCount =
        heirs.where((h) => h.relation == RelationType.daughter).length;
    final sonCount = heirs.where((h) => h.relation == RelationType.son).length;
    final fatherCount =
        heirs.where((h) => h.relation == RelationType.father).length;
    final motherCount =
        heirs.where((h) => h.relation == RelationType.mother).length;

    _engine.setGlobal('wifeCount', wifeCount);
    _engine.setGlobal('husbandCount', husbandCount);
    _engine.setGlobal('daughterCount', daughterCount);
    _engine.setGlobal('sonCount', sonCount);
    _engine.setGlobal('fatherCount', fatherCount);
    _engine.setGlobal('motherCount', motherCount);

    print('=== HEIR COUNTS ===');
    print('Wives: $wifeCount, Husbands: $husbandCount');
    print('Daughters: $daughterCount, Sons: $sonCount');
    print('Fathers: $fatherCount, Mothers: $motherCount');
  }

  FaraidCalculationResult _extractResults(List<FamilyMember> heirs) {
    final shares = _engine.getGlobal('shares') as Map<String, dynamic>? ?? {};
    final remainingShare = _engine.getGlobal('remainingShare') ?? 0.0;
    final executionLog = _engine.getExecutionLog();

    // DEBUG: Print what shares we found
    print('=== DEBUG: ACTUAL SHARES CALCULATED ===');
    shares.forEach((key, value) {
      print('  $key: $value');
    });
    print('Remaining: $remainingShare');
    print('Total assigned: ${_calculateTotal(shares)}');
    print('=== END DEBUG ===');

    final resultShares = <String, double>{};
    final resultReasons = <String, String>{};

    // Distribute shares to individual heirs
    for (final heir in heirs) {
      final shareKey = _getShareKey(heir);
      final shareValue = shares[shareKey];
      final heirCount = _getHeirCount(shareKey, heirs);

      if (shareValue is num && heirCount > 0) {
        // Divide the share equally among heirs of this type
        final individualShare = shareValue.toDouble() / heirCount;
        resultShares[heir.id] = individualShare;
        resultReasons[heir.id] = _getReasonForShare(
          heir,
          individualShare,
          shareValue,
        );
      } else {
        resultShares[heir.id] = 0.0;
        resultReasons[heir.id] = 'Tidak mendapatkan bagian';
      }
    }

    return FaraidCalculationResult(
      shares: resultShares,
      reasons: resultReasons,
      executedRules: executionLog,
      statistics: {
        'totalRules': _rules?.length ?? 0,
        'totalFacts': heirs.length + 2,
        'remainingShare': remainingShare,
      },
    );
  }

  double _calculateTotal(Map<String, dynamic> shares) {
    double total = 0.0;
    shares.forEach((key, value) {
      if (value is num) total += value.toDouble();
    });
    return total;
  }

  int _getHeirCount(String shareKey, List<FamilyMember> heirs) {
    switch (shareKey) {
      case 'son':
        return heirs.where((h) => h.relation == RelationType.son).length;
      case 'daughter':
        return heirs.where((h) => h.relation == RelationType.daughter).length;
      case 'wife':
        return heirs
            .where(
              (h) =>
                  h.relation == RelationType.spouse &&
                  h.gender == Gender.female,
            )
            .length;
      case 'husband':
        return heirs
            .where(
              (h) =>
                  h.relation == RelationType.spouse && h.gender == Gender.male,
            )
            .length;
      default:
        return 1;
    }
  }

  String _getShareKey(FamilyMember heir) {
    switch (heir.relation) {
      case RelationType.spouse:
        return heir.gender == Gender.female ? 'wife' : 'husband';
      case RelationType.son:
        return 'son';
      case RelationType.daughter:
        return 'daughter';
      case RelationType.father:
        return 'father';
      case RelationType.mother:
        return 'mother';
      case RelationType.paternalGrandfather:
        return 'paternalGrandfather';
      case RelationType.paternalGrandmother:
        return 'paternalGrandmother';
      case RelationType.maternalGrandfather:
        return 'maternalGrandfather';
      case RelationType.maternalGrandmother:
        return 'maternalGrandmother';
      case RelationType.brother:
        return 'brother';
      case RelationType.sister:
        return 'sister';
      default:
        return heir.relation.toString().split('.').last;
    }
  }

  // Option 2: Update to accept 3 parameters
  String _getReasonForShare(
    FamilyMember heir,
    num individualShare,
    num totalShareForHeirType,
  ) {
    final shareKey = _getShareKey(heir);
    final individualFraction = _convertToFraction(individualShare.toDouble());
    final totalFraction = _convertToFraction(totalShareForHeirType.toDouble());

    if (totalShareForHeirType > individualShare) {
      return 'Mendapatkan $individualFraction dari total $totalFraction sebagai ${_getRelationName(heir.relation)} (dibagi rata)';
    } else {
      return 'Mendapatkan $individualFraction sebagai ${_getRelationName(heir.relation)}';
    }
  }

  String _convertToFraction(double share) {
    if (share == 0.5) return '1/2';
    if (share == 0.25) return '1/4';
    if (share == 0.125) return '1/8';
    if (share == 0.166) return '1/6';
    if (share == 0.333) return '1/3';
    if (share == 0.666) return '2/3';
    return share.toStringAsFixed(3);
  }

  String _getRelationName(RelationType relation) {
    return relation.toString().split('.').last;
  }
}

class FaraidCalculationResult {
  final Map<String, double> shares;
  final Map<String, String> reasons;
  final List<String> executedRules;
  final Map<String, dynamic> statistics;

  FaraidCalculationResult({
    required this.shares,
    required this.reasons,
    required this.executedRules,
    required this.statistics,
  });
}
