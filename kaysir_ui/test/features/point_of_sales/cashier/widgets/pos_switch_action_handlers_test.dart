import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_product_runtime_pack_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_commerce_channel_switch_action_handler.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_mode_switch_action_handler.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_runtime_pack_switch_action_handler.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_action_context.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('mode switch handler confirms before applying a risky mode', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(posModeSwitchControllerProvider(1280));
    final quickCheckout = controller.optionFor('quick_checkout');
    final recorder = _SwitchActionRecorder(confirmationResults: [true]);

    final result = await handlePOSModeSwitchAction(
      actionContext: recorder.context,
      switchController: controller,
      option: quickCheckout,
      currentOrder: null,
    );

    expect(result.applied, isTrue);
    expect(result.kind, POSSwitchActionKind.mode);
    expect(result.targetId, 'quick_checkout');
    expect(result.targetLabel, 'Quick Checkout');
    expect(recorder.results.single, same(result));
    expect(recorder.confirmations.single.title, 'Review mode switch');
    expect(container.read(selectedPOSExperienceIdProvider), 'quick_checkout');
    expect(container.read(posLayoutPreferenceProvider).name, 'checkout');
    expect(recorder.handledCount, 1);
  });

  test(
    'runtime pack handler keeps cancelled active-order switches inert',
    () async {
      final registry = _runtimePackRegistry();
      final container = ProviderContainer(
        overrides: [
          posProductRuntimePackRegistryProvider.overrideWithValue(registry),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        posProductRuntimePackSwitchControllerProvider,
      );
      final recorder = _SwitchActionRecorder(confirmationResults: [false]);

      final result = await handlePOSRuntimePackSwitchAction(
        actionContext: recorder.context,
        switchController: controller,
        pack: controller.packFor('online_pack'),
        currentOrder: _activeOrder(),
      );

      expect(result.cancelled, isTrue);
      expect(result.kind, POSSwitchActionKind.runtimePack);
      expect(result.targetId, 'online_pack');
      expect(result.targetLabel, 'Online Pack');
      expect(result.reason, 'Keep current order?');
      expect(recorder.results.single, same(result));
      expect(recorder.confirmations.single.title, 'Keep current order?');
      expect(
        container.read(selectedPOSProductRuntimePackIdProvider),
        'kaysir_core',
      );
      expect(
        container.read(selectedPOSExperienceIdProvider),
        'standard_cashier',
      );
      expect(container.read(selectedPOSCommerceChannelIdProvider), 'in_store');
      expect(recorder.handledCount, 0);
    },
  );

  test(
    'runtime pack handler returns blocked metadata for unsafe orders',
    () async {
      final noPaymentPack = _noPaymentPack();
      final container = ProviderContainer(
        overrides: [
          posProductRuntimePackRegistryProvider.overrideWithValue(
            POSProductRuntimePackRegistry(
              defaultPackId: defaultPOSProductRuntimePack.id,
              packs: [defaultPOSProductRuntimePack, noPaymentPack],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        posProductRuntimePackSwitchControllerProvider,
      );
      final recorder = _SwitchActionRecorder();

      final result = await handlePOSRuntimePackSwitchAction(
        actionContext: recorder.context,
        switchController: controller,
        pack: controller.packFor('no_payment_pack'),
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
      );

      expect(result.blocked, isTrue);
      expect(result.kind, POSSwitchActionKind.runtimePack);
      expect(result.targetId, 'no_payment_pack');
      expect(result.targetLabel, 'No Payment Pack');
      expect(result.reason, 'Finish current order first');
      expect(recorder.results.single, same(result));
      expect(recorder.notices.single.title, 'Finish current order first');
      expect(
        container.read(selectedPOSProductRuntimePackIdProvider),
        'kaysir_core',
      );
      expect(recorder.handledCount, 0);
    },
  );

  test(
    'commerce channel handler exposes preflight confirmation details',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(
        posCommerceChannelSwitchControllerProvider,
      );
      final order = _activeOrder();
      final targetChannel = controller.channelFor('web_store');
      final plan = controllerPlanFor(
        container: container,
        controller: controller,
        targetChannelId: targetChannel.id,
        order: order,
      );
      final recorder = _SwitchActionRecorder(confirmationResults: [false]);

      final result = await handlePOSCommerceChannelSwitchAction(
        actionContext: recorder.context,
        switchController: controller,
        plan: plan,
      );

      expect(result.cancelled, isTrue);
      expect(result.kind, POSSwitchActionKind.commerceChannel);
      expect(result.targetId, 'web_store');
      expect(result.targetLabel, 'Web store');
      expect(result.reason, 'Keep current order?');
      expect(recorder.results.single, same(result));
      expect(recorder.confirmations.single.title, 'Keep current order?');
      expect(recorder.confirmations.single.details, isNotNull);
      expect(recorder.confirmations.single.canConfirmListenable, isNotNull);
      expect(container.read(selectedPOSCommerceChannelIdProvider), 'in_store');
      expect(recorder.handledCount, 0);
    },
  );
}

POSCommerceChannelSwitchPlan controllerPlanFor({
  required ProviderContainer container,
  required POSCommerceChannelSwitchController controller,
  required String targetChannelId,
  required Order? order,
}) {
  final targetChannel = controller.channelFor(targetChannelId);
  final currentFulfillmentContext = container.read(
    posOrderFulfillmentContextProvider,
  );
  final targetFulfillmentContext = resolvePOSOrderFulfillmentContextFor(
    order: order,
    channel: targetChannel,
    drafts: container.read(posOrderFulfillmentDraftsProvider),
  );

  return POSCommerceChannelSwitchPlan.resolve(
    currentChannel: controller.currentChannel,
    targetChannel: targetChannel,
    currentLayoutPreference: controller.currentLayoutPreference,
    currentFulfillmentContext: currentFulfillmentContext,
    targetFulfillmentContext: targetFulfillmentContext,
    order: order,
  );
}

POSProductRuntimePackRegistry _runtimePackRegistry() {
  final quickCheckoutProfile = defaultPOSProductRuntimePack
      .productProfileCatalog
      .profiles
      .firstWhere((profile) => profile.experience.id == 'quick_checkout');
  final webChannel = defaultPOSProductRuntimePack.commerceChannelRegistry
      .channelForId('web_store');
  final onlinePack = defaultPOSProductRuntimePack.copyWith(
    id: 'online_pack',
    label: 'Online Pack',
    productLine: 'Online',
    productProfileCatalog: POSProductProfileCatalog(
      profiles: [quickCheckoutProfile],
    ),
    commerceChannelRegistry: POSCommerceChannelRegistry(
      defaultChannelId: webChannel.id,
      channels: [webChannel],
    ),
  );

  return POSProductRuntimePackRegistry(
    defaultPackId: defaultPOSProductRuntimePack.id,
    packs: [defaultPOSProductRuntimePack, onlinePack],
  );
}

POSProductRuntimePack _noPaymentPack() {
  final noPaymentMode = defaultPOSExperience.copyWith(
    id: 'no_payment_mode',
    label: 'No Payment Mode',
    capabilities: defaultPOSExperience.capabilities.copyWith(payments: false),
  );
  final noPaymentProfile = POSProductProfile(
    id: 'no_payment_profile',
    label: 'No Payment Profile',
    description: noPaymentMode.description,
    recipe: POSExperienceRecipe.fromExperience(noPaymentMode),
    experienceOverride: noPaymentMode,
  );

  return defaultPOSProductRuntimePack.copyWith(
    id: 'no_payment_pack',
    label: 'No Payment Pack',
    productLine: 'Test',
    productProfileCatalog: POSProductProfileCatalog(
      profiles: [noPaymentProfile],
    ),
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

class _SwitchActionRecorder {
  final List<bool> confirmationResults;
  final List<POSSwitchNoticeRequest> notices = [];
  final List<POSSwitchConfirmationRequest> confirmations = [];
  final List<POSSwitchActionResult> results = [];
  int handledCount = 0;

  _SwitchActionRecorder({this.confirmationResults = const []});

  POSSwitchActionContext get context {
    return POSSwitchActionContext(
      showNotice: (request) async => notices.add(request),
      showConfirmation: (request) async {
        confirmations.add(request);
        if (confirmationResults.isEmpty) return true;
        return confirmationResults.removeAt(0);
      },
      onActionResult: results.add,
      onActionHandled: () => handledCount += 1,
    );
  }
}
