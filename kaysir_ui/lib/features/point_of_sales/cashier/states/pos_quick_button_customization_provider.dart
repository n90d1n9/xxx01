import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/pos_quick_button_customization.dart';
import '../models/pos_touch_layout_profile.dart';
import '../repositories/pos_quick_button_customization_repository.dart';

/// Controller for persisted POS quick-button customization.
class POSQuickButtonCustomizationController {
  final Ref _ref;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  var _hasLocalMutations = false;

  POSQuickButtonCustomizationController(this._ref);

  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrateFromRepository();
  }

  Future<void> flushPersistence() {
    return _persistFuture ?? Future<void>.value();
  }

  void togglePinned(String buttonId) {
    _setAndPersist(
      _ref.read(posQuickButtonCustomizationProvider).togglePinned(buttonId),
    );
  }

  void toggleHidden(String buttonId) {
    _setAndPersist(
      _ref.read(posQuickButtonCustomizationProvider).toggleHidden(buttonId),
    );
  }

  void movePinned(String buttonId, int offset) {
    _setAndPersist(
      _ref
          .read(posQuickButtonCustomizationProvider)
          .movePinned(buttonId, offset),
    );
  }

  void reset() {
    _setAndPersist(POSQuickButtonCustomization.empty);
  }

  void setDensityOverride(POSTouchLayoutDensity? density) {
    _setAndPersist(
      _ref
          .read(posQuickButtonCustomizationProvider)
          .withDensityOverride(density),
    );
  }

  Future<void> _hydrateFromRepository() async {
    final repository = _ref.read(posQuickButtonCustomizationRepositoryProvider);
    final restored = await repository.load();
    final current = _ref.read(posQuickButtonCustomizationProvider);
    if (_hasLocalMutations || !current.isEmpty) {
      _hasLocalMutations = true;
      await _queuePersist();
      return;
    }

    _ref.read(posQuickButtonCustomizationProvider.notifier).state = restored;
  }

  void _setAndPersist(POSQuickButtonCustomization nextState) {
    if (nextState == _ref.read(posQuickButtonCustomizationProvider)) return;

    _ref.read(posQuickButtonCustomizationProvider.notifier).state = nextState;
    _hasLocalMutations = true;
    unawaited(_queuePersist());
  }

  Future<void> _queuePersist() {
    final repository = _ref.read(posQuickButtonCustomizationRepositoryProvider);
    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    final snapshot = _ref.read(posQuickButtonCustomizationProvider);

    return _persistFuture = pending.then((_) => repository.save(snapshot));
  }
}

/// Scope used to isolate stored POS quick-button customization.
final posQuickButtonCustomizationScopeProvider =
    Provider<POSQuickButtonCustomizationScope>((ref) {
      return POSQuickButtonCustomizationScope.defaultScope;
    });

/// Repository provider for persisted POS quick-button customization.
final posQuickButtonCustomizationRepositoryProvider =
    Provider<POSQuickButtonCustomizationRepository>((ref) {
      return POSQuickButtonCustomizationRepository(
        store: LocalDbPOSQuickButtonCustomizationSnapshotStore(
          scope: ref.watch(posQuickButtonCustomizationScopeProvider),
        ),
      );
    });

final posQuickButtonCustomizationProvider =
    StateProvider<POSQuickButtonCustomization>(
      (ref) => POSQuickButtonCustomization.empty,
    );

/// Hydrates quick-button customization from local preferences.
final posQuickButtonCustomizationHydrationProvider = FutureProvider<void>((
  ref,
) {
  return ref.read(posQuickButtonCustomizationControllerProvider).hydrate();
});

final posQuickButtonCustomizationControllerProvider =
    Provider<POSQuickButtonCustomizationController>(
      (ref) => POSQuickButtonCustomizationController(ref),
    );
