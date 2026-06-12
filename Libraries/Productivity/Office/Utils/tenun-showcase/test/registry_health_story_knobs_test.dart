import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:tenun_showcase/story/registry_health_story_knobs.dart';

void main() {
  testWidgets('registry health knobs build focused action config', (
    tester,
  ) async {
    late RegistryHealthStoryKnobs knobs;

    await tester.pumpWidget(
      Storybook(
        initialStory: 'Probe',
        stories: [
          Story(
            name: 'Probe',
            builder: (context) {
              knobs = registryHealthStoryKnobs(
                context,
                initialSectionSet: 'contracts',
                initialMatrixViewMode: 'actions',
                initialShowMatrixTable: true,
                initialMatrixWorkLimit: 5,
                initialMatrixAttentionLimit: 7,
                initialDetailMode: 'compact',
                initialExportPreset: 'planning',
                initialAuditIssueLimit: 2,
                initialRenamePlanVisibleLimit: 3,
                initialBacklogPreviewMode: 'noSource',
                initialShowBacklogMetadata: false,
                initialBacklogVisibleLimit: 4,
              );
              return const SizedBox.shrink();
            },
          ),
        ],
        wrapperBuilder: (_, child) => MaterialApp(home: child),
      ),
    );
    await tester.pump();

    expect(knobs.showcaseBacklogVisibleLimit, 4);
    expect(knobs.showcaseBacklogOptions.showMetadataChips, isFalse);
    expect(knobs.showcaseBacklogOptions.showStarterJson, isFalse);
    expect(knobs.showcaseBacklogOptions.showDartSample, isFalse);
    expect(knobs.showcaseBacklogOptions.showSourcePanels, isFalse);

    expect(knobs.chartExampleMatrixOptions.showMetrics, isFalse);
    expect(knobs.chartExampleMatrixOptions.showBreakdown, isFalse);
    expect(knobs.chartExampleMatrixOptions.showTable, isFalse);
    expect(knobs.chartExampleMatrixOptions.prioritySummaryLimit, 5);
    expect(knobs.chartExampleMatrixOptions.actionSummaryLimit, 5);
    expect(knobs.chartExampleMatrixOptions.nextWorkLimit, 5);
    expect(knobs.chartExampleMatrixOptions.attentionLimit, 7);

    expect(knobs.detailOptions.readinessGateLimit, 4);
    expect(knobs.detailOptions.sampleIssueLimit, 2);
    expect(knobs.detailOptions.sourceIssueLimit, 2);
    expect(knobs.detailOptions.simpleSourceIssueLimit, 2);
    expect(knobs.detailOptions.sourceMapIssueLimit, 2);
    expect(knobs.detailOptions.packageBoundaryIssueLimit, 2);
    expect(knobs.detailOptions.proReadinessIssueLimit, 2);
    expect(knobs.detailOptions.renamePlanVisibleLimit, 3);
    expect(knobs.exportOptions.name, 'planning');

    expect(knobs.sectionOptions.showReadiness, isFalse);
    expect(knobs.sectionOptions.showShowcaseCoverage, isFalse);
    expect(knobs.sectionOptions.showSampleDiagnostics, isFalse);
    expect(knobs.sectionOptions.showExampleMatrix, isFalse);
    expect(knobs.sectionOptions.showContractMatrices, isTrue);
    expect(knobs.sectionOptions.showCapabilityMatrix, isTrue);
    expect(knobs.sectionOptions.showRuntimeDiagnostics, isFalse);
    expect(knobs.sectionOptions.showPackageBoundary, isFalse);
    expect(knobs.sectionOptions.showProReadiness, isFalse);
  });

  testWidgets('registry health knobs expose split review controls', (
    tester,
  ) async {
    late RegistryHealthStoryKnobs knobs;

    await tester.pumpWidget(
      Storybook(
        initialStory: 'Probe',
        stories: [
          Story(
            name: 'Probe',
            builder: (context) {
              knobs = registryHealthStoryKnobs(
                context,
                initialSectionSet: 'split',
                initialSplitIssueLimit: 1,
                initialShowPackageBoundary: true,
                initialShowProReadiness: false,
              );
              return const SizedBox.shrink();
            },
          ),
        ],
        wrapperBuilder: (_, child) => MaterialApp(home: child),
      ),
    );
    await tester.pump();

    expect(knobs.detailOptions.packageBoundaryIssueLimit, 1);
    expect(knobs.detailOptions.proReadinessIssueLimit, 1);
    expect(knobs.sectionOptions.showReadiness, isTrue);
    expect(knobs.sectionOptions.showShowcaseCoverage, isFalse);
    expect(knobs.sectionOptions.showSampleDiagnostics, isFalse);
    expect(knobs.sectionOptions.showExampleMatrix, isFalse);
    expect(knobs.sectionOptions.showNamingDiagnostics, isFalse);
    expect(knobs.sectionOptions.showSummaries, isFalse);
    expect(knobs.sectionOptions.showContractMatrices, isFalse);
    expect(knobs.sectionOptions.showRuntimeDiagnostics, isFalse);
    expect(knobs.sectionOptions.showCapabilityMatrix, isFalse);
    expect(knobs.sectionOptions.showPackageBoundary, isTrue);
    expect(knobs.sectionOptions.showProReadiness, isFalse);
  });
}
