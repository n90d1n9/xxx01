import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/story/chart_cartesian_stories.dart';
import 'package:tenun_showcase/story/chart_data_shape_gallery_stories.dart';
import 'package:tenun_showcase/story/chart_tool_stories.dart';
import 'package:tenun_showcase/story/charts.dart';

void main() {
  test('cartesian stories stay in family order', () {
    expect(chartCartesianStories.map((story) => story.name), const [
      'Charts/By Data Shape/Cartesian/Area Variants',
      'Charts/By Data Shape/Cartesian/Area Knobs',
      'Charts/By Data Shape/Cartesian/Line Variants',
      'Charts/By Data Shape/Cartesian/Line Knobs',
      'Charts/By Data Shape/Smart Type Switch',
      'Charts/By Data Shape/Cartesian/Bar/Simple',
      'Charts/By Data Shape/Cartesian/Bar/Grouped',
      'Charts/By Data Shape/Cartesian/Bar/Stacked',
      'Charts/By Data Shape/Cartesian/Bar/Horizontal',
      'Charts/By Data Shape/Cartesian/Bar/Gradient',
      'Charts/By Data Shape/Cartesian/Bar/Negative Values',
      'Charts/By Data Shape/Cartesian/Bar/Custom Colors',
      'Charts/By Data Shape/Cartesian/Bar/Mixed Bar-Line',
      'Charts/By Data Shape/Cartesian/Bar/JSON Showcase',
      'Charts/By Data Shape/Cartesian/Bar/Legacy Multi',
      'Charts/By Data Shape/Cartesian/Bar/Legacy Stacked',
      'Charts/By Data Shape/Cartesian/Scatter/Basic',
    ]);
  });

  test('top-level chart stories keep tools before cartesian groups', () {
    final names = charts.map((story) => story.name).toList();
    final galleryEndIndex = chartDataShapeGalleryStories.length - 1;
    final firstExplorationIndex = names.indexOf(
      chartCartesianExplorationStories.first.name,
    );
    final lastExplorationIndex = names.indexOf(
      chartCartesianExplorationStories.last.name,
    );
    final firstToolIndex = names.indexOf(chartToolStories.first.name);
    final lastToolIndex = names.indexOf(chartToolStories.last.name);
    final firstVariantIndex = names.indexOf(
      chartCartesianVariantStories.first.name,
    );
    final lastVariantIndex = names.indexOf(
      chartCartesianVariantStories.last.name,
    );

    expect(firstToolIndex, galleryEndIndex + 1);
    expect(lastToolIndex, firstToolIndex + chartToolStories.length - 1);
    expect(firstExplorationIndex, lastToolIndex + 1);
    expect(
      lastExplorationIndex,
      firstExplorationIndex + chartCartesianExplorationStories.length - 1,
    );
    expect(firstVariantIndex, lastExplorationIndex + 1);
    expect(
      lastVariantIndex,
      firstVariantIndex + chartCartesianVariantStories.length - 1,
    );
    expect(
      names[lastVariantIndex + 1],
      'Charts/By Data Shape/Matrix/Heatmap/Basic',
    );
  });
}
