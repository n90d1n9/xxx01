import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/story/chart_cartesian_stories.dart';
import 'package:tenun_showcase/story/chart_data_shape_gallery_stories.dart';
import 'package:tenun_showcase/story/chart_tool_stories.dart';
import 'package:tenun_showcase/story/charts.dart';

void main() {
  test('data-shape gallery stories stay grouped in navigation order', () {
    expect(chartDataShapeGalleryStories.map((story) => story.name), const [
      'Charts/Galleries/Advanced Business & AI-ML',
      'Charts/By Data Shape/Catalog Overview',
      'Charts/By Data Shape/AI & Machine Learning',
      'Charts/By Data Shape/Business & Project Management',
      'Charts/By Data Shape/Hierarchy/Focused Gallery',
      'Charts/By Data Shape/Flow/Focused Gallery',
      'Charts/By Data Shape/Radial/Focused Gallery',
      'Charts/By Data Shape/Geo/Focused Gallery',
      'Charts/By Data Shape/Text-Timeline/Focused Gallery',
      'Charts/By Data Shape/Mixed/Canonical All Gallery',
      'Charts/By Data Shape/Mixed/Stat-Trading-Graph Gallery',
      'Charts/By Data Shape/Mixed/V3 Variant Gallery',
      'Charts/By Data Shape/Cartesian/Simple Charts',
    ]);
  });

  test('top-level chart stories start with gallery and tool stories', () {
    final names = charts.map((story) => story.name).toList();
    final galleryNames = chartDataShapeGalleryStories
        .map((story) => story.name)
        .toList(growable: false);
    final toolNames = chartToolStories
        .map((story) => story.name)
        .toList(growable: false);

    expect(names.take(galleryNames.length), galleryNames);
    expect(names.skip(galleryNames.length).take(toolNames.length), toolNames);
    expect(
      names[galleryNames.length + toolNames.length],
      chartCartesianExplorationStories.first.name,
    );
  });
}
