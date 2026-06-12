import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('workspace command mutator updates station pressure', () {
    final now = DateTime(2026, 1, 1, 12);
    final mutation = const RestaurantWorkspaceCommandMutator()
        .updateStationStatus(
          snapshot: restaurantDemoSnapshot,
          stationId: 'grill',
          status: RestaurantServiceStatus.calm,
          now: now,
        );

    expect(mutation, isNotNull);
    expect(mutation?.undoLabel, 'Grill station change');
    expect(
      mutation?.activity.kind,
      RestaurantOperationActivityKind.stationStatusChanged,
    );
    expect(mutation?.activity.createdAt, now);
    expect(
      mutation?.snapshot.stations
          .singleWhere((station) => station.id == 'grill')
          .status,
      RestaurantServiceStatus.calm,
    );
  });

  test(
    'workspace command mutator validates reservation status transitions',
    () {
      final now = DateTime(2026, 1, 1, 12);
      const mutator = RestaurantWorkspaceCommandMutator();

      final mutation = mutator.updateReservationStatus(
        snapshot: restaurantDemoSnapshot,
        reservationId: 'wijaya-family',
        status: RestaurantReservationStatus.arrived,
        now: now,
      );

      expect(mutation, isNotNull);
      expect(
        mutation?.snapshot.reservations
            .singleWhere((reservation) => reservation.id == 'wijaya-family')
            .status,
        RestaurantReservationStatus.arrived,
      );
      expect(
        mutation?.activity.kind,
        RestaurantOperationActivityKind.reservationStatusChanged,
      );
      expect(mutation?.activity.title, 'Wijaya Family marked Arrived');

      expect(
        mutator.updateReservationStatus(
          snapshot: restaurantDemoSnapshot,
          reservationId: 'sari-party',
          status: RestaurantReservationStatus.seated,
          now: now,
        ),
        isNull,
      );
    },
  );

  test('workspace command mutator skips missing and duplicate commands', () {
    final now = DateTime(2026, 1, 1, 12);
    final mutator = const RestaurantWorkspaceCommandMutator();

    expect(
      mutator.completeTask(
        snapshot: restaurantDemoSnapshot,
        taskId: 'missing-task',
        now: now,
      ),
      isNull,
    );

    final completed = mutator.completeTask(
      snapshot: restaurantDemoSnapshot,
      taskId: 'rendang-par',
      now: now,
    );

    expect(completed, isNotNull);
    expect(
      mutator.completeTask(
        snapshot: completed!.snapshot,
        taskId: 'rendang-par',
        now: now,
      ),
      isNull,
    );
  });

  test('workspace command mutator resolves menu risk tags', () {
    final now = DateTime(2026, 1, 1, 12);
    final mutation = const RestaurantWorkspaceCommandMutator().resolveMenuRisk(
      snapshot: restaurantDemoSnapshot,
      menuSignalId: 'short-rib-rendang',
      now: now,
    );

    final signal = mutation?.snapshot.menuSignals.singleWhere(
      (signal) => signal.id == 'short-rib-rendang',
    );

    expect(signal?.soldOutRiskPercent, 12);
    expect(signal?.tags, contains('Restocked'));
    expect(signal?.tags, isNot(contains('Low stock')));
    expect(
      mutation?.activity.kind,
      RestaurantOperationActivityKind.menuRiskResolved,
    );
  });

  test('workspace command mutator reviews catalog readiness', () {
    final now = DateTime(2026, 1, 1, 12);
    final mutator = const RestaurantWorkspaceCommandMutator();
    final mutation = mutator.reviewCatalogItem(
      snapshot: restaurantDemoSnapshot,
      menuItemId: 'short-rib-rendang',
      now: now,
    );

    final item = mutation?.snapshot.menu?.itemById('short-rib-rendang');

    expect(item?.availability, RestaurantMenuAvailability.available);
    expect(item?.tags, contains(restaurantCatalogReviewedTag));
    expect(
      mutation?.activity.kind,
      RestaurantOperationActivityKind.menuCatalogReviewed,
    );
    expect(mutation?.activity.title, 'Short Rib Rendang catalog reviewed');
    expect(mutation?.undoLabel, 'Short Rib Rendang catalog review');

    final reviewedSummary = RestaurantMenuCatalogSummary.fromMenu(
      menu: mutation!.snapshot.menu!,
      recipes: mutation.snapshot.recipes,
    );
    expect(reviewedSummary.reviewCount, 2);

    expect(
      mutator.reviewCatalogItem(
        snapshot: mutation.snapshot,
        menuItemId: 'short-rib-rendang',
        now: now,
      ),
      isNull,
    );
    expect(
      mutator.reviewCatalogItem(
        snapshot: restaurantDemoSnapshot.copyWith(menu: null),
        menuItemId: 'short-rib-rendang',
        now: now,
      ),
      isNull,
    );
  });

  test('workspace command mutator reviews recipe production readiness', () {
    final now = DateTime(2026, 1, 1, 12);
    final mutator = const RestaurantWorkspaceCommandMutator();
    final mutation = mutator.reviewRecipeProduction(
      snapshot: restaurantDemoSnapshot,
      recipeId: 'short-rib-rendang',
      now: now,
    );

    final item = mutation?.snapshot.menu?.itemById('short-rib-rendang');

    expect(item?.availability, RestaurantMenuAvailability.available);
    expect(item?.tags, contains(restaurantRecipeProductionReviewedTag));
    expect(
      mutation?.activity.kind,
      RestaurantOperationActivityKind.recipeProductionReviewed,
    );
    expect(mutation?.activity.title, 'Short Rib Rendang production reviewed');
    expect(mutation?.undoLabel, 'Short Rib Rendang recipe production review');

    final reviewedSummary = RestaurantRecipeProductionSummary.fromCatalog(
      recipes: mutation!.snapshot.recipes,
      menu: mutation.snapshot.menu,
    );
    final reviewedEntry = reviewedSummary.entries.singleWhere(
      (entry) => entry.id == 'short-rib-rendang',
    );
    expect(reviewedEntry.needsAttention, isFalse);
    expect(reviewedSummary.attentionCount, 1);

    expect(
      mutator.reviewRecipeProduction(
        snapshot: mutation.snapshot,
        recipeId: 'short-rib-rendang',
        now: now,
      ),
      isNull,
    );
    expect(
      mutator.reviewRecipeProduction(
        snapshot: restaurantDemoSnapshot.copyWith(menu: null),
        recipeId: 'short-rib-rendang',
        now: now,
      ),
      isNull,
    );
  });

  test('workspace mutation toolkit rewrites tags and creates activities', () {
    final now = DateTime(2026, 1, 1, 12);
    const toolkit = RestaurantWorkspaceMutationToolkit();

    expect(
      toolkit.replaceTag(const ['Low stock'], 'Low stock', 'Restocked'),
      const ['Restocked'],
    );
    expect(
      toolkit.replaceTag(const ['Seasonal'], 'Low stock', 'Restocked'),
      const ['Seasonal', 'Restocked'],
    );

    final activity = toolkit.activity(
      now,
      RestaurantOperationActivityKind.menuRiskResolved,
      title: 'Rendang restocked',
      description: 'Risk lowered.',
    );

    expect(activity.id, 'menuRiskResolved-${now.microsecondsSinceEpoch}');
    expect(activity.createdAt, now);
  });
}
