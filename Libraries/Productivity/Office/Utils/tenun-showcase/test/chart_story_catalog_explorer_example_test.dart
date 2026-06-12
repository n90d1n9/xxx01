import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenun_showcase/example/chart_story_catalog_explorer_example.dart';
import 'package:tenun_showcase/example/chart_story_catalog_explorer_parts.dart';
import 'package:tenun_showcase/story/chart_story_contract_coverage.dart';
import 'package:tenun_showcase/story/chart_story_groups.dart';
import 'package:tenun_showcase/story/chart_story_tier.dart';
import 'package:tenun_showcase/story/chart_story_tier_coverage.dart';

void main() {
  testWidgets('story catalog explorer renders catalog metrics and entries', (
    tester,
  ) async {
    final coverage = ChartStoryContractCoverage.fromCatalog(chartStoryCatalog);
    final tierSummaries = chartStoryTierContractCoverageSummaries(
      chartStoryCatalog,
    );
    final proTierSummary = tierSummaries.singleWhere(
      (summary) => summary.tierKey == ChartStoryTier.pro.key,
    );

    await _pumpExplorer(tester);

    expect(find.text('Story Catalog Explorer'), findsOneWidget);
    expect(find.text('Groups'), findsOneWidget);
    expect(find.text('Stories'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Families'), findsOneWidget);
    expect(find.text('Contract coverage'), findsOneWidget);
    expect(find.text('Tier readiness'), findsOneWidget);
    expect(find.text('Quick views'), findsOneWidget);
    expect(find.text('Sort results'), findsOneWidget);
    expect(find.text('Group results'), findsOneWidget);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('Gaps'), findsOneWidget);
    expect(
      find.text(
        '${coverage.readyCount} of ${coverage.totalCount} stories are contract ready.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        '${proTierSummary.readyCount} / ${proTierSummary.totalCount} ready',
      ),
      findsOneWidget,
    );
    expect(find.byTooltip(ChartStoryTier.pro.description), findsWidgets);
    expect(find.textContaining('Toggle autoNormalizePayload'), findsOneWidget);
  });

  testWidgets('story catalog explorer renders custom landing copy', (
    tester,
  ) async {
    await _pumpExplorer(
      tester,
      title: 'Tooling Stories',
      subtitle:
          'Diagnostics, safety, export, performance, and authoring tools.',
    );

    expect(find.text('Tooling Stories'), findsOneWidget);
    expect(
      find.text(
        'Diagnostics, safety, export, performance, and authoring tools.',
      ),
      findsOneWidget,
    );
    expect(find.text('Story Catalog Explorer'), findsNothing);
  });

  testWidgets('story catalog explorer filters by search query', (tester) async {
    await _pumpExplorer(tester);

    await tester.enterText(find.byType(TextField), 'temperature heatmap');
    await tester.pump();

    expect(find.text('Basic'), findsOneWidget);
    expect(find.textContaining('Temperature heatmap example.'), findsOneWidget);
    expect(find.textContaining('Toggle autoNormalizePayload'), findsNothing);
  });

  testWidgets('story catalog explorer expands coverage starter bundle', (
    tester,
  ) async {
    await _pumpExplorer(tester);

    await tester.ensureVisible(
      find.widgetWithText(TextButton, 'Starter bundle'),
    );
    await tester.tap(find.widgetWithText(TextButton, 'Starter bundle'));
    await tester.pumpAndSettle();

    expect(find.text('Starter bundle'), findsWidgets);
    expect(find.textContaining('Copy the next'), findsOneWidget);
    expect(find.textContaining('ChartStoryContract('), findsOneWidget);
  });

  testWidgets('story catalog explorer filters by contract status chip', (
    tester,
  ) async {
    final coverage = ChartStoryContractCoverage.fromCatalog(chartStoryCatalog);
    final visibleReadyCount = coverage.readyCount > 80
        ? 80
        : coverage.readyCount;

    await _pumpExplorer(tester);

    await tester.ensureVisible(find.widgetWithText(FilterChip, 'Ready'));
    await tester.tap(find.widgetWithText(FilterChip, 'Ready'));
    await tester.pump();

    expect(find.text('Contract: Ready'), findsOneWidget);
    expect(
      find.text(
        'Showing $visibleReadyCount of ${coverage.readyCount} matching stories',
      ),
      findsOneWidget,
    );
    expect(find.text('Simple'), findsWidgets);

    await tester.ensureVisible(find.text('Clear filters'));
    await tester.tap(find.widgetWithText(TextButton, 'Clear filters'));
    await tester.pump();

    expect(find.text('Contract: Ready'), findsNothing);
    expect(find.text('Active filters'), findsNothing);
  });

  testWidgets('story catalog explorer finds stories missing contracts', (
    tester,
  ) async {
    final coverage = ChartStoryContractCoverage.fromCatalog(chartStoryCatalog);
    final visibleMissingCount = coverage.missingContractCount > 80
        ? 80
        : coverage.missingContractCount;

    await _pumpExplorer(tester);

    await tester.ensureVisible(
      find.widgetWithText(FilterChip, 'Needs contract'),
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Needs contract'));
    await tester.pump();

    expect(find.text('Contract: Needs contract'), findsOneWidget);
    expect(
      find.text(
        'Showing $visibleMissingCount of ${coverage.missingContractCount} matching stories',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Toggle autoNormalizePayload'), findsOneWidget);
  });

  testWidgets('story catalog explorer applies initial contract status', (
    tester,
  ) async {
    final coverage = ChartStoryContractCoverage.fromCatalog(chartStoryCatalog);
    final visibleJsonGapCount = coverage.totalCount - coverage.sampleJsonCount;
    final visibleCount = visibleJsonGapCount > 80 ? 80 : visibleJsonGapCount;

    await _pumpExplorer(
      tester,
      initialContractStatus: ChartStoryContractStatusFilter.needsSampleJson,
    );

    expect(find.text('Contract: Needs JSON'), findsOneWidget);
    expect(
      find.text(
        'Showing $visibleCount of $visibleJsonGapCount matching stories',
      ),
      findsOneWidget,
    );
  });

  testWidgets('story catalog explorer shows facet counts', (tester) async {
    await _pumpExplorer(tester);

    final toolsChip = find.widgetWithText(FilterChip, 'Tools');
    final toolsGroupChip = find.widgetWithText(FilterChip, 'Tools (Tooling)');
    final toolingChip = find.widgetWithText(FilterChip, 'Tooling');
    final barChip = find.widgetWithText(FilterChip, 'Bar');
    final toolsCount = chartStoryCatalog.entriesForSection('Tools').length;
    final toolsGroupCount = chartStoryCatalog.entriesForGroupId('tools').length;
    final toolingCount = chartStoryCatalog.entriesForCategory('Tooling').length;
    final barCount = chartStoryCatalog.entriesForFamily('Bar').length;

    expect(toolingChip, findsOneWidget);
    expect(
      find.descendant(of: toolingChip, matching: find.text('$toolingCount')),
      findsOneWidget,
    );

    expect(toolsGroupChip, findsOneWidget);
    expect(
      find.descendant(
        of: toolsGroupChip,
        matching: find.text('$toolsGroupCount'),
      ),
      findsOneWidget,
    );

    expect(toolsChip, findsOneWidget);
    expect(
      find.descendant(of: toolsChip, matching: find.text('$toolsCount')),
      findsOneWidget,
    );

    await _expandFacetUntilVisible(tester, 'Bar');
    await tester.ensureVisible(barChip);

    expect(barChip, findsOneWidget);
    expect(
      find.descendant(of: barChip, matching: find.text('$barCount')),
      findsOneWidget,
    );
  });

  testWidgets('story catalog explorer contextualizes facet counts', (
    tester,
  ) async {
    const query = 'temperature heatmap';
    final matchingEntries = chartStoryCatalog.entriesMatchingQuery(query);
    final coreShapeCount = matchingEntries
        .where((entry) => entry.categoryLabel == 'Core Shapes')
        .length;
    final matrixCount = matchingEntries
        .where((entry) => entry.dataShape == 'Matrix')
        .length;

    await _pumpExplorer(tester, initialQuery: query);

    final toolsChip = find.widgetWithText(FilterChip, 'Tools');
    final toolsGroupChip = find.widgetWithText(FilterChip, 'Tools (Tooling)');
    final toolingChip = find.widgetWithText(FilterChip, 'Tooling');
    final coreShapesChip = find.widgetWithText(FilterChip, 'Core Shapes');
    final matrixChip = find.widgetWithText(FilterChip, 'Matrix');

    expect(toolingChip, findsOneWidget);
    expect(
      find.descendant(of: toolingChip, matching: find.text('0')),
      findsOneWidget,
    );
    expect(tester.widget<FilterChip>(toolingChip).onSelected, isNull);

    expect(toolsGroupChip, findsOneWidget);
    expect(
      find.descendant(of: toolsGroupChip, matching: find.text('0')),
      findsOneWidget,
    );
    expect(tester.widget<FilterChip>(toolsGroupChip).onSelected, isNull);

    expect(coreShapesChip, findsOneWidget);
    expect(
      find.descendant(
        of: coreShapesChip,
        matching: find.text('$coreShapeCount'),
      ),
      findsOneWidget,
    );
    expect(tester.widget<FilterChip>(coreShapesChip).onSelected, isNotNull);

    expect(toolsChip, findsOneWidget);
    expect(
      find.descendant(of: toolsChip, matching: find.text('0')),
      findsOneWidget,
    );
    expect(tester.widget<FilterChip>(toolsChip).onSelected, isNull);

    expect(matrixChip, findsOneWidget);
    expect(
      find.descendant(of: matrixChip, matching: find.text('$matrixCount')),
      findsOneWidget,
    );
    expect(tester.widget<FilterChip>(matrixChip).onSelected, isNotNull);
  });

  testWidgets('story catalog explorer filters by section chip', (tester) async {
    await _pumpExplorer(tester);

    await tester.ensureVisible(find.widgetWithText(FilterChip, 'Tools'));
    await tester.tap(find.widgetWithText(FilterChip, 'Tools'));
    await tester.pump();

    expect(find.textContaining('Tools / Payload Doctor'), findsOneWidget);
    expect(find.textContaining('By Data Shape / Cartesian'), findsNothing);
  });

  testWidgets('story catalog explorer filters by category chip', (
    tester,
  ) async {
    final toolingCount = chartStoryCatalog.entriesForCategory('Tooling').length;

    await _pumpExplorer(tester);

    await tester.ensureVisible(find.widgetWithText(FilterChip, 'Tooling'));
    await tester.tap(find.widgetWithText(FilterChip, 'Tooling'));
    await tester.pump();

    expect(find.text('Category: Tooling'), findsOneWidget);
    expect(
      find.text('Showing $toolingCount of $toolingCount matching stories'),
      findsOneWidget,
    );
    expect(find.textContaining('Tools / Payload Doctor'), findsOneWidget);
    expect(find.textContaining('By Data Shape / Cartesian'), findsNothing);
  });

  testWidgets('story catalog explorer filters by tier chip', (tester) async {
    final proCount = chartStoryCatalog
        .entriesForTier(ChartStoryTier.pro.key)
        .length;
    final visibleProCount = proCount > 80 ? 80 : proCount;

    await _pumpExplorer(tester);

    await tester.ensureVisible(find.widgetWithText(FilterChip, 'Pro'));
    expect(find.byTooltip(ChartStoryTier.pro.description), findsWidgets);
    expect(
      find.descendant(
        of: find.widgetWithText(FilterChip, 'Pro'),
        matching: find.byIcon(Icons.workspace_premium_outlined),
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilterChip, 'Pro'));
    await tester.pump();

    expect(find.text('Tier: Pro'), findsOneWidget);
    expect(find.byTooltip(ChartStoryTier.pro.description), findsWidgets);
    expect(
      find.text('Showing $visibleProCount of $proCount matching stories'),
      findsOneWidget,
    );
    expect(find.textContaining('By Data Shape / Matrix'), findsWidgets);
    expect(
      find.textContaining('By Data Shape / Cartesian / Bar'),
      findsNothing,
    );
  });

  testWidgets('story catalog explorer filters by group chip', (tester) async {
    final toolsGroupCount = chartStoryCatalog.entriesForGroupId('tools').length;

    await _pumpExplorer(tester);

    await tester.ensureVisible(
      find.widgetWithText(FilterChip, 'Tools (Tooling)'),
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Tools (Tooling)'));
    await tester.pump();

    expect(find.text('Group: Tools'), findsOneWidget);
    expect(
      find.text(
        'Showing $toolsGroupCount of $toolsGroupCount matching stories',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Tools / Payload Doctor'), findsOneWidget);
    expect(find.textContaining('By Data Shape / Cartesian'), findsNothing);
  });

  testWidgets('story catalog explorer applies quick view presets', (
    tester,
  ) async {
    final coverage = ChartStoryContractCoverage.fromCatalog(chartStoryCatalog);
    final visibleGapCount = coverage.gapCount > 80 ? 80 : coverage.gapCount;
    final coreShapeCount = chartStoryCatalog
        .entriesForCategory('Core Shapes')
        .length;
    final visibleCoreShapeCount = coreShapeCount > 80 ? 80 : coreShapeCount;

    await _pumpExplorer(tester);

    await tester.ensureVisible(find.widgetWithText(FilterChip, 'Review gaps'));
    await tester.tap(find.widgetWithText(FilterChip, 'Review gaps'));
    await tester.pump();

    expect(find.text('Contract: Needs work'), findsOneWidget);
    expect(
      find.text(
        'Showing $visibleGapCount of ${coverage.gapCount} matching stories',
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.widgetWithText(FilterChip, 'Core shapes'));
    await tester.tap(find.widgetWithText(FilterChip, 'Core shapes'));
    await tester.pump();

    expect(find.text('Category: Core Shapes'), findsOneWidget);
    expect(find.text('Contract: Needs work'), findsNothing);
    expect(
      find.text(
        'Showing $visibleCoreShapeCount of $coreShapeCount matching stories',
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.widgetWithText(FilterChip, 'Pro tier'));
    await tester.tap(find.widgetWithText(FilterChip, 'Pro tier'));
    await tester.pump();

    final proCount = chartStoryCatalog
        .entriesForTier(ChartStoryTier.pro.key)
        .length;
    final visibleProCount = proCount > 80 ? 80 : proCount;
    expect(find.text('Tier: Pro'), findsOneWidget);
    expect(find.text('Category: Core Shapes'), findsNothing);
    expect(
      find.text('Showing $visibleProCount of $proCount matching stories'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.widgetWithText(FilterChip, 'All stories'));
    await tester.tap(find.widgetWithText(FilterChip, 'All stories'));
    await tester.pump();

    expect(find.text('Active filters'), findsNothing);
  });

  testWidgets('story catalog explorer filters by family chip', (tester) async {
    await _pumpExplorer(tester);

    await _expandFacetUntilVisible(tester, 'Bar');
    await tester.ensureVisible(find.widgetWithText(FilterChip, 'Bar'));
    await tester.tap(find.widgetWithText(FilterChip, 'Bar'));
    await tester.pump();

    expect(
      find.textContaining('By Data Shape / Cartesian / Bar / Simple'),
      findsOneWidget,
    );
    expect(find.textContaining('Toggle autoNormalizePayload'), findsNothing);
  });

  testWidgets('story catalog explorer groups results by category', (
    tester,
  ) async {
    const query = 'temperature heatmap';
    final matchingEntries = chartStoryCatalog.entriesMatchingQuery(query);
    final category = matchingEntries.first.categoryLabel;
    final categoryCount = matchingEntries
        .where((entry) => entry.categoryLabel == category)
        .length;

    await _pumpExplorer(tester, initialQuery: query);

    expect(find.text('$category ($categoryCount)'), findsOneWidget);
    expect(find.text('Basic'), findsOneWidget);
    expect(find.text('Matrix'), findsWidgets);
    expect(find.text('Heatmap'), findsWidgets);
  });

  testWidgets('story catalog explorer switches result grouping modes', (
    tester,
  ) async {
    const query = 'survey category';
    final matchingEntries = chartStoryCatalog.entriesMatchingQuery(query);
    final entry = matchingEntries.single;

    await _pumpExplorer(tester, initialQuery: query);

    expect(find.text('${entry.categoryLabel} (1)'), findsOneWidget);

    await tester.ensureVisible(find.text('Group results'));
    await tester.tap(find.text('Group').last);
    await tester.pump();

    expect(find.text('${entry.groupLabel} (1)'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(-500, 0),
    );
    await tester.pump();
    await tester.tap(find.text('Contract').last);
    await tester.pump();

    expect(
      find.text('${chartStoryContractReadinessLabel(entry)} (1)'),
      findsOneWidget,
    );
  });

  testWidgets('story catalog explorer groups results by tier', (tester) async {
    final coreCount = chartStoryCatalog
        .entriesForTier(ChartStoryTier.core.key)
        .length;
    final proCount = chartStoryCatalog
        .entriesForTier(ChartStoryTier.pro.key)
        .length;

    await _pumpExplorer(tester);

    await tester.ensureVisible(find.text('Group results'));
    await tester.tap(find.text('Tier').last);
    await tester.pump();

    expect(find.text('Core ($coreCount)'), findsOneWidget);
    expect(find.text('Pro ($proCount)'), findsOneWidget);
  });

  testWidgets('story catalog explorer shows contract metadata chips', (
    tester,
  ) async {
    final entry = chartStoryCatalog.entryByName(
      'Charts/By Data Shape/Cartesian/Bar/Simple',
    )!;

    await _pumpExplorer(tester, initialQuery: 'survey category');

    expect(find.text(entry.leaf!), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ChartCatalogResultTile).first,
        matching: find.text(entry.tierLabel),
      ),
      findsOneWidget,
    );
    expect(find.text('${entry.knobs.length} knobs'), findsWidgets);
    expect(find.text('JSON'), findsWidgets);
    expect(find.text('Code'), findsWidgets);
    expect(find.text('Ready'), findsWidgets);
    expect(find.textContaining('Missing:'), findsNothing);
  });

  testWidgets('story catalog explorer shows pro tier metadata on results', (
    tester,
  ) async {
    final entry = chartStoryCatalog.entryByName(
      'Charts/By Data Shape/Matrix/Heatmap/Basic',
    )!;

    await _pumpExplorer(tester, initialQuery: 'temperature heatmap');

    expect(find.text(entry.leaf!), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ChartCatalogResultTile).first,
        matching: find.text(entry.tierLabel),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'story catalog explorer shows missing contract parts on results',
    (tester) async {
      await _pumpExplorer(tester, initialQuery: 'Toggle autoNormalizePayload');

      expect(find.text('Needs contract'), findsWidgets);
      expect(
        find.text('Missing: contract, knobs, sample JSON, sample code'),
        findsWidgets,
      );
    },
  );

  testWidgets('story catalog explorer expands starter contract scaffold', (
    tester,
  ) async {
    await _pumpExplorer(tester, initialQuery: 'Toggle autoNormalizePayload');

    await tester.ensureVisible(find.text('Starter contract'));
    await tester.tap(find.text('Starter contract'));
    await tester.pumpAndSettle();

    expect(find.text('Contract starter'), findsOneWidget);
    expect(find.textContaining('ChartStoryContract('), findsOneWidget);
    expect(
      find.textContaining('toolsPayloadNormalizePlaygroundStoryContract'),
      findsOneWidget,
    );
  });

  testWidgets('story catalog explorer expands story contract details', (
    tester,
  ) async {
    await _pumpExplorer(tester, initialQuery: 'survey category');

    await tester.ensureVisible(find.text('Story contract'));
    await tester.tap(find.text('Story contract'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Simple bar chart story with business-neutral'),
      findsWidgets,
    );
    expect(find.text('Use cases'), findsOneWidget);
    expect(find.text('Survey category comparison'), findsOneWidget);
    expect(find.text('Knobs'), findsWidgets);
    expect(find.text('Sample JSON'), findsOneWidget);
    expect(find.text('Dart Code'), findsOneWidget);
    expect(find.text('Docs Markdown'), findsOneWidget);
  });

  testWidgets('story catalog explorer expands and collapses long facets', (
    tester,
  ) async {
    expect(chartStoryCatalog.families.length, greaterThan(10));
    final hiddenFamily = chartStoryCatalog.families[10];

    await _pumpExplorer(tester);

    expect(find.widgetWithText(FilterChip, hiddenFamily), findsNothing);

    await _expandFacetUntilVisible(tester, hiddenFamily);

    expect(find.widgetWithText(FilterChip, hiddenFamily), findsOneWidget);
    expect(find.text('Show fewer'), findsWidgets);

    await tester.ensureVisible(find.text('Show fewer').last);
    await tester.tap(find.text('Show fewer').last);
    await tester.pump();

    expect(find.widgetWithText(FilterChip, hiddenFamily), findsNothing);
  });

  testWidgets('story catalog explorer keeps selected hidden facets visible', (
    tester,
  ) async {
    expect(chartStoryCatalog.families.length, greaterThan(10));
    final hiddenFamily = chartStoryCatalog.families[10];

    await _pumpExplorer(tester, initialFamily: hiddenFamily);

    expect(find.widgetWithText(FilterChip, hiddenFamily), findsOneWidget);
    expect(find.text('Family: $hiddenFamily'), findsOneWidget);
  });

  testWidgets('story catalog explorer sorts results by title', (tester) async {
    final sortedEntries = chartStoryCatalog.entries.toList(growable: false)
      ..sort(_compareStoryTitle);
    final expectedTitle = sortedEntries.first.leaf ?? sortedEntries.first.name;

    await _pumpExplorer(tester);

    await tester.ensureVisible(find.text('A-Z'));
    await tester.tap(find.text('A-Z'));
    await tester.pump();

    final firstTile = tester.widget<ListTile>(find.byType(ListTile).first);
    final firstTitle = firstTile.title! as Text;
    expect(firstTitle.data, expectedTitle);
  });

  testWidgets('story catalog explorer resets from empty results', (
    tester,
  ) async {
    await _pumpExplorer(tester, initialQuery: 'chart family does not exist');

    expect(find.text('No matching stories'), findsOneWidget);
    expect(find.text('Reset search and filters'), findsOneWidget);
    expect(find.textContaining('Toggle autoNormalizePayload'), findsNothing);

    await tester.ensureVisible(find.text('Reset search and filters'));
    await tester.tap(
      find.widgetWithText(TextButton, 'Reset search and filters'),
    );
    await tester.pump();

    final searchField = tester.widget<TextField>(find.byType(TextField));
    expect(searchField.controller?.text, isEmpty);
    expect(find.text('No matching stories'), findsNothing);
    expect(find.text('Active filters'), findsNothing);
    expect(find.textContaining('Toggle autoNormalizePayload'), findsOneWidget);
  });

  testWidgets('story catalog explorer syncs updated initial filters', (
    tester,
  ) async {
    await _pumpExplorer(
      tester,
      initialQuery: 'payload normalize',
      initialCategory: 'Tooling',
      initialGroupId: 'tools',
      initialSection: 'Tools',
    );

    expect(find.textContaining('Toggle autoNormalizePayload'), findsOneWidget);

    await _pumpExplorer(
      tester,
      initialQuery: 'temperature heatmap',
      initialTier: ChartStoryTier.pro.key,
      initialCategory: 'Core Shapes',
      initialGroupId: 'matrix',
      initialDataShape: 'Matrix',
      initialFamily: 'Heatmap',
    );
    await tester.pump();

    expect(find.text('Basic'), findsOneWidget);
    expect(find.text('Tier: Pro'), findsOneWidget);
    expect(find.textContaining('Temperature heatmap example.'), findsOneWidget);
    expect(find.textContaining('Toggle autoNormalizePayload'), findsNothing);
  });

  testWidgets('story catalog explorer summarizes and clears active filters', (
    tester,
  ) async {
    await _pumpExplorer(
      tester,
      initialQuery: 'payload normalize',
      initialTier: ChartStoryTier.core.key,
      initialCategory: 'Tooling',
      initialGroupId: 'tools',
      initialSection: 'Tools',
    );

    expect(find.text('Active filters'), findsOneWidget);
    expect(find.text('Search: payload normalize'), findsOneWidget);
    expect(find.text('Tier: Core'), findsOneWidget);
    expect(find.byTooltip(ChartStoryTier.core.description), findsWidgets);
    expect(find.text('Category: Tooling'), findsOneWidget);
    expect(find.text('Group: Tools'), findsOneWidget);
    expect(find.text('Section: Tools'), findsOneWidget);
    expect(find.textContaining('Toggle autoNormalizePayload'), findsOneWidget);

    await tester.ensureVisible(find.text('Clear filters'));
    await tester.tap(find.widgetWithText(TextButton, 'Clear filters'));
    await tester.pump();

    final searchField = tester.widget<TextField>(find.byType(TextField));
    expect(searchField.controller?.text, isEmpty);
    expect(find.text('Active filters'), findsNothing);
    expect(find.text('Search: payload normalize'), findsNothing);
    expect(find.text('Tier: Core'), findsNothing);
    expect(find.text('Category: Tooling'), findsNothing);
    expect(find.text('Group: Tools'), findsNothing);
    expect(find.text('Section: Tools'), findsNothing);
    expect(find.textContaining('Toggle autoNormalizePayload'), findsOneWidget);
  });
}

Future<void> _pumpExplorer(
  WidgetTester tester, {
  String title = 'Story Catalog Explorer',
  String? subtitle,
  String initialQuery = '',
  String? initialTier,
  String? initialCategory,
  String? initialGroupId,
  String? initialSection,
  String? initialDataShape,
  String? initialFamily,
  ChartStoryContractStatusFilter initialContractStatus =
      ChartStoryContractStatusFilter.all,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ChartStoryCatalogExplorerExample(
          catalog: chartStoryCatalog,
          title: title,
          subtitle: subtitle,
          initialQuery: initialQuery,
          initialTier: initialTier,
          initialCategory: initialCategory,
          initialGroupId: initialGroupId,
          initialSection: initialSection,
          initialDataShape: initialDataShape,
          initialFamily: initialFamily,
          initialContractStatus: initialContractStatus,
          maxVisibleEntries: 80,
        ),
      ),
    ),
  );
}

Future<void> _expandFacetUntilVisible(
  WidgetTester tester,
  String chipLabel,
) async {
  for (var attempt = 0; attempt < 4; attempt += 1) {
    if (find.widgetWithText(FilterChip, chipLabel).evaluate().isNotEmpty) {
      return;
    }

    final showMore = find.textContaining(' more').first;
    await tester.ensureVisible(showMore);
    await tester.tap(showMore);
    await tester.pump();
  }
}

int _compareStoryTitle(ChartStoryEntry first, ChartStoryEntry second) {
  final firstTitle = first.leaf ?? first.name;
  final secondTitle = second.leaf ?? second.name;
  final value = firstTitle.toLowerCase().compareTo(secondTitle.toLowerCase());
  if (value != 0) {
    return value;
  }

  return first.name.toLowerCase().compareTo(second.name.toLowerCase());
}
