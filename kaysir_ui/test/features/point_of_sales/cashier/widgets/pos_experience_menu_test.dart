import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_profiles.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_contract.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_data_trait.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_result.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_experience_menu.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/states/current_order_provider.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('POSExperienceMenu switches the active profile and layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [POSExperienceMenu(), _SelectedExperienceProbe()],
            ),
          ),
        ),
      ),
    );

    expect(find.text('standard_cashier:auto'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Kaysir Core'), findsOneWidget);
    expect(find.text('3 modes'), findsOneWidget);
    expect(find.text('General commerce'), findsOneWidget);
    expect(find.text('Quick sale'), findsOneWidget);
    expect(find.text('Preview'), findsWidgets);
    expect(find.text('Kiosk, Tablet, Mobile'), findsOneWidget);
    expect(find.text('Current mode'), findsOneWidget);
    expect(find.text('Review'), findsWidgets);

    final quickCheckoutItem = find.ancestor(
      of: find.text('Quick Checkout'),
      matching: find.byType(CheckedPopupMenuItem<String>),
    );
    expect(quickCheckoutItem, findsOneWidget);

    await tester.tap(quickCheckoutItem);
    await tester.pumpAndSettle();

    expect(find.text('quick_checkout:checkout'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(_SelectedExperienceProbe)),
    );
    final history = container.read(posSwitchActionHistoryProvider);
    expect(history.latest?.result.kind, POSSwitchActionKind.mode);
    expect(history.latest?.result.outcome, POSSwitchActionOutcome.applied);
    expect(history.latest?.result.targetId, 'quick_checkout');
  });

  testWidgets('POSExperienceMenu confirms before switching screen mismatches', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                POSExperienceMenu(viewportWidth: 1280),
                _SelectedExperienceProbe(),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Current mode'), findsOneWidget);
    expect(find.text('Review'), findsWidgets);
    expect(find.text('Confirm'), findsOneWidget);

    await tester.tap(_quickCheckoutMenuItem());
    await tester.pumpAndSettle();

    expect(find.text('Review mode switch'), findsOneWidget);
    expect(
      find.text(
        'Quick Checkout is not declared for Desktop screens. Supported screens: Kiosk, Tablet, Mobile.',
      ),
      findsOneWidget,
    );
    expect(find.text('standard_cashier:auto'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('standard_cashier:auto'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();
    await tester.tap(_quickCheckoutMenuItem());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Switch anyway'));
    await tester.pumpAndSettle();

    expect(find.text('quick_checkout:checkout'), findsOneWidget);
  });

  testWidgets(
    'POSExperienceMenu uses a compact switch sheet on mobile widths',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  POSExperienceMenu(viewportWidth: 600),
                  _SelectedExperienceProbe(),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('standard_cashier:auto'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
      await tester.pumpAndSettle();

      expect(find.text('POS modes'), findsOneWidget);
      expect(find.text('Kaysir Core'), findsOneWidget);
      expect(find.text('Quick Checkout'), findsOneWidget);

      await tester.tap(find.text('Quick Checkout'));
      await tester.pumpAndSettle();

      expect(find.text('quick_checkout:checkout'), findsOneWidget);
    },
  );

  testWidgets('POSExperienceMenu confirms before switching an active order', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                POSExperienceMenu(viewportWidth: 800),
                _SelectedExperienceProbe(),
              ],
            ),
          ),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(_SelectedExperienceProbe)),
    );
    container.read(currentOrderProvider.notifier).restoreOrder(_activeOrder());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();
    await tester.tap(_quickCheckoutMenuItem());
    await tester.pumpAndSettle();

    expect(find.text('Keep current order?'), findsOneWidget);
    expect(
      find.textContaining(
        'Switching to Quick Checkout keeps the current order',
      ),
      findsOneWidget,
    );
    expect(find.text('standard_cashier:auto'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('standard_cashier:auto'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();
    await tester.tap(_quickCheckoutMenuItem());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep order'));
    await tester.pumpAndSettle();

    expect(find.text('quick_checkout:checkout'), findsOneWidget);
  });

  testWidgets('POSExperienceMenu blocks non-launchable product profiles', (
    tester,
  ) async {
    final blockedMode = defaultPOSExperience.copyWith(
      id: 'blocked_modifiers',
      label: 'Blocked Modifiers',
      manifest: defaultPOSExperience.manifest.copyWith(
        archetypeKey: 'blocked_modifiers',
        archetypeLabel: 'Blocked modifiers',
        releaseStage: POSExperienceReleaseStage.stable,
        dataTraits: const [POSDataTraitKeys.modifierGroups],
      ),
    );
    final blockedProfile = POSProductProfile(
      id: 'blocked_modifiers_profile',
      label: 'Blocked Modifiers Profile',
      description: 'Profile with incomplete modifier contract coverage.',
      recipe: POSExperienceRecipe.fromExperience(blockedMode),
      experienceOverride: blockedMode,
      requiredModules: blockedMode.modules,
      requiredFormFactors: blockedMode.manifest.supportedFormFactors,
      requiredDataTraits: blockedMode.manifest.dataTraits,
      dataAdapters: const [
        POSDataTraitAdapter(
          id: 'incomplete_menu_api',
          label: 'Incomplete Menu API',
          fieldsByTrait: {
            POSDataTraitKeys.modifierGroups: ['group_id', 'option_id'],
          },
        ),
      ],
    );
    final catalog = POSProductProfileCatalog(
      profiles: [defaultPOSProductProfiles.first, blockedProfile],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          posProductProfileCatalogProvider.overrideWithValue(catalog),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                POSExperienceMenu(viewportWidth: 1280),
                _SelectedExperienceProbe(),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('standard_cashier:auto'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dashboard_customize_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Blocked Modifiers'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);

    await tester.tap(
      find.ancestor(
        of: find.text('Blocked Modifiers'),
        matching: find.byType(CheckedPopupMenuItem<String>),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mode unavailable'), findsOneWidget);
    expect(find.textContaining('Data contracts'), findsOneWidget);
    expect(find.textContaining('Price delta'), findsOneWidget);
    expect(find.text('standard_cashier:auto'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('standard_cashier:auto'), findsOneWidget);
  });
}

Finder _quickCheckoutMenuItem() {
  return find.ancestor(
    of: find.text('Quick Checkout'),
    matching: find.byType(CheckedPopupMenuItem<String>),
  );
}

class _SelectedExperienceProbe extends ConsumerWidget {
  const _SelectedExperienceProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experience = ref.watch(posExperienceProvider);
    final layoutPreference = ref.watch(posLayoutPreferenceProvider);

    return Text('${experience.id}:${layoutPreference.name}');
  }
}

Order _activeOrder() {
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
