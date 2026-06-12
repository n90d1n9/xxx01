import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('workspace controller loads restaurant snapshots', () async {
    final controller = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
    );

    await controller.load();

    expect(controller.state.status, RestaurantWorkspaceLoadStatus.ready);
    expect(controller.state.snapshot?.locationName, 'Kaysir Table Service');
    expect(controller.state.updatedAt, isNotNull);

    controller.dispose();
  });

  test('workspace controller reports empty and error states', () async {
    final emptyController = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(snapshot: null),
    );
    await emptyController.load();

    expect(emptyController.state.status, RestaurantWorkspaceLoadStatus.empty);
    expect(emptyController.state.snapshot, isNull);
    emptyController.dispose();

    final errorController = RestaurantWorkspaceController(
      repository: CallbackRestaurantSnapshotRepository(() {
        throw StateError('offline');
      }),
    );
    await errorController.load();

    expect(errorController.state.status, RestaurantWorkspaceLoadStatus.error);
    expect(errorController.state.errorMessage, contains('offline'));
    errorController.dispose();
  });

  test('workspace controller preserves snapshot during refresh', () async {
    final refreshCompleter = Completer<RestaurantOperatingSnapshot?>();
    var calls = 0;
    final controller = RestaurantWorkspaceController(
      repository: CallbackRestaurantSnapshotRepository(() {
        calls += 1;
        if (calls == 1) return Future.value(restaurantDemoSnapshot);
        return refreshCompleter.future;
      }),
    );

    await controller.load();
    final refresh = controller.refresh();

    expect(controller.state.isRefreshing, isTrue);
    expect(controller.state.snapshot, restaurantDemoSnapshot);

    refreshCompleter.complete(restaurantDemoSnapshot);
    await refresh;

    expect(controller.state.status, RestaurantWorkspaceLoadStatus.ready);
    controller.dispose();
  });

  test('workspace controller preserves activities during refresh', () async {
    final refreshCompleter = Completer<RestaurantOperatingSnapshot?>();
    var calls = 0;
    final controller = RestaurantWorkspaceController(
      repository: CallbackRestaurantSnapshotRepository(() {
        calls += 1;
        if (calls == 1) return Future.value(restaurantDemoSnapshot);
        return refreshCompleter.future;
      }),
    );

    await controller.load();
    controller.completeTask('rendang-par');
    final activity = controller.state.activities.single;

    final refresh = controller.refresh();

    expect(controller.state.isRefreshing, isTrue);
    expect(controller.state.activities.single.id, activity.id);

    refreshCompleter.complete(restaurantDemoSnapshot);
    await refresh;

    expect(controller.state.status, RestaurantWorkspaceLoadStatus.ready);
    expect(controller.state.activities.single.id, activity.id);
    controller.dispose();
  });

  test('workspace controller applies operational commands', () async {
    final controller = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
    );
    await controller.load();

    expect(controller.completeTask('rendang-par'), isTrue);
    expect(
      controller.updateStationStatus('grill', RestaurantServiceStatus.calm),
      isTrue,
    );
    expect(
      controller.updateZoneStatus('private-room', RestaurantServiceStatus.calm),
      isTrue,
    );
    expect(
      controller.updateReservationStatus(
        'wijaya-family',
        RestaurantReservationStatus.arrived,
      ),
      isTrue,
    );
    expect(controller.resolveMenuRisk('short-rib-rendang'), isTrue);
    expect(controller.reviewCatalogItem('nasi-ulam'), isTrue);
    expect(controller.reviewRecipeProduction('burnt-cheesecake'), isTrue);

    final snapshot = controller.state.snapshot!;
    final completedTask = snapshot.tasks.singleWhere(
      (task) => task.id == 'rendang-par',
    );
    final grill = snapshot.stations.singleWhere(
      (station) => station.id == 'grill',
    );
    final privateRoom = snapshot.zones.singleWhere(
      (zone) => zone.id == 'private-room',
    );
    final reservation = snapshot.reservations.singleWhere(
      (reservation) => reservation.id == 'wijaya-family',
    );
    final shortRib = snapshot.menuSignals.singleWhere(
      (signal) => signal.id == 'short-rib-rendang',
    );
    final nasiUlam = snapshot.menu?.itemById('nasi-ulam');
    final cheesecake = snapshot.menu?.itemById('burnt-cheesecake');

    expect(completedTask.progress, 1);
    expect(completedTask.dueLabel, 'Done');
    expect(completedTask.status, RestaurantServiceStatus.calm);
    expect(grill.status, RestaurantServiceStatus.calm);
    expect(privateRoom.status, RestaurantServiceStatus.calm);
    expect(reservation.status, RestaurantReservationStatus.arrived);
    expect(shortRib.soldOutRiskPercent, 12);
    expect(shortRib.tags, contains('Restocked'));
    expect(shortRib.tags, isNot(contains('Low stock')));
    expect(nasiUlam?.tags, contains(restaurantCatalogReviewedTag));
    expect(cheesecake?.tags, contains(restaurantRecipeProductionReviewedTag));
    expect(controller.state.activities, hasLength(7));
    expect(
      controller.state.activities.first.kind,
      RestaurantOperationActivityKind.recipeProductionReviewed,
    );
    expect(
      controller.state.activities.first.title,
      contains('Burnt Cheesecake'),
    );

    expect(
      controller.state.undoEntry?.label,
      'Burnt Cheesecake recipe production review',
    );
    expect(controller.completeTask('missing-task'), isFalse);
    expect(controller.state.activities, hasLength(7));
    expect(controller.completeTask('rendang-par'), isFalse);
    expect(
      controller.updateStationStatus('grill', RestaurantServiceStatus.calm),
      isFalse,
    );
    expect(
      controller.updateReservationStatus(
        'wijaya-family',
        RestaurantReservationStatus.arrived,
      ),
      isFalse,
    );
    expect(
      controller.updateReservationStatus(
        'wijaya-family',
        RestaurantReservationStatus.completed,
      ),
      isFalse,
    );
    expect(controller.reviewCatalogItem('nasi-ulam'), isFalse);
    expect(controller.reviewRecipeProduction('burnt-cheesecake'), isFalse);
    expect(controller.state.activities, hasLength(7));

    controller.dispose();
  });

  test('workspace controller can undo latest command', () async {
    final controller = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
    );
    await controller.load();

    final changed = controller.updateStationStatus(
      'grill',
      RestaurantServiceStatus.calm,
    );

    expect(changed, isTrue);
    expect(controller.state.hasUndo, isTrue);
    expect(controller.state.activities, hasLength(1));
    expect(
      controller.state.snapshot!.stations
          .singleWhere((station) => station.id == 'grill')
          .status,
      RestaurantServiceStatus.calm,
    );

    expect(controller.undoLastAction(), isTrue);
    expect(controller.state.hasUndo, isFalse);
    expect(controller.state.activities, isEmpty);
    expect(
      controller.state.snapshot!.stations
          .singleWhere((station) => station.id == 'grill')
          .status,
      RestaurantServiceStatus.critical,
    );
    expect(controller.undoLastAction(), isFalse);

    controller.dispose();
  });

  test(
    'workspace action dispatcher maps commands to controller changes',
    () async {
      final controller = RestaurantWorkspaceController(
        repository: const DemoRestaurantSnapshotRepository(),
      );
      final dispatcher = RestaurantWorkspaceActionDispatcher(
        controller: controller,
      );
      await controller.load();

      final stationResult = dispatcher.applyBriefingAction(
        const RestaurantBriefingAction(
          kind: RestaurantBriefingActionKind.rebalanceStation,
          targetId: 'grill',
        ),
      );

      expect(stationResult.changed, isTrue);
      expect(stationResult.message, 'Station rebalanced');
      expect(
        controller.state.snapshot!.stations
            .singleWhere((station) => station.id == 'grill')
            .status,
        RestaurantServiceStatus.calm,
      );

      final duplicateResult = dispatcher.applyBriefingAction(
        const RestaurantBriefingAction(
          kind: RestaurantBriefingActionKind.rebalanceStation,
          targetId: 'grill',
        ),
      );

      expect(duplicateResult.changed, isFalse);
      expect(duplicateResult.message, 'Station rebalanced');
      expect(dispatcher.undoLastAction(), isTrue);
      expect(
        controller.state.snapshot!.stations
            .singleWhere((station) => station.id == 'grill')
            .status,
        RestaurantServiceStatus.critical,
      );

      final catalogResult = dispatcher.reviewCatalogItem('nasi-ulam');

      expect(catalogResult.changed, isTrue);
      expect(catalogResult.message, 'Catalog review saved');
      expect(
        controller.state.snapshot!.menu?.itemById('nasi-ulam')?.tags,
        contains(restaurantCatalogReviewedTag),
      );

      final recipeResult = dispatcher.reviewRecipeProduction(
        'burnt-cheesecake',
      );

      expect(recipeResult.changed, isTrue);
      expect(recipeResult.message, 'Recipe production review saved');
      expect(
        controller.state.snapshot!.menu?.itemById('burnt-cheesecake')?.tags,
        contains(restaurantRecipeProductionReviewedTag),
      );

      controller.dispose();
    },
  );
}
