import 'package:flutter_test/flutter_test.dart';
import 'package:tenun/tenun_core.dart';
import 'package:tenun_showcase/example/json_render_safety_models.dart';
import 'package:tenun_showcase/example/json_render_safety_telemetry.dart';

void main() {
  test('JSON render safety telemetry summarizes render failures', () {
    final snapshot = JsonRenderSafetyTelemetrySnapshot(
      scenario: JsonRenderSafetyScenario.unknownType,
      fallbackPreset: JsonRenderSafetyFallbackPreset.compact,
      payload: const {
        'type': 'linee',
        'series': [
          {
            'name': 'Activated',
            'data': [42, 48, 53],
          },
        ],
      },
      validatePayload: false,
      strictValidation: false,
      autoNormalizePayload: false,
      renderError: StateError('Chart type was not registered.'),
    );

    final json = snapshot.toJson();

    expect(json['event'], 'tenun.jsonRenderSafety');
    expect(json['status'], 'render_error');
    expect(json['scenario'], 'unknownType');
    expect(json['fallbackPreset'], 'compact');
    expect(json['payload'], containsPair('type', 'linee'));
    expect(json['payload'], containsPair('seriesCount', 1));
    expect(json['options'], containsPair('validatePayload', false));
    expect(json['renderError'], containsPair('type', 'StateError'));
    expect(json['validation'], containsPair('observed', false));
    expect(json['recommendedAction'], contains('Register the chart type'));
  });

  test('JSON render safety telemetry summarizes validation failures', () {
    const issue = ValidationIssue(
      severity: ValidationSeverity.error,
      code: 'INVALID_SAMPLING_ENABLED',
      message: 'sampling.enabled must be a boolean.',
      field: 'sampling.enabled',
      suggestion: 'Use true or false.',
    );
    const validation = ValidationResult(issues: [issue], type: ChartType.line);
    final snapshot = JsonRenderSafetyTelemetrySnapshot(
      scenario: JsonRenderSafetyScenario.invalidSamplingPolicy,
      fallbackPreset: JsonRenderSafetyFallbackPreset.defaults,
      payload: const {
        'type': 'line',
        'sampling': {'enabled': 'yes'},
        'series': [
          {
            'data': [1, 2, 3],
          },
        ],
      },
      validatePayload: true,
      strictValidation: true,
      autoNormalizePayload: false,
      validationResult: validation,
    );

    final json = snapshot.toJson();
    final validationJson = json['validation']! as Map<String, Object?>;

    expect(json['status'], 'validation_error');
    expect(validationJson['isValid'], false);
    expect(validationJson['errorCount'], 1);
    expect(validationJson['issues'], hasLength(1));
    expect(json['recommendedAction'], 'Use true or false.');
  });
}
