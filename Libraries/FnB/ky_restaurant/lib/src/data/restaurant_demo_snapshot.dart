import '../models/restaurant_models.dart';
import 'demo_floor_zones.dart';
import 'demo_kitchen_stations.dart';
import 'demo_menu_catalog.dart';
import 'demo_menu_signals.dart';
import 'demo_metrics.dart';
import 'demo_reservations.dart';
import 'demo_shift_tasks.dart';

export 'demo_floor_zones.dart';
export 'demo_kitchen_stations.dart';
export 'demo_menu_catalog.dart';
export 'demo_menu_signals.dart';
export 'demo_metrics.dart';
export 'demo_reservations.dart';
export 'demo_shift_tasks.dart';

/// Demo operating snapshot for the Kaysir restaurant workspace.
const restaurantDemoSnapshot = RestaurantOperatingSnapshot(
  locationName: 'Kaysir Table Service',
  serviceDateLabel: 'Live dinner shift',
  openHoursLabel: '11:00-23:00',
  managerName: 'Nadia Rahman',
  activeCovers: 148,
  pendingOrders: 36,
  seatUtilizationPercent: 82,
  averageTicketMinutes: 18,
  revenueTodayLabel: 'Rp 42.8M',
  metrics: restaurantDemoMetrics,
  zones: restaurantDemoFloorZones,
  stations: restaurantDemoKitchenStations,
  menuSignals: restaurantDemoMenuSignals,
  menu: restaurantDemoMenu,
  recipes: restaurantDemoRecipes,
  tasks: restaurantDemoShiftTasks,
  reservations: restaurantDemoReservations,
);
