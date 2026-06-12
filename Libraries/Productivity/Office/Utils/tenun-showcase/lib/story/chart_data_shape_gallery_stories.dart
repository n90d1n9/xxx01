import '../example/advanced_business_ml_gallery.dart';
import '../example/ai_ml_charts_example.dart';
import '../example/all_charts_gallery_example.dart';
import '../example/business_charts_example.dart';
import '../example/chart_sample_showcase.dart';
import '../example/chart_samples_registry.dart';
import '../example/data_shape_galleries_example.dart';
import '../example/new_charts_gallery_example.dart';
import '../example/new_v3_charts_gallery_example.dart';
import '../example/simple_charts_showcase_example.dart';
import 'chart_story_builders.dart';
import 'chart_story_knobs.dart';

final chartDataShapeGalleryStories = [
  chartStory(
    name: 'Charts/Galleries/Advanced Business & AI-ML',
    description: 'All-in-one gallery for Business, Project, and AI/ML charts.',
    builder: (context) => const AdvancedBusinessMLGallery(),
  ),
  fixedHeightChartStory(
    name: 'Charts/By Data Shape/Catalog Overview',
    description: 'Scannable index of focused chart sample families.',
    height: 900,
    builder: (context) => ChartSampleFamilyExplorer(
      families: ChartSamplesRegistry.focusedFamilies,
      options: chartStorySampleShowcaseOptions(context),
    ),
  ),
  chartStory(
    name: 'Charts/By Data Shape/AI & Machine Learning',
    description: 'Confusion Matrix and ROC Curves.',
    builder: (context) =>
        AIMLChartsExample(options: chartStorySampleShowcaseOptions(context)),
  ),
  chartStory(
    name: 'Charts/By Data Shape/Business & Project Management',
    description: 'S-Curve, Pareto, and KPI Indicators.',
    builder: (context) => BusinessChartsExample(
      options: chartStorySampleShowcaseOptions(context),
    ),
  ),
  fixedHeightChartStory(
    name: 'Charts/By Data Shape/Hierarchy/Focused Gallery',
    description: 'Hierarchy-focused charts: treemap and sunburst.',
    height: 1180,
    builder: (context) => HierarchyChartsGalleryExample(
      options: chartStorySampleShowcaseOptions(context),
    ),
  ),
  fixedHeightChartStory(
    name: 'Charts/By Data Shape/Flow/Focused Gallery',
    description:
        'Flow/process-focused charts: funnel, waterfall, sankey, gantt.',
    height: 2250,
    builder: (context) => FlowChartsGalleryExample(
      options: chartStorySampleShowcaseOptions(context),
    ),
  ),
  fixedHeightChartStory(
    name: 'Charts/By Data Shape/Radial/Focused Gallery',
    description: 'Radial-focused charts: gauge, radar, polar bar, radial.',
    height: 2160,
    builder: (context) => RadialChartsGalleryExample(
      options: chartStorySampleShowcaseOptions(context),
    ),
  ),
  fixedHeightChartStory(
    name: 'Charts/By Data Shape/Geo/Focused Gallery',
    description: 'Geo-focused chart: choropleth.',
    height: 720,
    builder: (context) => GeoChartsGalleryExample(
      options: chartStorySampleShowcaseOptions(context),
    ),
  ),
  fixedHeightChartStory(
    name: 'Charts/By Data Shape/Text-Timeline/Focused Gallery',
    description:
        'Timeline/text/date-focused charts: timeline, wordcloud, calendar.',
    height: 1580,
    builder: (context) => TextTimelineChartsGalleryExample(
      options: chartStorySampleShowcaseOptions(context),
    ),
  ),
  fixedHeightChartStory(
    name: 'Charts/By Data Shape/Mixed/Canonical All Gallery',
    description:
        'One page that renders gauge, radar, funnel, waterfall, sankey, sunburst, treemap, gantt, and polar bar.',
    height: 4800,
    builder: (context) => AllChartsGalleryExample(
      options: chartStorySampleShowcaseOptions(context),
    ),
  ),
  fixedHeightChartStory(
    name: 'Charts/By Data Shape/Mixed/Stat-Trading-Graph Gallery',
    description:
        'Gallery for combo, bullet, histogram, lollipop, trading, and advanced statistical charts.',
    height: 10000,
    builder: (context) => NewChartsGalleryExample(
      options: chartStorySampleShowcaseOptions(context),
    ),
  ),
  fixedHeightChartStory(
    name: 'Charts/By Data Shape/Mixed/V3 Variant Gallery',
    description:
        'Gallery for charts from tenun/lib/charts/new (choropleth, slope, dumbbell, area bump, and variants).',
    height: 4800,
    builder: (context) => NewV3ChartsGalleryExample(
      options: chartStorySampleShowcaseOptions(context),
    ),
  ),
  fixedHeightChartStory(
    name: 'Charts/By Data Shape/Cartesian/Simple Charts',
    description:
        'Simple chart gallery with categorical, statistical, flow, hierarchy, relationship, and trend variants including Lorenz, QQ, Bland-Altman, scatter plot matrix, continuous heatmap, dot density, boxen plot, binned dot plot, frequency polygon, rug plot, barcode plot, sina plot, small multiples, punch card, cycle plot, mosaic plot, Likert, tornado, step, bubble matrix, and cohort retention plots.',
    height: 760,
    builder: (context) {
      final knobs = chartStorySimpleChartsKnobs(context);

      return SimpleChartsShowcaseExample(
        barStyle: knobs.barStyle,
        trendStyle: knobs.trendStyle,
        tierFilter: knobs.tierFilter,
        darkMode: knobs.darkMode,
        showGrid: knobs.showGrid,
        showValues: knobs.showValues,
        showTracks: knobs.showTracks,
        showTooltips: knobs.showTooltips,
        showLegends: knobs.showLegends,
        showReferenceLines: knobs.showReferenceLines,
        showReferenceBands: knobs.showReferenceBands,
        showActiveBars: knobs.showActiveBars,
        stackAsPercent: knobs.stackAsPercent,
        showSampleJson: knobs.showSampleJson,
        showSampleCode: knobs.showSampleCode,
        progressiveGalleryLoading: knobs.progressiveGalleryLoading,
        initialVisibleGalleryGroups: knobs.initialVisibleGalleryGroups,
        galleryGroupRevealInterval: knobs.galleryGroupRevealInterval,
      );
    },
  ),
];
