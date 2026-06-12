import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/story/charts.dart';

import 'support/showcase_widget_test_harness.dart';

const _storyTimeout = Timeout(Duration(seconds: 45));

void main() {
  setUp(registerAllChartsForTest);

  test('chart story names are unique', () {
    final names = charts.map((story) => story.name).toList();
    expect(
      names.toSet(),
      hasLength(names.length),
      reason: 'Duplicate story names make Storybook initialStory unreliable.',
    );
  });

  group('chart storybook render smoke', () {
    for (final story in charts) {
      testWidgets(story.name, (tester) async {
        await pumpChartStorybook(tester, initialStory: story.name);

        expect(
          find.text('Select story'),
          findsNothing,
          reason: 'Storybook did not resolve "${story.name}".',
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'Chart story "${story.name}" threw during initial render.',
        );
      }, timeout: _storyTimeout);
    }
  });
}
