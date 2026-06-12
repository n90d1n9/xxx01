import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_module_contribution_manifest.dart';
import 'package:kaysir/features/product/models/product_module_contribution_registry_health_summary.dart';
import 'package:kaysir/features/product/widgets/product_module_contribution_registry_diagnostics_section.dart';

void main() {
  testWidgets('registry diagnostics section filters by issue severity', (
    tester,
  ) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final arguments = call.arguments! as Map<Object?, Object?>;
          copiedText = arguments['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final ignoredDiagnostics = const [
      ProductModuleContributionIgnoredManifestDiagnostic(
        reason: ProductModuleContributionIgnoredManifestReason.duplicateId,
        source: ProductModuleContributionSource(
          id: 'freshness_operations',
          title: 'Duplicate freshness module',
          description: 'Duplicate module id.',
        ),
        existingSource: ProductModuleContributionSource(
          id: 'freshness_operations',
          title: 'Freshness operations',
          description: 'Original module.',
        ),
      ),
    ];
    final duplicateDiagnostics = [
      ProductModuleContributionDuplicateHookDiagnostic(
        kind: ProductModuleContributionHookKind.action,
        hookId: 'freshness_queue',
        sources: const [
          ProductModuleContributionSource(
            id: 'freshness_a',
            title: 'Freshness A',
            description: 'First freshness module.',
          ),
          ProductModuleContributionSource(
            id: 'freshness_b',
            title: 'Freshness B',
            description: 'Second freshness module.',
          ),
        ],
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(1000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductModuleContributionRegistryDiagnosticsSection(
              healthSummary:
                  ProductModuleContributionRegistryHealthSummary.fromDiagnostics(
                    ignoredManifestDiagnostics: ignoredDiagnostics,
                    duplicateHookDiagnostics: duplicateDiagnostics,
                  ),
              ignoredManifestDiagnostics: ignoredDiagnostics,
              duplicateHookDiagnostics: duplicateDiagnostics,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Module registry health'), findsOneWidget);
    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('Errors (1)'), findsOneWidget);
    expect(find.text('Warnings (1)'), findsOneWidget);
    expect(find.text('Showing all registry diagnostics'), findsOneWidget);
    expect(find.text('2 visible issues'), findsOneWidget);
    expect(find.text('Resolve registry blockers'), findsOneWidget);
    expect(find.text('2 visible issues | 6 actions'), findsOneWidget);
    expect(find.text('Pick one source of truth'), findsNWidgets(2));
    expect(
      find.text('4 more actions across visible diagnostics'),
      findsOneWidget,
    );
    expect(find.text('Copy visible report'), findsOneWidget);
    expect(find.text('Copy action plan'), findsOneWidget);
    expect(find.text('View full plan'), findsOneWidget);
    expect(find.text('Ignored module manifests'), findsOneWidget);
    expect(find.text('Duplicate hook diagnostics'), findsOneWidget);

    await tester.tap(find.text('Copy action plan'));
    await tester.pumpAndSettle();

    expect(copiedText, contains('Product module registry triage plan'));
    expect(copiedText, contains('Title: Resolve registry blockers'));
    expect(copiedText, contains('Actions: 6'));
    expect(find.text('Action plan copied'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Copy visible report'));
    await tester.pump();

    expect(copiedText, contains('Filter: All diagnostics'));
    expect(copiedText, contains('Visible issues: 2'));
    expect(copiedText, contains('Duplicate module id / freshness_operations'));
    expect(copiedText, contains('Workspace action / freshness_queue'));
    expect(find.text('Visible diagnostics report copied'), findsOneWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Errors (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Showing registry errors'), findsOneWidget);
    expect(find.text('1 visible issue'), findsOneWidget);
    expect(find.text('Resolve registry blockers'), findsOneWidget);
    expect(find.text('1 visible issue | 3 actions'), findsOneWidget);
    expect(find.text('Retest affected packs'), findsNothing);
    expect(
      find.text('1 more action across visible diagnostics'),
      findsOneWidget,
    );
    expect(find.text('Ignored module manifests'), findsOneWidget);
    expect(find.text('Duplicate hook diagnostics'), findsNothing);

    await tester.tap(find.text('Copy visible report'));
    await tester.pumpAndSettle();

    expect(copiedText, contains('Filter: Errors'));
    expect(copiedText, contains('Duplicate module id / freshness_operations'));
    expect(copiedText, isNot(contains('Workspace action / freshness_queue')));

    await tester.tap(find.text('Warnings (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Showing registry warnings'), findsOneWidget);
    expect(find.text('1 visible issue'), findsOneWidget);
    expect(find.text('Review registry conflicts'), findsOneWidget);
    expect(find.text('1 visible issue | 3 actions'), findsOneWidget);
    expect(find.text('Choose the owning module'), findsNWidgets(2));
    expect(
      find.text('1 more action across visible diagnostics'),
      findsOneWidget,
    );
    expect(find.text('Pick one source of truth'), findsNothing);
    expect(find.text('Ignored module manifests'), findsNothing);
    expect(find.text('Duplicate hook diagnostics'), findsOneWidget);

    await tester.tap(find.text('All (2)'));
    await tester.pumpAndSettle();

    expect(find.text('Showing all registry diagnostics'), findsOneWidget);
    expect(find.text('2 visible issues'), findsOneWidget);
    expect(find.text('Ignored module manifests'), findsOneWidget);
    expect(find.text('Duplicate hook diagnostics'), findsOneWidget);
  });

  testWidgets('registry diagnostics section shows empty filtered severity', (
    tester,
  ) async {
    final duplicateDiagnostics = [
      ProductModuleContributionDuplicateHookDiagnostic(
        kind: ProductModuleContributionHookKind.action,
        hookId: 'freshness_queue',
        sources: const [
          ProductModuleContributionSource(
            id: 'freshness_a',
            title: 'Freshness A',
            description: 'First freshness module.',
          ),
          ProductModuleContributionSource(
            id: 'freshness_b',
            title: 'Freshness B',
            description: 'Second freshness module.',
          ),
        ],
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(1000, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductModuleContributionRegistryDiagnosticsSection(
              healthSummary:
                  ProductModuleContributionRegistryHealthSummary.fromDiagnostics(
                    duplicateHookDiagnostics: duplicateDiagnostics,
                  ),
              ignoredManifestDiagnostics: const [],
              duplicateHookDiagnostics: duplicateDiagnostics,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Errors (0)'), findsOneWidget);
    expect(find.text('Showing all registry diagnostics'), findsOneWidget);
    expect(find.text('1 visible issue'), findsOneWidget);
    expect(find.text('Review registry conflicts'), findsOneWidget);
    expect(find.text('1 visible issue | 3 actions'), findsOneWidget);
    expect(find.text('Duplicate hook diagnostics'), findsOneWidget);

    await tester.tap(find.text('Errors (0)'));
    await tester.pumpAndSettle();

    expect(find.text('Showing registry warnings'), findsNothing);
    expect(find.text('0 visible issues'), findsNothing);
    expect(find.text('Review registry conflicts'), findsNothing);
    expect(find.text('1 visible issue | 3 actions'), findsNothing);
    expect(find.text('No errors in this filter'), findsOneWidget);
    expect(find.text('Show all diagnostics'), findsOneWidget);
    expect(find.text('Duplicate hook diagnostics'), findsNothing);

    await tester.tap(find.text('Show all diagnostics'));
    await tester.pumpAndSettle();

    expect(find.text('No errors in this filter'), findsNothing);
    expect(find.text('Duplicate hook diagnostics'), findsOneWidget);
  });
}
