import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/analytic_controller.dart';
import '../states/provider.dart';

class AnalyticsTab extends ConsumerWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final analyticsData = ref.watch(analyticsDataProvider);

    return analyticsData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) =>
              Center(child: Text('Error loading analytics: $error')),
      data:
          (data) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                // Date Filter
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode ? const Color(0xFF2D2D42) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Last 30 days',
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_drop_down,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode ? const Color(0xFF2D2D42) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 18,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'All Projects',
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_drop_down,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed:
                          () =>
                              ref
                                  .read(analyticsControllerProvider.notifier)
                                  .exportData(),
                      icon: const Icon(Icons.download),
                      label: const Text('Export Data'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDarkMode ? Colors.white30 : Colors.black26,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Usage Overview
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? const Color(0xFF2D2D42)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'API Usage Overview',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: ref.watch(timeframeProvider),
                                  isDense: true,
                                  underline: const SizedBox(),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color:
                                        isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                  dropdownColor:
                                      isDarkMode
                                          ? const Color(0xFF1E1E2D)
                                          : Colors.white,
                                  items:
                                      ['Daily', 'Weekly', 'Monthly'].map((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isDarkMode
                                                      ? const Color(0xFF1E1E2D)
                                                      : const Color(0xFFF5F5F5),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                color:
                                                    isDarkMode
                                                        ? Colors.white70
                                                        : Colors.black87,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      ref
                                          .read(timeframeProvider.notifier)
                                          .state = newValue;
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 300,
                              child: LineChart(
                                LineChartData(
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      /* tooltipBgColor:
                                          isDarkMode
                                              ? const Color(0xFF1E1E2D)
                                              : Colors.white, */
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 500,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color:
                                            isDarkMode
                                                ? Colors.white12
                                                : Colors.black12,
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        interval: 5,
                                        getTitlesWidget: (value, meta) {
                                          const days = [
                                            '01',
                                            '05',
                                            '10',
                                            '15',
                                            '20',
                                            '25',
                                            '30',
                                          ];
                                          if (value.toInt() % 5 == 0 &&
                                              value.toInt() <= 30) {
                                            final index = value.toInt() ~/ 5;
                                            if (index < days.length) {
                                              return Text(
                                                days[index],
                                                style: TextStyle(
                                                  color:
                                                      isDarkMode
                                                          ? Colors.white60
                                                          : Colors.black54,
                                                  fontSize: 12,
                                                ),
                                              );
                                            }
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 500,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: TextStyle(
                                              color:
                                                  isDarkMode
                                                      ? Colors.white60
                                                      : Colors.black54,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  maxX: 30,
                                  minX: 0,
                                  maxY: 2000,
                                  minY: 0,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: data.authApiSpots,
                                      isCurved: true,
                                      color: Colors.blue,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.blue.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                    ),
                                    LineChartBarData(
                                      spots: data.dataApiSpots,
                                      isCurved: true,
                                      color: Colors.purple,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.purple.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildChartLegend(
                                  'Authentication API',
                                  Colors.blue,
                                  isDarkMode,
                                ),
                                const SizedBox(width: 24),
                                _buildChartLegend(
                                  'Data Processing API',
                                  Colors.purple,
                                  isDarkMode,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          _buildMetricCard(
                            'Total API Calls',
                            data.totalApiCalls,
                            data.apiCallsChange,
                            data.apiCallsPositive,
                            'Last 30 days',
                            isDarkMode,
                          ),
                          const SizedBox(height: 24),
                          _buildMetricCard(
                            'Average Response Time',
                            data.avgResponseTime,
                            data.responseTimeChange,
                            data.responseTimePositive,
                            'Improved from last month',
                            isDarkMode,
                          ),
                          const SizedBox(height: 24),
                          _buildMetricCard(
                            'Error Rate',
                            data.errorRate,
                            data.errorRateChange,
                            data.errorRatePositive,
                            '${data.totalErrors} errors in total',
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // API Performance and Endpoints
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? const Color(0xFF2D2D42)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'API Performance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Table(
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(1),
                                3: FlexColumnWidth(1),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color:
                                            isDarkMode
                                                ? Colors.white24
                                                : Colors.black12,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  children: [
                                    _buildTableHeader('API', isDarkMode),
                                    _buildTableHeader(
                                      'Avg. Response',
                                      isDarkMode,
                                    ),
                                    _buildTableHeader('Error Rate', isDarkMode),
                                    _buildTableHeader('Uptime', isDarkMode),
                                  ],
                                ),
                                ...data.apiPerformances.map(
                                  (api) => _buildApiPerformanceRow(
                                    api.name,
                                    api.responseTime,
                                    api.errorRate,
                                    api.uptime,
                                    isDarkMode,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? const Color(0xFF2D2D42)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Endpoints',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...data.endpoints.map(
                              (endpoint) => Column(
                                children: [
                                  _buildEndpointItem(
                                    endpoint.path,
                                    endpoint.callCount,
                                    endpoint.change,
                                    endpoint.percentage,
                                    isDarkMode,
                                  ),
                                  if (endpoint != data.endpoints.last)
                                    const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Error Logs
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2D2D42) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Error Logs',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed:
                                () =>
                                    ref
                                        .read(
                                          analyticsControllerProvider.notifier,
                                        )
                                        .viewAllLogs(),
                            child: const Text('View All Logs'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(1),
                          4: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      isDarkMode
                                          ? Colors.white24
                                          : Colors.black12,
                                  width: 1,
                                ),
                              ),
                            ),
                            children: [
                              _buildTableHeader('Time', isDarkMode),
                              _buildTableHeader('Error', isDarkMode),
                              _buildTableHeader('Endpoint', isDarkMode),
                              _buildTableHeader('Status', isDarkMode),
                              _buildTableHeader('Action', isDarkMode),
                            ],
                          ),
                          ...data.errorLogs.map(
                            (error) => _buildErrorLogRow(
                              error.time,
                              error.message,
                              error.endpoint,
                              error.status.toString(),
                              isDarkMode,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildChartLegend(String label, Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String change,
    bool isPositive,
    String subtitle,
    bool isDarkMode,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D42) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isPositive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white60 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  TableRow _buildApiPerformanceRow(
    String api,
    String response,
    String error,
    String uptime,
    bool isDarkMode,
  ) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.white12 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      children: [
        _buildTableCell(api, isDarkMode),
        _buildTableCell(response, isDarkMode),
        _buildTableCell(
          error,
          isDarkMode,
          color:
              double.parse(error.replaceAll('%', '')) > 1.0
                  ? Colors.orange
                  : Colors.green,
        ),
        _buildTableCell(uptime, isDarkMode, color: Colors.green),
      ],
    );
  }

  Widget _buildTableCell(String text, bool isDarkMode, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? (isDarkMode ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildEndpointItem(
    String endpoint,
    String calls,
    String change,
    double percentage,
    bool isDarkMode,
  ) {
    final isPositive = change.contains('+');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                endpoint,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Text(
              calls,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:
                    isPositive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor:
                isDarkMode ? const Color(0xFF1E1E2D) : const Color(0xFFF5F5F5),
            color: Colors.blue,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  TableRow _buildErrorLogRow(
    String time,
    String error,
    String endpoint,
    String status,
    bool isDarkMode,
  ) {
    final statusCode = int.parse(status);
    final statusColor =
        statusCode >= 500
            ? Colors.red
            : statusCode >= 400
            ? Colors.orange
            : Colors.green;

    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.white12 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            time,
            style: TextStyle(
              color: isDarkMode ? Colors.white60 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            error,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            endpoint,
            style: TextStyle(
              color: isDarkMode ? Colors.white60 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: IconButton(
            icon: Icon(
              Icons.visibility,
              color: isDarkMode ? Colors.white70 : Colors.blue,
              size: 20,
            ),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }
}
