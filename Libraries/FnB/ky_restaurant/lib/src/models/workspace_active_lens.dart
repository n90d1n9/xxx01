import 'restaurant_workspace_view.dart';

/// Identifies the type of active workspace lens shown in the command center.
enum RestaurantWorkspaceLensKind {
  floor,
  reservations,
  kitchen,
  menu,
  task,
  activity,
  menuSort,
  menuSearch,
  reservationSearch,
}

/// Describes an active workspace lens and the view it should navigate to.
class RestaurantWorkspaceActiveLens {
  const RestaurantWorkspaceActiveLens({
    required this.kind,
    required this.label,
  });

  final RestaurantWorkspaceLensKind kind;
  final String label;

  RestaurantWorkspaceView get targetView {
    return switch (kind) {
      RestaurantWorkspaceLensKind.floor => RestaurantWorkspaceView.floor,
      RestaurantWorkspaceLensKind.reservations ||
      RestaurantWorkspaceLensKind.reservationSearch =>
        RestaurantWorkspaceView.reservations,
      RestaurantWorkspaceLensKind.kitchen => RestaurantWorkspaceView.kitchen,
      RestaurantWorkspaceLensKind.menu ||
      RestaurantWorkspaceLensKind.menuSort ||
      RestaurantWorkspaceLensKind.menuSearch => RestaurantWorkspaceView.menu,
      RestaurantWorkspaceLensKind.task ||
      RestaurantWorkspaceLensKind.activity => RestaurantWorkspaceView.pulse,
    };
  }
}
