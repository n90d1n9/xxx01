import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_behavior.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_touch_layout_profile_catalog.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_command_actions.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_layout_strategy_pack.dart';

void main() {
  test('default runtime pack bundles the reusable POS runtime', () {
    expect(defaultPOSProductRuntimePack.id, 'kaysir_core');
    expect(defaultPOSProductRuntimePack.productLine, 'Kaysir Core');
    expect(defaultPOSProductRuntimePack.validate(), isEmpty);
    expect(defaultPOSProductRuntimePack.isValid, isTrue);
    expect(defaultPOSProductRuntimePack.throwIfInvalid, returnsNormally);
    expect(
      defaultPOSProductRuntimePack.productProfileCatalog.launchableProfiles,
      isNotEmpty,
    );
    expect(
      defaultPOSProductRuntimePack.commerceChannelRegistry.defaultChannelId,
      'in_store',
    );
    expect(
      defaultPOSProductRuntimePack.commerceChannelBehaviorRegistry
          .profileForChannel('delivery_app')
          .supportsModule(POSCommerceChannelBehaviorModules.deliveryAggregator),
      isTrue,
    );
    expect(
      defaultPOSProductRuntimePack.touchLayoutProfileCatalog.defaultProfileId,
      'core_counter_touch',
    );
  });

  test('runtime pack validation collects nested extension issues', () {
    final brokenPack = defaultPOSProductRuntimePack.copyWith(
      id: '',
      label: '',
      description: '',
      productProfileCatalog: POSProductProfileCatalog(profiles: const []),
      commerceChannelRegistry: POSCommerceChannelRegistry(
        defaultChannelId: 'missing',
        channels: const [],
      ),
      commerceChannelBehaviorRegistry: POSCommerceChannelBehaviorRegistry(
        profiles: const [],
      ),
      layoutStrategyPack: POSLayoutStrategyPack.withRenderers(
        renderers: const [],
      ),
      touchLayoutProfileCatalog: const POSTouchLayoutProfileCatalog(
        defaultProfileId: 'missing',
        profiles: [],
      ),
      commandActionRegistry: POSCommandActionRegistry(
        specs: [
          POSCommandActionRegistry.defaultSpecs.first,
          POSCommandActionRegistry.defaultSpecs.first,
        ],
      ),
    );

    final issueTypes = brokenPack.validate().map((issue) => issue.type);

    expect(
      issueTypes,
      containsAll([
        POSProductRuntimePackIssueType.blankPackId,
        POSProductRuntimePackIssueType.blankPackLabel,
        POSProductRuntimePackIssueType.blankPackDescription,
        POSProductRuntimePackIssueType.productProfileCatalogIssue,
        POSProductRuntimePackIssueType.commerceChannelRegistryIssue,
        POSProductRuntimePackIssueType.commerceChannelBehaviorIssue,
        POSProductRuntimePackIssueType.layoutRendererIssue,
        POSProductRuntimePackIssueType.touchLayoutProfileIssue,
        POSProductRuntimePackIssueType.commandActionIssue,
      ]),
    );
    expect(brokenPack.throwIfInvalid, throwsStateError);
  });

  test(
    'runtime pack registry resolves default, fallback, and registry issues',
    () {
      final duplicateA = defaultPOSProductRuntimePack.copyWith(
        id: 'duplicate_pack',
        label: 'Duplicate A',
      );
      final duplicateB = defaultPOSProductRuntimePack.copyWith(
        id: 'duplicate_pack',
        label: 'Duplicate B',
      );
      final registry = POSProductRuntimePackRegistry(
        defaultPackId: 'missing_pack',
        packs: [duplicateA, duplicateB],
      );

      final fallback = registry.resolveDetailed('unknown_pack');
      final issueTypes = registry.validate().map((issue) => issue.type);

      expect(fallback.usedFallback, isTrue);
      expect(fallback.pack, same(duplicateA));
      expect(fallback.fallbackReason, contains('not registered'));
      expect(
        issueTypes,
        containsAll([
          POSProductRuntimePackRegistryIssueType.duplicatePackId,
          POSProductRuntimePackRegistryIssueType.missingDefaultPack,
        ]),
      );
      expect(registry.isValid, isFalse);
      expect(registry.throwIfInvalid, throwsStateError);
    },
  );
}
