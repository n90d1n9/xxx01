// faraid/adapters/generic_faraid_adapter.dart
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

import '../qonun/new/core.dart';
import '../qonun/new/yaml_rule_loader.dart';
import 'domain_agnostic_registry.dart';
import 'faraid_rule_engine_adapter.dart';
import 'yaml_converter.dart';

class GenericFaraidAdapter {
  final DomainAgnosticRuleEngine _engine;
  final Map<String, dynamic> _config;

  GenericFaraidAdapter() : _engine = DomainAgnosticRuleEngine(), _config = {} {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final configText = await rootBundle.loadString(
        'assets/rules/faraid_config.yaml',
      );
      final yamlMap = loadYaml(configText);
      _config.addAll(YamlConverter.yamlToMap(yamlMap));
      print('Faraid config loaded successfully');
    } catch (e) {
      print('Error loading Faraid config: $e');
    }
  }

  Future<FaraidCalculationResult> calculate({
    required String method,
    required Map<String, dynamic> heirs,
    required Map<String, dynamic> estate,
  }) async {
    print('=== STARTING CALCULATION ===');
    print('Method: $method');
    print('Heirs: $heirs');

    try {
      final rules = await _loadMethodRules(method);
      print('Loaded ${rules.length} rules');

      final facts = _prepareFacts(heirs, estate, method);

      final result = await _engine.executeRules(
        initialFacts: facts,
        rules: rules,
        executionContext: {'method': method},
      );

      print('=== CALCULATION RESULT ===');
      print('Shares: ${result.shares}');
      print('Remaining: ${result.remainingShare}');

      return _buildResult(result, heirs);
    } catch (e, stackTrace) {
      print('CALCULATION ERROR: $e');
      print(stackTrace);
      return FaraidCalculationResult(
        shares: {},
        reasons: {'error': 'Calculation failed'},
        executedRules: ['Error: $e'],
        statistics: {'error': e.toString()},
      );
    }
  }

  // faraid/adapters/generic_faraid_adapter.dart
  Future<List<Rule>> _loadMethodRules(String method) async {
    print(' >>>>>>>>>> $method');
    try {
      // Try multiple possible file names
      final possibleFiles = [
        'assets/rules/faraid_${method}_rules.yaml',
        'assets/rules/faraid_${method.toLowerCase()}_rules.yaml',
        'assets/rules/faraid_basic_rules.yaml',
      ];

      for (final file in possibleFiles) {
        try {
          print('Trying rule file: $file');
          final rulesText = await rootBundle.loadString(file);
          final rules = YamlRuleLoader.load(rulesText);
          if (rules.isNotEmpty) {
            print('Successfully loaded rules from: $file');
            return rules;
          }
        } catch (e) {
          print('Failed to load $file: $e');
          continue;
        }
      }

      print('No rule files found for method: $method');
      return [];
    } catch (e) {
      print('Error loading rules for method $method: $e');
      return [];
    }
  }

  Map<String, dynamic> _buildExecutionContext(String method) {
    // Handle case where _config might be null
    final inheritanceSystems = _config['inheritance_systems'] ?? {};
    final methodConfig =
        inheritanceSystems[method] ??
        inheritanceSystems[method.toLowerCase()] ??
        {};

    return {
      'method': method,
      'config': methodConfig,
      'heir_types': _config['heir_types'] ?? {},
      'calculations': _config['calculations'] ?? [],
    };
  }

  Map<String, dynamic> _prepareFacts(
    Map<String, dynamic> heirs,
    Map<String, dynamic> estate,
    String method,
  ) {
    final facts = <String, dynamic>{};

    // Add heirs as simple lists
    heirs.forEach((type, data) {
      if (data is List) {
        facts[type] = data;
      } else {
        facts[type] = [data];
      }
    });

    print('=== PREPARED FACTS ===');
    facts.forEach((key, value) {
      print('$key: $value (${value.runtimeType})');
    });

    return facts;
  }

  FaraidCalculationResult _buildResult(
    RuleExecutionResult engineResult,
    Map<String, dynamic> heirs,
  ) {
    final shares = _distributeShares(engineResult.shares, heirs);

    return FaraidCalculationResult(
      shares: shares,
      reasons: _buildReasons(engineResult, shares),
      executedRules: engineResult.executionLog,
      statistics: {
        'totalRules': engineResult.context['firedRules'] ?? 0,
        'remainingShare': engineResult.remainingShare,
        'calculationTime': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Map<String, double> _distributeShares(
    Map<String, dynamic> aggregateShares,
    Map<String, dynamic> heirs,
  ) {
    final individualShares = <String, double>{};

    aggregateShares.forEach((heirType, totalShare) {
      if (totalShare is num) {
        final heirsOfType = heirs[heirType];
        final count = heirsOfType is List ? heirsOfType.length : 1;

        if (count > 0) {
          final sharePerHeir = totalShare.toDouble() / count;

          if (heirsOfType is List) {
            for (final heir in heirsOfType) {
              individualShares[heir['id']] = sharePerHeir;
            }
          } else {
            individualShares[heirsOfType['id']] = sharePerHeir;
          }
        }
      }
    });

    return individualShares;
  }

  Map<String, String> _buildReasons(
    RuleExecutionResult result,
    Map<String, double> shares,
  ) {
    final reasons = <String, String>{};
    final context = result.context;

    shares.forEach((heirId, share) {
      final heirType = _getHeirType(heirId);
      final calculation =
          context['calculation_$heirType'] ?? 'Standard Islamic inheritance';
      reasons[heirId] = '$calculation (${_formatShare(share)})';
    });

    return reasons;
  }

  String _getHeirType(String heirId) {
    // Extract heir type from ID or use mapping
    return heirId.split('_').first;
  }

  String _formatShare(double share) {
    if (share == 0.5) return '1/2';
    if (share == 0.25) return '1/4';
    if (share == 0.125) return '1/8';
    if (share == 0.333) return '1/3';
    if (share == 0.666) return '2/3';
    return share.toStringAsFixed(3);
  }
}
