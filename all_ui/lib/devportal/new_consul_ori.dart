import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Console State Providers
final selectedTabProvider = StateProvider<int>((ref) => 0);
final usageDataProvider = FutureProvider<List<ApiUsageData>>((ref) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));
  return [
    ApiUsageData(name: 'Authentication', calls: 12453, growth: 23),
    ApiUsageData(name: 'Data Processing', calls: 8721, growth: -5),
    ApiUsageData(name: 'Storage', calls: 15234, growth: 17),
    ApiUsageData(name: 'Analytics', calls: 6542, growth: 8),
  ];
});

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));
  return [
    Project(
      id: '1',
      name: 'Production API',
      status: ProjectStatus.active,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      apis: ['Authentication', 'Data Processing', 'Storage'],
    ),
    Project(
      id: '2',
      name: 'Beta Analytics',
      status: ProjectStatus.warning,
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      apis: ['Analytics', 'Storage'],
    ),
    Project(
      id: '3',
      name: 'Dev Environment',
      status: ProjectStatus.inactive,
      lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
      apis: ['Authentication', 'Analytics'],
    ),
  ];
});

final apiKeysProvider = FutureProvider<List<ApiKey>>((ref) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));
  return [
    ApiKey(
      id: 'apikey_prod_123456',
      name: 'Production Key',
      created: DateTime.now().subtract(const Duration(days: 90)),
      expires: DateTime.now().add(const Duration(days: 275)),
      lastUsed: DateTime.now().subtract(const Duration(minutes: 5)),
      status: ApiKeyStatus.active,
    ),
    ApiKey(
      id: 'apikey_dev_789012',
      name: 'Development Key',
      created: DateTime.now().subtract(const Duration(days: 30)),
      expires: DateTime.now().add(const Duration(days: 335)),
      lastUsed: DateTime.now().subtract(const Duration(hours: 2)),
      status: ApiKeyStatus.active,
    ),
    ApiKey(
      id: 'apikey_test_345678',
      name: 'Test Environment',
      created: DateTime.now().subtract(const Duration(days: 120)),
      expires: DateTime.now().subtract(const Duration(days: 10)),
      lastUsed: DateTime.now().subtract(const Duration(days: 15)),
      status: ApiKeyStatus.expired,
    ),
  ];
});

final alertsProvider = FutureProvider<List<Alert>>((ref) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));
  return [
    Alert(
      id: '1',
      title: 'API Rate Limit Approaching',
      description: 'Your Authentication API is at 85% of its rate limit',
      severity: AlertSeverity.warning,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Alert(
      id: '2',
      title: 'New Security Advisory',
      description: 'Security update available for your Storage API integration',
      severity: AlertSeverity.info,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Alert(
      id: '3',
      title: 'API Key Expiring',
      description: 'Your Test Environment API key will expire in 10 days',
      severity: AlertSeverity.critical,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
});

// Main Console Screen
class DeveloperConsoleScreen extends ConsumerWidget {
  const DeveloperConsoleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // Side Navigation
          NavigationRail(
            selectedIndex: selectedTab,
            onDestinationSelected: (index) {
              ref.read(selectedTabProvider.notifier).state = index;
            },
            labelType: NavigationRailLabelType.selected,
            backgroundColor: isDarkMode
                ? const Color(0xFF1E1E2D)
                : const Color(0xFFF8F9FC),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.code_outlined),
                selectedIcon: Icon(Icons.code),
                label: Text('Projects'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.vpn_key_outlined),
                selectedIcon: Icon(Icons.vpn_key),
                label: Text('API Keys'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: Text('Analytics'),
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
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF2D2D42)
                        : Colors.white,
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
                      Text(
                        'Developer Console',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF333333),
                        ),
                      ),
                      const Spacer(),
                      // Search Bar
                      Container(
                        width: 300,
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF1E1E2D)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white30
                                        : Colors.black38,
                                  ),
                                ),
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Notification Icon
                      Badge(
                        backgroundColor: Colors.red,
                        label: const Text('3'),
                        child: IconButton(
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      // User Profile
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/300',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Admin User',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                // Tab Content
                Expanded(
                  child: _buildTabContent(selectedTab, ref, isDarkMode),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int tab, WidgetRef ref, bool isDarkMode) {
    switch (tab) {
      case 0:
        return DashboardTab(isDarkMode: isDarkMode);
      case 1:
        return ProjectsTab(isDarkMode: isDarkMode);
      case 2:
        return ApiKeysTab(isDarkMode: isDarkMode);
      case 3:
        return AnalyticsTab(isDarkMode: isDarkMode);
      case 4:
        return SettingsTab(isDarkMode: isDarkMode);
      default:
        return const Center(child: Text('Unknown Tab'));
    }
  }
}

// Dashboard Tab
class DashboardTab extends ConsumerWidget {
  final bool isDarkMode;

  const DashboardTab({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageData = ref.watch(usageDataProvider);
    final alerts = ref.watch(alertsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          // Quick Stats Row
          Row(
            children: [
              _buildStatCard(
                'Total API Calls',
                '42,950',
                Icons.compare_arrows,
                Colors.blue,
                '+15% this month',
                isDarkMode,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Active Projects',
                '3',
                Icons.folder,
                Colors.green,
                '2 updates pending',
                isDarkMode,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'API Keys',
                '3',
                Icons.vpn_key,
                Colors.orange,
                '1 expiring soon',
                isDarkMode,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'API Health',
                '99.9%',
                Icons.health_and_safety,
                Colors.purple,
                'All systems operational',
                isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // API Usage Chart and Alerts
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // API Usage Chart
              Expanded(
                flex: 2,
                child: Container(
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
                      Text(
                        'API Usage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Last 30 days',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 250,
                        child: usageData.when(
                          data: (data) => BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 20000,
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) => Text(
                                      '${value ~/ 1000}k',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white60
                                            : Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value >= 0 && value < data.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            data[value.toInt()].name,
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.white60
                                                  : Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      }
                                      return const Text('');
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
                              borderData: FlBorderData(
                                show: false,
                              ),
                              barGroups: data.asMap().entries.map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: item.calls.toDouble(),
                                      color: _getApiColor(index),
                                      width: 20,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(4),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (_, __) => const Center(
                            child: Text('Failed to load API usage data'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        children: usageData.maybeWhen(
                          data: (data) => data.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getApiColor(index),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.growth > 0
                                      ? '+${item.growth}%'
                                      : '${item.growth}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: item.growth > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                          orElse: () => [],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Alerts Panel
              Expanded(
                child: Container(
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
                            'Recent Alerts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      alerts.when(
                        data: (alertList) => Column(
                          children: alertList.map((alert) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: AlertCard(
                                alert: alert,
                                isDarkMode: isDarkMode,
                              ),
                            );
                          }).toList(),
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (_, __) => const Center(
                          child: Text('Failed to load alerts'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Projects
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
                      'Recent Projects',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(selectedTabProvider.notifier).state = 1;
                      },
                      child: const Text('View All Projects'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final projects = ref.watch(projectsProvider);
                    return projects.when(
                      data: (projectList) => Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isDarkMode
                                      ? Colors.white24
                                      : Colors.black12,
                                  width: 1,
                                ),
                              ),
                            ),
                            children: [
                              _buildTableHeader('Project Name', isDarkMode),
                              _buildTableHeader('Status', isDarkMode),
                              _buildTableHeader('Last Updated', isDarkMode),
                              _buildTableHeader('Actions', isDarkMode),
                            ],
                          ),
                          ...projectList.map((project) {
                            return TableRow(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isDarkMode
                                        ? Colors.white12
                                        : Colors.black12,
                                    width: 1,
                                  ),
                                ),
                              ),
                              children: [
                                _buildTableCell(
                                  project.name,
                                  isDarkMode,
                                ),
                                _buildTableCell(
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: StatusBadge(
                                      status: project.status,
                                      isDarkMode: isDarkMode,
                                    ),
                                  ),
                                  isDarkMode,
                                  alignment: Alignment.centerLeft,
                                ),
                                _buildTableCell(
                                  'Updated ${_timeAgo(project.lastUpdated)}',
                                  isDarkMode,
                                  textColor: isDarkMode
                                      ? Colors.white60
                                      : Colors.black54,
                                ),
                                _buildTableCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                          color: isDarkMode
                                              ? Colors.white60
                                              : Colors.black54,
                                        ),
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.bar_chart_outlined,
                                          size: 20,
                                          color: isDarkMode
                                              ? Colors.white60
                                              : Colors.black54,
                                        ),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                  isDarkMode,
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, __) => const Center(
                        child: Text('Failed to load projects'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      String subtitle, bool isDarkMode) {
    return Expanded(
      child: Container(
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.more_horiz,
                  color: isDarkMode ? Colors.white60 : Colors.black45,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
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
      ),
    );
  }

  Widget _buildTableHeader(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTableCell(Widget content, bool isDarkMode,
      {Alignment alignment = Alignment.centerLeft, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: alignment,
      child: content is String
          ? Text(
              content,
              style: TextStyle(
                color: textColor ??
                    (isDarkMode ? Colors.white : Colors.black87),
              ),
            )
          : content,
    );
  }

  Color _getApiColor(int index) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }

  String _timeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hours ago';
    } else {
      return '${duration.inDays} days ago';
    }
  }
}

// Projects Tab
class ProjectsTab extends ConsumerWidget {
  final bool isDarkMode;

  const ProjectsTab({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Projects',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('New Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Filter Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF1E1E2D)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search projects',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.white30
                                  : Colors.black38,
                            ),
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF1E1E2D)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'All Status',
                    items: ['All Status', 'Active', 'Warning', 'Inactive']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (_) {},
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    dropdownColor:
                        isDarkMode ? const Color(0xFF1E1E2D) : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF1E1E2D)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'Last Updated',
                    items: [
                      'Last Updated',
                      'Name A-Z',
                      'Name Z-A',
                      'Oldest First'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (_) {},
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    dropdownColor:
                        isDarkMode ? const Color(0xFF1E1E2D) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Projects Grid
          Expanded(
            child: projects.when(
              data: (projectList) => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: projectList.length,
                itemBuilder: (context, index) {
                  final project = projectList[index];
                  return Container(
                    decoration: BoxDecoration(
                      color:
                          isDarkMode ? const Color(0xFF2D2D42) : Colors.white,
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
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      StatusBadge(
                                        status: project.status,
                                        isDarkMode: isDarkMode,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Updated ${_timeAgo(project.lastUpdated)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDarkMode
                                              ? Colors.white60
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert,
                                  color:
                                      isDarkMode ? Colors.white60 : Colors.black54,
                                ),
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text('Edit Project'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'settings',
                                    child: Text('Project Settings'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'duplicate',
                                    child: Text('Duplicate'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                                onSelected: (String value) {},
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'API Integrations:',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: project.apis.map((api) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color(0xFF1E1E2D)
                                      : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  api,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isDarkMode ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: isDarkMode
                                    ? Colors.white12
                                    : Colors.black12,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isDarkMode
                                        ? Colors.white30
                                        : Colors.black26,
                                  ),
                                ),
                                child: const Text('View Docs'),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Manage'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (_, __) => const Center(
                child: Text('Failed to load projects'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hours ago';
    } else {
      return '${duration.inDays} days ago';
    }
  }
}

// API Keys Tab
class ApiKeysTab extends ConsumerWidget {
  final bool isDarkMode;

  const ApiKeysTab({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKeys = ref.watch(apiKeysProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'API Keys',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Generate New Key'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Security Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'API keys provide full access to your account resources. Keep your API keys secure and never share them in publicly accessible areas.',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // API Keys Table
          Expanded(
            child: Container(
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
              child: apiKeys.when(
                data: (keyList) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF1E1E2D)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Search API keys',
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white30
                                              : Colors.black38,
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF1E1E2D)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: 'All Status',
                                items: ['All Status', 'Active', 'Expired']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (_) {},
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                                dropdownColor: isDarkMode
                                    ? const Color(0xFF1E1E2D)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: keyList.length,
                        separatorBuilder: (context, index) => Divider(
                          color:
                              isDarkMode ? Colors.white12 : Colors.black12,
                        ),
                        itemBuilder: (context, index) {
                          final apiKey = keyList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        apiKey.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        apiKey.id,
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white60
                                              : Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Created: ${DateFormat('MMM d, yyyy').format(apiKey.created)}',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white60
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Expires: ${DateFormat('MMM d, yyyy').format(apiKey.expires)}',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white60
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: ApiKeyStatusBadge(
                                    status: apiKey.status,
                                    isDarkMode: isDarkMode,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.copy_outlined,
                                        color: isDarkMode
                                            ? Colors.white60
                                            : Colors.black54,
                                      ),
                                      onPressed: () {},
                                      tooltip: 'Copy Key',
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.refresh_outlined,
                                        color: isDarkMode
                                            ? Colors.white60
                                            : Colors.black54,
                                      ),
                                      onPressed: () {},
                                      tooltip: 'Regenerate',
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: isDarkMode
                                            ? Colors.white60
                                            : Colors.black54,
                                      ),
                                      onPressed: () {},
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => const Center(
                  child: Text('Failed to load API keys'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Analytics Tab
class AnalyticsTab extends StatelessWidget {
  final bool isDarkMode;

  const AnalyticsTab({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF2D2D42)
                      : Colors.white,
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
                        color: isDarkMode ? Colors.white70 : Colors.black87,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF2D2D42)
                      : Colors.white,
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
                        color: isDarkMode ? Colors.white70 : Colors.black87,
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
                onPressed: () {},
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
                    color: isDarkMode
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
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF1E1E2D)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Daily',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                  size: 20,
                                ),
                              ],
                            ),
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
                                tooltipBgColor: isDarkMode
                                    ? const Color(0xFF1E1E2D)
                                    : Colors.white,
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 500,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: isDarkMode
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
                                      '30'
                                    ];
                                    if (value.toInt() % 5 == 0 &&
                                        value.toInt() <= 30) {
                                      final index = value.toInt() ~/ 5;
                                      if (index < days.length) {
                                        return Text(
                                          days[index],
                                          style: TextStyle(
                                            color: isDarkMode
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
                                        color: isDarkMode
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
                                spots: _generateRandomSpots(30, 600, 1400),
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blue.withValues(alpha: 0.1),
                                ),
                              ),
                              LineChartBarData(
                                spots: _generateRandomSpots(30, 200, 800),
                                isCurved: true,
                                color: Colors.purple,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.purple.withValues(alpha: 0.1),
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
                              'Authentication API', Colors.blue, isDarkMode),
                          const SizedBox(width: 24),
                          _buildChartLegend(
                              'Data Processing API', Colors.purple, isDarkMode),
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
                      '42,950',
                      '+15%',
                      true,
                      'Last 30 days',
                      isDarkMode,
                    ),
                    const SizedBox(height: 24),
                    _buildMetricCard(
                      'Average Response Time',
                      '127ms',
                      '-5%',
                      true,
                      'Improved from last month',
                      isDarkMode,
                    ),
                    const SizedBox(height: 24),
                    _buildMetricCard(
                      'Error Rate',
                      '0.8%',
                      '+0.2%',
                      false,
                      '341 errors in total',
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
                    color: isDarkMode
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
                          color: isDarkMode ? Colors.white : Colors.black87,
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
                                  color: isDarkMode
                                      ? Colors.white24
                                      : Colors.black12,
                                  width: 1,
                                ),
                              ),
                            ),
                            children: [
                              _buildTableHeader('API', isDarkMode),
                              _buildTableHeader('Avg. Response', isDarkMode),
                              _buildTableHeader('Error Rate', isDarkMode),
                              _buildTableHeader('Uptime', isDarkMode),
                            ],
                          ),
                          _buildApiPerformanceRow(
                            'Authentication',
                            '102ms',
                            '0.5%',
                            '99.9%',
                            isDarkMode,
                          ),
                          _buildApiPerformanceRow(
                            'Data Processing',
                            '245ms',
                            '1.2%',
                            '99.8%',
                            isDarkMode,
                          ),
                          _buildApiPerformanceRow(
                            'Storage',
                            '89ms',
                            '0.3%',
                            '100%',
                            isDarkMode,
                          ),
                          _buildApiPerformanceRow(
                            'Analytics',
                            '167ms',
                            '1.1%',
                            '99.7%',
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
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode
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
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildEndpointItem(
                        '/api/v1/auth/token',
                        '8,453',
                        '+12%',
                        0.8,
                        isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      _buildEndpointItem(
                        '/api/v1/data/process',
                        '6,254',
                        '+8%',
                        0.6,
                        isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      _buildEndpointItem(
                        '/api/v1/storage/upload',
                        '5,872',
                        '+21%',
                        0.55,
                        isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      _buildEndpointItem(
                        '/api/v1/analytics/events',
                        '3,984',
                        '-3%',
                        0.35,
                        isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      _buildEndpointItem(
                        '/api/v1/users/profile',
                        '3,145',
                        '+5%',
                        0.3,
                        isDarkMode,
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
                      onPressed: () {},
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
                                isDarkMode ? Colors.white24 : Colors.black12,
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
                    _buildErrorLogRow(
                      '15:32:21',
                      'Invalid Authentication Token',
                      '/api/v1/auth/verify',
                      '401',
                      isDarkMode,
                    ),
                    _buildErrorLogRow(
                      '14:23:15',
                      'Rate Limit Exceeded',
                      '/api/v1/data/process',
                      '429',
                      isDarkMode,
                    ),
                    _buildErrorLogRow(
                      '12:45:08',
                      'Resource Not Found',
                      '/api/v1/storage/file/123',
                      '404',
                      isDarkMode,
                    ),
                    _buildErrorLogRow(
                      '09:21:54',
                      'Bad Request Format',
                      '/api/v1/analytics/events',
                      '400',
                      isDarkMode,
                    ),
                    _buildErrorLogRow(
                      '08:12:39',
                      'Server Process Error',
                      '/api/v1/data/transform',
                      '500',
                      isDarkMode,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
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

  Widget _buildMetricCard(String title, String value, String change,
      bool isPositive, String subtitle, bool isDarkMode) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
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
      String api, String response, String error, String uptime, bool isDarkMode) {
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
          color: double.parse(error.replaceAll('%', '')) > 1.0
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

  Widget _buildEndpointItem(String endpoint, String calls, String change,
      double percentage, bool isDarkMode) {
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
                color: isPositive
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
            backgroundColor: isDarkMode
                ? const Color(0xFF1E1E2D)
                : const Color(0xFFF5F5F5),
            color: Colors.blue,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  TableRow _buildErrorLogRow(String time, String error, String endpoint,
      String status, bool isDarkMode) {
    final statusCode = int.parse(status);
    final statusColor = statusCode >= 500
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
          padding: const EdgeInsets.symmetric