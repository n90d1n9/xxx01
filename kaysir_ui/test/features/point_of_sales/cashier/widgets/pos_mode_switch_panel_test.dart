import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_mode_switch_panel.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('mode switch panel renders grouped options and current mode', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(600));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 560,
            child: POSModeSwitchPanel(state: state, onOptionSelected: (_) {}),
          ),
        ),
      ),
    );

    expect(find.text('POS modes'), findsOneWidget);
    expect(find.text('Kaysir Core'), findsOneWidget);
    expect(find.text('3 modes'), findsOneWidget);
    expect(find.text(defaultPOSExperience.label), findsWidgets);
    expect(find.text('Quick Checkout'), findsOneWidget);
    expect(find.text('Assisted Service'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('mode switch panel reports selected options', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(600));
    String? selectedId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 560,
            child: POSModeSwitchPanel(
              state: state,
              onOptionSelected: (option) => selectedId = option.id,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Quick Checkout'));
    await tester.pumpAndSettle();

    expect(selectedId, quickCheckoutPOSExperience.id);
  });

  testWidgets('mode switch panel filters options by search query', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(600));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 560,
            child: POSModeSwitchPanel(state: state, onOptionSelected: (_) {}),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'quick');
    await tester.pumpAndSettle();

    expect(find.text('Quick Checkout'), findsOneWidget);
    expect(find.text('Assisted Service'), findsNothing);
  });

  testWidgets('mode switch panel filters options by feature impact query', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(600));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 560,
            child: POSModeSwitchPanel(state: state, onOptionSelected: (_) {}),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'customer off');
    await tester.pumpAndSettle();

    expect(find.text('Quick Checkout'), findsOneWidget);
    expect(find.text('Customer off'), findsOneWidget);
    expect(find.text('Assisted Service'), findsNothing);
  });

  testWidgets('mode switch panel filters options by readiness status', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(1280));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 560,
            child: POSModeSwitchPanel(state: state, onOptionSelected: (_) {}),
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Quick Checkout'), findsOneWidget);
    expect(find.text('Assisted Service'), findsNothing);
  });

  testWidgets('mode switch panel shows active order impact per mode', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(600));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 560,
            child: POSModeSwitchPanel(
              state: state,
              currentOrder: _activeOrder(),
              onOptionSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Current order'), findsOneWidget);
    expect(find.text('Keeps order'), findsWidgets);
    expect(find.text('Active order'), findsOneWidget);
    expect(find.text('1 line, 2 items, Rp 100.000'), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(ChoiceChip, 'Confirm'),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('mode switch panel filters active order blockers', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 560,
            child: POSModeSwitchPanel(
              state: _stateWithPaymentlessMode(),
              currentOrder: _activeOrder(
                payments: [
                  Payment(
                    id: 'payment_1',
                    amount: 100000,
                    method: 'Cash',
                    timestamp: DateTime(2026, 5, 30, 9, 15),
                    reference: 'REF1',
                    isComplete: true,
                  ),
                ],
              ),
              onOptionSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Blocked'));
    await tester.pumpAndSettle();

    expect(find.text('No Payment Mode'), findsOneWidget);
    expect(find.text('Finish order'), findsOneWidget);
    expect(find.text('Current order'), findsNothing);
    expect(
      find.descendant(
        of: find.widgetWithText(ChoiceChip, 'Blocked'),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });
}

POSModeSwitchState _stateWithPaymentlessMode() {
  final noPaymentMode = defaultPOSExperience.copyWith(
    id: 'no_payment_mode',
    label: 'No Payment Mode',
    capabilities: defaultPOSExperience.capabilities.copyWith(payments: false),
  );

  return POSModeSwitchState(
    currentExperience: defaultPOSExperience,
    sections: [
      POSModeSwitchSection(
        productLine: 'Test Modes',
        options: [
          POSModeSwitchOption(
            experience: defaultPOSExperience,
            productProfile: null,
            decision: POSModeSwitchPolicy.evaluate(
              experience: defaultPOSExperience,
              viewportWidth: 800,
            ),
            selected: true,
          ),
          POSModeSwitchOption(
            experience: noPaymentMode,
            productProfile: null,
            decision: POSModeSwitchPolicy.evaluate(
              experience: noPaymentMode,
              viewportWidth: 800,
            ),
            selected: false,
          ),
        ],
      ),
    ],
  );
}

Order _activeOrder({List<Payment> payments = const []}) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'order_1',
    items: [
      OrderItem(
        id: 'line_1',
        product: product,
        quantity: 2,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: payments,
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 5, 30, 9),
    status: 'pending',
  );
}
