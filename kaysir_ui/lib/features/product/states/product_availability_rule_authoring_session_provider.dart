import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/product_availability_rule_authoring.dart';
import '../models/product_availability_rule_authoring_session.dart';
import 'product_availability_rule_template_provider.dart';
import 'management_pack_provider.dart';

final productAvailabilityRuleAuthoringSessionProvider =
    StateProvider<ProductAvailabilityRuleAuthoringSession>((ref) {
      return ProductAvailabilityRuleAuthoringSession.defaults;
    });

final productAvailabilityRuleAuthoringSessionPersistenceProvider =
    StateProvider<ProductAvailabilityRuleAuthoringSessionPersistenceState>((
      ref,
    ) {
      return ProductAvailabilityRuleAuthoringSessionPersistenceState.idle;
    });

final productAvailabilityRuleAuthoringSelectedSourceIdProvider =
    Provider<String>((ref) {
      return ref
          .watch(productAvailabilityRuleAuthoringSessionProvider)
          .selectedSourceId;
    });

final productAvailabilityRuleAuthoringEffectiveSourceIdProvider =
    Provider<String>((ref) {
      final selectedSourceId = ref.watch(
        productAvailabilityRuleAuthoringSelectedSourceIdProvider,
      );
      if (selectedSourceId == productAvailabilityRuleTemplateAllSourceId) {
        return selectedSourceId;
      }

      final sourceSummaries = ref.watch(
        productAvailabilityRuleTemplateSourceSummariesProvider,
      );
      final sourceExists = sourceSummaries.any(
        (source) => source.id == selectedSourceId,
      );

      return sourceExists
          ? selectedSourceId
          : productAvailabilityRuleTemplateAllSourceId;
    });

final productAvailabilityRuleAuthoringSelectedTemplateIdProvider =
    Provider<ProductAvailabilityRuleTemplateId>((ref) {
      return ref
          .watch(productAvailabilityRuleAuthoringSessionProvider)
          .selectedTemplateId;
    });

final productAvailabilityRuleAuthoringAvailableTemplateEntriesProvider =
    Provider<List<ProductAvailabilityRuleTemplateEntry>>((ref) {
      final entries = ref.watch(productAvailabilityRuleTemplateEntriesProvider);
      final sourceId = ref.watch(
        productAvailabilityRuleAuthoringEffectiveSourceIdProvider,
      );
      if (sourceId == productAvailabilityRuleTemplateAllSourceId) {
        return entries;
      }

      return List.unmodifiable(
        entries.where((entry) => entry.normalizedSourceId == sourceId),
      );
    });

final productAvailabilityRuleAuthoringEffectiveTemplateEntryProvider =
    Provider<ProductAvailabilityRuleTemplateEntry?>((ref) {
      final sourceEntries = ref.watch(
        productAvailabilityRuleAuthoringAvailableTemplateEntriesProvider,
      );
      final allEntries = ref.watch(
        productAvailabilityRuleTemplateEntriesProvider,
      );
      final entries = sourceEntries.isEmpty ? allEntries : sourceEntries;
      if (entries.isEmpty) return null;

      final selectedTemplateId = ref.watch(
        productAvailabilityRuleAuthoringSelectedTemplateIdProvider,
      );
      for (final entry in entries) {
        if (entry.template.id == selectedTemplateId) return entry;
      }

      return entries.first;
    });

final productAvailabilityRuleAuthoringEffectiveTemplateIdProvider =
    Provider<ProductAvailabilityRuleTemplateId>((ref) {
      return ref
              .watch(
                productAvailabilityRuleAuthoringEffectiveTemplateEntryProvider,
              )
              ?.template
              .id ??
          ProductAvailabilityRuleTemplateId.counterService;
    });

final productAvailabilityRuleAuthoringSelectedTargetProvider =
    Provider<ProductAvailabilityRuleAuthoringTarget>((ref) {
      return ref
          .watch(productAvailabilityRuleAuthoringSessionProvider)
          .selectedTarget;
    });

final productAvailabilityRuleAuthoringEffectiveTargetProvider =
    Provider<ProductAvailabilityRuleAuthoringTarget>((ref) {
      return ref.watch(productAvailabilityRuleAuthoringSelectedTargetProvider);
    });

final productAvailabilityRuleAuthoringSessionSummaryProvider = Provider<
  ProductAvailabilityRuleAuthoringSessionSummary
>((ref) {
  final sourceId = ref.watch(
    productAvailabilityRuleAuthoringEffectiveSourceIdProvider,
  );
  final sourceSummaries = ref.watch(
    productAvailabilityRuleTemplateSourceSummariesProvider,
  );
  final availableEntries = ref.watch(
    productAvailabilityRuleAuthoringAvailableTemplateEntriesProvider,
  );
  final allEntries = ref.watch(productAvailabilityRuleTemplateEntriesProvider);
  final templateEntry = ref.watch(
    productAvailabilityRuleAuthoringEffectiveTemplateEntryProvider,
  );

  return ProductAvailabilityRuleAuthoringSessionSummary(
    sourceId: sourceId,
    sourceLabel: _sourceLabelFor(
      sourceId: sourceId,
      sourceSummaries: sourceSummaries,
    ),
    sourceTemplateCount: availableEntries.length,
    totalTemplateCount: allEntries.length,
    templateEntry: templateEntry,
    target: ref.watch(productAvailabilityRuleAuthoringEffectiveTargetProvider),
  );
});

final productAvailabilityRuleAuthoringSessionControllerProvider =
    Provider<ProductAvailabilityRuleAuthoringSessionController>((ref) {
      return ProductAvailabilityRuleAuthoringSessionController(ref);
    });

class ProductAvailabilityRuleAuthoringSessionController {
  const ProductAvailabilityRuleAuthoringSessionController(this.ref);

  final Ref ref;

  void selectSource(String sourceId) {
    final registry = ref.read(productAvailabilityRuleTemplateRegistryProvider);
    final session = ref.read(productAvailabilityRuleAuthoringSessionProvider);
    final effectiveSourceId = _effectiveSourceIdFor(
      registry: registry,
      sourceId: sourceId,
    );
    final entries = _entriesForSource(
      entries: registry.entries,
      sourceId: effectiveSourceId,
    );
    final selectedTemplateId = session.selectedTemplateId;
    final nextTemplateId =
        entries.isNotEmpty &&
                !entries.any((entry) => entry.template.id == selectedTemplateId)
            ? entries.first.template.id
            : selectedTemplateId;

    _setSession(
      session.copyWith(
        selectedSourceId: effectiveSourceId,
        selectedTemplateId: nextTemplateId,
      ),
    );
  }

  void selectTemplate(ProductAvailabilityRuleTemplateId templateId) {
    final registry = ref.read(productAvailabilityRuleTemplateRegistryProvider);
    final session = ref.read(productAvailabilityRuleAuthoringSessionProvider);
    final entry = _entryForTemplateId(
      entries: registry.entries,
      templateId: templateId,
    );
    final effectiveSourceId = _effectiveSourceIdFor(
      registry: registry,
      sourceId: session.selectedSourceId,
    );
    var nextSourceId = session.selectedSourceId;
    if (entry != null &&
        effectiveSourceId != productAvailabilityRuleTemplateAllSourceId &&
        entry.normalizedSourceId != effectiveSourceId) {
      nextSourceId = entry.normalizedSourceId;
    }

    _setSession(
      session.copyWith(
        selectedSourceId: nextSourceId,
        selectedTemplateId: templateId,
      ),
    );
  }

  void selectTarget(ProductAvailabilityRuleAuthoringTarget target) {
    final session = ref.read(productAvailabilityRuleAuthoringSessionProvider);

    _setSession(session.copyWith(selectedTarget: target));
  }

  void restore(ProductAvailabilityRuleAuthoringSession session) {
    final registry = ref.read(productAvailabilityRuleTemplateRegistryProvider);

    _setSession(_normalizedSessionFor(registry: registry, session: session));
  }

  Future<ProductAvailabilityRuleAuthoringSession> hydrate() async {
    final sessionBeforeHydration = ref.read(
      productAvailabilityRuleAuthoringSessionProvider,
    );
    final repository = ref.read(
      productManagementPackPreferencesRepositoryProvider,
    );
    _setPersistence(
      const ProductAvailabilityRuleAuthoringSessionPersistenceState(
        phase:
            ProductAvailabilityRuleAuthoringSessionPersistencePhase.hydrating,
      ),
    );

    try {
      final preferences = await repository.load();
      if (!ref.mounted) return sessionBeforeHydration;

      final currentSession = ref.read(
        productAvailabilityRuleAuthoringSessionProvider,
      );
      if (currentSession != sessionBeforeHydration) {
        if (ref
                .read(
                  productAvailabilityRuleAuthoringSessionPersistenceProvider,
                )
                .phase ==
            ProductAvailabilityRuleAuthoringSessionPersistencePhase.hydrating) {
          _setPersistence(
            ProductAvailabilityRuleAuthoringSessionPersistenceState.idle,
          );
        }

        return currentSession;
      }

      final registry = ref.read(
        productAvailabilityRuleTemplateRegistryProvider,
      );
      final session = _normalizedSessionFor(
        registry: registry,
        session: preferences.availabilityAuthoringSession,
      );
      _setSession(session, persist: false);
      _setPersistence(
        const ProductAvailabilityRuleAuthoringSessionPersistenceState(
          phase: ProductAvailabilityRuleAuthoringSessionPersistencePhase.saved,
        ),
      );

      return session;
    } catch (_) {
      if (!ref.mounted) return sessionBeforeHydration;

      _setPersistence(
        const ProductAvailabilityRuleAuthoringSessionPersistenceState(
          phase: ProductAvailabilityRuleAuthoringSessionPersistencePhase.failed,
        ),
      );

      return ref.read(productAvailabilityRuleAuthoringSessionProvider);
    }
  }

  Future<void> persistCurrent() {
    return _persistSession(
      ref.read(productAvailabilityRuleAuthoringSessionProvider),
    );
  }

  void reset() {
    _setSession(ProductAvailabilityRuleAuthoringSession.defaults);
  }

  void _setSession(
    ProductAvailabilityRuleAuthoringSession session, {
    bool persist = true,
  }) {
    ref.read(productAvailabilityRuleAuthoringSessionProvider.notifier).state =
        session;
    if (persist) unawaited(_persistSession(session));
  }

  Future<void> _persistSession(
    ProductAvailabilityRuleAuthoringSession session,
  ) async {
    final repository = ref.read(
      productManagementPackPreferencesRepositoryProvider,
    );
    _setPersistence(
      const ProductAvailabilityRuleAuthoringSessionPersistenceState(
        phase: ProductAvailabilityRuleAuthoringSessionPersistencePhase.saving,
      ),
    );
    try {
      await repository.saveAvailabilityAuthoringSession(session);
      if (!ref.mounted) return;

      if (ref.read(productAvailabilityRuleAuthoringSessionProvider) ==
          session) {
        _setPersistence(
          const ProductAvailabilityRuleAuthoringSessionPersistenceState(
            phase:
                ProductAvailabilityRuleAuthoringSessionPersistencePhase.saved,
          ),
        );
      }
    } catch (_) {
      if (!ref.mounted) return;

      if (ref.read(productAvailabilityRuleAuthoringSessionProvider) ==
          session) {
        _setPersistence(
          const ProductAvailabilityRuleAuthoringSessionPersistenceState(
            phase:
                ProductAvailabilityRuleAuthoringSessionPersistencePhase.failed,
          ),
        );
      }
    }
  }

  void _setPersistence(
    ProductAvailabilityRuleAuthoringSessionPersistenceState state,
  ) {
    if (!ref.mounted) return;

    ref
        .read(
          productAvailabilityRuleAuthoringSessionPersistenceProvider.notifier,
        )
        .state = state;
  }
}

String _effectiveSourceIdFor({
  required ProductAvailabilityRuleTemplateRegistry registry,
  required String sourceId,
}) {
  if (sourceId == productAvailabilityRuleTemplateAllSourceId) {
    return sourceId;
  }

  final sourceExists = registry.sourceSummaries.any(
    (source) => source.id == sourceId,
  );
  return sourceExists ? sourceId : productAvailabilityRuleTemplateAllSourceId;
}

List<ProductAvailabilityRuleTemplateEntry> _entriesForSource({
  required List<ProductAvailabilityRuleTemplateEntry> entries,
  required String sourceId,
}) {
  if (sourceId == productAvailabilityRuleTemplateAllSourceId) return entries;

  return List.unmodifiable(
    entries.where((entry) => entry.normalizedSourceId == sourceId),
  );
}

ProductAvailabilityRuleTemplateEntry? _entryForTemplateId({
  required List<ProductAvailabilityRuleTemplateEntry> entries,
  required ProductAvailabilityRuleTemplateId templateId,
}) {
  for (final entry in entries) {
    if (entry.template.id == templateId) return entry;
  }

  return null;
}

ProductAvailabilityRuleAuthoringSession _normalizedSessionFor({
  required ProductAvailabilityRuleTemplateRegistry registry,
  required ProductAvailabilityRuleAuthoringSession session,
}) {
  final sourceId = _effectiveSourceIdFor(
    registry: registry,
    sourceId: session.selectedSourceId,
  );
  final sourceEntries = _entriesForSource(
    entries: registry.entries,
    sourceId: sourceId,
  );
  final entries = sourceEntries.isEmpty ? registry.entries : sourceEntries;
  var templateId = session.selectedTemplateId;

  if (entries.isNotEmpty &&
      !entries.any((entry) => entry.template.id == templateId)) {
    templateId = entries.first.template.id;
  }

  return session.copyWith(
    selectedSourceId: sourceId,
    selectedTemplateId: templateId,
  );
}

String _sourceLabelFor({
  required String sourceId,
  required List<ProductAvailabilityRuleTemplateSourceSummary> sourceSummaries,
}) {
  if (sourceId == productAvailabilityRuleTemplateAllSourceId) {
    return 'All templates';
  }

  for (final summary in sourceSummaries) {
    if (summary.id == sourceId) return summary.title;
  }

  return productAvailabilityRuleTemplateCoreSourceTitle;
}
