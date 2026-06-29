/// Configuration validation for chart configs.
///
/// Validates a [BaseChartConfig] before rendering and returns a [ValidationResult]
/// with structured errors, warnings, and auto-fix suggestions.
///
/// Usage:
/// ```dart
/// final result = ChartConfigValidator.validate(myConfig);
/// if (!result.isValid) {
///   for (final e in result.errors) debugPrint('[ERROR] ${e.message}');
/// }
/// for (final w in result.warnings) debugPrint('[WARN] ${w.message}');
/// final fixed = result.applyFixes(myConfig);
/// ```
library chart_config_validator;

import 'base_config.dart';
import 'chart_type.dart';
import 'series.dart';

// ---------------------------------------------------------------------------
// ValidationIssue
// ---------------------------------------------------------------------------

enum ValidationSeverity { error, warning, info }

class ValidationIssue {
  final ValidationSeverity severity;
  final String code;
  final String message;
  final String? field;
  final String? suggestion;

  const ValidationIssue({
    required this.severity,
    required this.code,
    required this.message,
    this.field,
    this.suggestion,
  });

  bool get isError => severity == ValidationSeverity.error;
  bool get isWarning => severity == ValidationSeverity.warning;

  @override
  String toString() =>
      '[${severity.name.toUpperCase()}] $code: $message'
      '${field != null ? ' (field: $field)' : ''}'
      '${suggestion != null ? '\n  → $suggestion' : ''}';
}

// ---------------------------------------------------------------------------
// ValidationResult
// ---------------------------------------------------------------------------

class ValidationResult {
  final List<ValidationIssue> issues;
  final ChartType type;

  const ValidationResult({required this.issues, required this.type});

  List<ValidationIssue> get errors =>
      issues.where((i) => i.isError).toList();
  List<ValidationIssue> get warnings =>
      issues.where((i) => i.isWarning).toList();
  List<ValidationIssue> get infos =>
      issues.where((i) => i.severity == ValidationSeverity.info).toList();

  bool get isValid => errors.isEmpty;
  bool get hasWarnings => warnings.isNotEmpty;

  @override
  String toString() {
    if (issues.isEmpty) return 'ValidationResult: OK';
    return 'ValidationResult(${errors.length} errors, '
        '${warnings.length} warnings):\n'
        '${issues.map((i) => '  $i').join('\n')}';
  }
}

// ---------------------------------------------------------------------------
// ChartConfigValidator
// ---------------------------------------------------------------------------

class ChartConfigValidator {
  /// Validate [config] and return a [ValidationResult].
  static ValidationResult validate(BaseChartConfig config) {
    final issues = <ValidationIssue>[];
    final v = _Validator(config, issues);

    v.checkSeriesNotEmpty();
    v.checkSeriesDataNotNull();
    v.checkDataLengthConsistency();
    v.checkNoNullValues();
    v.checkColorStrings();
    v.checkTypeSpecificRules();
    v.checkAxisConfig();
    v.checkLegendConfig();

    return ValidationResult(issues: issues, type: config.type);
  }

  /// Validate JSON before parsing. Returns errors found in the raw map.
  static List<String> validateJson(Map<String, dynamic> json) {
    final errors = <String>[];
    if (json['type'] == null) {
      errors.add('Missing required field: "type"');
    }
    if (json['series'] == null) {
      errors.add('Missing required field: "series"');
    } else if (json['series'] is! List) {
      errors.add('"series" must be a List');
    } else if ((json['series'] as List).isEmpty) {
      errors.add('"series" must not be empty');
    }
    return errors;
  }
}

// ---------------------------------------------------------------------------
// Internal validator
// ---------------------------------------------------------------------------

class _Validator {
  final BaseChartConfig config;
  final List<ValidationIssue> issues;

  _Validator(this.config, this.issues);

  void _error(String code, String message,
          {String? field, String? suggestion}) =>
      issues.add(ValidationIssue(
        severity: ValidationSeverity.error,
        code: code,
        message: message,
        field: field,
        suggestion: suggestion,
      ));

  void _warn(String code, String message,
          {String? field, String? suggestion}) =>
      issues.add(ValidationIssue(
        severity: ValidationSeverity.warning,
        code: code,
        message: message,
        field: field,
        suggestion: suggestion,
      ));

  void _info(String code, String message, {String? field}) =>
      issues.add(ValidationIssue(
        severity: ValidationSeverity.info,
        code: code,
        message: message,
        field: field,
      ));

  void checkSeriesNotEmpty() {
    if (config.series.isEmpty) {
      _error(
        'EMPTY_SERIES',
        'Chart has no series data.',
        field: 'series',
        suggestion: 'Add at least one Series with data.',
      );
    }
  }

  void checkSeriesDataNotNull() {
    for (int i = 0; i < config.series.length; i++) {
      final s = config.series[i];
      if (s.data == null) {
        _error(
          'NULL_SERIES_DATA',
          'Series[$i] "${s.name ?? i}" has null data.',
          field: 'series[$i].data',
          suggestion: 'Set data to an empty list [] instead of null.',
        );
      } else if (s.data!.isEmpty) {
        _warn(
          'EMPTY_SERIES_DATA',
          'Series[$i] "${s.name ?? i}" has an empty data list.',
          field: 'series[$i].data',
        );
      }
    }
  }

  void checkDataLengthConsistency() {
    if (config.series.length < 2) return;
    final lengths = config.series
        .where((s) => s.data != null)
        .map((s) => s.data!.length)
        .toSet();
    if (lengths.length > 1) {
      _warn(
        'INCONSISTENT_DATA_LENGTH',
        'Series have different data lengths: ${lengths.join(', ')}. '
            'Shorter series will show as missing values.',
        field: 'series[*].data.length',
        suggestion: 'Pad shorter series with nulls or 0.',
      );
    }
  }

  void checkNoNullValues() {
    for (int i = 0; i < config.series.length; i++) {
      final data = config.series[i].data ?? [];
      int nullCount = 0;
      for (final v in data) {
        if (v == null) nullCount++;
      }
      if (nullCount > 0) {
        _warn(
          'NULL_DATA_VALUES',
          'Series[$i] contains $nullCount null value(s) — '
              'they will be skipped during rendering.',
          field: 'series[$i].data',
          suggestion: 'Replace nulls with 0, or use a chart type that '
              'supports gaps (line with connectNulls: false).',
        );
      }
    }
  }

  void checkColorStrings() {
    for (int i = 0; i < config.series.length; i++) {
      final color = config.series[i].itemStyle?.color;
      if (color != null && color.isNotEmpty) {
        final valid = _isValidColor(color);
        if (!valid) {
          _warn(
            'INVALID_COLOR',
            'Series[$i] itemStyle.color "$color" is not a valid color string.',
            field: 'series[$i].itemStyle.color',
            suggestion:
                'Use hex (#RRGGBB), rgb(r,g,b), rgba(r,g,b,a) or a named color.',
          );
        }
      }
    }
  }

  void checkTypeSpecificRules() {
    switch (config.type) {
      case ChartType.pie:
      case ChartType.donut:
        _checkPie();
      case ChartType.candlestick:
      case ChartType.ohlc:
        _checkOhlc();
      case ChartType.sankey:
        _checkSankey();
      case ChartType.scatter:
        _checkScatter();
      case ChartType.bubble:
        _checkBubble();
      default:
        break;
    }
  }

  void _checkPie() {
    if (config.series.length > 1) {
      _warn(
        'PIE_MULTIPLE_SERIES',
        'Pie/donut charts only render the first series. '
            '${config.series.length} series provided.',
        suggestion: 'Use a grouped bar chart for multiple series comparison.',
      );
    }
    final data = config.series.firstOrNull?.data ?? [];
    bool hasNegative = data.any((v) => v is num && v < 0);
    if (hasNegative) {
      _error(
        'PIE_NEGATIVE_VALUES',
        'Pie/donut charts cannot render negative values.',
        field: 'series[0].data',
        suggestion: 'Use absolute values or a bar chart with diverging axis.',
      );
    }
  }

  void _checkOhlc() {
    for (int i = 0; i < config.series.length; i++) {
      final data = config.series[i].data ?? [];
      for (int j = 0; j < data.length; j++) {
        final item = data[j];
        if (item is List && item.length < 4) {
          _error(
            'OHLC_INSUFFICIENT_VALUES',
            'Candlestick/OHLC series[$i] item[$j] needs 4 values '
                '[open, high, low, close], got ${item.length}.',
            field: 'series[$i].data[$j]',
          );
          break;
        }
      }
    }
  }

  void _checkSankey() {
    // Sankey expects links with source/target/value.
    final data = config.series.firstOrNull?.data ?? [];
    if (data.isNotEmpty && data.first is Map) {
      final first = data.first as Map;
      if (!first.containsKey('source') || !first.containsKey('target')) {
        _error(
          'SANKEY_MISSING_LINKS',
          'Sankey data items must have "source", "target", and "value" keys.',
          field: 'series[0].data',
        );
      }
    }
  }

  void _checkScatter() {
    for (int i = 0; i < config.series.length; i++) {
      final data = config.series[i].data ?? [];
      for (int j = 0; j < data.length; j++) {
        final item = data[j];
        if (item is List && item.length < 2) {
          _error(
            'SCATTER_INSUFFICIENT_VALUES',
            'Scatter series[$i] item[$j] needs at least [x, y], got ${item.length}.',
            field: 'series[$i].data[$j]',
          );
          break;
        }
      }
    }
  }

  void _checkBubble() {
    for (int i = 0; i < config.series.length; i++) {
      final data = config.series[i].data ?? [];
      for (int j = 0; j < data.length; j++) {
        final item = data[j];
        if (item is List && item.length < 3) {
          _warn(
            'BUBBLE_MISSING_SIZE',
            'Bubble series[$i] item[$j] should be [x, y, size], got ${item.length}. '
                'Default size will be used.',
            field: 'series[$i].data[$j]',
          );
          break;
        }
      }
    }
  }

  void checkAxisConfig() {
    // Warn on suspiciously large Y ranges (potential unit mismatch).
    if (config.series.isNotEmpty) {
      double max = double.negativeInfinity;
      double min = double.infinity;
      for (final s in config.series) {
        for (final v in s.data ?? []) {
          final d = v is num ? v.toDouble() : null;
          if (d != null) {
            if (d > max) max = d;
            if (d < min) min = d;
          }
        }
      }
      if (max.isFinite && min.isFinite && (max - min) > 1e9) {
        _warn(
          'LARGE_Y_RANGE',
          'Data range is very large (${min.toStringAsExponential(2)} to '
              '${max.toStringAsExponential(2)}). Consider a log scale.',
          suggestion: 'Set yAxisConfig: ChartAxisConfig.log()',
        );
      }
    }
  }

  void checkLegendConfig() {
    if (config.series.length > 1) {
      final unnamed = config.series
          .where((s) => s.name == null || s.name!.isEmpty)
          .length;
      if (unnamed > 0) {
        _info(
          'UNNAMED_SERIES',
          '$unnamed series have no name. Legend items will show as empty.',
          field: 'series[*].name',
        );
      }
    }
  }

  // ---- Helpers ----

  static bool _isValidColor(String s) {
    if (s.startsWith('#')) return s.length == 4 || s.length == 7 || s.length == 9;
    if (s.toLowerCase().startsWith('rgb(') ||
        s.toLowerCase().startsWith('rgba(')) return true;
    const named = {
      'black', 'white', 'red', 'green', 'blue', 'yellow', 'orange',
      'purple', 'pink', 'grey', 'gray', 'cyan', 'teal', 'indigo',
      'transparent', 'amber', 'lime', 'brown', 'navy', 'maroon',
      'gold', 'silver', 'olive',
    };
    return named.contains(s.toLowerCase());
  }
}
