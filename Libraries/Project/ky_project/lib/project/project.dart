import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// MODELS
class Project {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final double actualCost;
  final double plannedProgress;
  final double actualProgress;
  final List<Task> tasks;
  final String manager;
  final String status;

  final String? managerId;

  var team;

  Project({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.budget = 0,
    this.actualCost = 0,
    required this.plannedProgress,
    required this.actualProgress,
    required this.tasks,
    required this.manager,
    required this.status,
    this.managerId,
    required List team,
  });
}

class Task {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final double plannedProgress;
  final double actualProgress;
  final String assignee;
  final String status;

  Task({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.plannedProgress,
    required this.actualProgress,
    required this.assignee,
    required this.status,
  });
}

class SCurveData {
  final DateTime date;
  final double planned;
  final double actual;

  SCurveData({required this.date, required this.planned, required this.actual});
}

// PROVIDERS
final selectedProjectIdProvider = StateProvider<String>((ref) => 'proj-001');

final projectsProvider = Provider<List<Project>>((ref) {
  // Simulated data
  return [
    Project(
      id: 'proj-001',
      name: 'Office Building Renovation',
      startDate: DateTime(2025, 1, 15),
      endDate: DateTime(2025, 12, 30),
      budget: 1200000,
      actualCost: 480000,
      plannedProgress: 60,
      actualProgress: 40,
      manager: 'Alex Johnson',
      status: 'In Progress',
      tasks: [
        Task(
          id: 'task-001',
          name: 'Design Phase',
          startDate: DateTime(2025, 1, 15),
          endDate: DateTime(2025, 3, 15),
          plannedProgress: 100,
          actualProgress: 100,
          assignee: 'Maria Garcia',
          status: 'Completed',
        ),
        Task(
          id: 'task-002',
          name: 'Foundation Work',
          startDate: DateTime(2025, 3, 20),
          endDate: DateTime(2025, 5, 30),
          plannedProgress: 100,
          actualProgress: 90,
          assignee: 'David Chen',
          status: 'In Progress',
        ),
        Task(
          id: 'task-003',
          name: 'Structural Framework',
          startDate: DateTime(2025, 6, 1),
          endDate: DateTime(2025, 8, 30),
          plannedProgress: 80,
          actualProgress: 35,
          assignee: 'Sarah Wilson',
          status: 'In Progress',
        ),
        Task(
          id: 'task-004',
          name: 'Interior Work',
          startDate: DateTime(2025, 9, 1),
          endDate: DateTime(2025, 11, 30),
          plannedProgress: 0,
          actualProgress: 0,
          assignee: 'James Taylor',
          status: 'Not Started',
        ),
        Task(
          id: 'task-005',
          name: 'Final Inspection',
          startDate: DateTime(2025, 12, 1),
          endDate: DateTime(2025, 12, 30),
          plannedProgress: 0,
          actualProgress: 0,
          assignee: 'Lisa Brown',
          status: 'Not Started',
        ),
      ],
      team: [],
    ),
    Project(
      id: 'proj-002',
      name: 'Mobile App Development',
      startDate: DateTime(2025, 3, 1),
      endDate: DateTime(2025, 8, 30),
      budget: 350000,
      actualCost: 175000,
      plannedProgress: 70,
      actualProgress: 65,
      manager: 'Sophie Martin',
      status: 'In Progress',
      tasks: [],
      team: [],
    ),
    Project(
      id: 'proj-003',
      name: 'Marketing Campaign',
      startDate: DateTime(2025, 2, 15),
      endDate: DateTime(2025, 5, 15),
      budget: 80000,
      actualCost: 76000,
      plannedProgress: 90,
      actualProgress: 95,
      manager: 'Michael Wong',
      status: 'In Progress',
      tasks: [],
      team: [],
    ),
  ];
});

final selectedProjectProvider = Provider<Project>((ref) {
  final projectId = ref.watch(selectedProjectIdProvider);
  final projects = ref.watch(projectsProvider);
  return projects.firstWhere((project) => project.id == projectId);
});

final sCurveDataProvider = Provider<List<SCurveData>>((ref) {
  final project = ref.watch(selectedProjectProvider);

  // Generate S-curve data based on project timeline
  final totalDays = project.endDate.difference(project.startDate).inDays;
  final List<SCurveData> result = [];

  // Create data points for S-curve (simplified example)
  for (int i = 0; i <= totalDays; i += 15) {
    final currentDate = project.startDate.add(Duration(days: i));

    // S-curve model: slower at beginning and end, faster in middle
    final dayRatio = i / totalDays;
    double plannedProgress;

    if (dayRatio < 0.3) {
      // Starting phase - slower progress
      plannedProgress = dayRatio * 15;
    } else if (dayRatio < 0.7) {
      // Middle phase - faster progress
      plannedProgress = 4.5 + (dayRatio - 0.3) * 90;
    } else {
      // End phase - slowing down
      plannedProgress = 40.5 + (dayRatio - 0.7) * 59.5;
    }

    // Simulate actual progress (with some variance)
    final progressDifference =
        (project.actualProgress - project.plannedProgress) / 100;
    final actualProgressFactor = 1 + progressDifference * (i / totalDays * 2);
    double actualProgress = plannedProgress * actualProgressFactor;

    // Cap values at 100%
    plannedProgress = plannedProgress.clamp(0, 100);
    actualProgress = actualProgress.clamp(0, 100);

    // Only add data points up to current date
    if (currentDate.isBefore(DateTime.now()) || i == 0) {
      result.add(
        SCurveData(
          date: currentDate,
          planned: plannedProgress,
          actual: actualProgress,
        ),
      );
    } else {
      result.add(
        SCurveData(
          date: currentDate,
          planned: plannedProgress,
          actual: currentDate.isBefore(DateTime.now()) ? actualProgress : 0,
        ),
      );
    }
  }

  return result;
});

// MAIN SCREEN
class ProjectManagementScreen extends ConsumerWidget {
  const ProjectManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProject = ref.watch(selectedProjectProvider);
    final sCurveData = ref.watch(sCurveDataProvider);
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Left Sidebar
            NavigationRail(
              extended: true,
              minExtendedWidth: 240,
              selectedIndex: 0,
              backgroundColor: const Color(0xFF1A1F38),
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: const IconThemeData(
                color: Color(0xFF9CA3AF),
              ),
              selectedLabelTextStyle: const TextStyle(color: Colors.white),
              unselectedLabelTextStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
              ),
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: Text('Projects'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.task_outlined),
                  selectedIcon: Icon(Icons.task),
                  label: Text('Tasks'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Team'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assessment_outlined),
                  selectedIcon: Icon(Icons.assessment),
                  label: Text('Reports'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),

            // Main Content Area
            Expanded(
              child: Container(
                color: const Color(0xFFF5F8FA),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Bar
                    Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Project Selector Dropdown
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedProject.id,
                                icon: const Icon(Icons.arrow_drop_down),
                                style: const TextStyle(
                                  color: Color(0xFF1A1F38),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    ref
                                            .read(
                                              selectedProjectIdProvider
                                                  .notifier,
                                            )
                                            .state =
                                        newValue;
                                  }
                                },
                                items: projects.map<DropdownMenuItem<String>>((
                                  Project project,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: project.id,
                                    child: Text(project.name),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          // Right side icons
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.help_outline),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 16),
                          const CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/150?img=11',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Content
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          // Project Header
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedProject.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1F38),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manager: ${selectedProject.manager} • Status: ${selectedProject.status}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.add),
                                label: const Text('New Task'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // KPI Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'Project Budget',
                                  value:
                                      '\$${NumberFormat('#,###').format(selectedProject.budget)}',
                                  subtitle:
                                      '\$${NumberFormat('#,###').format(selectedProject.actualCost)} Spent',
                                  percent:
                                      selectedProject.actualCost /
                                      selectedProject.budget *
                                      100,
                                  icon: Icons.account_balance_wallet_outlined,
                                  color: const Color(0xFF4F46E5),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'Planned Progress',
                                  value:
                                      '${selectedProject.plannedProgress.toStringAsFixed(1)}%',
                                  subtitle:
                                      '${selectedProject.actualProgress.toStringAsFixed(1)}% Completed',
                                  percent:
                                      selectedProject.actualProgress /
                                      selectedProject.plannedProgress *
                                      100,
                                  icon: Icons.trending_up_outlined,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildKpiCard(
                                  title: 'Timeline',
                                  value:
                                      '${DateFormat('MMM d').format(selectedProject.startDate)} - ${DateFormat('MMM d, y').format(selectedProject.endDate)}',
                                  subtitle:
                                      '${DateTime.now().difference(selectedProject.startDate).inDays} days from start',
                                  percent:
                                      DateTime.now()
                                          .difference(selectedProject.startDate)
                                          .inDays /
                                      selectedProject.endDate
                                          .difference(selectedProject.startDate)
                                          .inDays *
                                      100,
                                  icon: Icons.calendar_today_outlined,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // S-Curve Section
                          const Text(
                            'Project S-Curve Performance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1F38),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 350,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Cumulative Progress (%)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF4F46E5),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Planned',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFF97316),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Actual',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Expanded(child: sCurveChart(sCurveData)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Tasks Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Project Tasks',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1F38),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.filter_list, size: 18),
                                label: const Text('Filter'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tasks List
                          ...selectedProject.tasks
                              .map((task) => _buildTaskCard(task))
                              .toList(),

                          if (selectedProject.tasks.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.assignment_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No tasks available for this project',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
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

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required double percent,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: percent > 90
                      ? Colors.green[50]
                      : percent > 70
                      ? Colors.yellow[50]
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  percent >= 100
                      ? 'On Track'
                      : percent > 85
                      ? 'Near Target'
                      : 'Behind',
                  style: TextStyle(
                    fontSize: 12,
                    color: percent > 90
                        ? Colors.green[700]
                        : percent > 70
                        ? Colors.orange[700]
                        : Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1F38),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                percent > 90
                    ? Colors.green
                    : percent > 70
                    ? Colors.orange
                    : Colors.red,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    // Determine status color
    Color statusColor;
    switch (task.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'in progress':
        statusColor = Colors.blue;
        break;
      case 'delayed':
        statusColor = Colors.orange;
        break;
      case 'not started':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Task details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1F38),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${DateFormat('MMM d').format(task.startDate)} - ${DateFormat('MMM d').format(task.endDate)} • Assigned to ${task.assignee}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Progress and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  task.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${task.actualProgress.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1F38),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: task.actualProgress / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          task.actualProgress >= task.plannedProgress
                              ? Colors.green
                              : task.actualProgress >=
                                    task.plannedProgress * 0.8
                              ? Colors.orange
                              : Colors.red,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget sCurveChart(List<SCurveData> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 20,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: const Color(0xFFE2E8F0), strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: const Color(0xFFE2E8F0), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: data.length > 10
                  ? (data.length / 5).ceil().toDouble()
                  : 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length || value.toInt() < 0) {
                  return const SizedBox.shrink();
                }
                final date = data[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MMM d').format(date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                    ),
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
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          // Planned Progress Line
          LineChartBarData(
            spots: List.generate(data.length, (index) {
              return FlSpot(index.toDouble(), data[index].planned);
            }),
            isCurved: true,
            color: const Color(0xFF4F46E5),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF4F46E5),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF4F46E5).withOpacity(0.1),
            ),
          ),

          // Actual Progress Line
          LineChartBarData(
            spots: List.generate(data.length, (index) {
              // Only show actual data up to current date
              if (data[index].date.isBefore(DateTime.now())) {
                return FlSpot(index.toDouble(), data[index].actual);
              } else {
                return FlSpot(index.toDouble(), 0);
              }
            }),
            isCurved: true,
            color: const Color(0xFFF97316),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFFF97316),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFF97316).withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            //tooltipBgColor: const Color(0xFF1A1F38).withOpacity(0.8),
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= data.length) return null;

                final date = data[index].date;
                final value = spot.y;
                final isPlanned = spot.barIndex == 0;

                return LineTooltipItem(
                  '${isPlanned ? 'Planned' : 'Actual'}: ${value.toStringAsFixed(1)}%\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: '${DateFormat('MMM d, y').format(date)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          touchSpotThreshold: 20,
        ),
      ),
    );
  }
}

// ADDITIONAL UI COMPONENTS

// This would be your main.dart file
void main() {
  runApp(const ProviderScope(child: ProjectManagementApp()));
}

class ProjectManagementApp extends StatelessWidget {
  const ProjectManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Management Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4F46E5),
        scaffoldBackgroundColor: const Color(0xFFF5F8FA),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1A1F38)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1F38),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const ProjectManagementScreen(),
    );
  }
}

// You would also need to add these dependencies to your pubspec.yaml:
/*
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  fl_chart: ^0.65.0
  intl: ^0.19.0
*/
