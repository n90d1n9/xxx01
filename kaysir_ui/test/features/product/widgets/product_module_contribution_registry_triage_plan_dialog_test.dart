import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_module_contribution_manifest.dart';
import 'package:kaysir/features/product/models/product_module_contribution_registry_diagnostic_detail.dart';
import 'package:kaysir/features/product/models/product_module_contribution_registry_triage_plan.dart';
import 'package:kaysir/features/product/widgets/product_module_contribution_registry_diagnostic_detail_dialog.dart';
import 'package:kaysir/features/product/widgets/product_module_contribution_registry_triage_plan_dialog.dart';

void main() {
  testWidgets('registry triage plan dialog renders full grouped plan', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 760));
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
          body: ProductModuleContributionRegistryTriagePlanDialog(
            plan: _plan,
            accentColor: Colors.deepOrange.shade700,
          ),
        ),
      ),
    );

    expect(find.text('Full action plan'), findsOneWidget);
    expect(find.text('Resolve registry blockers'), findsOneWidget);
    expect(find.text('2 visible issues | 6 actions'), findsOneWidget);
    expect(
      find.text('Duplicate module id / freshness_operations'),
      findsOneWidget,
    );
    expect(find.text('Workspace action / freshness_queue'), findsOneWidget);
    expect(find.text('Retest affected packs'), findsOneWidget);
    expect(find.text('Retest the active pack'), findsOneWidget);
    expect(find.text('3 actions'), findsNWidgets(2));
    expect(find.byTooltip('Inspect diagnostic'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Inspect diagnostic').last);
    await tester.pumpAndSettle();

    expect(
      find.byType(ProductModuleContributionRegistryDiagnosticDetailDialog),
      findsOneWidget,
    );
    expect(find.text('What happened'), findsOneWidget);
    expect(find.text('Affected sources'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(
          ProductModuleContributionRegistryDiagnosticDetailDialog,
        ),
        matching: find.text('Close'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Copy action plan'));
    await tester.pumpAndSettle();

    expect(copiedText, contains('Product module registry triage plan'));
    expect(copiedText, contains('Actions: 6'));
    expect(
      copiedText,
      contains('Diagnostic: Workspace action / freshness_queue'),
    );
    expect(find.text('Action plan copied'), findsOneWidget);
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
