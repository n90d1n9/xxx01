import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_module_contribution_manifest.dart';
import 'package:kaysir/features/product/models/product_module_contribution_registry_diagnostic_detail.dart';
import 'package:kaysir/features/product/models/product_module_contribution_registry_triage_plan.dart';
import 'package:kaysir/features/product/widgets/product_module_contribution_registry_triage_panel.dart';

void main() {
  testWidgets('registry triage panel renders visible action preview', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 720));
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductModuleContributionRegistryTriagePanel(
            accentColor: Colors.deepOrange.shade700,
            plan: _plan,
            visibleActionLimit: 2,
          ),
        ),
      ),
    );

    expect(find.text('Resolve registry blockers'), findsOneWidget);
    expect(find.text('Pick one source of truth'), findsNWidgets(2));
    expect(find.text('2 visible issues | 6 actions'), findsOneWidget);
    expect(find.text('Copy action plan'), findsOneWidget);
    expect(find.text('View full plan'), findsOneWidget);
    expect(find.text('Rename or merge the duplicate'), findsOneWidget);
    expect(find.text('Retest affected packs'), findsNothing);
    expect(
      find.text('4 more actions across visible diagnostics'),
      findsOneWidget,
    );
    expect(
      find.text('Duplicate module id / freshness_operations'),
      findsOneWidget,
    );
    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Ignored manifest'), findsOneWidget);
    expect(find.text('2 actions'), findsOneWidget);
    expect(find.byTooltip('Inspect diagnostic'), findsOneWidget);

    await tester.tap(find.byTooltip('Inspect diagnostic'));
    await tester.pumpAndSettle();

    expect(find.text('What happened'), findsOneWidget);
    expect(find.text('Recommended fix'), findsOneWidget);
    expect(find.text('Diagnostic metadata'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('View full plan'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Full action plan'), findsOneWidget);
    expect(find.text('Retest affected packs'), findsOneWidget);
    expect(find.text('Workspace action / freshness_queue'), findsOneWidget);
    expect(find.text('Choose the owning module'), findsOneWidget);
    expect(find.text('3 actions'), findsNWidgets(2));

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Copy action plan'),
      ),
    );
    await tester.pumpAndSettle();

    expect(copiedText, contains('Product module registry triage plan'));
    expect(
      copiedText,
      contains('Diagnostic: Workspace action / freshness_queue'),
    );
    expect(find.text('Action plan copied'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Copy action plan'));
    await tester.pumpAndSettle();

    expect(copiedText, contains('Product module registry triage plan'));
    expect(copiedText, contains('Title: Resolve registry blockers'));
    expect(copiedText, contains('Actions: 6'));
    expect(copiedText, contains('1. Pick one source of truth'));
    expect(
      copiedText,
      contains('Diagnostic: Duplicate module id / freshness_operations'),
    );
    expect(find.text('Action plan copied'), findsOneWidget);
  });

  testWidgets('registry triage panel hides when there are no actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductModuleContributionRegistryTriagePanel(
            accentColor: Colors.amber.shade800,
            plan: ProductModuleContributionRegistryTriagePlan.fromDiagnostics(
              const [],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Registry triage clear'), findsNothing);
    expect(
      find.byType(ProductModuleContributionRegistryTriagePanel),
      findsOneWidget,
    );
  });
}

final _plan = ProductModuleContributionRegistryTriagePlan.fromDiagnostics([
  ProductModuleContributionRegistryDiagnosticDetail.fromIgnoredManifest(
    const ProductModuleContributionIgnoredManifestDiagnostic(
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
  ),
  ProductModuleContributionRegistryDiagnosticDetail.fromDuplicateHook(
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
  ),
]);
