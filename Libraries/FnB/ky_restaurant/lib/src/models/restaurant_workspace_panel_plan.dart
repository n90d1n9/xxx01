import 'restaurant_workspace_view.dart';

enum RestaurantWorkspacePanelSlot {
  service,
  briefing,
  floor,
  reservations,
  kitchen,
  task,
  menu,
  activity,
}

class RestaurantWorkspacePanelPlan {
  const RestaurantWorkspacePanelPlan._(this.slots);

  static const pulse = RestaurantWorkspacePanelPlan._([
    RestaurantWorkspacePanelSlot.service,
    RestaurantWorkspacePanelSlot.briefing,
    RestaurantWorkspacePanelSlot.floor,
    RestaurantWorkspacePanelSlot.reservations,
    RestaurantWorkspacePanelSlot.kitchen,
    RestaurantWorkspacePanelSlot.task,
    RestaurantWorkspacePanelSlot.activity,
  ]);

  static const floor = RestaurantWorkspacePanelPlan._([
    RestaurantWorkspacePanelSlot.briefing,
    RestaurantWorkspacePanelSlot.floor,
    RestaurantWorkspacePanelSlot.reservations,
    RestaurantWorkspacePanelSlot.task,
    RestaurantWorkspacePanelSlot.activity,
  ]);

  static const reservations = RestaurantWorkspacePanelPlan._([
    RestaurantWorkspacePanelSlot.briefing,
    RestaurantWorkspacePanelSlot.reservations,
    RestaurantWorkspacePanelSlot.floor,
    RestaurantWorkspacePanelSlot.task,
    RestaurantWorkspacePanelSlot.activity,
  ]);

  static const menu = RestaurantWorkspacePanelPlan._([
    RestaurantWorkspacePanelSlot.briefing,
    RestaurantWorkspacePanelSlot.menu,
    RestaurantWorkspacePanelSlot.kitchen,
    RestaurantWorkspacePanelSlot.activity,
  ]);

  static const kitchen = RestaurantWorkspacePanelPlan._([
    RestaurantWorkspacePanelSlot.briefing,
    RestaurantWorkspacePanelSlot.kitchen,
    RestaurantWorkspacePanelSlot.task,
    RestaurantWorkspacePanelSlot.menu,
    RestaurantWorkspacePanelSlot.activity,
  ]);

  final List<RestaurantWorkspacePanelSlot> slots;

  bool contains(RestaurantWorkspacePanelSlot slot) => slots.contains(slot);

  static RestaurantWorkspacePanelPlan forView(RestaurantWorkspaceView view) {
    return switch (view) {
      RestaurantWorkspaceView.pulse => pulse,
      RestaurantWorkspaceView.floor => floor,
      RestaurantWorkspaceView.reservations => reservations,
      RestaurantWorkspaceView.menu => menu,
      RestaurantWorkspaceView.kitchen => kitchen,
    };
  }
}
