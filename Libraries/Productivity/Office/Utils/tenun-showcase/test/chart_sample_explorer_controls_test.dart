import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/chart_sample_explorer_controls.dart';
import 'package:tenun_showcase/example/chart_sample_explorer_logic.dart';
import 'package:tenun_showcase/example/chart_samples_registry.dart';

import 'support/chart_sample_widget_test_harness.dart';

void main() {
  testWidgets(
    'explorer controls render search, stats, result, and empty state',
    (WidgetTester tester) async {
      final controller = TextEditingController();
      final changes = <String>[];
      var clearCount = 0;
      addTearDown(controller.dispose);

      await pumpChartSampleBody(
        tester,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChartSampleFamilySearchField(
              controller: controller,
              resultLabel: 'Showing 1 of 3 families',
              clearTooltip: 'Clear filters',
              onChanged: changes.add,
              onClear: () => clearCount += 1,
            ),
            const SizedBox(height: 12),
            const ChartFamilyStatsStrip(
              visibleStats: ChartFamilyExplorerStats(
                familyCount: 1,
                sampleCount: 2,
                typeCount: 1,
              ),
              totalStats: ChartFamilyExplorerStats(
                familyCount: 3,
                sampleCount: 8,
                typeCount: 4,
              ),
              filtered: true,
            ),
            const SizedBox(height: 12),
            const ChartSampleResultLabel(visibleCount: 2, totalCount: 5),
            const SizedBox(height: 12),
            const ChartSampleFamilyEmptyState(),
          ],
        ),
      );

      expect(find.text('Search families'), findsOneWidget);
      expect(find.text('Showing 1 of 3 families'), findsOneWidget);
      expect(find.text('Families 1/3'), findsOneWidget);
      expect(find.text('Samples 2/8'), findsOneWidget);
      expect(find.text('Types 1/4'), findsOneWidget);
      expect(find.text('Showing 2 of 5 samples'), findsOneWidget);
      expect(find.text('No chart families found'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'bar');
      await tester.pump();
      await tester.tap(find.byTooltip('Clear filters'));
      await tester.pump();

      expect(changes, ['bar']);
      expect(clearCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('type filter strip and sort control emit selections', (
    WidgetTester tester,
  ) async {
    final selectedTierFilters = <ChartShowcaseTierFilter>[];
    final selectedTypes = <String?>[];
    final selectedSortModes = <ChartFamilySortMode>[];

    await pumpChartSampleBody(
      tester,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChartTierFilterStrip(
            options: const [
              ChartTierFilterOption(
                tierFilter: ChartShowcaseTierFilter.core,
                familyCount: 1,
              ),
              ChartTierFilterOption(
                tierFilter: ChartShowcaseTierFilter.pro,
                familyCount: 2,
              ),
            ],
            totalFamilyCount: 3,
            selectedTierFilter: ChartShowcaseTierFilter.core,
            onSelected: selectedTierFilters.add,
          ),
          const SizedBox(height: 12),
          ChartTypeFilterStrip(
            options: const [
              ChartTypeFilterOption(type: 'bar', familyCount: 2),
              ChartTypeFilterOption(type: 'line', familyCount: 1),
            ],
            totalFamilyCount: 3,
            selectedType: 'bar',
            onSelected: selectedTypes.add,
          ),
          const SizedBox(height: 12),
          ChartFamilySortControl(
            mode: ChartFamilySortMode.name,
            onChanged: selectedSortModes.add,
          ),
        ],
      ),
    );

    expect(find.text('All tiers (3)'), findsOneWidget);
    expect(find.text('Core (1)'), findsOneWidget);
    expect(find.text('Pro (2)'), findsOneWidget);
    expect(find.text('All (3)'), findsOneWidget);
    expect(find.text('bar (2)'), findsOneWidget);
    expect(find.text('line (1)'), findsOneWidget);
    expect(find.text('Sort: Name'), findsOneWidget);

    await tester.tap(find.text('All tiers (3)'));
    await tester.pump();
    await tester.tap(find.text('Pro (2)'));
    await tester.pump();
    await tester.tap(find.text('All (3)'));
    await tester.pump();
    await tester.tap(find.text('line (1)'));
    await tester.pump();

    await tester.tap(find.byTooltip('Sort chart families'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Samples').last);
    await tester.pumpAndSettle();

    expect(selectedTierFilters, [
      ChartShowcaseTierFilter.all,
      ChartShowcaseTierFilter.pro,
    ]);
    expect(selectedTypes, [null, 'line']);
    expect(selectedSortModes, [ChartFamilySortMode.samples]);
    expect(tester.takeException(), isNull);
  });
}
