import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('workspace action coordinator presents undo feedback for changes', () {
    final controller = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
      initialState: RestaurantWorkspaceState.ready(
        snapshot: restaurantDemoSnapshot,
      ),
    );
    final messages = <String>[];
    String? undoMessage;
    VoidCallback? undoCallback;

    final coordinator = RestaurantWorkspaceActionCoordinator(
      dispatcher: RestaurantWorkspaceActionDispatcher(controller: controller),
      showUndoMessage: (message, onUndo) {
        undoMessage = message;
        undoCallback = onUndo;
      },
      showMessage: messages.add,
    );

    coordinator.completeTask('rendang-par');

    expect(undoMessage, 'Task completed');
    expect(
      controller.state.activities.first.kind,
      RestaurantOperationActivityKind.taskCompleted,
    );

    undoCallback?.call();

    expect(messages, [
      RestaurantWorkspaceActionCoordinator.undoConfirmationMessage,
    ]);
    expect(controller.state.activities, isEmpty);

    controller.dispose();
  });

  test('workspace action coordinator skips feedback when nothing changes', () {
    final controller = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
      initialState: RestaurantWorkspaceState.ready(
        snapshot: restaurantDemoSnapshot,
      ),
    );
    final undoMessages = <String>[];

    final coordinator = RestaurantWorkspaceActionCoordinator(
      dispatcher: RestaurantWorkspaceActionDispatcher(controller: controller),
      showUndoMessage: (message, _) => undoMessages.add(message),
    );

    coordinator.completeTask('missing-task');

    expect(undoMessages, isEmpty);
    expect(controller.state.activities, isEmpty);

    controller.dispose();
  });

  test('workspace action coordinator reports preference reset feedback', () {
    final messages = <String>[];
    final controller = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
      initialState: RestaurantWorkspaceState.ready(
        snapshot: restaurantDemoSnapshot,
      ),
    );

    final coordinator = RestaurantWorkspaceActionCoordinator(
      dispatcher: RestaurantWorkspaceActionDispatcher(controller: controller),
      showMessage: messages.add,
    );

    coordinator.showPreferenceResetConfirmation();

    expect(messages, [
      RestaurantWorkspaceActionCoordinator.preferenceResetMessage,
    ]);

    controller.dispose();
  });

  test('workspace action coordinator reviews recipe production work', () {
    final controller = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
      initialState: RestaurantWorkspaceState.ready(
        snapshot: restaurantDemoSnapshot,
      ),
    );
    final undoMessages = <String>[];

    final coordinator = RestaurantWorkspaceActionCoordinator(
      dispatcher: RestaurantWorkspaceActionDispatcher(controller: controller),
      showUndoMessage: (message, _) => undoMessages.add(message),
    );

    coordinator.reviewRecipeProduction('burnt-cheesecake');

    expect(undoMessages, ['Recipe production review saved']);
    expect(
      controller.state.activities.first.kind,
      RestaurantOperationActivityKind.recipeProductionReviewed,
    );
    expect(
      controller.state.snapshot!.menu?.itemById('burnt-cheesecake')?.tags,
      contains(restaurantRecipeProductionReviewedTag),
    );

    controller.dispose();
  });
}
