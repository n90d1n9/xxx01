import 'package:flutter/widgets.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

class PayloadNormalizationStoryKnobs {
  const PayloadNormalizationStoryKnobs({
    required this.targetType,
    required this.autoNormalizePayload,
    required this.strictValidation,
    required this.dropUnsupportedSampling,
    required this.sanitizeTradingPayload,
    required this.highlightDiff,
    required this.normalizeDefaultThreshold,
    required this.normalizeDefaultMode,
  });

  final String targetType;
  final bool autoNormalizePayload;
  final bool strictValidation;
  final bool dropUnsupportedSampling;
  final bool sanitizeTradingPayload;
  final bool highlightDiff;
  final int normalizeDefaultThreshold;
  final String normalizeDefaultMode;
}

PayloadNormalizationStoryKnobs payloadNormalizationStoryKnobs(
  BuildContext context, {
  String initialTargetType = 'line',
  bool initialAutoNormalizePayload = false,
  bool initialStrictValidation = true,
  bool initialDropUnsupportedSampling = true,
  bool initialSanitizeTradingPayload = true,
  bool initialHighlightDiff = true,
  int initialNormalizeDefaultThreshold = 1200,
  String initialNormalizeDefaultMode = 'auto',
}) {
  return PayloadNormalizationStoryKnobs(
    targetType: context.knobs.options<String>(
      label: 'Target Type',
      initial: initialTargetType,
      options: const [
        Option(label: 'Line', value: 'line'),
        Option(label: 'Pie', value: 'pie'),
        Option(label: 'Renko', value: 'renko'),
        Option(label: 'Kagi', value: 'kagi'),
        Option(label: 'MACD', value: 'macd'),
      ],
    ),
    autoNormalizePayload: context.knobs.boolean(
      label: 'Auto Normalize Payload',
      initial: initialAutoNormalizePayload,
    ),
    strictValidation: context.knobs.boolean(
      label: 'Strict Validation',
      initial: initialStrictValidation,
    ),
    dropUnsupportedSampling: context.knobs.boolean(
      label: 'Drop Unsupported Sampling',
      initial: initialDropUnsupportedSampling,
    ),
    sanitizeTradingPayload: context.knobs.boolean(
      label: 'Sanitize Trading Payload',
      initial: initialSanitizeTradingPayload,
    ),
    highlightDiff: context.knobs.boolean(
      label: 'Highlight Diff',
      initial: initialHighlightDiff,
    ),
    normalizeDefaultThreshold: context.knobs.sliderInt(
      label: 'Normalize Default Threshold',
      initial: initialNormalizeDefaultThreshold,
      min: 100,
      max: 5000,
      divisions: 49,
    ),
    normalizeDefaultMode: context.knobs.options<String>(
      label: 'Normalize Default Mode',
      initial: initialNormalizeDefaultMode,
      options: const [
        Option(label: 'Regular', value: 'regular'),
        Option(label: 'Auto', value: 'auto'),
        Option(label: 'Large', value: 'large'),
      ],
    ),
  );
}
