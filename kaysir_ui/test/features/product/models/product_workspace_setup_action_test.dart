import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_workspace_recommendation.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_action.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/product_routes.dart';

void main() {
  test('workspace setup action resolves recommendation route', () {
    const recommendation = ProductWorkspaceRecommendation(
      id: 'freshness_data_setup',
      title: 'Prepare freshness data',
      subtitle: 'Complete freshness fields',
      actionLabel: 'Open freshness',
      statusLabel: 'Freshness',
      priority: ProductWorkspaceRecommendationPriority.high,
      routePath: '/products?review=Freshness+setup',
    );

    final action = ProductWorkspaceSetupAction.resolve(
      target: ProductWorkspaceSetupTarget.freshness,
      recommendations: const [recommendation],
    );

    expect(action.targetId, 'freshness');
    expect(action.label, 'Review freshness data');
    expect(action.routePath, '/products?review=Freshness+setup');
    expect(action.usesRecommendation, isTrue);
    expect(action.usesFallback, isFalse);
  });

  test('workspace setup action normalizes contributed target metadata', () {
    const target = ProductWorkspaceSetupTarget(
      id: ' restaurant_menu ',
      title: 'Restaurant menu setup',
      subtitle: 'Prepare dine-in menu metadata.',
      actionLabel: 'Review menu setup',
      recommendationId: ' restaurant_menu_setup ',
    );
    const recommendation = ProductWorkspaceRecommendation(
      id: ' restaurant_menu_setup ',
      title: 'Prepare menu data',
      subtitle: 'Complete restaurant menu fields',
      actionLabel: 'Open menu',
      statusLabel: 'Menu',
      priority: ProductWorkspaceRecommendationPriority.high,
      routePath: '/products?review=Menu+setup',
    );

    final action = ProductWorkspaceSetupAction.resolve(
      target: target,
      recommendations: const [recommendation],
    );
    final prompt = ProductWorkspaceSetupActionResolver(
      recommendations: const [],
      activations: const [
        ProductWorkspaceSetupActivation(
          targetId: ' restaurant_menu ',
          packId: ProductManagementPackId.groceryFreshGoods,
          packTitle: 'Grocery Fresh Goods',
        ),
      ],
    ).promptFor(
      target,
      availability: ProductWorkspaceSetupTargetAvailability.inactive,
    );

    expect(action.targetId, 'restaurant_menu');
    expect(action.routePath, '/products?review=Menu+setup');
    expect(action.usesRecommendation, isTrue);
    expect(prompt.targetId, 'restaurant_menu');
    expect(
      prompt.action.activationPackId,
      ProductManagementPackId.groceryFreshGoods,
    );
  });

  test(
    'workspace setup action falls back when recommendation is unavailable',
    () {
      const recommendation = ProductWorkspaceRecommendation(
        id: 'freshness_data_setup',
        title: 'Prepare freshness data',
        subtitle: 'Complete freshness fields',
        actionLabel: 'Open freshness',
        statusLabel: 'Freshness',
        priority: ProductWorkspaceRecommendationPriority.high,
      );

      final action = ProductWorkspaceSetupAction.resolve(
        target: ProductWorkspaceSetupTarget.freshness,
        recommendations: const [recommendation],
      );

      expect(action.routePath, ProductRoutes.catalogPath);
      expect(action.usesFallback, isTrue);
    },
  );

  test('workspace setup action flags inactive setup targets', () {
    final action = ProductWorkspaceSetupAction.resolve(
      target: ProductWorkspaceSetupTarget.freshness,
      recommendations: const [],
      activations: const [
        ProductWorkspaceSetupActivation(
          targetId: 'freshness',
          packId: ProductManagementPackId.groceryFreshGoods,
          packTitle: 'Grocery Fresh Goods',
          packFocusLabel:
              'Track freshness-critical product data before selling across channels',
        ),
      ],
      availability: ProductWorkspaceSetupTargetAvailability.inactive,
    );
    final prompt = ProductWorkspaceSetupActionResolver(
      recommendations: const [],
      activations: const [
        ProductWorkspaceSetupActivation(
          targetId: 'freshness',
          packId: ProductManagementPackId.groceryFreshGoods,
          packTitle: 'Grocery Fresh Goods',
          packFocusLabel:
              'Track freshness-critical product data before selling across channels',
        ),
      ],
    ).promptFor(
      ProductWorkspaceSetupTarget.freshness,
      availability: ProductWorkspaceSetupTargetAvailability.inactive,
    );

    expect(action.routePath, ProductRoutes.workspacePath);
    expect(action.activationPackId, ProductManagementPackId.groceryFreshGoods);
    expect(
      action.activationFeedbackMessage,
      'Grocery Fresh Goods activated for setup.',
    );
    expect(action.usesInactiveTarget, isTrue);
    expect(prompt.title, 'Freshness control setup unavailable');
    expect(
      prompt.subtitle,
      'Switch to Grocery Fresh Goods to activate this setup target. Track freshness-critical product data before selling across channels.',
    );
    expect(prompt.statusLabel, 'Not in pack');
    expect(prompt.actionLabel, 'Switch to Grocery Fresh Goods');
    expect(prompt.isInactive, isTrue);
  });

  test(
    'workspace setup action handles inactive targets without activation',
    () {
      final prompt = const ProductWorkspaceSetupActionResolver(
        recommendations: [],
      ).promptFor(
        ProductWorkspaceSetupTarget.freshness,
        availability: ProductWorkspaceSetupTargetAvailability.inactive,
      );

      expect(prompt.actionLabel, 'Review product pack');
      expect(prompt.action.hasActivationPack, isFalse);
      expect(prompt.action.activationFeedbackMessage, isNull);
      expect(
        prompt.subtitle,
        'This setup target is not active for the current product pack.',
      );
      expect(prompt.routePath, ProductRoutes.workspacePath);
      expect(prompt.isInactive, isTrue);
    },
  );

  test('workspace setup action preserves custom setup target prompts', () {
    final prompt = const ProductWorkspaceSetupActionResolver(
      recommendations: [],
    ).promptFor(
      ProductWorkspaceSetupTarget.custom('kiosk_bundle'),
      availability: ProductWorkspaceSetupTargetAvailability.custom,
    );

    expect(prompt.title, 'Kiosk Bundle setup');
    expect(prompt.statusLabel, 'Custom setup');
    expect(prompt.isCustom, isTrue);
    expect(prompt.usesFallback, isTrue);
  });

  test('workspace setup action resolver preserves custom fallback routes', () {
    const target = ProductWorkspaceSetupTarget(
      id: 'restaurant_menu',
      title: 'Restaurant menu setup',
      subtitle: 'Prepare dine-in menu metadata.',
      actionLabel: '',
    );
    const resolver = ProductWorkspaceSetupActionResolver(
      recommendations: [],
      fallbackRoutePath: '/products?filter=attention',
    );

    final action = resolver.resolve(target);

    expect(action.label, 'Open setup');
    expect(action.routePath, '/products?filter=attention');
    expect(action.usesFallback, isTrue);
  });

  test('workspace setup action resolver builds coherent prompts', () {
    const target = ProductWorkspaceSetupTarget(
      id: 'restaurant_menu',
      title: 'Restaurant menu setup',
      subtitle: 'Prepare dine-in menu metadata.',
      actionLabel: 'Review menu setup',
    );
    const resolver = ProductWorkspaceSetupActionResolver(
      recommendations: [],
      fallbackRoutePath: '/products?filter=attention',
    );

    final prompt = resolver.promptFor(target);

    expect(prompt.target, target);
    expect(prompt.targetId, 'restaurant_menu');
    expect(prompt.title, 'Restaurant menu setup');
    expect(prompt.subtitle, 'Prepare dine-in menu metadata.');
    expect(prompt.actionLabel, 'Review menu setup');
    expect(prompt.routePath, '/products?filter=attention');
    expect(prompt.usesFallback, isTrue);
  });
}
