import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_module_contribution_registry_health_summary.dart';
import 'package:kaysir/features/product/widgets/product_module_contribution_registry_health_banner.dart';

void main() {
  testWidgets('registry health banner stays hidden without issues', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductModuleContributionRegistryHealthBanner(
            summary: ProductModuleContributionRegistryHealthSummary(),
          ),
        ),
      ),
    );

    expect(find.text('Module registry health'), findsNothing);
    expect(find.text('Registry healthy'), findsNothing);
  });

  testWidgets('registry health banner shows grouped issues and next action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 500));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductModuleContributionRegistryHealthBanner(
            summary: ProductModuleContributionRegistryHealthSummary(
              errorCount: 2,
              warningCount: 1,
              primaryNextAction: 'Rename the duplicate module id.',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Module registry health'), findsOneWidget);
    expect(find.text('2 errors, 1 warning'), findsOneWidget);
    expect(find.text('3 registry issues'), findsOneWidget);
    expect(find.text('Rename the duplicate module id.'), findsOneWidget);
  });
}
