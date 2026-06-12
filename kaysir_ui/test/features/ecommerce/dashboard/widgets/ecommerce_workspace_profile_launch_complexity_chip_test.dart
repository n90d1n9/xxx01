import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/profile_comparison.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/icon_label_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_launch_complexity_chip.dart';

void main() {
  testWidgets('ProfileLaunchComplexityChip renders score', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileLaunchComplexityChip(
            complexity: ProfileLaunchComplexity.standard,
            score: 18,
          ),
        ),
      ),
    );

    expect(find.text('Standard launch | 18 pts'), findsOneWidget);
    expect(find.byIcon(Icons.rocket_launch_outlined), findsOneWidget);
    expect(find.byType(IconLabelChip), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileLaunchComplexityChip.forProfile derives score', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileLaunchComplexityChip.forProfile(
            profile: ProductProfile.marketplaceOperations,
          ),
        ),
      ),
    );

    expect(find.text('Advanced launch | 23 pts'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
