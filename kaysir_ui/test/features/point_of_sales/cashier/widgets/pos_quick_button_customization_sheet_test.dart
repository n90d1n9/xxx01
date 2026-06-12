import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_touch_layout_profiles.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button_customization.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button_customization_view.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_touch_layout_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_quick_button_customization_sheet.dart';

void main() {
  testWidgets('customization sheet exposes unpin show and reset actions', (
    tester,
  ) async {
    String? unpinnedId;
    String? shownId;
    String? movedUpId;
    String? movedDownId;
    POSTouchLayoutDensity? selectedDensity;
    var reset = false;
    final buttons =
        coreCounterTouchLayoutProfile.groups
            .expand((group) => group.buttons)
            .toList();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSQuickButtonCustomizationSheet(
            view: POSQuickButtonCustomizationView.fromButtons(
              buttons: buttons,
              customization: const POSQuickButtonCustomization(
                pinnedButtonIds: [
                  'core_category_top_sellers',
                  'core_category_services',
                ],
                hiddenButtonIds: ['core_category_favorites'],
                densityOverride: POSTouchLayoutDensity.spacious,
              ),
            ),
            profileDensity: coreCounterTouchLayoutProfile.density,
            selectedDensity: POSTouchLayoutDensity.spacious,
            onTogglePinned: (buttonId) => unpinnedId = buttonId,
            onToggleHidden: (buttonId) => shownId = buttonId,
            onDensityChanged: (density) => selectedDensity = density,
            onMovePinnedUp: (buttonId) => movedUpId = buttonId,
            onMovePinnedDown: (buttonId) => movedDownId = buttonId,
            onReset: () => reset = true,
          ),
        ),
      ),
    );

    expect(find.text('Top Sellers'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.byTooltip('Move Top Sellers down'), findsOneWidget);
    expect(find.byTooltip('Move Services up'), findsOneWidget);
    expect(find.text('Touch density'), findsOneWidget);

    await tester.tap(find.byTooltip('Move Top Sellers down'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Move Services up'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unpin').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(movedDownId, 'core_category_top_sellers');
    expect(movedUpId, 'core_category_services');
    expect(selectedDensity, isNull);
    expect(unpinnedId, 'core_category_top_sellers');
    expect(shownId, 'core_category_favorites');
    expect(reset, isTrue);
  });
}
