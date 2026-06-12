import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_availability.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_impact.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_preview.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_mode_switch_option_tile.dart';

void main() {
  testWidgets('mode switch section header renders reusable counts', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: POSModeSwitchSectionHeader(title: 'Kaysir Core', count: 3),
        ),
      ),
    );

    expect(find.text('Kaysir Core'), findsOneWidget);
    expect(find.text('3 modes'), findsOneWidget);
  });

  testWidgets('mode switch option tile renders mode metadata and readiness', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(1280));
    final option = state.findOption(defaultPOSExperience.id);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSModeSwitchOptionTile(
            option: option!,
            showSelectedIndicator: true,
          ),
        ),
      ),
    );

    expect(find.text('Standard Cashier'), findsOneWidget);
    expect(find.text('General commerce'), findsOneWidget);
    expect(find.text('Stable'), findsOneWidget);
    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('Desktop, Tablet, Mobile'), findsOneWidget);
    expect(find.text('Launch ready'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('mode switch option tile renders confirmation state', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(1280));
    final option = state.findOption(quickCheckoutPOSExperience.id);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: POSModeSwitchOptionTile(option: option!)),
      ),
    );

    expect(find.text('Quick Checkout'), findsOneWidget);
    expect(find.text('Quick sale'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Kiosk, Tablet, Mobile'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets('mode switch option tile renders feature impact summary', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(600));
    final option = state.findOption(quickCheckoutPOSExperience.id);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSModeSwitchOptionTile(
            option: option!,
            impact: POSModeSwitchImpact.evaluate(
              currentExperience: state.currentExperience,
              targetExperience: option.experience,
            ),
          ),
        ),
      ),
    );

    expect(find.text('5 off'), findsOneWidget);
    expect(find.text('Customer off'), findsOneWidget);
    expect(find.text('Holds off'), findsOneWidget);
    expect(find.text('Promos off'), findsOneWidget);
    expect(find.byIcon(Icons.compare_arrows_outlined), findsOneWidget);
  });

  testWidgets('mode switch option tile renders reusable switch preview', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(600));
    final option = state.findOption(quickCheckoutPOSExperience.id);
    final availability = POSModeSwitchAvailability.evaluate(
      option: option!,
      order: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSModeSwitchOptionTile(
            option: option,
            availability: availability,
            preview: POSModeSwitchPreview.evaluate(
              availability: availability,
              currentExperience: state.currentExperience,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Auto to Checkout'), findsOneWidget);
    expect(find.text('5 off'), findsOneWidget);
    expect(find.text('Customer off'), findsOneWidget);
    expect(find.byIcon(Icons.splitscreen_outlined), findsOneWidget);
  });
}
