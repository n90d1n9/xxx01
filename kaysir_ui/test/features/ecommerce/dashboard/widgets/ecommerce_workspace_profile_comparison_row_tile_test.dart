import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/profile_comparison.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/current_profile_badge.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_comparison_row_tile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_decision_signals.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_details_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_footprint_chips.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  final standardRow = ProfileComparisonRow.fromProfile(ProductProfile.standard);
  final marketplaceRow = ProfileComparisonRow.fromProfile(
    ProductProfile.marketplaceOperations,
  );

  testWidgets('ProfileComparisonRowTile renders selected row', (tester) async {
    await tester.pumpWorkspaceWidget(
      ProfileComparisonRowTile(
        row: standardRow,
        selected: true,
        onSelected: null,
      ),
    );

    expect(find.text('Standard commerce'), findsOneWidget);
    expect(find.text('Standard workspace'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
    expect(find.byType(CurrentProfileBadge), findsOneWidget);
    expect(find.byType(ProfileDecisionSignals), findsOneWidget);
    expect(find.byType(ProfileFootprintChips), findsOneWidget);
    expect(find.byType(ProfileDetailsButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileComparisonRowTile invokes row actions', (tester) async {
    var selected = false;
    var detailsRequested = false;

    await tester.pumpWorkspaceWidget(
      ProfileComparisonRowTile(
        row: marketplaceRow,
        selected: false,
        onSelected: () => selected = true,
        onDetailsRequested: () => detailsRequested = true,
      ),
    );

    expect(find.text('Marketplace operations'), findsOneWidget);
    expect(find.text('Operations first workspace'), findsOneWidget);
    expect(find.text('Current'), findsNothing);
    expect(find.byType(ProfileDetailsButton), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('profile_comparison_details_marketplace_operations'),
      ),
    );
    await tester.pump();

    expect(detailsRequested, isTrue);
    expect(selected, isFalse);

    await tester.tap(find.text('Marketplace operations'));
    await tester.pump();

    expect(selected, isTrue);
    expect(tester.takeException(), isNull);
  });
}
