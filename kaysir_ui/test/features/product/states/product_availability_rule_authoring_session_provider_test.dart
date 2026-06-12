import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_availability_rule_authoring.dart';
import 'package:kaysir/features/product/models/product_availability_rule_authoring_session.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/states/product_availability_rule_authoring_session_provider.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';

void main() {
  test(
    'availability authoring session coordinates source template and target',
    () async {
      final container = ProviderContainer(
        overrides: [
          productManagementPacksProvider.overrideWithValue([
            coreProductManagementPack,
            groceryFreshGoodsProductManagementPack,
          ]),
          _memoryPreferencesRepositoryOverride(),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(productManagementPackIdProvider.notifier)
          .selectPack(ProductManagementPackId.groceryFreshGoods);

      final sessionController = container.read(
        productAvailabilityRuleAuthoringSessionControllerProvider,
      );

      expect(
        container.read(productAvailabilityRuleAuthoringSessionProvider),
        ProductAvailabilityRuleAuthoringSession.defaults,
      );
      expect(
        container.read(
          productAvailabilityRuleAuthoringEffectiveSourceIdProvider,
        ),
        productAvailabilityRuleTemplateAllSourceId,
      );
      expect(
        container.read(
          productAvailabilityRuleAuthoringEffectiveTemplateIdProvider,
        ),
        ProductAvailabilityRuleTemplateId.counterService,
      );
      expect(
        container.read(productAvailabilityRuleAuthoringEffectiveTargetProvider),
        ProductAvailabilityRuleAuthoringTarget.unconfigured,
      );
      var sessionSummary = container.read(
        productAvailabilityRuleAuthoringSessionSummaryProvider,
      );
      expect(sessionSummary.isDefault, isTrue);
      expect(sessionSummary.sessionLabel, 'Default session');
      expect(sessionSummary.sourceDisplayLabel, 'All templates');
      expect(sessionSummary.templateLabel, 'Counter service');
      expect(sessionSummary.targetLabel, 'Missing rules');
      expect(
        sessionSummary.availableTemplateCountLabel,
        '8 templates available',
      );

      sessionController.selectSource('freshness_availability_templates');
      expect(
        container.read(
          productAvailabilityRuleAuthoringSelectedSourceIdProvider,
        ),
        'freshness_availability_templates',
      );
      expect(
        container.read(
          productAvailabilityRuleAuthoringSelectedTemplateIdProvider,
        ),
        ProductAvailabilityRuleTemplateId.freshShelf,
      );
      expect(
        container
            .read(productAvailabilityRuleAuthoringSessionProvider)
            .selectedTemplateId,
        ProductAvailabilityRuleTemplateId.freshShelf,
      );
      expect(
        container.read(
          productAvailabilityRuleAuthoringAvailableTemplateEntriesProvider,
        ),
        hasLength(2),
      );
      sessionSummary = container.read(
        productAvailabilityRuleAuthoringSessionSummaryProvider,
      );
      expect(sessionSummary.isDefault, isFalse);
      expect(sessionSummary.sessionLabel, 'Custom session');
      expect(
        sessionSummary.sourceDisplayLabel,
        'Freshness availability templates',
      );
      expect(sessionSummary.templateLabel, 'Fresh shelf');
      expect(
        sessionSummary.availableTemplateCountLabel,
        '2 templates available',
      );
      expect(sessionSummary.totalTemplateCountLabel, '8 templates total');

      sessionController.selectTemplate(
        ProductAvailabilityRuleTemplateId.counterService,
      );
      expect(
        container.read(
          productAvailabilityRuleAuthoringEffectiveSourceIdProvider,
        ),
        productAvailabilityRuleTemplateCoreSourceId,
      );
      expect(
        container.read(
          productAvailabilityRuleAuthoringEffectiveTemplateIdProvider,
        ),
        ProductAvailabilityRuleTemplateId.counterService,
      );

      container
          .read(productAvailabilityRuleAuthoringSessionProvider.notifier)
          .state = container
          .read(productAvailabilityRuleAuthoringSessionProvider)
          .copyWith(selectedSourceId: 'freshness_availability_templates');
      expect(
        container.read(
          productAvailabilityRuleAuthoringEffectiveSourceIdProvider,
        ),
        'freshness_availability_templates',
      );
      expect(
        container.read(
          productAvailabilityRuleAuthoringEffectiveTemplateIdProvider,
        ),
        ProductAvailabilityRuleTemplateId.freshShelf,
      );

      container
          .read(productAvailabilityRuleAuthoringSessionProvider.notifier)
          .state = container
          .read(productAvailabilityRuleAuthoringSessionProvider)
          .copyWith(
            selectedTemplateId: ProductAvailabilityRuleTemplateId.freshnessHold,
          );
      expect(
        container.read(
          productAvailabilityRuleAuthoringEffectiveTemplateIdProvider,
        ),
        ProductAvailabilityRuleTemplateId.freshnessHold,
      );

      container
          .read(productAvailabilityRuleAuthoringSessionProvider.notifier)
          .state = container
          .read(productAvailabilityRuleAuthoringSessionProvider)
          .copyWith(selectedSourceId: 'missing_source');
      expect(
        container.read(
          productAvailabilityRuleAuthoringEffectiveSourceIdProvider,
        ),
        productAvailabilityRuleTemplateAllSourceId,
      );
      expect(
        container.read(
          productAvailabilityRuleAuthoringEffectiveTemplateIdProvider,
        ),
        ProductAvailabilityRuleTemplateId.freshnessHold,
      );

      sessionController.selectTarget(
        ProductAvailabilityRuleAuthoringTarget.stockAttention,
      );
      expect(
        container.read(productAvailabilityRuleAuthoringSelectedTargetProvider),
        ProductAvailabilityRuleAuthoringTarget.stockAttention,
      );
      expect(
        container
            .read(productAvailabilityRuleAuthoringSessionProvider)
            .selectedTarget,
        ProductAvailabilityRuleAuthoringTarget.stockAttention,
      );
      expect(
        container.read(productAvailabilityRuleAuthoringEffectiveTargetProvider),
        ProductAvailabilityRuleAuthoringTarget.stockAttention,
      );

      sessionController.restore(
        const ProductAvailabilityRuleAuthoringSession(
          selectedSourceId: 'freshness_availability_templates',
          selectedTemplateId: ProductAvailabilityRuleTemplateId.freshnessHold,
          selectedTarget: ProductAvailabilityRuleAuthoringTarget.allProducts,
        ),
      );
      expect(
        container.read(
          productAvailabilityRuleAuthoringSelectedSourceIdProvider,
        ),
        'freshness_availability_templates',
      );
      expect(
        container.read(
          productAvailabilityRuleAuthoringSelectedTemplateIdProvider,
        ),
        ProductAvailabilityRuleTemplateId.freshnessHold,
      );
      expect(
        container.read(productAvailabilityRuleAuthoringSelectedTargetProvider),
        ProductAvailabilityRuleAuthoringTarget.allProducts,
      );

      sessionController.restore(
        const ProductAvailabilityRuleAuthoringSession(
          selectedSourceId: 'missing_source',
          selectedTemplateId: ProductAvailabilityRuleTemplateId(
            'missing_template',
          ),
          selectedTarget:
              ProductAvailabilityRuleAuthoringTarget.availabilityRisk,
        ),
      );
      expect(
        container.read(
          productAvailabilityRuleAuthoringSelectedSourceIdProvider,
        ),
        productAvailabilityRuleTemplateAllSourceId,
      );
      expect(
        container.read(
          productAvailabilityRuleAuthoringSelectedTemplateIdProvider,
        ),
        ProductAvailabilityRuleTemplateId.counterService,
      );
      expect(
        container.read(productAvailabilityRuleAuthoringSelectedTargetProvider),
        ProductAvailabilityRuleAuthoringTarget.availabilityRisk,
      );

      sessionController.reset();
      expect(
        container.read(
          productAvailabilityRuleAuthoringSelectedSourceIdProvider,
        ),
        productAvailabilityRuleTemplateAllSourceId,
      );
      expect(
        container.read(
          productAvailabilityRuleAuthoringSelectedTemplateIdProvider,
        ),
        ProductAvailabilityRuleTemplateId.counterService,
      );
      expect(
        container.read(productAvailabilityRuleAuthoringSelectedTargetProvider),
        ProductAvailabilityRuleAuthoringTarget.unconfigured,
      );
      expect(
        container.read(productAvailabilityRuleAuthoringSessionProvider),
        ProductAvailabilityRuleAuthoringSession.defaults,
      );
      sessionSummary = container.read(
        productAvailabilityRuleAuthoringSessionSummaryProvider,
      );
      expect(sessionSummary.isDefault, isTrue);
    },
  );

  test(
    'availability authoring session hydrates and persists preferences',
    () async {
      const savedSession = ProductAvailabilityRuleAuthoringSession(
        selectedSourceId: 'freshness_availability_templates',
        selectedTemplateId: ProductAvailabilityRuleTemplateId.freshShelf,
        selectedTarget: ProductAvailabilityRuleAuthoringTarget.allProducts,
      );
      final store = MemoryProductManagementPackPreferencesStore(
        initialSnapshot: {
          'selectedPackId': ProductManagementPackId.groceryFreshGoods.value,
          'availabilityAuthoringSession': savedSession.toJson(),
        },
      );
      final container = ProviderContainer(
        overrides: [
          productManagementPacksProvider.overrideWithValue([
            coreProductManagementPack,
            groceryFreshGoodsProductManagementPack,
          ]),
          productManagementPackPreferencesRepositoryProvider.overrideWithValue(
            ProductManagementPackPreferencesRepository(store: store),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(productManagementPackIdProvider.notifier).hydrate();

      final sessionController = container.read(
        productAvailabilityRuleAuthoringSessionControllerProvider,
      );

      await sessionController.hydrate();

      expect(
        container.read(productAvailabilityRuleAuthoringSessionProvider),
        savedSession,
      );
      expect(
        container
            .read(productAvailabilityRuleAuthoringSessionPersistenceProvider)
            .phase,
        ProductAvailabilityRuleAuthoringSessionPersistencePhase.saved,
      );

      sessionController.selectTarget(
        ProductAvailabilityRuleAuthoringTarget.stockAttention,
      );
      expect(
        container
            .read(productAvailabilityRuleAuthoringSessionPersistenceProvider)
            .phase,
        ProductAvailabilityRuleAuthoringSessionPersistencePhase.saving,
      );
      await sessionController.persistCurrent();

      var preferences = ProductManagementPackPreferences.fromJson(
        store.snapshot!,
      );
      expect(
        preferences.availabilityAuthoringSession.selectedTarget,
        ProductAvailabilityRuleAuthoringTarget.stockAttention,
      );
      expect(
        container
            .read(productAvailabilityRuleAuthoringSessionPersistenceProvider)
            .phase,
        ProductAvailabilityRuleAuthoringSessionPersistencePhase.saved,
      );

      sessionController.reset();
      await sessionController.persistCurrent();

      preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);
      expect(
        preferences.availabilityAuthoringSession,
        ProductAvailabilityRuleAuthoringSession.defaults,
      );
      expect(store.snapshot?['availabilityAuthoringSession'], isNull);
      expect(
        container
            .read(productAvailabilityRuleAuthoringSessionPersistenceProvider)
            .phase,
        ProductAvailabilityRuleAuthoringSessionPersistencePhase.saved,
      );
    },
  );

  test(
    'availability authoring session does not overwrite local changes with late hydration',
    () async {
      const savedSession = ProductAvailabilityRuleAuthoringSession(
        selectedSourceId: productAvailabilityRuleTemplateAllSourceId,
        selectedTemplateId: ProductAvailabilityRuleTemplateId.onlineStore,
        selectedTarget: ProductAvailabilityRuleAuthoringTarget.allProducts,
      );
      final store = _DelayedPreferencesStore();
      final container = ProviderContainer(
        overrides: [
          productManagementPackPreferencesRepositoryProvider.overrideWithValue(
            ProductManagementPackPreferencesRepository(store: store),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sessionController = container.read(
        productAvailabilityRuleAuthoringSessionControllerProvider,
      );

      final hydrateFuture = sessionController.hydrate();
      sessionController.selectTarget(
        ProductAvailabilityRuleAuthoringTarget.stockAttention,
      );

      store.completeRead({
        'selectedPackId': ProductManagementPackId.coreCatalog.value,
        'availabilityAuthoringSession': savedSession.toJson(),
      });

      final hydratedSession = await hydrateFuture;

      expect(
        hydratedSession.selectedTarget,
        ProductAvailabilityRuleAuthoringTarget.stockAttention,
      );
      expect(
        container
            .read(productAvailabilityRuleAuthoringSessionProvider)
            .selectedTarget,
        ProductAvailabilityRuleAuthoringTarget.stockAttention,
      );
      expect(
        container
            .read(productAvailabilityRuleAuthoringSessionProvider)
            .selectedTemplateId,
        ProductAvailabilityRuleTemplateId.counterService,
      );
    },
  );
}

dynamic _memoryPreferencesRepositoryOverride() {
  return productManagementPackPreferencesRepositoryProvider.overrideWithValue(
    ProductManagementPackPreferencesRepository(
      store: MemoryProductManagementPackPreferencesStore(),
    ),
  );
}

class _DelayedPreferencesStore
    implements ProductManagementPackPreferencesStore {
  final _readCompleter = Completer<Map<String, Object?>?>();

  void completeRead(Map<String, Object?>? snapshot) {
    _readCompleter.complete(snapshot);
  }

  @override
  Future<Map<String, Object?>?> read() {
    return _readCompleter.future;
  }

  @override
  Future<void> write(Map<String, Object?> snapshot) async {}
}
