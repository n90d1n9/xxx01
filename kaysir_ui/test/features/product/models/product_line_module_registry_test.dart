import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_line_module_definition.dart';
import 'package:kaysir/features/product/models/product_line_module_registry.dart';
import 'package:kaysir/features/product/utils/default_product_line_module_manifests.dart';

void main() {
  test('product line module registry resolves default definitions', () {
    final registry = defaultProductLineModuleRegistry;
    final contributionRegistry = registry.toContributionRegistry();

    expect(registry.moduleCountLabel, '4 modules');
    expect(registry.ignoredDefinitionCountLabel, '0 ignored modules');
    expect(registry.hasIgnoredDefinitionDiagnostics, isFalse);
    expect(registry.definitionIds, [
      'coffee_counter_operations',
      'restaurant_menu_operations',
      'retail_assortment_operations',
      'kiosk_self_service_operations',
    ]);
    expect(
      registry
          .activeDefinitionsFor(coreProductManagementPack)
          .map((definition) => definition.normalizedId),
      registry.definitionIds,
    );
    expect(
      registry.activeDefinitionsFor(groceryFreshGoodsProductManagementPack),
      isEmpty,
    );
    expect(
      registry
          .setupTargetsFor(coreProductManagementPack)
          .map((target) => target.normalizedId),
      ['coffee_menu', 'restaurant_menu', 'retail_assortment', 'kiosk_bundle'],
    );
    expect(
      registry.definitionForSetupTarget(' kiosk_bundle ')?.titleLabel,
      'Kiosk self-service operations',
    );
    expect(
      registry.definitionOrNull('retail_assortment_operations')?.setupTarget.id,
      'retail_assortment',
    );
    expect(registry.manifests.map((manifest) => manifest.id), [
      'coffee_counter_operations',
      'restaurant_menu_operations',
      'retail_assortment_operations',
      'kiosk_self_service_operations',
    ]);
    expect(contributionRegistry.hasDuplicateHookDiagnostics, isFalse);
    expect(contributionRegistry.ignoredManifestDiagnostics, isEmpty);
  });

  test(
    'product line module registry reports duplicate and blank definitions',
    () {
      final duplicate = ProductLineModuleDefinition(
        id: ' coffee_counter_operations ',
        title: 'Duplicate coffee module',
        description: 'Duplicate module id.',
        setupTarget: coffeeCounterProductLineModuleDefinition.setupTarget,
        workspaceAction:
            coffeeCounterProductLineModuleDefinition.workspaceAction,
        recommendation: coffeeCounterProductLineModuleDefinition.recommendation,
        briefAction: coffeeCounterProductLineModuleDefinition.briefAction,
        availabilityTemplates:
            coffeeCounterProductLineModuleDefinition.availabilityTemplates,
        readinessRules: coffeeCounterProductLineModuleDefinition.readinessRules,
      );
      final blank = ProductLineModuleDefinition(
        id: ' ',
        title: 'Blank product line',
        description: 'Missing module id.',
        setupTarget: restaurantMenuProductLineModuleDefinition.setupTarget,
        workspaceAction:
            restaurantMenuProductLineModuleDefinition.workspaceAction,
        recommendation:
            restaurantMenuProductLineModuleDefinition.recommendation,
        briefAction: restaurantMenuProductLineModuleDefinition.briefAction,
      );

      final registry = ProductLineModuleRegistry(
        definitions: [
          coffeeCounterProductLineModuleDefinition,
          duplicate,
          blank,
        ],
      );

      expect(registry.definitionIds, ['coffee_counter_operations']);
      expect(registry.ignoredDefinitionCount, 2);
      expect(
        registry.ignoredDefinitionDiagnostics.map(
          (diagnostic) => '${diagnostic.reasonLabel}:${diagnostic.moduleLabel}',
        ),
        [
          'Duplicate module id:coffee_counter_operations',
          'Blank module id:Blank product line',
        ],
      );
      expect(
        registry.ignoredDefinitionDiagnostics.first.message,
        'Duplicate coffee module was ignored because Coffee counter operations '
        'already registered "coffee_counter_operations".',
      );
      expect(
        registry.ignoredDefinitionDiagnostics.last.resolutionGuidance,
        'Set a stable non-empty product-line module id before registering '
        'Blank product line.',
      );
    },
  );
}
