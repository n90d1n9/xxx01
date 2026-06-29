import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/ibs/utils/helper.dart';

import '../models/entity_count.dart';
import '../models/enums.dart';
import '../models/kpi.dart';
import '../states/dash_provider.dart';

class SchoolDashboardScreen extends ConsumerWidget {
  const SchoolDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(currentFilterProvider);
    final kpiData = ref.watch(kpiDataProvider);
    final entityData = ref.watch(entityDataProvider);
    final attendanceData = ref.watch(attendanceChartDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Islamic Boarding School',
          style: TextStyle(
            color: Color(0xFF235D3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF235D3A),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
            radius: 18,
          ),
          const SizedBox(width: 20),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF235D3A)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                    radius: 40,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ustadh Ahmad',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const Text(
                    'Administrator',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              selected: true,
              selectedTileColor: const Color(0xFFE8F5E9),
              leading: const Icon(Icons.dashboard, color: Color(0xFF235D3A)),
              title: const Text(
                'Dashboard',
                style: TextStyle(color: Color(0xFF235D3A)),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Students'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.school_outlined),
              title: const Text('Teachers'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.business_center_outlined),
              title: const Text('Staff'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.event_available_outlined),
              title: const Text('Attendance'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Curriculum'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assalamu\'alaikum, Ustadh Ahmad',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  _buildFilterDropdown(ref),
                ],
              ),

              const SizedBox(height: 24),

              // Entity summary cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: entityData.length,
                itemBuilder: (context, index) {
                  return _buildEntityCard(entityData[index]);
                },
              ),

              const SizedBox(height: 24),

              // KPI Cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.8,
                ),
                itemCount: kpiData.length,
                itemBuilder: (context, index) {
                  return _buildKpiCard(kpiData[index]);
                },
              ),

              const SizedBox(height: 24),

              // Attendance Chart
              _buildAttendanceChart(context, attendanceData, currentFilter),

              const SizedBox(height: 24),

              // Recent Activities
              _buildRecentActivities(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(WidgetRef ref) {
    final currentFilter = ref.watch(currentFilterProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<TimeFilter>(
        value: currentFilter,
        icon: const Icon(Icons.keyboard_arrow_down),
        elevation: 0,
        underline: Container(),
        onChanged: (TimeFilter? newValue) {
          if (newValue != null) {
            ref.read(currentFilterProvider.notifier).state = newValue;
          }
        },
        items:
            TimeFilter.values.map<DropdownMenuItem<TimeFilter>>((
              TimeFilter filter,
            ) {
              return DropdownMenuItem<TimeFilter>(
                value: filter,
                child: Text(filter.name.capitalize()),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildEntityCard(EntityCount data) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.name,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        data.isPositive
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        data.isPositive
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 12,
                        color: data.isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${data.change}',
                        style: TextStyle(
                          fontSize: 12,
                          color: data.isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data.count.toString(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(KpiData data) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: data.color.withValues(alpha: 0.2),
                  radius: 20,
                  child: Icon(data.icon, color: data.color, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${data.target}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: data.progress,
                      backgroundColor: data.color.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(data.color),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${data.value}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart(
    BuildContext context,
    List<FlSpot> data,
    TimeFilter filter,
  ) {
    final List<String> labels = _getLabelsForFilter(filter);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attendance Overview',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(Icons.more_horiz),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: data.length > 6 ? 5.0 : 1.0,
                        getTitlesWidget: (value, meta) {
                          final int index = value.toInt();
                          if (index < 0 || index >= labels.length) {
                            return const Text('');
                          }
                          return Text(
                            labels[index],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: data.isNotEmpty ? data.last.x : 10,
                  minY: 50,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF235D3A), Color(0xFF4CAF50)],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4CAF50).withValues(alpha: 0.2),
                            const Color(0xFF235D3A).withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getLabelsForFilter(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.day:
        return ['8AM', '10AM', '12PM', '2PM', '4PM', '6PM', '8PM'];
      case TimeFilter.month:
        return ['1', '5', '10', '15', '20', '25', '30'];
      case TimeFilter.semester:
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
      case TimeFilter.year:
        return ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov', 'Dec'];
    }
  }

  Widget _buildRecentActivities() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activities',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(Icons.more_horiz),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(5, (index) => _buildActivityTile(index)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(int index) {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'New student registration completed',
        'description': '5 new students registered for the upcoming semester',
        'time': '2 hours ago',
        'icon': Icons.person_add,
        'color': Colors.blue,
      },
      {
        'title': 'Attendance report generated',
        'description': 'Monthly attendance report is ready for review',
        'time': '4 hours ago',
        'icon': Icons.summarize,
        'color': Colors.amber,
      },
      {
        'title': 'Staff meeting scheduled',
        'description': 'Meeting with all staff members tomorrow at 9:00 AM',
        'time': '6 hours ago',
        'icon': Icons.event,
        'color': Colors.purple,
      },
      {
        'title': 'Quran memorization assessment completed',
        'description':
            '12 students achieved perfect scores in their assessment',
        'time': '1 day ago',
        'icon': Icons.book,
        'color': Colors.green,
      },
      {
        'title': 'New teaching materials uploaded',
        'description':
            'Ustadh Yusuf has uploaded new materials for Islamic history',
        'time': '1 day ago',
        'icon': Icons.upload_file,
        'color': Colors.orange,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: activities[index]['color'].withValues(alpha: 0.2),
            radius: 18,
            child: Icon(
              activities[index]['icon'],
              color: activities[index]['color'],
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activities[index]['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activities[index]['description'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  activities[index]['time'],
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
