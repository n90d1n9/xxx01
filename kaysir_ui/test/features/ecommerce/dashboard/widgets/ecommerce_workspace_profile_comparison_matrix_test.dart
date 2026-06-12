import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/profile_comparison.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_comparison_matrix.dart';

void main() {
  testWidgets('ProfileComparisonMatrix renders profile rows', (tester) async {
    String? selectedProfileId;
    String? detailsProfileId;
    final rows = profileComparisonRows([
      ProductProfile.standard,
      ProductProfile.marketplaceOperations,
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileComparisonMatrix(
            rows: rows,
            activeProfileId: ProductProfile.standard.id,
            totalProfileCount: 6,
            onProfileSelected: (profileId) => selectedProfileId = profileId,
            onProfileDetailsRequested:
                (profileId) => detailsProfileId = profileId,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('profile_comparison_matrix')),
      findsOneWidget,
    );
    expect(find.text('Profile matrix'), findsOneWidget);
    expect(find.text('2 profiles compared'), findsOneWidget);
    expect(find.text('Standard commerce'), findsOneWidget);
    expect(find.text('Marketplace operations'), findsOneWidget);
    expect(find.text('Standard workspace'), findsOneWidget);
    expect(find.text('Operations first workspace'), findsOneWidget);
    expect(find.text('Omnichannel motion'), findsOneWidget);
    expect(find.text('Marketplace motion'), findsOneWidget);
    expect(find.text('Standard launch | 18 pts'), findsOneWidget);
    expect(find.text('Advanced launch | 23 pts'), findsOneWidget);
    expect(find.text('3 ch'), findsNWidgets(2));
    expect(find.text('6 mod'), findsOneWidget);
    expect(find.text('10 rule'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('profile_comparison_details_marketplace_operations'),
      ),
    );
    await tester.pump();

    expect(detailsProfileId, 'marketplace_operations');
    expect(selectedProfileId, isNull);

    await tester.tap(find.text('Marketplace operations'));
    await tester.pump();

    expect(selectedProfileId, 'marketplace_operations');
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileComparisonMatrix reports search scope', (tester) async {
    final rows = profileComparisonRows([ProductProfile.marketplaceOperations]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileComparisonMatrix(
            rows: rows,
            activeProfileId: ProductProfile.standard.id,
            totalProfileCount: 6,
            query: 'seller center',
            onProfileSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('1 of 6 compared'), findsOneWidget);
    expect(find.text('Marketplace operations'), findsOneWidget);
    expect(find.text('Standard commerce'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileComparisonMatrix stays quiet empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileComparisonMatrix(
            rows: const [],
            activeProfileId: '',
            onProfileSelected: (_) {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('profile_comparison_matrix')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
