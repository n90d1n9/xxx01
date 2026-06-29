import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/dashboard_provider.dart';
import '../widgets/acc_chart.dart';
import '../widgets/consumer_chart.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/info_card.dart';
import '../widgets/sales_card.dart';
import '../widgets/top_table.dart';

class DashboardLargeScreen extends ConsumerStatefulWidget {
  const DashboardLargeScreen({super.key});

  @override
  ConsumerState<DashboardLargeScreen> createState() =>
      _DashboardLargeScreenState();
}

class _DashboardLargeScreenState extends ConsumerState<DashboardLargeScreen> {
  @override
  Widget build(BuildContext context) {
    final dashboardData = ref.watch(dashboardDataProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);

    return dashboardData.when(
      data: (data) => LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: 500,
                  child: /* Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: */
                      Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _totalRow(data),
                      const SizedBox(height: 24),
                      //_linechart(selectedFilter),
                      //SalesChart(salesData: data.salesData),
                      const SizedBox(height: 24),
                      _aqq(selectedFilter),
                      //AcquisitionChart(acquisitionData: data.acquisitionData),
                      const SizedBox(height: 24),
                      /* Row(
                        children: [
                          const Text(
                            'Top Selling Products',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          FilterDropdown(
                            onChanged: (value) {
                              ref.read(selectedFilterProvider.notifier).state =
                                  value;
                            },
                            initialValue: selectedFilter,
                          ),
                        ],
                      ),
                      TopProductsTable(products: data.topProducts),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Text(
                            'Customers',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          FilterDropdown(
                            onChanged: (value) {
                              ref.read(selectedFilterProvider.notifier).state =
                                  value;
                            },
                            initialValue: selectedFilter,
                          ),
                        ],
                      ),
                      CustomerChart(customerData: data.customerData), */
                    ],
                  ),
                ),
                //),
              )),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }

  _linechart(selectedFilter) {
    return Row(
      children: [
        const Text(
          'Sales Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            // Handle help action
          },
        ),
        const Spacer(),
        FilterDropdown(
          onChanged: (value) {
            ref.read(selectedFilterProvider.notifier).state = value;
          },
          initialValue: selectedFilter,
        ),
      ],
    );
  }

  _totalRow(data) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: InfoCard(
              title: 'PHOTOS',
              value: data.photos.toString(),
              percentageChange: data.photosChange,
              color: Colors.pink.shade100,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InfoCard(
              title: 'VIDEO',
              value: data.video.toString(),
              percentageChange: data.videoChange,
              color: Colors.purple.shade100,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InfoCard(
              title: 'EVENT',
              value: data.event.toString(),
              percentageChange: data.eventChange,
              color: Colors.green.shade100,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InfoCard(
              title: 'GROWTH',
              value: '${data.growth.toStringAsFixed(2)}%',
              percentageChange: data.growthChange,
              color: Colors.amber.shade100,
            ),
          ),
        ],
      );

  _aqq(selectedFilter) {
    return Row(
      children: [
        const Text(
          'Aquisition',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            // Handle help action
          },
        ),
        const Spacer(),
        FilterDropdown(
          onChanged: (value) {
            ref.read(selectedFilterProvider.notifier).state = value;
          },
          initialValue: selectedFilter,
        ),
      ],
    );
  }
}
