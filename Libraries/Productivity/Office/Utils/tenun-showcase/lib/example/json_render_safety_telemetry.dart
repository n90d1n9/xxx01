import 'package:tenun/tenun_core.dart';

import 'json_render_safety_models.dart';

class JsonRenderSafetyTelemetrySnapshot {
  const JsonRenderSafetyTelemetrySnapshot({
    required this.scenario,
    required this.fallbackPreset,
    required this.payload,
    required this.validatePayload,
    required this.strictValidation,
    required this.autoNormalizePayload,
    this.renderError,
    this.validationResult,
  });

  final JsonRenderSafetyScenario scenario;
  final JsonRenderSafetyFallbackPreset fallbackPreset;
  final Map<String, dynamic> payload;
  final bool validatePayload;
  final bool strictValidation;
  final bool autoNormalizePayload;
  final Object? renderError;
  final ValidationResult? validationResult;

  Map<String, Object?> toJson({int maxIssues = 4}) {
    final signature = ChartDataSignature.fromJson(payload);
    final validation = validationResult;
    final error = renderError;

    return {
      'event': 'tenun.jsonRenderSafety',
      'status': _status(error, validation),
      'scenario': scenario.name,
      'fallbackPreset': fallbackPreset.name,
      'payload': {
        'type': signature.typeString ?? payload['type']?.toString(),
        'hash': signature.hash,
        'canonicalBytes': signature.canonicalBytes,
        'seriesCount': signature.seriesCount,
        'dataPointCount': signature.dataPointCount,
      },
      'options': {
        'validatePayload': validatePayload,
        'strictValidation': strictValidation,
        'autoNormalizePayload': autoNormalizePayload,
      },
      if (error != null)
        'renderError': {
          'type': error.runtimeType.toString(),
          'message': _shorten(error.toString()),
        },
      if (validation != null)
        'validation': {
          'type': chartTypeToString(validation.type),
          'isValid': validation.isValid,
          'errorCount': validation.errors.length,
          'warningCount': validation.warnings.length,
          'issues': [
            for (final issue in validation.issues.take(maxIssues))
              issue.toJson(),
          ],
        }
      else
        'validation': {'observed': false},
      'recommendedAction': _recommendedAction(error, validation),
    };
  }
}

String _status(Object? error, ValidationResult? validation) {
  if (error != null) return 'render_error';
  if (validation != null && !validation.isValid) return 'validation_error';
  if (validation != null && validation.hasWarnings) return 'validation_warning';
  if (validation != null) return 'valid';
  return 'waiting';
}

String _recommendedAction(Object? error, ValidationResult? validation) {
  if (error != null) {
    return 'Register the chart type, fix the payload type, or keep the fallback visible.';
  }

  final validationError = validation == null
      ? null
      : _firstOrNull(validation.errors);
  if (validationError != null) {
    return validationError.suggestion ??
        'Fix validation errors before rendering in strict mode.';
  }

  final warning = validation == null ? null : _firstOrNull(validation.warnings);
  if (warning != null) {
    return warning.suggestion ??
        'Review validation warnings before publishing.';
  }

  return 'No action required.';
}

String _shorten(String value, {int maxLength = 240}) {
  if (value.length <= maxLength) return value;
  return '${value.substring(0, maxLength - 1)}...';
}

T? _firstOrNull<T>(List<T> values) {
  return values.isEmpty ? null : values.first;
}
