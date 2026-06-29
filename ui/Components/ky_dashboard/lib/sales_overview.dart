import 'package:flutter/material.dart';

class SalesOverviewWidget extends ConsumerWidget {
  const SalesOverviewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSales = ref.watch(totalSalesProvider);
    final salesTrends = ref.watch(salesTrendsProvider);
    final topSellingProducts = ref.watch(topSellingProductsProvider);
    final salesByLocation = ref.watch(salesByLocationProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sales Overview', style: Theme.of(context).textTheme.headline6),
          const SizedBox(height: 16),

          // Total Sales
          Text('Total Sales:', style: Theme.of(context).textTheme.subtitle1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: totalSales.entries
                .map((entry) => Column(
                      children: [
                        Text(entry.key, style: Theme.of(context).textTheme.bodyText1),
                        Text('\$${entry.value.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyText2),
                      ],
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Sales Trends Chart
          Text('Sales Trends:', style: Theme.of(context).textTheme.subtitle1),
          SizedBox(
            height: 200,
            child: charts.LineChart(
              [
                charts.Series<ChartData, String>(
                  id: 'Sales Trends',
                  colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                  domainFn: (ChartData data, _) => data.label,
                  measureFn: (ChartData data, _) => data.value,
                  data: salesTrends,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Top-Selling Products
          Text('Top-Selling Products:', style: Theme.of(context).textTheme.subtitle1),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: topSellingProducts
                .map((product) => Text('${product.label}: \$${product.value.toStringAsFixed(2)}'))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Sales by Store Location
          Text('Sales by Store Location:', style: Theme.of(context).textTheme.subtitle1),
          SizedBox(
            height: 200,
            child: charts.BarChart(
              [
                charts.Series<ChartData, String>(
                  id: 'Sales by Location',
                  colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
                  domainFn: (ChartData data, _) => data.label,
                  measureFn: (ChartData data, _) => data.value,
                  data: salesByLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
