import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/profile_comparison.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_footprint_chips.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/text_badge.dart';

void main() {
  testWidgets('ProfileFootprintChips renders counts', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileFootprintChips(
            salesChannelCount: 2,
            capabilityCount: 3,
            moduleCount: 4,
            actionRuleCount: 5,
            searchKeywordCount: 6,
          ),
        ),
      ),
    );

    expect(find.text('2 ch'), findsOneWidget);
    expect(find.text('3 cap'), findsOneWidget);
    expect(find.text('4 mod'), findsOneWidget);
    expect(find.text('5 rule'), findsOneWidget);
    expect(find.text('6 kw'), findsOneWidget);
    expect(find.byType(TextBadge), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileFootprintChips.forProfile derives profile counts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileFootprintChips.forProfile(
            profile: ProductProfile.marketplaceOperations,
          ),
        ),
      ),
    );

    expect(find.text('3 ch'), findsOneWidget);
    expect(find.text('4 cap'), findsOneWidget);
    expect(find.text('6 mod'), findsOneWidget);
    expect(find.text('10 rule'), findsOneWidget);
    expect(find.text('4 kw'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileFootprintChips.forComparisonRow uses row counts', (
    tester,
  ) async {
    final row = ProfileComparisonRow.fromProfile(ProductProfile.standard);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProfileFootprintChips.forComparisonRow(row: row)),
      ),
    );

    expect(find.text('3 ch'), findsOneWidget);
    expect(find.text('5 cap'), findsOneWidget);
    expect(find.text('3 mod'), findsOneWidget);
    expect(find.text('7 rule'), findsOneWidget);
    expect(find.text('5 kw'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
