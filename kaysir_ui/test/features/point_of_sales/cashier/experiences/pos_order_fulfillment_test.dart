import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/customer.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/states/current_order_provider.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('immediate handoff channel is ready without extra context', () {
    final channel = defaultPOSCommerceChannelRegistry.channelForId('in_store');
    final readiness = resolvePOSOrderFulfillmentReadiness(
      order: _order(),
      channel: channel,
      context: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.immediateHandoff,
      ),
    );

    expect(readiness.canComplete, isTrue);
    expect(readiness.statusLabel, 'Ready for handoff');
    expect(readiness.needsOperatorInput, isFalse);
  });

  test('delivery channel requires a destination', () {
    final channel = defaultPOSCommerceChannelRegistry.channelForId(
      'delivery_app',
    );
    final missingDestination = resolvePOSOrderFulfillmentReadiness(
      order: _order(),
      channel: channel,
      context: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.delivery,
      ),
    );
    final ready = resolvePOSOrderFulfillmentReadiness(
      order: _order(),
      channel: channel,
      context: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.delivery,
        destination: 'Jl. Merdeka 10',
      ),
    );

    expect(missingDestination.canComplete, isFalse);
    expect(missingDestination.statusLabel, 'Delivery address needed');
    expect(ready.canComplete, isTrue);
    expect(ready.summaryLabel, 'Jl. Merdeka 10');
  });

  test('pickup channel accepts customer or pickup contact', () {
    final channel = defaultPOSCommerceChannelRegistry.channelForId('web_store');
    final missingContact = resolvePOSOrderFulfillmentReadiness(
      order: _order(),
      channel: channel,
      context: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.pickup,
      ),
    );
    final customerReady = resolvePOSOrderFulfillmentReadiness(
      order: _order(customer: _customer()),
      channel: channel,
      context: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.pickup,
      ),
    );
    final contactReady = resolvePOSOrderFulfillmentReadiness(
      order: _order(),
      channel: channel,
      context: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.pickup,
        contactName: 'Aisyah',
      ),
    );

    expect(missingContact.canComplete, isFalse);
    expect(missingContact.statusLabel, 'Pickup contact needed');
    expect(customerReady.canComplete, isTrue);
    expect(contactReady.canComplete, isTrue);
  });

  test('preorder requires both contact and schedule', () {
    final channel = defaultPOSCommerceChannelRegistry.channelForId(
      'phone_order',
    );
    final readiness = resolvePOSOrderFulfillmentReadiness(
      order: _order(),
      channel: channel,
      context: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.preorder,
      ),
    );

    expect(readiness.canComplete, isFalse);
    expect(
      readiness.issues.map((issue) => issue.type),
      containsAll([
        POSOrderFulfillmentIssueType.missingContact,
        POSOrderFulfillmentIssueType.missingSchedule,
      ]),
    );
  });

  test('readiness creates an order fulfillment snapshot', () {
    final channel = defaultPOSCommerceChannelRegistry.channelForId('web_store');
    final readiness = resolvePOSOrderFulfillmentReadiness(
      order: _order(customer: _customer()),
      channel: channel,
      context: const POSOrderFulfillmentContext(
        mode: POSFulfillmentMode.pickup,
      ),
    );

    final snapshot = readiness.toOrderFulfillmentSnapshot();

    expect(snapshot.commerceChannelId, 'web_store');
    expect(snapshot.commerceChannelLabel, 'Web store');
    expect(snapshot.fulfillmentModeKey, 'pickup');
    expect(snapshot.fulfillmentModeLabel, 'Pickup');
    expect(snapshot.contactName, 'Aisyah');
    expect(snapshot.statusLabel, 'Pickup ready');
    expect(snapshot.detailLabel, 'Aisyah');
    expect(snapshot.hasDetails, isTrue);
  });

  test('fulfillment drafts are scoped by order and commerce channel', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(selectedPOSCommerceChannelIdProvider.notifier).state =
        'web_store';
    container
        .read(currentOrderProvider.notifier)
        .restoreOrder(_order(id: 'order_1'));

    final controller = container.read(posOrderFulfillmentControllerProvider);
    controller.setMode(POSFulfillmentMode.delivery);
    controller.setDestination('Jl. Merdeka 10');

    var context = container.read(posOrderFulfillmentContextProvider);
    expect(context.mode, POSFulfillmentMode.delivery);
    expect(context.destination, 'Jl. Merdeka 10');

    container
        .read(currentOrderProvider.notifier)
        .restoreOrder(_order(id: 'order_2'));

    context = container.read(posOrderFulfillmentContextProvider);
    expect(context.mode, POSFulfillmentMode.pickup);
    expect(context.destination, isEmpty);

    container
        .read(currentOrderProvider.notifier)
        .restoreOrder(_order(id: 'order_1'));

    context = container.read(posOrderFulfillmentContextProvider);
    expect(context.mode, POSFulfillmentMode.delivery);
    expect(context.destination, 'Jl. Merdeka 10');

    container.read(selectedPOSCommerceChannelIdProvider.notifier).state =
        'delivery_app';

    context = container.read(posOrderFulfillmentContextProvider);
    expect(context.mode, POSFulfillmentMode.delivery);
    expect(context.destination, isEmpty);
  });

  test('fulfillment provider applies channel behavior schedule rules', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(selectedPOSCommerceChannelIdProvider.notifier).state =
        'phone_order';
    container
        .read(currentOrderProvider.notifier)
        .restoreOrder(_order(customer: _customer()));

    var readiness = container.read(posOrderFulfillmentReadinessProvider);

    expect(readiness?.canComplete, isFalse);
    expect(readiness?.statusLabel, 'Schedule needed');

    container
        .read(posOrderFulfillmentControllerProvider)
        .setScheduleLabel('Tomorrow 10:00');

    readiness = container.read(posOrderFulfillmentReadinessProvider);

    expect(readiness?.canComplete, isTrue);
    expect(readiness?.statusLabel, 'Pickup ready');
  });
}

Order _order({String id = 'order_1', Customer? customer}) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: id,
    items: [
      OrderItem(
        id: 'line_1',
        product: product,
        quantity: 1,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    customer: customer,
    payments: const [],
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

Customer _customer() {
  return Customer(
    id: 'customer_1',
    name: 'Aisyah',
    phone: '08123456789',
    email: 'aisyah@example.com',
    loyaltyPoints: 10,
  );
}
