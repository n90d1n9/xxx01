import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:tenun/tenun_core.dart'
    show SimpleBarChartStyle, SimpleTrendChartStyle;
import 'package:tenun_showcase/example/chart_sample_source_helpers.dart';
import 'package:tenun_showcase/example/simple_charts_showcase_families.dart';
import 'package:tenun_showcase/story/chart_story_knobs.dart';

void main() {
  test('data mode knobs report advanced state from selected mode', () {
    expect(
      const ChartStoryDataModeKnobs(
        dataMode: 'regular',
        pointCount: 2500,
        samplingThreshold: 600,
        samplingStrategyIndex: 0,
      ).advancedEnabled,
      isFalse,
    );
    expect(
      const ChartStoryDataModeKnobs(
        dataMode: 'large',
        pointCount: 2500,
        samplingThreshold: 600,
        samplingStrategyIndex: 0,
      ).advancedEnabled,
      isTrue,
    );
  });

  testWidgets('display knobs wrap children in matching theme brightness', (
    tester,
  ) async {
    Brightness? brightness;

    await tester.pumpWidget(
      MaterialApp(
        home: const ChartStoryDisplayKnobs(isDark: true, showTooltip: false)
            .wrapThemed(
              Builder(
                builder: (context) {
                  brightness = Theme.of(context).brightness;
                  return const SizedBox.shrink();
                },
              ),
            ),
      ),
    );

    expect(brightness, Brightness.dark);
  });

  testWidgets('interactive data knobs combine theme, tooltip, and sampling', (
    tester,
  ) async {
    late ChartStoryInteractiveDataKnobs knobs;

    await tester.pumpWidget(
      Storybook(
        initialStory: 'Probe',
        stories: [
          Story(
            name: 'Probe',
            builder: (context) {
              knobs = chartStoryInteractiveDataKnobs(
                context,
                initialDark: true,
                initialTooltip: false,
                initialDataMode: 'large',
                initialPointCount: 1200,
                initialSamplingThreshold: 400,
              );
              return const SizedBox.shrink();
            },
          ),
        ],
        wrapperBuilder: (_, child) => MaterialApp(home: child),
      ),
    );
    await tester.pump();

    expect(knobs.isDark, isTrue);
    expect(knobs.showTooltip, isFalse);
    expect(knobs.dataMode, 'large');
    expect(knobs.pointCount, 1200);
    expect(knobs.samplingThreshold, 400);
    expect(knobs.samplingStrategyIndex, 0);
    expect(knobs.sampling.advancedEnabled, isTrue);
  });

  testWidgets('cartesian display knobs expose shared visual toggles', (
    tester,
  ) async {
    late ChartStoryCartesianDisplayKnobs display;

    await tester.pumpWidget(
      Storybook(
        initialStory: 'Probe',
        stories: [
          Story(
            name: 'Probe',
            builder: (context) {
              display = chartStoryCartesianDisplayKnobs(
                context,
                labelPrefix: 'Line',
                initialLegend: false,
                initialTooltip: false,
                initialGrid: false,
                initialDots: false,
              );
              return const SizedBox.shrink();
            },
          ),
        ],
        wrapperBuilder: (_, child) => MaterialApp(home: child),
      ),
    );
    await tester.pump();

    expect(display.showLegend, isFalse);
    expect(display.showTooltip, isFalse);
    expect(display.showGrid, isFalse);
    expect(display.showDots, isFalse);
  });

  testWidgets('sample showcase option knobs expose copy-ready defaults', (
    tester,
  ) async {
    late ChartSampleShowcaseOptions options;

    await tester.pumpWidget(
      Storybook(
        initialStory: 'Probe',
        stories: [
          Story(
            name: 'Probe',
            builder: (context) {
              options = chartStorySampleShowcaseOptions(
                context,
                initialSampleJson: false,
                initialSampleCode: false,
                initialLegend: false,
                initialTooltip: false,
                chartPadding: 12,
                sourcePanelHeight: 144,
                sourcePanelMinWidth: 320,
              );
              return const SizedBox.shrink();
            },
          ),
        ],
        wrapperBuilder: (_, child) => MaterialApp(home: child),
      ),
    );
    await tester.pump();

    expect(options.showSampleJson, isFalse);
    expect(options.showSampleCode, isFalse);
    expect(options.showLegend, isFalse);
    expect(options.showTooltip, isFalse);
    expect(options.chartPadding, 12);
    expect(options.sourcePanelHeight, 144);
    expect(options.sourcePanelMinWidth, 320);
  });

  testWidgets('area knobs combine cartesian display and sampling config', (
    tester,
  ) async {
    late ChartStoryAreaKnobs knobs;

    await tester.pumpWidget(
      Storybook(
        initialStory: 'Probe',
        stories: [
          Story(
            name: 'Probe',
            builder: (context) {
              knobs = chartStoryAreaKnobs(context, initialGradientArea: false);
              return const SizedBox.shrink();
            },
          ),
        ],
        wrapperBuilder: (_, child) => MaterialApp(home: child),
      ),
    );
    await tester.pump();

    expect(knobs.showLegend, isTrue);
    expect(knobs.showTooltip, isTrue);
    expect(knobs.showGrid, isTrue);
    expect(knobs.showDots, isTrue);
    expect(knobs.gradientArea, isFalse);
    expect(knobs.dataMode, 'regular');
    expect(knobs.pointCount, 2500);
    expect(knobs.samplingThreshold, 600);
    expect(knobs.samplingStrategyIndex, 0);
  });

  testWidgets('line knobs combine cartesian display and curve config', (
    tester,
  ) async {
    late ChartStoryLineKnobs knobs;

    await tester.pumpWidget(
      Storybook(
        initialStory: 'Probe',
        stories: [
          Story(
            name: 'Probe',
            builder: (context) {
              knobs = chartStoryLineKnobs(context, initialCurveSmoothness: 0.4);
              return const SizedBox.shrink();
            },
          ),
        ],
        wrapperBuilder: (_, child) => MaterialApp(home: child),
      ),
    );
    await tester.pump();

    expect(knobs.showLegend, isTrue);
    expect(knobs.showGrid, isTrue);
    expect(knobs.showDots, isTrue);
    expect(knobs.curveSmoothness, 0.4);
    expect(knobs.dataMode, 'regular');
    expect(knobs.pointCount, 2500);
    expect(knobs.samplingThreshold, 600);
    expect(knobs.samplingStrategyIndex, 0);
  });

  testWidgets('simple charts knobs return typed style and loading config', (
    tester,
  ) async {
    late ChartStorySimpleChartsKnobs knobs;

    await tester.pumpWidget(
      Storybook(
        initialStory: 'Probe',
        stories: [
          Story(
            name: 'Probe',
            builder: (context) {
              knobs = chartStorySimpleChartsKnobs(
                context,
                initialBarStyle: SimpleBarChartStyle.trendy,
                initialTrendStyle: SimpleTrendChartStyle.professional,
                initialTierFilter: SimpleChartsShowcaseTierFilter.pro,
                initialDarkMode: true,
                initialShowGrid: false,
                initialShowValues: false,
                initialShowTracks: false,
                initialShowTooltips: false,
                initialShowLegends: false,
                initialShowReferenceLines: false,
                initialShowReferenceBands: false,
                initialShowActiveBars: false,
                initialStackAsPercent: true,
                initialShowSampleJson: true,
                initialShowSampleCode: true,
                initialProgressiveGalleryLoading: false,
                initialVisibleGalleryGroups: 3,
                initialGalleryGroupRevealIntervalMs: 700,
              );
              return const SizedBox.shrink();
            },
          ),
        ],
        wrapperBuilder: (_, child) => MaterialApp(home: child),
      ),
    );
    await tester.pump();

    expect(knobs.barStyle, SimpleBarChartStyle.trendy);
    expect(knobs.trendStyle, SimpleTrendChartStyle.professional);
    expect(knobs.tierFilter, SimpleChartsShowcaseTierFilter.pro);
    expect(knobs.darkMode, isTrue);
    expect(knobs.showGrid, isFalse);
    expect(knobs.showValues, isFalse);
    expect(knobs.showTracks, isFalse);
    expect(knobs.showTooltips, isFalse);
    expect(knobs.showLegends, isFalse);
    expect(knobs.showReferenceLines, isFalse);
    expect(knobs.showReferenceBands, isFalse);
    expect(knobs.showActiveBars, isFalse);
    expect(knobs.stackAsPercent, isTrue);
    expect(knobs.showSampleJson, isTrue);
    expect(knobs.showSampleCode, isTrue);
    expect(knobs.progressiveGalleryLoading, isFalse);
    expect(knobs.initialVisibleGalleryGroups, 3);
    expect(knobs.galleryGroupRevealInterval, const Duration(milliseconds: 700));
  });
}
