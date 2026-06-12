import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';

void main() {
  test('workspace setup target carries action metadata', () {
    expect(ProductWorkspaceSetupTarget.freshness.id, 'freshness');
    expect(ProductWorkspaceSetupTarget.freshness.normalizedId, 'freshness');
    expect(
      ProductWorkspaceSetupTarget.freshness.recommendationId,
      'freshness_data_setup',
    );
    expect(ProductWorkspaceSetupTarget.freshness.hasRecommendation, isTrue);
    expect(ProductWorkspaceSetupTarget.freshness.isCustom, isFalse);
    expect(
      ProductWorkspaceSetupTarget.freshness.priority,
      ProductWorkspaceSetupPriority.high,
    );
    expect(
      ProductWorkspaceSetupTarget.freshness.estimatedEffortLabel,
      '18 min',
    );
    expect(
      ProductWorkspaceSetupTarget.freshness.requirementCountLabel,
      '3 requirements',
    );
    expect(
      ProductWorkspaceSetupTarget.freshness.requirements.map(
        (requirement) => requirement.label,
      ),
      ['Expiry date data', 'Batch traceability', 'Pull-from-shelf workflow'],
    );
  });

  test('workspace setup target registry resolves known and custom targets', () {
    const restaurantTarget = ProductWorkspaceSetupTarget(
      id: 'restaurant_menu',
      title: 'Restaurant menu setup',
      subtitle: 'Prepare dine-in menu metadata.',
      actionLabel: 'Review menu setup',
      recommendationId: 'restaurant_menu_setup',
    );
    const registry = ProductWorkspaceSetupTargetRegistry([
      ProductWorkspaceSetupTarget.freshness,
      restaurantTarget,
    ]);

    expect(
      registry.resolve('freshness'),
      ProductWorkspaceSetupTarget.freshness,
    );
    expect(registry.resolve(' restaurant_menu '), restaurantTarget);
    expect(registry.resolve(''), isNull);
    expect(registry.contains('restaurant_menu'), isTrue);
    expect(registry.contains('unknown'), isFalse);

    final customTarget = registry.resolve('kiosk_bundle');

    expect(customTarget?.id, 'kiosk_bundle');
    expect(customTarget?.title, 'Kiosk Bundle setup');
    expect(customTarget?.isCustom, isTrue);
    expect(customTarget?.hasRecommendation, isFalse);
    expect(customTarget?.requirementCountLabel, '2 requirements');
    expect(customTarget?.priorityLabel, 'Medium priority');
  });

  test('workspace setup target registry normalizes contributed ids', () {
    const restaurantTarget = ProductWorkspaceSetupTarget(
      id: ' restaurant_menu ',
      title: 'Restaurant menu setup',
      subtitle: 'Prepare dine-in menu metadata.',
      actionLabel: 'Review menu setup',
    );
    const registry = ProductWorkspaceSetupTargetRegistry(
      [restaurantTarget],
      activeTargetIds: {' restaurant_menu '},
      tracksAvailability: true,
    );

    final resolution = registry.resolveWithAvailability(' restaurant_menu ');

    expect(registry.contains('restaurant_menu'), isTrue);
    expect(registry.isActive('restaurant_menu'), isTrue);
    expect(resolution?.target, restaurantTarget);
    expect(resolution?.target.normalizedId, 'restaurant_menu');
    expect(resolution?.isActive, isTrue);
  });

  test(
    'workspace setup target registry tracks active targets when requested',
    () {
      const registry = ProductWorkspaceSetupTargetRegistry(
        [ProductWorkspaceSetupTarget.freshness],
        activeTargetIds: {'freshness'},
        tracksAvailability: true,
      );
      const inactiveRegistry = ProductWorkspaceSetupTargetRegistry([
        ProductWorkspaceSetupTarget.freshness,
      ], tracksAvailability: true);

      final activeResolution = registry.resolveWithAvailability('freshness');
      final inactiveResolution = inactiveRegistry.resolveWithAvailability(
        'freshness',
      );
      final customResolution = registry.resolveWithAvailability('kiosk_bundle');

      expect(registry.isActive('freshness'), isTrue);
      expect(activeResolution?.isActive, isTrue);
      expect(inactiveRegistry.isActive('freshness'), isFalse);
      expect(inactiveResolution?.isInactive, isTrue);
      expect(customResolution?.isCustom, isTrue);
    },
  );
}
