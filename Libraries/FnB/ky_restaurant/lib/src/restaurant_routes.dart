import 'models/restaurant_workspace_view.dart';

/// Describes one sidebar destination for the restaurant operations workspace.
class RestaurantRouteDefinition {
  const RestaurantRouteDefinition({
    required this.routeName,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.path,
    required this.view,
  });

  final String routeName;
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final String path;
  final RestaurantWorkspaceView view;
}

/// Centralizes route names and paths used by restaurant workspace surfaces.
class RestaurantRoutes {
  const RestaurantRoutes._();

  static const workspacePath = '/restaurant';
  static const floorPath = '/restaurant/floor';
  static const reservationsPath = '/restaurant/reservations';
  static const reservationQrPath = '/restaurant/reservations/qr';
  static const menuPath = '/restaurant/menu';
  static const kitchenPath = '/restaurant/kitchen';

  static const workspaceRouteName = 'restaurantWorkspace';
  static const floorRouteName = 'restaurantFloor';
  static const reservationsRouteName = 'restaurantReservations';
  static const menuRouteName = 'restaurantMenu';
  static const kitchenRouteName = 'restaurantKitchen';

  static String pathForView(RestaurantWorkspaceView view) {
    return restaurantRouteDefinitionForView(view).path;
  }
}

const restaurantRouteDefinitions = [
  RestaurantRouteDefinition(
    routeName: RestaurantRoutes.workspaceRouteName,
    title: 'Restaurant',
    subtitle: 'Table-service operations',
    description:
        'Modern restaurant command workspace for service pulse, floor status, menu demand, and kitchen pacing.',
    icon: 'restaurant',
    path: RestaurantRoutes.workspacePath,
    view: RestaurantWorkspaceView.pulse,
  ),
  RestaurantRouteDefinition(
    routeName: RestaurantRoutes.floorRouteName,
    title: 'Floor Plan',
    subtitle: 'Tables and seating pressure',
    description:
        'Floor operations view for occupied tables, waitlist pressure, covers, and section-level service timing.',
    icon: 'restaurant-floor',
    path: RestaurantRoutes.floorPath,
    view: RestaurantWorkspaceView.floor,
  ),
  RestaurantRouteDefinition(
    routeName: RestaurantRoutes.reservationsRouteName,
    title: 'Reservations',
    subtitle: 'Bookings and seating flow',
    description:
        'Reservation management view for arrivals, seating readiness, VIP bookings, late parties, and no-show risk.',
    icon: 'restaurant-reservations',
    path: RestaurantRoutes.reservationsPath,
    view: RestaurantWorkspaceView.reservations,
  ),
  RestaurantRouteDefinition(
    routeName: RestaurantRoutes.menuRouteName,
    title: 'Menu Mix',
    subtitle: 'Demand and availability',
    description:
        'Menu performance view for high-demand dishes, margin, prep time, and sell-out risk.',
    icon: 'restaurant-menu',
    path: RestaurantRoutes.menuPath,
    view: RestaurantWorkspaceView.menu,
  ),
  RestaurantRouteDefinition(
    routeName: RestaurantRoutes.kitchenRouteName,
    title: 'Kitchen Flow',
    subtitle: 'Station load and ticket pacing',
    description:
        'Kitchen operations view for station queues, fire times, blockers, and shift follow-up tasks.',
    icon: 'restaurant-kitchen',
    path: RestaurantRoutes.kitchenPath,
    view: RestaurantWorkspaceView.kitchen,
  ),
];

RestaurantRouteDefinition restaurantRouteDefinitionForView(
  RestaurantWorkspaceView view,
) {
  return restaurantRouteDefinitions.firstWhere(
    (definition) => definition.view == view,
  );
}

RestaurantWorkspaceView restaurantWorkspaceViewFromPath(String? path) {
  return restaurantRouteDefinitions
      .firstWhere(
        (definition) => definition.path == path,
        orElse: () => restaurantRouteDefinitions.first,
      )
      .view;
}
