import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_module_contribution_manifest.dart';
import 'package:kaysir/features/product/models/product_module_contribution_registry_diagnostic_detail.dart';
import 'package:kaysir/features/product/widgets/product_module_contribution_registry_notice.dart';

void main() {
  testWidgets('registry notice sorts issues by diagnostic severity', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductModuleContributionRegistryNotice(
            title: 'Module registry diagnostics',
            countLabel: '2 registry issues',
            accentColor: Colors.amber.shade800,
            headerIcon: Icons.warning_amber_rounded,
            countIcon: Icons.account_tree_rounded,
            items: const [
              ProductModuleContributionRegistryNoticeItem(
                title: 'Warning item',
                detail: 'Duplicate hook should be reviewed.',
                severity: ProductModuleContributionDiagnosticSeverity.warning,
                resolutionGuidance: 'Rename the duplicate hook id.',
              ),
              ProductModuleContributionRegistryNoticeItem(
                title: 'Error item',
                detail: 'Ignored manifest must be fixed first.',
                severity: ProductModuleContributionDiagnosticSeverity.error,
                resolutionGuidance: 'Restore the manifest id.',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Error item'), findsOneWidget);
    expect(find.text('Warning item'), findsOneWidget);
    expect(find.text('Restore the manifest id.'), findsOneWidget);
    expect(find.text('Rename the duplicate hook id.'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Error item')).dy,
      lessThan(tester.getTopLeft(find.text('Warning item')).dy),
    );
  });

  testWidgets('registry notice opens diagnostic detail dialog', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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

    final diagnostic = ProductModuleContributionDuplicateHookDiagnostic(
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
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductModuleContributionRegistryNotice(
            title: 'Duplicate hook diagnostics',
            countLabel: '1 duplicate hook',
            accentColor: Colors.amber.shade800,
            headerIcon: Icons.warning_amber_rounded,
            countIcon: Icons.account_tree_rounded,
            items: [
              ProductModuleContributionRegistryNoticeItem(
                title: '${diagnostic.kindLabel} / ${diagnostic.hookId}',
                detail: diagnostic.sourceLabel,
                icon: Icons.merge_type_rounded,
                severity: diagnostic.severity,
                resolutionGuidance: diagnostic.resolutionGuidance,
                diagnosticDetail:
                    ProductModuleContributionRegistryDiagnosticDetail.fromDuplicateHook(
                      diagnostic,
                    ),
                statusLabel: diagnostic.occurrenceCountLabel,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byTooltip('Open diagnostic details'), findsOneWidget);

    await tester.tap(find.byTooltip('Open diagnostic details'));
    await tester.pumpAndSettle();

    expect(find.text('What happened'), findsOneWidget);
    expect(find.text('Recommended fix'), findsOneWidget);
    expect(find.text('Next actions'), findsOneWidget);
    expect(find.text('3 actions'), findsOneWidget);
    expect(find.text('Choose the owning module'), findsOneWidget);
    expect(find.text('Rename duplicate hooks'), findsOneWidget);
    expect(find.text('Retest the active pack'), findsOneWidget);
    expect(find.text('Diagnostic metadata'), findsOneWidget);
    expect(find.text('Affected sources'), findsOneWidget);
    expect(find.text('Hook id'), findsOneWidget);
    expect(find.text('freshness_queue'), findsOneWidget);
    expect(find.text('Registered source'), findsNWidgets(2));
    expect(find.text('Freshness A'), findsOneWidget);
    expect(find.text('Freshness B'), findsOneWidget);

    await tester.tap(find.text('Copy report'));
    await tester.pumpAndSettle();

    expect(copiedText, contains('Product module registry diagnostic'));
    expect(copiedText, contains('Title: Workspace action / freshness_queue'));
    expect(copiedText, contains('Next actions:'));
    expect(copiedText, contains('1. Choose the owning module'));
    expect(copiedText, contains('- Hook id: freshness_queue'));
    expect(copiedText, contains('- Registered source: Freshness A'));
    expect(find.text('Diagnostic report copied'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('What happened'), findsNothing);
  });
}
