import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_data.dart';

final selectedFilterProvider = StateProvider<String>((ref) => 'This Week');

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  await Future.delayed(const Duration(seconds: 1)); // Simulate API call

  final filter = ref.watch(selectedFilterProvider);

  // Dummy data
  return DashboardData(
    photos: 127012,
    photosChange: '+ 2% than last week',
    video: 5661,
    videoChange: '+ 3,21% than last month',
    event: 15138,
    eventChange: '+ 12% than last month',
    growth: 19.56,
    growthChange: '- 4,87% than last week',
    salesData: [
      SalesDataPoint(
          date: DateTime(2024, 5, 20),
          currentWeekSales: 15000,
          previousWeekSales: 12000),
      SalesDataPoint(
          date: DateTime(2024, 5, 21),
          currentWeekSales: 20000,
          previousWeekSales: 18000),
      SalesDataPoint(
          date: DateTime(2024, 5, 22),
          currentWeekSales: 35000,
          previousWeekSales: 25000),
      SalesDataPoint(
          date: DateTime(2024, 5, 23),
          currentWeekSales: 40000,
          previousWeekSales: 30000),
      SalesDataPoint(
          date: DateTime(2024, 5, 24),
          currentWeekSales: 30000,
          previousWeekSales: 20000),
      SalesDataPoint(
          date: DateTime(2024, 5, 25),
          currentWeekSales: 32000,
          previousWeekSales: 28000),
      SalesDataPoint(
          date: DateTime(2024, 5, 26),
          currentWeekSales: 28000,
          previousWeekSales: 25000),
    ],
    acquisitionData: AcquisitionData(reviews: 31, education: 18, deals: 51),
    topProducts: [
      Product(
        name: 'Kegels Silicone Kegel Balls - Pink',
        date: DateTime(2024, 4, 14),
        price: 79.49,
        quantity: 1276,
        code: 'SKU 6426327',
      ),
      Product(
        name: 'Botanic Passionate Men\'s Complex',
        date: DateTime(2024, 4, 13),
        price: 26,
        quantity: 4498,
        code: 'SKU 6426327',
      ),
    ],
    customerData: [
      CustomerDataPoint(month: 'Jan', value: 1000),
      CustomerDataPoint(month: 'Feb', value: 1500),
      CustomerDataPoint(month: 'Mar', value: 2000),
      CustomerDataPoint(month: 'Apr', value: 2500),
      CustomerDataPoint(month: 'May', value: 3000),
      CustomerDataPoint(month: 'Jun', value: -2900),
      CustomerDataPoint(month: 'Jul', value: 1000),
    ],
  );
});
