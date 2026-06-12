import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_signal_visibility.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/product_profile_summary.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('ProductProfileSummary renders reusable profile copy', (
    tester,
  ) async {
    await tester.pumpWorkspaceWidget(
      ProductProfileSummary(
        profile: ProductProfile.marketplaceOperations,
        eyebrow: 'Active profile',
        trailing: const Text('Current'),
        signalVisibility: ProductProfileSignalVisibility.detailed,
        chipLimits: const ProductProfileChipLimits(
          channels: 2,
          capabilities: 2,
          requirements: 3,
        ),
      ),
    );

    expect(find.text('Active profile'), findsOneWidget);
    expect(find.text('Marketplace operations'), findsOneWidget);
    expect(
      find.text(
        'Marketplace order workload, settlement, and fulfillment review.',
      ),
      findsOneWidget,
    );
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Marketplace motion'), findsOneWidget);
    expect(find.text('Advanced launch | 23 pts'), findsOneWidget);
    expect(find.text('3 ch'), findsOneWidget);
    expect(find.text('4 cap'), findsOneWidget);
    expect(find.text('6 mod'), findsOneWidget);
    expect(find.text('10 rule'), findsOneWidget);
    expect(find.text('4 kw'), findsOneWidget);
    expect(find.text('Delivery app'), findsOneWidget);
    expect(find.text('+1 channels'), findsOneWidget);
    expect(find.text('Remote pay'), findsOneWidget);
    expect(find.text('+2 more'), findsOneWidget);
    expect(find.text('Price lists'), findsNothing);
    expect(find.text('+1 rules'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProductProfileSummary hides footprint by default', (
    tester,
  ) async {
    await tester.pumpWorkspaceWidget(
      ProductProfileSummary(
        profile: ProductProfile.standard,
        signalVisibility: ProductProfileSignalVisibility.decision,
      ),
    );

    expect(find.text('Omnichannel motion'), findsOneWidget);
    expect(find.text('Standard launch | 18 pts'), findsOneWidget);
    expect(find.text('3 ch'), findsNothing);
    expect(find.text('5 cap'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
