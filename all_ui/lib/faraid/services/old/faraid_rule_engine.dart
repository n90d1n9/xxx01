// patched_faraid_engine.dart
import 'dart:async';
import '../models/estate.dart';
import '../models/family_member.dart';
import '../models/faraid.dart';
import 'engine5.dart';
import 'utils.dart';

class FaraidDrlEngine {
  final RuleEngine _engine = RuleEngine();
  final bool debugMode;
  bool _rulesLoaded = false;

  FaraidDrlEngine({this.debugMode = false}) {
    _initializeEngine();
  }

  Future<void> _initializeEngine() async {
    if (!_rulesLoaded) {
      _engine.clearRules();
      _engine.logExecution = true;

      try {
        final drl = await loadDrlFile('assets/rules/faraid_rules_patched.drl');
        final rules = DrlParser.parse(drl);
        _engine.addRules(rules);
        if (debugMode) print('[FaraidDrlEngine] loaded ${rules.length} rules');
      } catch (e) {
        if (debugMode) print('[FaraidDrlEngine] DRL load failed: $e');
      }

      _rulesLoaded = true;
    }

    // Always ensure globals exist with correct types
    _engine.setGlobal('shares', <String, double>{});
    _engine.setGlobal('reasons', <String, String>{});
    _engine.setGlobal('executionLog', <String>[]);
    _engine.setGlobal('flags', <String, bool>{});
    _engine.setGlobal('calculationMethod', 'Hanafi');
    _engine.setGlobal('totalEstate', 1.0);
    _engine.setGlobal('remainingShare', 0.0);
  }

  Future<FaraidResult> calculate({
    required FamilyMember deceased,
    required List<FamilyMember> heirs,
    required Estate estate,
    String method = 'Hanafi',
  }) async {
    if (debugMode) print('[FaraidDrlEngine] calculate start');

    _engine.clearFacts();

    // reset globals per calculation
    _engine.setGlobal('shares', <String, double>{});
    _engine.setGlobal('reasons', <String, String>{});
    _engine.setGlobal('executionLog', <String>[]);
    _engine.setGlobal('flags', <String, bool>{});
    _engine.setGlobal('calculationMethod', method);
    _engine.setGlobal(
      'totalEstate',
      estate.netValue > 0 ? estate.netValue : 1.0,
    );
    _engine.setGlobal('remainingShare', 0.0);

    // Insert sanitized facts (deceased + heirs)
    final decMap = _toFactMap(deceased);
    decMap['relationName'] = 'deceased';
    _engine.insert(Fact('FamilyMember', decMap));

    _engine.setFocus('fixed-shares');
    _engine.setFocus('residual-calculation');
    _engine.setFocus('residual-distribution');
    _engine.setFocus('validation');
    _engine.setFocus('completion');

    final seen = <String>{};
    for (final h in heirs) {
      final fm = _toFactMap(h);
      final id = fm['id'].toString();
      if (seen.contains(id)) continue;
      seen.add(id);
      _engine.insert(Fact('FamilyMember', fm));
    }

    // Fire rules in rounds; break when DRL sets flags indicating completion of phases
    final maxRounds = 6;
    for (var round = 0; round < maxRounds; round++) {
      if (debugMode) print('[FaraidDrlEngine] fireAllRules round $round');
      _engine.fireAllRules();

      final flags = _engine.getGlobal('flags') as Map<dynamic, dynamic>? ?? {};
      final doneChildren = flags['childrenResidualDone'] == true;
      final remainingComputed = flags['remainingComputed'] == true;
      final fallbackDone = flags['fallbackDone'] == true || false;
      final complete = flags['complete'] == true;

      if (debugMode) {
        final sharesSnap = _engine.getGlobal('shares');
        final exec = _engine.getGlobal('executionLog') as List<dynamic>?;
        print('[FaraidDrlEngine] shares: $sharesSnap');
        print('[FaraidDrlEngine] flags: $flags');
        print('[FaraidDrlEngine] exec len: ${exec?.length ?? 0}');
      }

      if (complete) break;
      if (remainingComputed && (doneChildren || fallbackDone)) break;
    }

    // Safety compute remaining if DRL didn't compute properly
    _computeRemainingIfMissing();

    // Final programmatic fallback if still empty (rare)
    _finalFallbackIfEmpty();

    final results = _getResults();
    if (debugMode) {
      print('[FaraidDrlEngine] calculate done, result: ${results.shares}');
    }
    return results;
  }

  Map<String, dynamic> _toFactMap(FamilyMember m) {
    final raw = Map<String, dynamic>.from(m.toFactMap());
    if (raw.containsKey('relation'))
      raw['relationName'] =
          raw['relation'].toString().split('.').last.toLowerCase();
    if (raw.containsKey('relationName'))
      raw['relationName'] = raw['relationName'].toString().toLowerCase();
    if (raw.containsKey('gender'))
      raw['genderName'] =
          raw['gender'].toString().split('.').last.toLowerCase();
    if (raw.containsKey('genderName'))
      raw['genderName'] = raw['genderName'].toString().toLowerCase();
    raw['id'] = raw['id'].toString();
    raw['isDeceased'] = raw['isDeceased'] ?? false;
    raw['faraidShare'] =
        (raw['faraidShare'] is num)
            ? (raw['faraidShare'] as num).toDouble()
            : double.tryParse(raw['faraidShare']?.toString() ?? '') ?? 0.0;
    return raw;
  }

  void _computeRemainingIfMissing() {
    final sharesMap =
        _engine.getGlobal('shares') as Map<dynamic, dynamic>? ?? {};
    double total = 0.0;
    for (final v in sharesMap.values) {
      total += _toDouble(v);
    }
    double rem = 1.0 - total;
    if (rem < 0) rem = 0.0;
    _engine.setGlobal('remainingShare', rem);
    final flags = _engine.getGlobal('flags') as Map<dynamic, dynamic>? ?? {};
    flags['remainingComputed'] = true;
    final exec = _engine.getGlobal('executionLog') as List<dynamic>?;
    exec?.add('ComputeRemainingIfMissing: remaining = $rem');
  }

  void _finalFallbackIfEmpty() {
    final sharesMap =
        _engine.getGlobal('shares') as Map<dynamic, dynamic>? ?? {};
    final flags = _engine.getGlobal('flags') as Map<dynamic, dynamic>? ?? {};
    final exec = _engine.getGlobal('executionLog') as List<dynamic>?;
    final facts = _engine.getFactsByType('FamilyMember') ?? [];

    final empty =
        sharesMap.isEmpty || sharesMap.values.every((v) => _toDouble(v) == 0.0);
    if (empty && flags['fallbackDone'] != true) {
      Fact? found;
      try {
        found = facts.firstWhere(
          (f) =>
              (f.get('relationName')?.toString() ?? '') == 'son' &&
              f.get('isDeceased') == false,
        );
      } catch (_) {
        found = null;
      }
      if (found != null) {
        final id = found.get('id').toString();
        sharesMap[id] = 1.0;
        (_engine.getGlobal('reasons') as Map)[id] =
            'Fallback assigned programmatically';
        exec?.add('Fallback assigned son $id programmatically');
      } else {
        Fact? any;
        try {
          any = facts.firstWhere(
            (f) =>
                (f.get('relationName')?.toString() ?? '') != 'deceased' &&
                f.get('isDeceased') == false,
          );
        } catch (_) {
          any = null;
        }
        if (any != null) {
          final id = any.get('id').toString();
          sharesMap[id] = 1.0;
          (_engine.getGlobal('reasons') as Map)[id] =
              'Fallback assigned programmatically';
          exec?.add('Fallback assigned heir $id programmatically');
        }
      }
      flags['fallbackDone'] = true;
    }
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return (v as num).toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  FaraidResult _getResults() {
    final sharesDyn =
        _engine.getGlobal('shares') as Map<dynamic, dynamic>? ?? {};
    final reasonsDyn =
        _engine.getGlobal('reasons') as Map<dynamic, dynamic>? ?? {};
    final execDyn = _engine.getGlobal('executionLog') as List<dynamic>? ?? [];

    final shares = <String, double>{};
    final reasons = <String, String>{};

    sharesDyn.forEach((k, v) {
      if (k is String) shares[k] = _toDouble(v);
    });

    reasonsDyn.forEach((k, v) {
      if (k is String && v is String) reasons[k] = v;
    });

    final execLog = execDyn.whereType<String>().toList();

    return FaraidResult(
      shares: shares,
      reasons: reasons,
      executedRules: execLog,
      statistics: _engine.getStatistics(),
    );
  }
}
