import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_touch_layout_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_catalog_filter_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_quick_button_customization_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_touch_quick_button_panel.dart';

void main() {
  testWidgets('touch quick button panel applies catalog shortcut search', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 720, child: POSTouchQuickButtonPanel()),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Top Sellers'));
    await tester.pumpAndSettle();

    expect(container.read(posCatalogFilterProvider).query, 'top sellers');
    expect(container.read(posCatalogFilterProvider).category, isNull);
  });

  testWidgets('touch quick button panel pins hides and resets buttons', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 720, child: POSTouchQuickButtonPanel()),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Customize Top Sellers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pin first'));
    await tester.pumpAndSettle();

    expect(
      container.read(posQuickButtonCustomizationProvider).pinnedButtonIds,
      ['core_category_top_sellers'],
    );

    await tester.tap(find.byTooltip('Customize Top Sellers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hide'));
    await tester.pumpAndSettle();

    final hiddenState = container.read(posQuickButtonCustomizationProvider);
    expect(hiddenState.hiddenButtonIds, ['core_category_top_sellers']);
    expect(hiddenState.pinnedButtonIds, isEmpty);

    await tester.tap(find.byTooltip('Reset quick-button customization'));
    await tester.pumpAndSettle();

    expect(container.read(posQuickButtonCustomizationProvider).isEmpty, isTrue);
  });

  testWidgets(
    'touch quick button panel can show a hidden button from manager',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(posQuickButtonCustomizationProvider.notifier)
          .state = container
          .read(posQuickButtonCustomizationProvider)
          .toggleHidden('core_category_top_sellers');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(width: 720, child: POSTouchQuickButtonPanel()),
            ),
          ),
        ),
      );

      expect(find.text('Top Sellers'), findsNothing);

      await tester.tap(find.byTooltip('Manage quick-button customization'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(
        container.read(posQuickButtonCustomizationProvider).hiddenButtonIds,
        isEmpty,
      );
    },
  );

  testWidgets('touch quick button panel updates touch density preference', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 720, child: POSTouchQuickButtonPanel()),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Manage quick-button customization'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spacious'));
    await tester.pumpAndSettle();

    expect(
      container.read(posQuickButtonCustomizationProvider).densityOverride,
      POSTouchLayoutDensity.spacious,
    );

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(
      container.read(posQuickButtonCustomizationProvider).densityOverride,
      isNull,
    );
  });
}
