import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_touch_layout_profiles.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_touch_layout_profile_selector.dart';

void main() {
  testWidgets('touch layout profile selector reports selected profile', (
    tester,
  ) async {
    String? selectedProfileId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSTouchLayoutProfileSelector(
            catalog: defaultPOSTouchLayoutProfileCatalog,
            selectedProfile: coreCounterTouchLayoutProfile,
            onProfileSelected: (profileId) => selectedProfileId = profileId,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coffee Counter Touch').last);
    await tester.pumpAndSettle();

    expect(selectedProfileId, 'coffee_counter_touch');
  });
}
