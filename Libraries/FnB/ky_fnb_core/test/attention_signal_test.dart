import 'package:flutter_test/flutter_test.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

void main() {
  test('attention signal queue ranks mixed FnB pressure', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final snoozed = const FnbServiceAlertLifecycle().applyAction(
      FnbServiceAlertLifecycleAction.snooze,
      at: now,
      snoozeDuration: const Duration(minutes: 15),
    );
    final queue = FnbAttentionSignalQueue.fromSignals([
      FnbAttentionSignal.fromKitchenStation(
        const FnbKitchenStation(
          id: 'grill',
          name: 'Grill',
          lead: 'Ari',
          ticketsInProgress: 10,
          averageFireMinutes: 18,
          queueLabel: 'Steaks',
          status: FnbServiceStatus.critical,
        ),
      ),
      FnbAttentionSignal.fromMenuSignal(
        const FnbMenuSignal(
          id: 'rib',
          name: 'Short Rib',
          category: 'Main',
          orders: 42,
          grossMarginPercent: 68,
          soldOutRiskPercent: 76,
          prepMinutes: 18,
          tags: ['Low stock'],
        ),
      ),
      FnbAttentionSignal.fromServiceAlertEntry(
        FnbServiceAlertEntry(
          sourceId: 'table-4',
          sourceLabel: 'Table 4',
          lifecycle: snoozed,
          alert: const FnbServiceAlert(
            type: FnbServiceAlertType.allergy,
            label: 'Peanut allergy',
            critical: true,
          ),
        ),
        now: now,
      ),
    ]);

    expect(queue.hasAttention, isTrue);
    expect(queue.signalCount, 3);
    expect(queue.attentionCount, 2);
    expect(queue.serviceStatus, FnbServiceStatus.critical);
    expect(queue.topSignal?.id, 'menu-risk-rib');
    expect(queue.attentionCountLabel, '2 signals need attention');
    expect(
      queue.signalsForKind(FnbAttentionSignalKind.serviceAlert),
      hasLength(1),
    );
    expect(queue.attentionCountForKind(FnbAttentionSignalKind.serviceAlert), 0);
  });

  test('attention adapters describe catalog and recipe production gaps', () {
    const recipe = FnbRecipe(
      id: 'spritz-recipe',
      name: 'Pandan Spritz',
      categoryId: 'beverage',
      stationId: 'bar',
      prepMinutes: 4,
      fireMinutes: 0,
      yieldQuantity: 1,
      yieldUnit: 'glass',
      costCents: 320,
    );
    const hiddenItem = FnbMenuItem(
      id: 'spritz',
      name: 'Pandan Spritz',
      categoryId: 'beverage',
      priceCents: 850,
      availability: FnbMenuAvailability.hidden,
    );
    const catalogEntry = FnbMenuCatalogEntry(item: hiddenItem, recipe: recipe);
    const productionEntry = FnbRecipeProductionEntry(
      recipe: recipe,
      menuItem: hiddenItem,
    );

    final catalogSignal = FnbAttentionSignal.fromMenuCatalogEntry(catalogEntry);
    final recipeSignal = FnbAttentionSignal.fromRecipeProductionEntry(
      productionEntry,
    );

    expect(catalogSignal.kind, FnbAttentionSignalKind.menuCatalog);
    expect(catalogSignal.valueLabel, 'Hidden from menu');
    expect(catalogSignal.status, FnbServiceStatus.busy);
    expect(recipeSignal.kind, FnbAttentionSignalKind.recipeProduction);
    expect(recipeSignal.valueLabel, 'Hidden from menu');
    expect(recipeSignal.needsAttention, isTrue);
  });

  test('attention signal copyWith keeps stable identity', () {
    const signal = FnbAttentionSignal(
      id: 'custom-1',
      kind: FnbAttentionSignalKind.custom,
      title: 'Check service pass',
      detail: 'Expo needs a runner',
      status: FnbServiceStatus.busy,
      urgencyScore: 20,
    );

    final updated = signal.copyWith(
      status: FnbServiceStatus.critical,
      valueLabel: 'Now',
      tags: ['Expo'],
    );

    expect(updated.id, 'custom-1');
    expect(updated.kindLabel, 'Custom');
    expect(updated.statusLabel, 'Critical');
    expect(updated.valueLabel, 'Now');
    expect(updated.accessibilityLabel, contains('Check service pass'));
  });
}
