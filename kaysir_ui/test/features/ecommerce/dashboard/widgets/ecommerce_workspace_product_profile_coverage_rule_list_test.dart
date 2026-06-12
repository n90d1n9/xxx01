import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/detail_row.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/empty_state.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/product_profile_coverage_rule_list.dart';

void main() {
  testWidgets('ProductProfileCoverageRuleList renders rule coverage', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductProfileCoverageRuleList(
            profile: ProductProfile.marketplaceOperations,
          ),
        ),
      ),
    );

    expect(find.byType(DetailRow), findsNWidgets(4));
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Customers'), findsOneWidget);
    expect(find.text('Tracking'), findsOneWidget);
    expect(find.text('Price lists'), findsOneWidget);
    expect(find.text('Payment-capable channels'), findsOneWidget);
    expect(find.text('Customer-aware channels'), findsOneWidget);
    expect(find.text('Fulfillment tracking channels'), findsOneWidget);
    expect(find.text('Price-list channels'), findsOneWidget);
    expect(find.text('Required: 1 matching channels'), findsNWidgets(2));
    expect(find.text('Required: 3 matching channels'), findsOneWidget);
    expect(find.text('Required: 2 matching channels'), findsOneWidget);
    expect(
      find.text('Playbook: Add price-list channel coverage'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProductProfileCoverageRuleList shows empty state', (
    tester,
  ) async {
    final profile = ProductProfile.standard.copyWith(
      channelCoverageRequirements: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProductProfileCoverageRuleList(profile: profile)),
      ),
    );

    expect(find.byType(EmptyState), findsOneWidget);
    expect(
      find.text('No channel coverage rules are registered for this profile.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
