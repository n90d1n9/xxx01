import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticScreen extends StatefulWidget {
  const AnalyticScreen({super.key});

  @override
  State<AnalyticScreen> createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Visitor Analytics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            DropdownButton<String>(
              value: 'Last 30 days',
              items: const [
                DropdownMenuItem(value: 'Today', child: Text('Today')),
                DropdownMenuItem(
                  value: 'Last 7 days',
                  child: Text('Last 7 days'),
                ),
                DropdownMenuItem(
                  value: 'Last 30 days',
                  child: Text('Last 30 days'),
                ),
                DropdownMenuItem(
                  value: 'Last 90 days',
                  child: Text('Last 90 days'),
                ),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 350,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildAnalyticsMetric(
                    context,
                    title: 'Total Sessions',
                    value: '43,210',
                    change: '+12.5%',
                    isPositive: true,
                  ),
                  _buildAnalyticsMetric(
                    context,
                    title: 'Average Session Duration',
                    value: '2m 37s',
                    change: '+3.2%',
                    isPositive: true,
                  ),
                  _buildAnalyticsMetric(
                    context,
                    title: 'Bounce Rate',
                    value: '32.1%',
                    change: '-2.5%',
                    isPositive: true,
                  ),
                  _buildAnalyticsMetric(
                    context,
                    title: 'Conversion Rate',
                    value: '4.8%',
                    change: '-0.3%',
                    isPositive: false,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 1,
                      verticalInterval: 1,
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            const days = [
                              '1',
                              '5',
                              '10',
                              '15',
                              '20',
                              '25',
                              '30',
                            ];
                            final index = value.toInt();
                            if (index >= 0 && index < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(days[index]),
                              );
                            }
                            return const Text('');
                          },
                          interval: 5,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}k');
                          },
                          reservedSize: 42,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    minX: 0,
                    maxX: 30,
                    minY: 0,
                    maxY: 8,
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(31, (index) {
                          // Generate some random-ish but consistent data points
                          return FlSpot(
                            index.toDouble(),
                            (4 +
                                    index % 5 * 0.1 +
                                    (index ~/ 7) * 0.4 +
                                    (index % 3 == 0 ? 0.2 : 0))
                                .toDouble(),
                          );
                        }),
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Pages',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Page')),
                          DataColumn(label: Text('Views')),
                          DataColumn(label: Text('Unique')),
                          DataColumn(label: Text('Bounce Rate')),
                          DataColumn(label: Text('Avg. Time')),
                        ],
                        rows: [
                          DataRow(
                            cells: [
                              DataCell(Text('/home')),
                              DataCell(Text('14,394')),
                              DataCell(Text('10,832')),
                              DataCell(Text('23.4%')),
                              DataCell(Text('1m 45s')),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(Text('/products')),
                              DataCell(Text('8,293')),
                              DataCell(Text('6,489')),
                              DataCell(Text('34.2%')),
                              DataCell(Text('2m 12s')),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(Text('/checkout')),
                              DataCell(Text('6,983')),
                              DataCell(Text('5,127')),
                              DataCell(Text('12.9%')),
                              DataCell(Text('3m 50s')),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(Text('/category/electronics')),
                              DataCell(Text('5,192')),
                              DataCell(Text('4,385')),
                              DataCell(Text('28.5%')),
                              DataCell(Text('1m 32s')),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(Text('/blog')),
                              DataCell(Text('4,295')),
                              DataCell(Text('3,127')),
                              DataCell(Text('45.2%')),
                              DataCell(Text('0m 58s')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Devices',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: 52,
                              title: 'Mobile\n52%',
                              color: Colors.blue,
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: 28,
                              title: 'Desktop\n28%',
                              color: Colors.green,
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: 20,
                              title: 'Tablet\n20%',
                              color: Colors.amber,
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor: Colors.blue,
                                ),
                                SizedBox(width: 8),
                                Text('Mobile'),
                              ],
                            ),
                            Text('52%'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor: Colors.green,
                                ),
                                SizedBox(width: 8),
                                Text('Desktop'),
                              ],
                            ),
                            Text('28%'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor: Colors.amber,
                                ),
                                SizedBox(width: 8),
                                Text('Tablet'),
                              ],
                            ),
                            Text('20%'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsMetric(
    BuildContext context, {
    required String title,
    required String value,
    required String change,
    required bool isPositive,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
