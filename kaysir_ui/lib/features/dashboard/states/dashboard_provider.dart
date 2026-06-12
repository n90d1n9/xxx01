import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/dashboard_data.dart';

abstract final class DashboardFilters {
  static const thisWeek = 'This Week';
  static const lastWeek = 'Last Week';
  static const thisMonth = 'This Month';
  static const lastMonth = 'Last Month';

  static const values = [thisWeek, lastWeek, thisMonth, lastMonth];

  static String currentSeriesLabel(String filter) {
    return switch (filter) {
      lastWeek => 'Last week',
      thisMonth => 'This month',
      lastMonth => 'Last month',
      _ => 'This week',
    };
  }

  static String previousSeriesLabel(String filter) {
    return switch (filter) {
      lastWeek => 'Previous week',
      thisMonth => 'Last month',
      lastMonth => 'Previous month',
      _ => 'Last week',
    };
  }
}

final selectedFilterProvider = StateProvider<String>(
  (ref) => DashboardFilters.thisWeek,
);

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final filter = ref.watch(selectedFilterProvider);
  await Future.delayed(const Duration(milliseconds: 250));

  return switch (filter) {
    DashboardFilters.lastWeek => _buildDashboardData(
      transactions: 118420,
      transactionsChange: '- 1.4% than previous week',
      itemsSold: 5318,
      itemsSoldChange: '+ 1.8% than previous week',
      openOrders: 13920,
      openOrdersChange: '- 3.6% than previous week',
      growth: 14.8,
      growthChange: '+ 2.1% than previous week',
      currentSales: const [18000, 21000, 27000, 31000, 29000, 33000, 30000],
      previousSales: const [16000, 19000, 24000, 26000, 28000, 29000, 27000],
      acquisitionData: AcquisitionData(reviews: 28, education: 22, deals: 50),
      topProducts: const [
        _ProductSeed('Starter Retail Bundle', 1250000, 982, 'SKU 104820'),
        _ProductSeed('Organic Shelf Label Set', 820000, 741, 'SKU 204197'),
        _ProductSeed('Counter Display Kit', 610000, 526, 'SKU 883002'),
      ],
    ),
    DashboardFilters.thisMonth => _buildDashboardData(
      transactions: 486200,
      transactionsChange: '+ 8.6% than last month',
      itemsSold: 22140,
      itemsSoldChange: '+ 6.9% than last month',
      openOrders: 52680,
      openOrdersChange: '+ 4.2% than last month',
      growth: 23.4,
      growthChange: '+ 3.8% than last month',
      currentSales: const [72000, 86000, 112000, 98000, 128000, 136000, 118000],
      previousSales: const [66000, 78000, 94000, 91000, 107000, 119000, 103000],
      acquisitionData: AcquisitionData(reviews: 34, education: 16, deals: 50),
      topProducts: const [
        _ProductSeed('Ramadan Promo Pack', 2850000, 3498, 'SKU 742110'),
        _ProductSeed('POS Receipt Paper Box', 740000, 2810, 'SKU 100421'),
        _ProductSeed('Premium Shopping Bag', 540000, 2194, 'SKU 584020'),
      ],
    ),
    DashboardFilters.lastMonth => _buildDashboardData(
      transactions: 447780,
      transactionsChange: '+ 5.1% than previous month',
      itemsSold: 20716,
      itemsSoldChange: '+ 4.4% than previous month',
      openOrders: 50490,
      openOrdersChange: '- 1.8% than previous month',
      growth: 19.2,
      growthChange: '+ 1.2% than previous month',
      currentSales: const [64000, 75000, 96000, 104000, 116000, 120000, 108000],
      previousSales: const [59000, 71000, 88000, 96000, 103000, 111000, 99000],
      acquisitionData: AcquisitionData(reviews: 30, education: 20, deals: 50),
      topProducts: const [
        _ProductSeed('Daily Essentials Crate', 2100000, 3122, 'SKU 446700'),
        _ProductSeed('Seasonal Gift Wrap', 680000, 2450, 'SKU 331900'),
        _ProductSeed('Checkout Accessory Kit', 920000, 1786, 'SKU 507722'),
      ],
    ),
    _ => _buildDashboardData(
      transactions: 127012,
      transactionsChange: '+ 2% than last week',
      itemsSold: 5661,
      itemsSoldChange: '+ 3.2% than last week',
      openOrders: 15138,
      openOrdersChange: '+ 12% than last week',
      growth: 19.6,
      growthChange: '- 4.9% than last week',
      currentSales: const [15000, 20000, 35000, 40000, 30000, 32000, 28000],
      previousSales: const [12000, 18000, 25000, 30000, 20000, 28000, 25000],
      acquisitionData: AcquisitionData(reviews: 31, education: 18, deals: 51),
      topProducts: const [
        _ProductSeed('Signature Retail Pack', 1275000, 1276, 'SKU 6426327'),
        _ProductSeed('Botanic Men\'s Complex', 420000, 968, 'SKU 6426331'),
        _ProductSeed('Express Counter Bundle', 760000, 812, 'SKU 6426348'),
      ],
    ),
  };
});

DashboardData _buildDashboardData({
  required int transactions,
  required String transactionsChange,
  required int itemsSold,
  required String itemsSoldChange,
  required int openOrders,
  required String openOrdersChange,
  required double growth,
  required String growthChange,
  required List<int> currentSales,
  required List<int> previousSales,
  required AcquisitionData acquisitionData,
  required List<_ProductSeed> topProducts,
}) {
  return DashboardData(
    photos: transactions,
    photosChange: transactionsChange,
    video: itemsSold,
    videoChange: itemsSoldChange,
    event: openOrders,
    eventChange: openOrdersChange,
    growth: growth,
    growthChange: growthChange,
    salesData: _salesData(currentSales, previousSales),
    acquisitionData: acquisitionData,
    topProducts: _products(topProducts),
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
}

List<SalesDataPoint> _salesData(
  List<int> currentSales,
  List<int> previousSales,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return [
    for (var index = 0; index < currentSales.length; index++)
      SalesDataPoint(
        date: today.subtract(Duration(days: currentSales.length - index - 1)),
        currentWeekSales: currentSales[index],
        previousWeekSales: previousSales[index],
      ),
  ];
}

List<Product> _products(List<_ProductSeed> products) {
  final now = DateTime.now();

  return [
    for (var index = 0; index < products.length; index++)
      Product(
        name: products[index].name,
        date: now.subtract(Duration(days: index + 1)),
        price: products[index].price,
        quantity: products[index].quantity,
        code: products[index].code,
      ),
  ];
}

class _ProductSeed {
  final String name;
  final double price;
  final int quantity;
  final String code;

  const _ProductSeed(this.name, this.price, this.quantity, this.code);
}
