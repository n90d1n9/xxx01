import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/profile_business_motion.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/icon_label_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_business_motion_chip.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('ProfileBusinessMotionChip renders label and icon', (
    tester,
  ) async {
    await tester.pumpWorkspaceWidget(
      const ProfileBusinessMotionChip(
        motion: ProfileBusinessMotion.marketplace,
      ),
    );

    expect(find.text('Marketplace motion'), findsOneWidget);
    expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
    expect(find.byType(IconLabelChip), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
