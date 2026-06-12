import '../models/restaurant_models.dart';

/// Demo headline metrics used by the Kaysir restaurant workspace.
const restaurantDemoMetrics = [
  RestaurantMetric(
    id: 'covers',
    label: 'Active covers',
    value: '148',
    detail: '34 open tabs across dining zones',
    trend: '+12 vs last hour',
    status: RestaurantServiceStatus.busy,
  ),
  RestaurantMetric(
    id: 'seat-utilization',
    label: 'Seat utilization',
    value: '82%',
    detail: 'Main floor close to peak capacity',
    trend: '7 tables turning soon',
    status: RestaurantServiceStatus.busy,
  ),
  RestaurantMetric(
    id: 'ticket-time',
    label: 'Avg ticket time',
    value: '18m',
    detail: 'Kitchen target is 16m',
    trend: '+2m over target',
    status: RestaurantServiceStatus.critical,
  ),
  RestaurantMetric(
    id: 'revenue',
    label: 'Net sales today',
    value: 'Rp 42.8M',
    detail: 'Dine-in, takeaway, and events',
    trend: '+9% vs forecast',
    status: RestaurantServiceStatus.calm,
  ),
];
