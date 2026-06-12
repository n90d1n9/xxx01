import '../models/restaurant_models.dart';

/// Demo menu demand and availability signals for the Kaysir workspace.
const restaurantDemoMenuSignals = [
  RestaurantMenuSignal(
    id: 'short-rib-rendang',
    name: 'Short Rib Rendang',
    category: 'Signature',
    orders: 46,
    grossMarginPercent: 64,
    soldOutRiskPercent: 72,
    prepMinutes: 18,
    tags: ['High margin', 'Low stock'],
  ),
  RestaurantMenuSignal(
    id: 'smoked-duck-noodles',
    name: 'Smoked Duck Noodles',
    category: 'Mains',
    orders: 31,
    grossMarginPercent: 58,
    soldOutRiskPercent: 38,
    prepMinutes: 14,
    tags: ['Fast fire', 'Popular'],
  ),
  RestaurantMenuSignal(
    id: 'citrus-pandan-spritz',
    name: 'Citrus Pandan Spritz',
    category: 'Beverage',
    orders: 54,
    grossMarginPercent: 71,
    soldOutRiskPercent: 24,
    prepMinutes: 5,
    tags: ['Batch ready', 'Upsell'],
  ),
  RestaurantMenuSignal(
    id: 'burnt-cheesecake',
    name: 'Burnt Cheesecake',
    category: 'Dessert',
    orders: 22,
    grossMarginPercent: 69,
    soldOutRiskPercent: 56,
    prepMinutes: 7,
    tags: ['Limited', 'Dessert'],
  ),
];
