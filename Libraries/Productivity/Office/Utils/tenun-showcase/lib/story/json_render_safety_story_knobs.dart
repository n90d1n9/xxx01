import 'package:flutter/widgets.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../example/json_render_safety_models.dart';

class JsonRenderSafetyStoryKnobs {
  const JsonRenderSafetyStoryKnobs({
    required this.scenario,
    required this.fallbackPreset,
    required this.validatePayload,
    required this.strictValidation,
    required this.autoNormalizePayload,
    required this.showPayloadSource,
  });

  final JsonRenderSafetyScenario scenario;
  final JsonRenderSafetyFallbackPreset fallbackPreset;
  final bool validatePayload;
  final bool strictValidation;
  final bool autoNormalizePayload;
  final bool showPayloadSource;
}

JsonRenderSafetyStoryKnobs jsonRenderSafetyStoryKnobs(
  BuildContext context, {
  JsonRenderSafetyScenario initialScenario =
      JsonRenderSafetyScenario.unknownType,
  JsonRenderSafetyFallbackPreset initialFallbackPreset =
      JsonRenderSafetyFallbackPreset.defaults,
  bool initialValidatePayload = false,
  bool initialStrictValidation = false,
  bool initialAutoNormalizePayload = false,
  bool initialShowPayloadSource = true,
}) {
  return JsonRenderSafetyStoryKnobs(
    scenario: context.knobs.options<JsonRenderSafetyScenario>(
      label: 'Scenario',
      initial: initialScenario,
      options: const [
        Option(
          label: 'Unknown Type',
          value: JsonRenderSafetyScenario.unknownType,
        ),
        Option(
          label: 'Unregistered Custom Type',
          value: JsonRenderSafetyScenario.unregisteredCustomType,
        ),
        Option(
          label: 'Invalid Sampling Policy',
          value: JsonRenderSafetyScenario.invalidSamplingPolicy,
        ),
      ],
    ),
    fallbackPreset: context.knobs.options<JsonRenderSafetyFallbackPreset>(
      label: 'Fallback Preset',
      initial: initialFallbackPreset,
      options: const [
        Option(
          label: 'Default',
          value: JsonRenderSafetyFallbackPreset.defaults,
        ),
        Option(label: 'Compact', value: JsonRenderSafetyFallbackPreset.compact),
        Option(label: 'Quiet', value: JsonRenderSafetyFallbackPreset.quiet),
        Option(
          label: 'Production',
          value: JsonRenderSafetyFallbackPreset.production,
        ),
      ],
    ),
    validatePayload: context.knobs.boolean(
      label: 'Validate Payload',
      initial: initialValidatePayload,
    ),
    strictValidation: context.knobs.boolean(
      label: 'Strict Validation',
      initial: initialStrictValidation,
    ),
    autoNormalizePayload: context.knobs.boolean(
      label: 'Auto Normalize Payload',
      initial: initialAutoNormalizePayload,
    ),
    showPayloadSource: context.knobs.boolean(
      label: 'Show Payload Source',
      initial: initialShowPayloadSource,
    ),
  );
}
