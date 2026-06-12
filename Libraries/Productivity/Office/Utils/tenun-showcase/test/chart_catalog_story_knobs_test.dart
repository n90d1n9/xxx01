import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:tenun_showcase/story/chart_catalog_story_knobs.dart';
import 'package:tenun_showcase/story/chart_story_contract_coverage.dart';
import 'package:tenun_showcase/story/chart_story_groups.dart';
import 'package:tenun_showcase/story/chart_story_tier.dart';

void main() {
  testWidgets('catalog explorer knobs expose initial filter config', (
    tester,
  ) async {
    late ChartCatalogExplorerKnobs knobs;

    await tester.pumpWidget(
      Storybook(
        initialStory: 'Probe',
        stories: [
          Story(
            name: 'Probe',
            builder: (context) {
              knobs = chartCatalogExplorerKnobs(
                context,
                chartStoryCatalog,
                initialQuery: 'payload normalize',
                initialTier: ChartStoryTier.pro.key,
                initialCategory: 'Tooling',
                initialGroupId: 'tools',
                initialSection: 'Tools',
                initialDataShape: 'Cartesian',
                initialFamily: 'Bar',
                initialContractStatus:
                    ChartStoryContractStatusFilter.needsSampleJson,
                initialMaxVisibleEntries: 12,
              );
              return const SizedBox.shrink();
            },
          ),
        ],
        wrapperBuilder: (_, child) => MaterialApp(home: child),
      ),
    );
    await tester.pump();

    expect(knobs.initialQuery, 'payload normalize');
    expect(knobs.initialTier, ChartStoryTier.pro.key);
    expect(knobs.initialCategory, 'Tooling');
    expect(knobs.initialGroupId, 'tools');
    expect(knobs.initialSection, 'Tools');
    expect(knobs.initialDataShape, 'Cartesian');
    expect(knobs.initialFamily, 'Bar');
    expect(
      knobs.initialContractStatus,
      ChartStoryContractStatusFilter.needsSampleJson,
    );
    expect(knobs.maxVisibleEntries, 12);
  });

  testWidgets('catalog explorer knobs ignore unknown initial facets', (
    tester,
  ) async {
    late ChartCatalogExplorerKnobs knobs;

    await tester.pumpWidget(
      Storybook(
        initialStory: 'Probe',
        stories: [
          Story(
            name: 'Probe',
            builder: (context) {
              knobs = chartCatalogExplorerKnobs(
                context,
                chartStoryCatalog,
                initialTier: 'unknown',
                initialCategory: 'Unknown',
                initialGroupId: 'unknown',
                initialSection: 'Unknown',
                initialDataShape: 'Unknown',
                initialFamily: 'Unknown',
                initialMaxVisibleEntries: 999,
              );
              return const SizedBox.shrink();
            },
          ),
        ],
        wrapperBuilder: (_, child) => MaterialApp(home: child),
      ),
    );
    await tester.pump();

    expect(knobs.initialTier, isNull);
    expect(knobs.initialCategory, isNull);
    expect(knobs.initialGroupId, isNull);
    expect(knobs.initialSection, isNull);
    expect(knobs.initialDataShape, isNull);
    expect(knobs.initialFamily, isNull);
    expect(knobs.initialContractStatus, ChartStoryContractStatusFilter.all);
    expect(knobs.maxVisibleEntries, 80);
  });
}
