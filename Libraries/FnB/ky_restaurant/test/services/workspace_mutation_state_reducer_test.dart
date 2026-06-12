import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('workspace mutation state reducer creates undoable ready state', () {
    final now = DateTime(2026, 1, 1, 12);
    const reducer = RestaurantWorkspaceMutationStateReducer(activityLimit: 2);
    final previousActivities = [
      RestaurantOperationActivity(
        id: 'previous',
        kind: RestaurantOperationActivityKind.stationStatusChanged,
        title: 'Previous station update',
        description: 'Station was updated.',
        createdAt: now.subtract(const Duration(minutes: 1)),
      ),
      RestaurantOperationActivity(
        id: 'older',
        kind: RestaurantOperationActivityKind.taskCompleted,
        title: 'Older task update',
        description: 'Task was completed.',
        createdAt: now.subtract(const Duration(minutes: 2)),
      ),
    ];
    final mutation = RestaurantWorkspaceMutation(
      snapshot: restaurantDemoSnapshot.copyWith(activeCovers: 144),
      activity: RestaurantOperationActivity(
        id: 'latest',
        kind: RestaurantOperationActivityKind.menuRiskResolved,
        title: 'Latest menu update',
        description: 'Menu risk was resolved.',
        createdAt: now,
      ),
      undoLabel: 'Menu update',
    );

    final state = reducer.reduce(
      previousSnapshot: restaurantDemoSnapshot,
      previousActivities: previousActivities,
      mutation: mutation,
      now: now,
    );

    expect(state.status, RestaurantWorkspaceLoadStatus.ready);
    expect(state.snapshot?.activeCovers, 144);
    expect(state.activities.map((activity) => activity.id), [
      'latest',
      'previous',
    ]);
    expect(state.undoEntry?.id, 'undo-${now.microsecondsSinceEpoch}');
    expect(state.undoEntry?.label, 'Menu update');
    expect(state.undoEntry?.snapshot, same(restaurantDemoSnapshot));
    expect(state.undoEntry?.activities, same(previousActivities));
    expect(state.updatedAt, now);
  });
}
