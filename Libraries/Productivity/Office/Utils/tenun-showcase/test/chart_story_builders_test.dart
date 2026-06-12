import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/story/chart_story_builders.dart';
import 'package:tenun_showcase/story/chart_story_contract.dart';

void main() {
  test('chartStory keeps story metadata', () {
    final story = chartStory(
      name: 'Charts/Test/Plain',
      description: 'Plain story',
      builder: (context) => const SizedBox(),
    );

    expect(story.name, 'Charts/Test/Plain');
    expect(story.description, 'Plain story');
  });

  test('chartStory can register a structured story contract', () {
    final contract = ChartStoryContract(
      section: 'Test',
      dataShape: 'Cartesian',
      family: 'Line',
      variant: 'Contract',
      tags: const ['contract'],
      knobs: const [
        ChartStoryKnobSpec.boolean(key: 'showTooltip', label: 'Show Tooltip'),
      ],
      sampleJson: const {'type': 'line'},
      sampleCode: 'TenunChartFromJson(jsonConfig: chartJson)',
    );
    final story = chartStory(
      name: 'Charts/Test/Contract',
      description: 'Contract story',
      contract: contract,
      builder: (context) => const SizedBox(),
    );

    expect(
      chartStoryContractRegistry.contractForStoryName(story.name),
      same(contract),
    );
  });

  testWidgets('fixedHeightChartStory wraps builder output in a SizedBox', (
    tester,
  ) async {
    final story = fixedHeightChartStory(
      name: 'Charts/Test/Fixed',
      description: 'Fixed height story',
      height: 320,
      builder: (context) => const Text('chart'),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(builder: story.builder),
      ),
    );

    final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(box.height, 320);
    expect(find.text('chart'), findsOneWidget);
  });

  testWidgets('centeredChartStory centers the provided child', (tester) async {
    final story = centeredChartStory(
      name: 'Charts/Test/Centered',
      description: 'Centered story',
      child: const Text('chart'),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(builder: story.builder),
      ),
    );

    expect(find.byType(Center), findsOneWidget);
    expect(find.text('chart'), findsOneWidget);
  });
}
