import '../models/restaurant_models.dart';

/// Demo floor zones used by the Kaysir restaurant workspace.
const restaurantDemoFloorZones = [
  RestaurantServiceZone(
    id: 'main-floor',
    name: 'Main Floor',
    section: 'Dining',
    occupiedTables: 18,
    totalTables: 22,
    covers: 72,
    waitList: 6,
    ticketMinutes: 17,
    status: RestaurantServiceStatus.busy,
  ),
  RestaurantServiceZone(
    id: 'terrace',
    name: 'Terrace',
    section: 'Outdoor',
    occupiedTables: 9,
    totalTables: 14,
    covers: 34,
    waitList: 2,
    ticketMinutes: 14,
    status: RestaurantServiceStatus.calm,
  ),
  RestaurantServiceZone(
    id: 'private-room',
    name: 'Private Room',
    section: 'Events',
    occupiedTables: 4,
    totalTables: 4,
    covers: 28,
    waitList: 0,
    ticketMinutes: 22,
    status: RestaurantServiceStatus.critical,
  ),
  RestaurantServiceZone(
    id: 'bar',
    name: 'Bar Counter',
    section: 'Beverage',
    occupiedTables: 11,
    totalTables: 16,
    covers: 14,
    waitList: 3,
    ticketMinutes: 9,
    status: RestaurantServiceStatus.calm,
  ),
];
