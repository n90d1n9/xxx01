import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_touch_layout_profiles.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button_customization.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_touch_layout_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_quick_button_actions.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_touch_quick_button_board.dart';

void main() {
  testWidgets('quick button board renders visible profile buttons', (
    tester,
  ) async {
    String? selectedCategory;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            child: POSTouchQuickButtonBoard(
              profile: groceryScannerTouchLayoutProfile,
              surface: POSQuickButtonSurface.primaryGrid,
              formFactor: POSExperienceFormFactor.tablet,
              layoutPreference: POSLayoutPreference.counter,
              actionHandlers: POSQuickButtonActionHandlers(
                onCategorySelected:
                    (categoryId) => selectedCategory = categoryId,
                onDiscountSelected: (_) {},
                onCustomFlow: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Departments'), findsOneWidget);
    expect(find.text('Produce'), findsOneWidget);
    expect(find.text('Weigh Item'), findsOneWidget);

    await tester.tap(find.text('Produce'));
    await tester.pumpAndSettle();

    expect(selectedCategory, 'produce');
  });

  testWidgets('quick button board applies pinned and hidden customization', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            child: POSTouchQuickButtonBoard(
              profile: groceryScannerTouchLayoutProfile,
              surface: POSQuickButtonSurface.primaryGrid,
              formFactor: POSExperienceFormFactor.tablet,
              layoutPreference: POSLayoutPreference.counter,
              customization: POSQuickButtonCustomization(
                pinnedButtonIds: ['grocery_weigh_item'],
                hiddenButtonIds: ['grocery_markdown'],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Weigh Item'), findsOneWidget);
    expect(find.text('Markdown'), findsNothing);

    final weighTop = tester.getTopLeft(find.text('Weigh Item')).dy;
    final produceTop = tester.getTopLeft(find.text('Produce')).dy;
    expect(weighTop, lessThanOrEqualTo(produceTop));
  });

  testWidgets('quick button board displays selected touch density', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            child: POSTouchQuickButtonBoard(
              profile: groceryScannerTouchLayoutProfile,
              surface: POSQuickButtonSurface.primaryGrid,
              formFactor: POSExperienceFormFactor.tablet,
              layoutPreference: POSLayoutPreference.counter,
              touchDensity: POSTouchLayoutDensity.spacious,
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Spacious'), findsOneWidget);
  });
}
