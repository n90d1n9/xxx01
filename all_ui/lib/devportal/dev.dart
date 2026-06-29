import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Models
class Project {
  final String id;
  final String name;
  final String description;
  final int apiCalls;
  final double uptime;
  final String lastDeployed;
  final String status;
  final String language;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.apiCalls,
    required this.uptime,
    required this.lastDeployed,
    required this.status,
    required this.language,
  });
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime dateTime;
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.dateTime,
    required this.isRead,
  });
}

// Providers
final projectsProvider = StateProvider<AsyncValue<List<Project>>>((ref) {
  return const AsyncValue.loading();
});

final selectedProjectProvider = StateProvider<String?>((ref) => null);

final notificationsProvider = StateProvider<List<NotificationItem>>((ref) {
  return [
    NotificationItem(
      title: 'Deployment Successful',
      message: 'Your API was successfully deployed to production',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationItem(
      title: 'Threshold Alert',
      message: 'Auth API has exceeded the rate limit threshold',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      title: 'New Service Available',
      message: 'ML model training service is now available in beta',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];
});

// Controller to fetch projects
final projectsControllerProvider = Provider<ProjectsController>((ref) {
  return ProjectsController(ref);
});

class ProjectsController {
  final Ref _ref;

  ProjectsController(this._ref);

  Future<void> fetchProjects() async {
    _ref.read(projectsProvider.notifier).state = const AsyncValue.loading();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final projects = [
        Project(
          id: 'proj-1',
          name: 'Payment API',
          description: 'Handles all payment processing functionality',
          apiCalls: 12543,
          uptime: 99.98,
          lastDeployed: '2025-03-15',
          status: 'healthy',
          language: 'TypeScript',
        ),
        Project(
          id: 'proj-2',
          name: 'Auth Service',
          description: 'Authentication and authorization service',
          apiCalls: 45231,
          uptime: 99.95,
          lastDeployed: '2025-03-12',
          status: 'warning',
          language: 'Go',
        ),
        Project(
          id: 'proj-3',
          name: 'Data Analytics',
          description: 'Customer data processing pipeline',
          apiCalls: 5438,
          uptime: 99.87,
          lastDeployed: '2025-03-10',
          status: 'healthy',
          language: 'Python',
        ),
        Project(
          id: 'proj-4',
          name: 'User Management',
          description: 'User profile and preferences manager',
          apiCalls: 8721,
          uptime: 100.00,
          lastDeployed: '2025-03-08',
          status: 'healthy',
          language: 'Kotlin',
        ),
      ];

      _ref.read(projectsProvider.notifier).state = AsyncValue.data(projects);

      // Set default selected project
      if (_ref.read(selectedProjectProvider) == null && projects.isNotEmpty) {
        _ref.read(selectedProjectProvider.notifier).state = projects.first.id;
      }
    } catch (e) {
      _ref.read(projectsProvider.notifier).state = AsyncValue.error(
        e,
        StackTrace.current,
      );
    }
  }
}

// Main Widget
class DeveloperPortalScreen extends ConsumerStatefulWidget {
  const DeveloperPortalScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DeveloperPortalScreen> createState() =>
      _DeveloperPortalScreenState();
}

class _DeveloperPortalScreenState extends ConsumerState<DeveloperPortalScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Fetch projects when screen loads
    Future.microtask(
      () => ref.read(projectsControllerProvider).fetchProjects(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getLanguageIcon(String language) {
    switch (language.toLowerCase()) {
      case 'typescript':
        return '🔷';
      case 'go':
        return '🔵';
      case 'python':
        return '🐍';
      case 'kotlin':
        return '🟣';
      default:
        return '📄';
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final selectedProjectId = ref.watch(selectedProjectProvider);
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Nexus Developer Portal',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Badge(
            isLabelVisible: unreadCount > 0,
            label: Text('$unreadCount'),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => _buildNotificationsPanel(notifications),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.indigo,
            child: Text(
              'JS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Row(
        children: [
          // Side Navigation
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 1200,
            minExtendedWidth: 200,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.api_outlined),
                selectedIcon: Icon(Icons.api),
                label: Text('APIs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.code_outlined),
                selectedIcon: Icon(Icons.code),
                label: Text('SDKs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.book_outlined),
                selectedIcon: Icon(Icons.book),
                label: Text('Documentation'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
            selectedIndex: 0,
            onDestinationSelected: (index) {
              // Handle navigation
            },
          ),

          // Main Content
          Expanded(
            child: projectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Text('Error loading projects: ${error.toString()}'),
                  ),
              data: (projects) {
                final selectedProject = projects.firstWhere(
                  (p) => p.id == selectedProjectId,
                  orElse: () => projects.first,
                );

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Developer Dashboard',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Monitor and manage your enterprise APIs',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats Cards
                      SizedBox(
                        height: 120,
                        child: Row(
                          children: [
                            _buildStatCard(
                              context,
                              'Total Services',
                              '${projects.length}',
                              Icons.cloud_outlined,
                              Colors.blue,
                            ),
                            _buildStatCard(
                              context,
                              'API Calls Today',
                              NumberFormat.compact().format(
                                projects.fold<int>(
                                  0,
                                  (sum, p) => sum + p.apiCalls,
                                ),
                              ),
                              Icons.bar_chart_outlined,
                              Colors.green,
                            ),
                            _buildStatCard(
                              context,
                              'Average Uptime',
                              '${(projects.fold<double>(0, (sum, p) => sum + p.uptime) / projects.length).toStringAsFixed(2)}%',
                              Icons.trending_up_outlined,
                              Colors.purple,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Projects Section
                      Row(
                        children: [
                          Text(
                            'Projects',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('New Project'),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Project Cards
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 1400
                                        ? 3
                                        : 2,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            final isSelected = project.id == selectedProjectId;

                            return InkWell(
                              onTap: () {
                                ref
                                    .read(selectedProjectProvider.notifier)
                                    .state = project.id;
                              },
                              child: Card(
                                    elevation: isSelected ? 4 : 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side:
                                          isSelected
                                              ? BorderSide(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                width: 2,
                                              )
                                              : BorderSide.none,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  _getLanguageIcon(
                                                    project.language,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      project.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      project.language,
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                    project.status,
                                                  ).withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 4,
                                                      backgroundColor:
                                                          _getStatusColor(
                                                            project.status,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      project.status
                                                          .capitalize(),
                                                      style: TextStyle(
                                                        color: _getStatusColor(
                                                          project.status,
                                                        ),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            project.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              height: 1.3,
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              _buildMetricChip(
                                                Icons.call_made_outlined,
                                                NumberFormat.compact().format(
                                                  project.apiCalls,
                                                ),
                                                'calls',
                                              ),
                                              _buildMetricChip(
                                                Icons.trending_up_outlined,
                                                '${project.uptime}%',
                                                'uptime',
                                              ),
                                              _buildMetricChip(
                                                Icons.update_outlined,
                                                project.lastDeployed,
                                                'deployed',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .animate(target: isSelected ? 1 : 0)
                                  .scaleXY(
                                    begin: 1.0,
                                    end: 1.02,
                                    curve: Curves.easeOut,
                                    duration: const Duration(milliseconds: 200),
                                  ),
                            );
                          },
                        ),
                      ),

                      // Selected Project Details
                      const SizedBox(height: 24),
                      Text(
                        'Project Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildProjectDetailSection(context, selectedProject),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.only(right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectDetailSection(BuildContext context, Project project) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getLanguageIcon(project.language),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.description,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Console'),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Project'),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildActionButton(
                  'API Keys',
                  Icons.vpn_key_outlined,
                  Colors.indigo,
                  onPressed: () {},
                ),
                _buildActionButton(
                  'Documentation',
                  Icons.description_outlined,
                  Colors.blue,
                  onPressed: () {},
                ),
                _buildActionButton(
                  'Analytics',
                  Icons.analytics_outlined,
                  Colors.green,
                  onPressed: () {},
                ),
                _buildActionButton(
                  'Logs',
                  Icons.terminal,
                  Colors.grey[700]!,
                  onPressed: () {},
                ),
                _buildActionButton(
                  'Settings',
                  Icons.settings_outlined,
                  Colors.orange,
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // API Usage Graph
            Text(
              'API Calls (Last 7 Days)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '4K',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '3K',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '2K',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '1K',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '0',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        // Simple mockup chart
                        Expanded(
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildBarChartColumn(0.6, isHighlighted: false),
                                _buildBarChartColumn(
                                  0.75,
                                  isHighlighted: false,
                                ),
                                _buildBarChartColumn(0.5, isHighlighted: false),
                                _buildBarChartColumn(
                                  0.85,
                                  isHighlighted: false,
                                ),
                                _buildBarChartColumn(0.9, isHighlighted: true),
                                _buildBarChartColumn(
                                  0.65,
                                  isHighlighted: false,
                                ),
                                _buildBarChartColumn(
                                  0.78,
                                  isHighlighted: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Mon',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        'Tue',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        'Wed',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        'Thu',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        'Fri',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        'Sat',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        'Sun',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

  Widget _buildBarChartColumn(
    double heightFactor, {
    required bool isHighlighted,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          height: 140 * heightFactor,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors:
                  isHighlighted
                      ? [Colors.blue[300]!, Colors.blue]
                      : [Colors.blue[100]!, Colors.blue[300]!],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color, {
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsPanel(List<NotificationItem> notifications) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Mark all as read'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            notification.isRead
                                ? Colors.grey[200]
                                : Colors.blue[50],
                        child: Icon(
                          notification.title.contains('Deployment')
                              ? Icons.rocket_launch_outlined
                              : notification.title.contains('Threshold')
                              ? Icons.warning_amber_outlined
                              : Icons.notifications_outlined,
                          color:
                              notification.isRead ? Colors.grey : Colors.blue,
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight:
                              notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification.message),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatTimeAgo(notification.dateTime)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

// Extension Methods
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// Main Application
class DeveloperPortalApp extends StatelessWidget {
  const DeveloperPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Developer Portal',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: false),
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: false),
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const DeveloperPortalScreen(),
      ),
    );
  }
}

void main() {
  runApp(const DeveloperPortalApp());
}
