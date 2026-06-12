import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_touch_layout_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_touch_density_selector.dart';

void main() {
  testWidgets('touch density selector emits override and profile reset', (
    tester,
  ) async {
    POSTouchLayoutDensity? selectedDensity;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSTouchDensitySelector(
            profileDensity: POSTouchLayoutDensity.comfortable,
            selectedDensity: POSTouchLayoutDensity.spacious,
            onDensityChanged: (density) => selectedDensity = density,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Kiosk'));
    await tester.pumpAndSettle();

    expect(selectedDensity, POSTouchLayoutDensity.kiosk);

    await tester.tap(find.text('Use profile'));
    await tester.pumpAndSettle();

    expect(selectedDensity, isNull);
  });
}
