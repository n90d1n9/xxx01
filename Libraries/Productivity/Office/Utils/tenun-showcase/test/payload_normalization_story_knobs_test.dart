import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:tenun_showcase/story/payload_normalization_story_knobs.dart';

void main() {
  testWidgets('payload normalization knobs expose typed playground config', (
    tester,
  ) async {
    late PayloadNormalizationStoryKnobs knobs;

    await tester.pumpWidget(
      Storybook(
        initialStory: 'Probe',
        stories: [
          Story(
            name: 'Probe',
            builder: (context) {
              knobs = payloadNormalizationStoryKnobs(
                context,
                initialTargetType: 'kagi',
                initialAutoNormalizePayload: true,
                initialStrictValidation: false,
                initialDropUnsupportedSampling: false,
                initialSanitizeTradingPayload: false,
                initialHighlightDiff: false,
                initialNormalizeDefaultThreshold: 900,
                initialNormalizeDefaultMode: 'large',
              );
              return const SizedBox.shrink();
            },
          ),
        ],
        wrapperBuilder: (_, child) => MaterialApp(home: child),
      ),
    );
    await tester.pump();

    expect(knobs.targetType, 'kagi');
    expect(knobs.autoNormalizePayload, isTrue);
    expect(knobs.strictValidation, isFalse);
    expect(knobs.dropUnsupportedSampling, isFalse);
    expect(knobs.sanitizeTradingPayload, isFalse);
    expect(knobs.highlightDiff, isFalse);
    expect(knobs.normalizeDefaultThreshold, 900);
    expect(knobs.normalizeDefaultMode, 'large');
  });
}
