import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/profile_business_motion.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/profile_comparison.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_decision_signals.dart';

void main() {
  testWidgets('ProfileDecisionSignals renders both signals', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileDecisionSignals(
            businessMotion: ProfileBusinessMotion.omnichannel,
            launchComplexity: ProfileLaunchComplexity.standard,
            launchComplexityScore: 18,
          ),
        ),
      ),
    );

    expect(find.text('Omnichannel motion'), findsOneWidget);
    expect(find.text('Standard launch | 18 pts'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileDecisionSignals.forProfile can scope output', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileDecisionSignals.forProfile(
            profile: ProductProfile.remotePayment,
            showLaunchComplexity: false,
          ),
        ),
      ),
    );

    expect(find.text('Assisted selling'), findsOneWidget);
    expect(find.textContaining('launch'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileDecisionSignals stays quiet empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfileDecisionSignals())),
    );

    expect(find.byType(Wrap), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
