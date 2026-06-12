import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_contribution_bundle.dart';
import 'package:kaysir/features/product/models/management_pack_readiness.dart';
import 'package:kaysir/features/product/widgets/management_pack_readiness_panel.dart';

void main() {
  testWidgets('pack readiness panel renders score and delegates action', (
    tester,
  ) async {
    var actionCount = 0;

    await tester.binding.setSurfaceSize(const Size(1000, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackReadinessPanel(
            readiness: _readiness,
            onPrimaryAction: () => actionCount += 1,
          ),
        ),
      ),
    );

    expect(find.text('Pack readiness'), findsOneWidget);
    expect(find.text('Core Catalog readiness'), findsOneWidget);
    expect(find.text('70% ready'), findsAtLeastNWidgets(1));
    expect(find.text('Improving'), findsAtLeastNWidgets(1));
    expect(find.text('Data contract'), findsOneWidget);
    expect(find.text('Channel coverage'), findsOneWidget);
    expect(find.text('Workflow availability'), findsOneWidget);
    expect(find.text('Extension hooks'), findsOneWidget);
    expect(find.text('Review data'), findsOneWidget);

    await tester.tap(find.text('Review data'));

    expect(actionCount, 1);
  });
}

final _readiness = ProductManagementPackReadiness(
  bundle: ProductManagementPackContributionBundle(
    managementPack: coreProductManagementPack,
    workspaceActionGroups: const [],
    actionContributions: const [],
    recommendationContributions: const [],
  ),
  sections: const [
    ProductManagementPackReadinessSection(
      id: productManagementPackReadinessDataSectionId,
      title: 'Data contract',
      detailLabel: '2/4 ready, 2 gaps',
      scorePercent: 50,
      level: ProductManagementPackReadinessLevel.improving,
    ),
    ProductManagementPackReadinessSection(
      id: productManagementPackReadinessChannelSectionId,
      title: 'Channel coverage',
      detailLabel: '2/3 channels ready, 2 product-channel gaps',
      scorePercent: 70,
      level: ProductManagementPackReadinessLevel.improving,
    ),
    ProductManagementPackReadinessSection(
      id: productManagementPackReadinessWorkflowSectionId,
      title: 'Workflow availability',
      detailLabel: '4 ready, 1 waiting for setup.',
      scorePercent: 80,
      level: ProductManagementPackReadinessLevel.improving,
    ),
    ProductManagementPackReadinessSection(
      id: productManagementPackReadinessExtensionSectionId,
      title: 'Extension hooks',
      detailLabel: 'No active extension hooks required',
      scorePercent: 100,
      level: ProductManagementPackReadinessLevel.ready,
    ),
  ],
);
