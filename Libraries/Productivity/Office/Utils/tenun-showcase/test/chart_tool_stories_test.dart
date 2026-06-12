import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/story/chart_tool_stories.dart';
import 'package:tenun_showcase/story/chart_story_groups.dart';
import 'package:tenun_showcase/story/charts.dart';

void main() {
  test('chart tool stories stay grouped in navigation order', () {
    expect(chartToolStories.map((story) => story.name), const [
      'Charts/Tools/Chart Export Lab',
      'Charts/Tools/TenunChartJson ForceType Guardrails',
      'Charts/Tools/JSON Render Safety',
      'Charts/Tools/Zoom Legacy Charts',
      'Charts/Tools/Drilldown Bar',
      'Charts/Tools/Large Data Sampling Lab',
      'Charts/Tools/Interaction Reliability Lab',
      'Charts/Tools/Performance Diagnostics Lab',
      'Charts/Tools/Payload Doctor',
      'Charts/Tools/Payload Normalize Playground',
      'Charts/Tools/Registry Health Matrix',
      'Charts/Tools/Registry Health Split Review',
    ]);
  });

  test(
    'top-level chart stories keep tools between discovery and core shapes',
    () {
      final names = charts.map((story) => story.name).toList();
      final discoveryStories = findChartStoryGroupById(
        'data-shape-gallery',
      )!.storyNames;
      final coreShapeStories = findChartStoryGroupById(
        'cartesian-exploration',
      )!.storyNames;
      final lastDiscoveryIndex = names.indexOf(discoveryStories.last);
      final firstToolIndex = names.indexOf(chartToolStories.first.name);
      final lastToolIndex = names.indexOf(chartToolStories.last.name);
      final firstCoreShapeIndex = names.indexOf(coreShapeStories.first);

      expect(lastDiscoveryIndex, isNonNegative);
      expect(firstCoreShapeIndex, isNonNegative);
      expect(firstToolIndex, lastDiscoveryIndex + 1);
      expect(lastToolIndex, firstToolIndex + chartToolStories.length - 1);
      expect(firstCoreShapeIndex, lastToolIndex + 1);
    },
  );
}
