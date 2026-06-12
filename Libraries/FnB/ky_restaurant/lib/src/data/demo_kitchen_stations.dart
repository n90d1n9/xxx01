import '../models/restaurant_models.dart';

/// Demo kitchen station pressure used by the Kaysir restaurant workspace.
const restaurantDemoKitchenStations = [
  RestaurantKitchenStation(
    id: 'grill',
    name: 'Grill',
    lead: 'Ari',
    ticketsInProgress: 12,
    averageFireMinutes: 21,
    queueLabel: 'Steaks and skewers',
    status: RestaurantServiceStatus.critical,
  ),
  RestaurantKitchenStation(
    id: 'wok',
    name: 'Wok',
    lead: 'Mei',
    ticketsInProgress: 8,
    averageFireMinutes: 15,
    queueLabel: 'Noodles, rice, sambal',
    status: RestaurantServiceStatus.busy,
  ),
  RestaurantKitchenStation(
    id: 'cold',
    name: 'Cold Pass',
    lead: 'Dimas',
    ticketsInProgress: 5,
    averageFireMinutes: 8,
    queueLabel: 'Salads and desserts',
    status: RestaurantServiceStatus.calm,
  ),
  RestaurantKitchenStation(
    id: 'barista',
    name: 'Barista',
    lead: 'Laila',
    ticketsInProgress: 3,
    averageFireMinutes: 6,
    queueLabel: 'Coffee and mocktails',
    status: RestaurantServiceStatus.calm,
  ),
];
