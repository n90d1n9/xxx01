// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ProviderScope(child: AdminApp()));
}

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Flutter Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: themeMode,
      /* builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 600, name: MOBILE),
          const Breakpoint(start: 601, end: 900, name: TABLET),
          const Breakpoint(start: 901, end: 1200, name: DESKTOP),
          const Breakpoint(start: 1201, end: double.infinity, name: '4K'),
        ],
      ), */
      home: const DashboardScreen(),
    );
  }
}

// providers/app_providers.dart

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Sidebar mode enum
enum SidebarMode { expanded, compact, hidden }

// Sidebar mode provider
final sidebarModeProvider = StateProvider<SidebarMode>(
  (ref) => SidebarMode.expanded,
);

// Current page provider
final currentPageProvider = StateProvider<String>((ref) => 'Dashboard');

// User provider
final userProvider = Provider(
  (ref) => User(
    name: 'Alex Johnson',
    email: 'alex@example.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    role: 'Admin',
  ),
);

// Example user model
class User {
  final String name;
  final String email;
  final String avatarUrl;
  final String role;

  User({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.role,
  });
}

// Dynamic content provider
final dashboardContentProvider = Provider((ref) {
  final currentPage = ref.watch(currentPageProvider);

  switch (currentPage) {
    case 'Dashboard':
      return DashboardContent(
        title: 'Dashboard Overview',
        stats: [
          StatCard(
            title: 'Total Users',
            value: '3,456',
            icon: Icons.people,
            color: Colors.blue,
          ),
          StatCard(
            title: 'Revenue',
            value: '\$23,489',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
          StatCard(
            title: 'Tasks',
            value: '67',
            icon: Icons.task_alt,
            color: Colors.orange,
          ),
          StatCard(
            title: 'Messages',
            value: '24',
            icon: Icons.message,
            color: Colors.purple,
          ),
        ],
      );
    case 'Analytics':
      return DashboardContent(
        title: 'Analytics',
        stats: [
          StatCard(
            title: 'Page Views',
            value: '12,456',
            icon: Icons.visibility,
            color: Colors.indigo,
          ),
          StatCard(
            title: 'Bounce Rate',
            value: '32%',
            icon: Icons.trending_down,
            color: Colors.red,
          ),
          StatCard(
            title: 'Avg. Time',
            value: '2m 34s',
            icon: Icons.timer,
            color: Colors.teal,
          ),
          StatCard(
            title: 'Conversions',
            value: '534',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ],
      );
    case 'Orders':
      return DashboardContent(
        title: 'Orders Management',
        stats: [
          StatCard(
            title: 'New Orders',
            value: '34',
            icon: Icons.shopping_cart,
            color: Colors.amber,
          ),
          StatCard(
            title: 'Processing',
            value: '12',
            icon: Icons.hourglass_bottom,
            color: Colors.blue,
          ),
          StatCard(
            title: 'Shipped',
            value: '78',
            icon: Icons.local_shipping,
            color: Colors.green,
          ),
          StatCard(
            title: 'Returned',
            value: '5',
            icon: Icons.assignment_return,
            color: Colors.red,
          ),
        ],
      );
    default:
      return DashboardContent(
        title: currentPage,
        stats: [
          StatCard(
            title: 'Sample Stat',
            value: '100',
            icon: Icons.star,
            color: Colors.amber,
          ),
          StatCard(
            title: 'Sample Stat',
            value: '200',
            icon: Icons.star,
            color: Colors.blue,
          ),
          StatCard(
            title: 'Sample Stat',
            value: '300',
            icon: Icons.star,
            color: Colors.green,
          ),
          StatCard(
            title: 'Sample Stat',
            value: '400',
            icon: Icons.star,
            color: Colors.purple,
          ),
        ],
      );
  }
});

// Dashboard content model
class DashboardContent {
  final String title;
  final List<StatCard> stats;

  DashboardContent({required this.title, required this.stats});
}

// Stat card model
class StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

// screens/dashboard_screen.dart
/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/app_header.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_footer.dart';
import '../widgets/dashboard_content.dart'; */

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarMode = ref.watch(sidebarModeProvider);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Conditionally show sidebar based on mode
            if (sidebarMode != SidebarMode.hidden) const AppSidebar(),

            // Main content
            Expanded(
              child: Column(
                children: [
                  // Header
                  const AppHeader1(),

                  // Dynamic content
                  const Expanded(child: DashboardContentWidget()),

                  // Footer
                  const AppFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
      // Drawer for mobile view
      drawer:
          MediaQuery.of(context).size.width < 600
              ? const Drawer(child: AppSidebar(isDrawer: true))
              : null,
    );
  }
}

// widgets/app_header.dart
/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart'; */

class AppHeader1 extends ConsumerWidget {
  const AppHeader1({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final currentPage = ref.watch(currentPageProvider);
    final sidebarMode = ref.watch(sidebarModeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mobile drawer toggle
          if (MediaQuery.of(context).size.width < 600)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),

          // Desktop sidebar toggle
          if (MediaQuery.of(context).size.width >= 600)
            IconButton(
              icon: Icon(
                sidebarMode == SidebarMode.expanded
                    ? Icons.menu_open
                    : sidebarMode == SidebarMode.compact
                    ? Icons.menu
                    : Icons.menu,
              ),
              onPressed: () {
                ref
                    .read(sidebarModeProvider.notifier)
                    .state = switch (sidebarMode) {
                  SidebarMode.expanded => SidebarMode.compact,
                  SidebarMode.compact => SidebarMode.hidden,
                  SidebarMode.hidden => SidebarMode.expanded,
                };
              },
            ),

          // Page title
          Expanded(
            child: Text(
              currentPage,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          // Search
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),

          // Notifications
          Badge(
            label: const Text('3'),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ),

          // Theme toggle
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_round,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
          ),

          const SizedBox(width: 8),

          // User profile
          PopupMenuButton(
            offset: const Offset(0, 40),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(user.avatarUrl),
                ),
                if (MediaQuery.of(context).size.width > 600) ...[
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.role,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// widgets/app_sidebar.dart

class AppSidebar extends ConsumerWidget {
  final bool isDrawer;

  const AppSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final sidebarMode = ref.watch(sidebarModeProvider);
    final isCompact = sidebarMode == SidebarMode.compact && !isDrawer;

    final menuItems = [
      MenuItem(title: 'Dashboard', icon: Icons.dashboard_outlined),
      MenuItem(title: 'Analytics', icon: Icons.analytics_outlined),
      MenuItem(title: 'Orders', icon: Icons.shopping_cart_outlined),
      MenuItem(title: 'Products', icon: Icons.inventory_2_outlined),
      MenuItem(title: 'Customers', icon: Icons.people_outline),
      MenuItem(title: 'Marketing', icon: Icons.campaign_outlined),
      MenuItem(title: 'Reports', icon: Icons.bar_chart_outlined),
      MenuItem(title: 'Settings', icon: Icons.settings_outlined),
    ];

    return Container(
      width: isCompact ? 70 : 260,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Logo area
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 12),
                  Text(
                    'AdminPro',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final item in menuItems)
                  _buildMenuItem(
                    context,
                    item,
                    isSelected: item.title == currentPage,
                    isCompact: isCompact,
                    onTap: () {
                      ref.read(currentPageProvider.notifier).state = item.title;
                      // Close drawer if this is in drawer mode
                      if (isDrawer) {
                        Navigator.pop(context);
                      }
                    },
                  ),
              ],
            ),
          ),

          // Bottom section with version and help
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child:
                isCompact
                    ? IconButton(
                      icon: const Icon(Icons.help_outline),
                      onPressed: () {},
                    )
                    : Row(
                      children: [
                        Text(
                          'v1.0.0',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.help_outline, size: 16),
                          label: const Text('Help'),
                          onPressed: () {},
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    MenuItem item, {
    required bool isSelected,
    required bool isCompact,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          margin: EdgeInsets.symmetric(
            vertical: 2,
            horizontal: isCompact ? 8 : 16,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 24,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
              ),
              if (!isCompact) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (item.title == 'Dashboard' ||
                    item.title == 'Analytics' ||
                    item.title == 'Orders')
                  Badge(
                    label: Text(
                      item.title == 'Orders'
                          ? '34'
                          : item.title == 'Analytics'
                          ? '7'
                          : '5',
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;

  MenuItem({required this.title, required this.icon});
}

// widgets/app_footer.dart

class AppFooter extends ConsumerWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '© 2025 AdminPro. All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          if (MediaQuery.of(context).size.width > 600) ...[
            TextButton(onPressed: () {}, child: const Text('Privacy Policy')),
            TextButton(onPressed: () {}, child: const Text('Terms of Service')),
          ],
          IconButton(
            icon: const Icon(Icons.support_agent, size: 20),
            onPressed: () {},
            tooltip: 'Contact Support',
          ),
        ],
      ),
    );
  }
}

// widgets/dashboard_content.dart

class DashboardContentWidget extends ConsumerWidget {
  const DashboardContentWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(dashboardContentProvider);
    final currentPage = ref.watch(currentPageProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content.title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Stats cards grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.of(context).size.width < 600
                      ? 1
                      : MediaQuery.of(context).size.width < 900
                      ? 2
                      : 4,
              childAspectRatio: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: content.stats.length,
            itemBuilder: (context, index) {
              final stat = content.stats[index];
              return StatCardWidget(stat: stat);
            },
          ),

          const SizedBox(height: 24),

          // Charts and tables based on current page
          if (currentPage == 'Dashboard') ...[
            _buildChartSection(context),
            const SizedBox(height: 24),
            _buildRecentActivitySection(context),
          ],

          if (currentPage == 'Analytics') ...[_buildAnalyticsSection(context)],

          if (currentPage == 'Orders') ...[_buildOrdersSection(context)],

          // Default content for other pages
          if (currentPage != 'Dashboard' &&
              currentPage != 'Analytics' &&
              currentPage != 'Orders') ...[
            _buildDefaultSection(context, currentPage),
          ],
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Performance Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'week', label: Text('Week')),
                ButtonSegment(value: 'month', label: Text('Month')),
                ButtonSegment(value: 'year', label: Text('Year')),
              ],
              selected: {'month'},
              onSelectionChanged: (value) {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
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
                      const titles = [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec',
                      ];
                      final index = value.toInt();
                      if (index >= 0 && index < titles.length) {
                        return Text(titles[index]);
                      }
                      return const Text('');
                    },
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 42),
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
              maxX: 11,
              minY: 0,
              maxY: 6,
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 3),
                    FlSpot(1, 2.5),
                    FlSpot(2, 3.5),
                    FlSpot(3, 3.2),
                    FlSpot(4, 4.1),
                    FlSpot(5, 3.8),
                    FlSpot(6, 4.5),
                    FlSpot(7, 4.2),
                    FlSpot(8, 5),
                    FlSpot(9, 4.8),
                    FlSpot(10, 5.2),
                    FlSpot(11, 5.5),
                  ],
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
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 1.8),
                    FlSpot(1, 2.1),
                    FlSpot(2, 2.3),
                    FlSpot(3, 2.0),
                    FlSpot(4, 2.5),
                    FlSpot(5, 2.2),
                    FlSpot(6, 2.8),
                    FlSpot(7, 3.0),
                    FlSpot(8, 3.5),
                    FlSpot(9, 3.2),
                    FlSpot(10, 3.8),
                    FlSpot(11, 4.0),
                  ],
                  isCurved: true,
                  color: Theme.of(context).colorScheme.tertiary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 200,
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
                      'User Demographics',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: 35,
                              title: '35%',
                              color: Colors.blue,
                              radius: 50,
                            ),
                            PieChartSectionData(
                              value: 25,
                              title: '25%',
                              color: Colors.green,
                              radius: 50,
                            ),
                            PieChartSectionData(
                              value: 20,
                              title: '20%',
                              color: Colors.amber,
                              radius: 50,
                            ),
                            PieChartSectionData(
                              value: 20,
                              title: '20%',
                              color: Colors.red,
                              radius: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 200,
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
                      'Traffic Sources',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 20,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              //tooltipBgColor:
                              //  Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const titles = [
                                    'Direct',
                                    'Social',
                                    'Organic',
                                    'Referral',
                                  ];
                                  final index = value.toInt();
                                  if (index >= 0 && index < titles.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        titles[index],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                                reservedSize: 30,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: 12.5,
                                  color: Colors.blueAccent,
                                  width: 16,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: 8.2,
                                  color: Colors.purpleAccent,
                                  width: 16,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 2,
                              barRods: [
                                BarChartRodData(
                                  toY: 15.8,
                                  color: Colors.greenAccent,
                                  width: 16,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 3,
                              barRods: [
                                BarChartRodData(
                                  toY: 6.4,
                                  color: Colors.orangeAccent,
                                  width: 16,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            FilledButton.tonal(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 16),
        Container(
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
            children: [
              for (var i = 0; i < 5; i++)
                _buildActivityItem(
                  context,
                  date: 'Mar ${15 - i}, 2025',
                  title:
                      i == 0
                          ? 'New user registered'
                          : i == 1
                          ? 'Order #2458 completed'
                          : i == 2
                          ? 'Payment received'
                          : i == 3
                          ? 'New product added'
                          : 'Customer feedback received',
                  description:
                      i == 0
                          ? 'John Smith created a new account'
                          : i == 1
                          ? 'Order was delivered and marked as completed'
                          : i == 2
                          ? 'Payment of \$1,250 was received for invoice #INV-2023'
                          : i == 3
                          ? 'Admin added a new product "Wireless Earbuds"'
                          : 'Alex Johnson left a 5-star review',
                  icon:
                      i == 0
                          ? Icons.person_add_outlined
                          : i == 1
                          ? Icons.check_circle_outline
                          : i == 2
                          ? Icons.payments_outlined
                          : i == 3
                          ? Icons.add_box_outlined
                          : Icons.star_border,
                  color:
                      i == 0
                          ? Colors.green
                          : i == 1
                          ? Colors.blue
                          : i == 2
                          ? Colors.purple
                          : i == 3
                          ? Colors.orange
                          : Colors.amber,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String date,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(date, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
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

  Widget _buildOrdersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Orders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            FilledButton(onPressed: () {}, child: const Text('Create Order')),
          ],
        ),
        const SizedBox(height: 16),
        Container(
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
              // Filter and search row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search orders...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  PopupMenuButton(
                    initialValue: 'all',
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'all',
                            child: Text('All Orders'),
                          ),
                          const PopupMenuItem(
                            value: 'pending',
                            child: Text('Pending'),
                          ),
                          const PopupMenuItem(
                            value: 'processing',
                            child: Text('Processing'),
                          ),
                          const PopupMenuItem(
                            value: 'shipped',
                            child: Text('Shipped'),
                          ),
                          const PopupMenuItem(
                            value: 'delivered',
                            child: Text('Delivered'),
                          ),
                          const PopupMenuItem(
                            value: 'cancelled',
                            child: Text('Cancelled'),
                          ),
                        ],
                    onSelected: (value) {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Text('All Orders'),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Orders table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Order ID')),
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        DataCell(Text('#ORD-2458')),
                        DataCell(Text('John Smith')),
                        DataCell(Text('Mar 15, 2025')),
                        DataCell(Text('\$534.25')),
                        DataCell(
                          Chip(
                            label: Text('Delivered'),
                            backgroundColor: Colors.green,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.visibility_outlined),
                                onPressed: null,
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_outlined),
                                onPressed: null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text('#ORD-2457')),
                        DataCell(Text('Emma Johnson')),
                        DataCell(Text('Mar 14, 2025')),
                        DataCell(Text('\$289.99')),
                        DataCell(
                          Chip(
                            label: Text('Processing'),
                            backgroundColor: Colors.blue,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.visibility_outlined),
                                onPressed: null,
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_outlined),
                                onPressed: null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text('#ORD-2456')),
                        DataCell(Text('Alex Wong')),
                        DataCell(Text('Mar 14, 2025')),
                        DataCell(Text('\$892.50')),
                        DataCell(
                          Chip(
                            label: Text('Shipped'),
                            backgroundColor: Colors.orange,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.visibility_outlined),
                                onPressed: null,
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_outlined),
                                onPressed: null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text('#ORD-2455')),
                        DataCell(Text('Sarah Miller')),
                        DataCell(Text('Mar 13, 2025')),
                        DataCell(Text('\$129.00')),
                        DataCell(
                          Chip(
                            label: Text('Pending'),
                            backgroundColor: Colors.amber,
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.visibility_outlined),
                                onPressed: null,
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_outlined),
                                onPressed: null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text('#ORD-2454')),
                        DataCell(Text('David Lee')),
                        DataCell(Text('Mar 12, 2025')),
                        DataCell(Text('\$345.75')),
                        DataCell(
                          Chip(
                            label: Text('Cancelled'),
                            backgroundColor: Colors.red,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.visibility_outlined),
                                onPressed: null,
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_outlined),
                                onPressed: null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Pagination
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Showing 1-5 of 34 items',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {},
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('2'),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('3'),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('...'),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('7'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {},
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultSection(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
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
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.construction,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  "$title Content",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  "This section is under construction. Content for $title will be available soon.",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text("Learn More"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StatCardWidget extends StatelessWidget {
  final StatCard stat;

  const StatCardWidget({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, color: stat.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(stat.title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 4),
                Text(
                  stat.value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add support for notifications with a NotificationService
class NotificationService {
  //static const String _storageKey = 'admin_notifications';

  final notifications = <AdminNotification>[
    AdminNotification(
      id: '1',
      title: 'New order received',
      message: 'Order #2458 was placed by John Smith.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: NotificationType.order,
      isRead: false,
    ),
    AdminNotification(
      id: '2',
      title: 'Payment successful',
      message: 'Payment of \$534.25 received for order #2457.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      type: NotificationType.payment,
      isRead: false,
    ),
    AdminNotification(
      id: '3',
      title: 'Low inventory alert',
      message: 'Product "Wireless Earbuds" has low inventory (3 remaining).',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotificationType.inventory,
      isRead: true,
    ),
    AdminNotification(
      id: '4',
      title: 'New user registered',
      message: 'Emma Johnson created a new account.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.user,
      isRead: true,
    ),
  ];

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = notifications.indexWhere(
      (notification) => notification.id == id,
    );
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      _saveNotifications();
    }
  }

  void markAllAsRead() {
    notifications.asMap().forEach((index, notification) {
      notifications[index] = notification.copyWith(isRead: true);
    });
    _saveNotifications();
  }

  void addNotification(AdminNotification notification) {
    notifications.insert(0, notification);
    _saveNotifications();
  }

  void removeNotification(String id) {
    notifications.removeWhere((notification) => notification.id == id);
    _saveNotifications();
  }

  void _saveNotifications() {
    // In a real app, this would save to local storage or a database
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setString(_storageKey, jsonEncode(notifications.map((n) => n.toJson()).toList()));
    // });
  }
}

// Notification model
class AdminNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  const AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.isRead,
  });

  AdminNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
  }) {
    return AdminNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'isRead': isRead,
    };
  }

  static AdminNotification fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      type: NotificationType.values.firstWhere(
        (t) => t.toString() == json['type'],
        orElse: () => NotificationType.general,
      ),
      isRead: json['isRead'],
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_cart_outlined;
      case NotificationType.payment:
        return Icons.payments_outlined;
      case NotificationType.inventory:
        return Icons.inventory_2_outlined;
      case NotificationType.user:
        return Icons.person_outline;
      case NotificationType.general:
      default:
        return Icons.notifications_outlined;
    }
  }

  Color getColor(BuildContext context) {
    switch (type) {
      case NotificationType.order:
        return Colors.blue;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.inventory:
        return Colors.orange;
      case NotificationType.user:
        return Colors.purple;
      case NotificationType.general:
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

enum NotificationType {
  order,
  payment,
  inventory,
  user,
  general,
  success,
  warning,
  error,
  info,
}

// Add NotificationProvider to app_providers.dart
final notificationServiceProvider = Provider((ref) => NotificationService());

final notificationsProvider = Provider((ref) {
  return ref.watch(notificationServiceProvider).notifications;
});

final unreadNotificationsCountProvider = Provider((ref) {
  return ref.watch(notificationServiceProvider).unreadCount;
});

// Create a notification center widget
class NotificationCenter extends ConsumerWidget {
  const NotificationCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final notificationService = ref.watch(notificationServiceProvider);

    return Container(
      width: 320,
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => notificationService.markAllAsRead(),
                  child: const Text('Mark all as read'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Notification list
          notifications.isEmpty
              ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'re all caught up!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
              : Flexible(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationTile(
                      notification: notification,
                      onTap:
                          () => notificationService.markAsRead(notification.id),
                      onDismiss:
                          () => notificationService.removeNotification(
                            notification.id,
                          ),
                    );
                  },
                ),
              ),

          // Footer
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('View All Notifications'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final AdminNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color:
              notification.isRead
                  ? null
                  : Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(
                    notification.type,
                  ).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight:
                            notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimeAgo(notification.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),

              // Status indicator
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6, left: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.info:
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.info:
      default:
        return Icons.info_outline;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Responsive layout management
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop;
        } else if (constraints.maxWidth >= 650) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}

// Theme mode provider
//final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Main theme data
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: const Color(0xFF2563EB),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: const Color(0xFF3B82F6),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
  );
}

// Sidebar state provider
final sidebarExpandedProvider = StateProvider<bool>((ref) => true);

// Main layout for Admin screens
class AdminLayout extends ConsumerWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const AdminLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isMobile = ResponsiveLayout.isMobile(context);
    final bool isTablet = ResponsiveLayout.isTablet(context);
    final bool isSidebarExpanded = ref.watch(sidebarExpandedProvider);

    return Scaffold(
      drawer: isMobile ? const AppSidebar(isDrawer: true) : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sidebar for tablet and desktop
            if (!isMobile)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSidebarExpanded ? 250 : 70,
                child: const AppSidebar(isDrawer: false),
              ),

            // Main content area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  AppHeader(
                    title: title,
                    actions: actions,
                    showMenuButton: isMobile,
                    onMenuPressed:
                        isMobile
                            ? () => Scaffold.of(context).openDrawer()
                            : () =>
                                ref
                                    .read(sidebarExpandedProvider.notifier)
                                    .state = !isSidebarExpanded,
                  ),

                  // Main content
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 16 : 24),
                      child: child,
                    ),
                  ),

                  // Footer
                  const AppFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// App Header implementation
class AppHeader extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.showMenuButton = false,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showMenuButton)
            IconButton(icon: const Icon(Icons.menu), onPressed: onMenuPressed),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          ...?actions,
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          const SizedBox(width: 8),
          _buildNotificationButton(context),
          const SizedBox(width: 8),
          _buildProfileMenu(context),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return PopupMenuButton(
      offset: const Offset(0, 16),
      position: PopupMenuPosition.under,
      tooltip: 'Notifications',
      icon: Badge(
        label: const Text('3'),
        child: const Icon(Icons.notifications_outlined),
      ),
      itemBuilder: (_) => [],
      child: const SizedBox(),
      onOpened: () {
        // Show notification center
        // This is handled separately via an overlay
      },
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 16), // Position the menu below the avatar
      position:
          PopupMenuPosition.under, // Ensure the menu appears below the button
      icon: const CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(
          'https://i.pravatar.cc/300',
        ), // Placeholder avatar image
      ),
      itemBuilder:
          (context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: const [
                  Icon(Icons.person_outline), // Profile icon
                  SizedBox(width: 8), // Spacing between icon and text
                  Text('Profile'), // Profile text
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'settings',
              child: Row(
                children: const [
                  Icon(Icons.settings_outlined), // Settings icon
                  SizedBox(width: 8), // Spacing between icon and text
                  Text('Settings'), // Settings text
                ],
              ),
            ),
            const PopupMenuDivider(), // Divider between settings and logout (no type argument needed)
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: const [
                  Icon(Icons.logout), // Logout icon
                  SizedBox(width: 8), // Spacing between icon and text
                  Text('Logout'), // Logout text
                ],
              ),
            ),
          ],
      onSelected: (value) {
        // Handle menu selection based on the selected value
        switch (value) {
          case 'profile':
            // Navigate to the profile screen or perform an action
            print('Profile selected');
            break;
          case 'settings':
            // Navigate to the settings screen or perform an action
            print('Settings selected');
            break;
          case 'logout':
            // Perform logout action
            print('Logout selected');
            break;
          default:
            break;
        }
      },
    );
  }
}

// App Footer implementation
class AppFooter2 extends StatelessWidget {
  const AppFooter2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ResponsiveLayout(
        mobile: const Column(
          children: [
            Text('© 2025 AdminApp. All rights reserved.'),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Terms of Service'),
                SizedBox(width: 16),
                Text('Privacy Policy'),
              ],
            ),
          ],
        ),
        tablet: const Row(
          children: [
            Text('© 2025 AdminApp. All rights reserved.'),
            Spacer(),
            Text('Terms of Service'),
            SizedBox(width: 16),
            Text('Privacy Policy'),
          ],
        ),
        desktop: Row(
          children: [
            const Text('© 2025 AdminApp. All rights reserved.'),
            const Spacer(),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook, size: 20),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.alternate_email, size: 20),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(width: 24),
            const Text('Terms of Service'),
            const SizedBox(width: 16),
            const Text('Privacy Policy'),
          ],
        ),
      ),
    );
  }
}

// Sidebar implementation
class AppSidebar2 extends ConsumerWidget {
  final bool isDrawer;

  const AppSidebar2({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSidebarExpanded = ref.watch(sidebarExpandedProvider);
    final currentRoute = ref.watch(currentRouteProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      height: double.infinity,
      child: Column(
        children: [
          // Logo and title
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.dashboard,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (isSidebarExpanded || isDrawer) ...[
                  const SizedBox(width: 16),
                  Text(
                    'AdminApp',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
                const Spacer(),
                if (!isDrawer && isSidebarExpanded)
                  IconButton(
                    icon: const Icon(Icons.keyboard_double_arrow_left),
                    onPressed:
                        () =>
                            ref.read(sidebarExpandedProvider.notifier).state =
                                false,
                  ),
                if (!isDrawer && !isSidebarExpanded)
                  IconButton(
                    icon: const Icon(Icons.keyboard_double_arrow_right),
                    onPressed:
                        () =>
                            ref.read(sidebarExpandedProvider.notifier).state =
                                true,
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Menu items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Dashboard
                  /*  MenuItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    isExpanded: isSidebarExpanded || isDrawer,
                    isActive: currentRoute == '/dashboard',
                    onTap: () => _navigateTo(context, '/dashboard'),
                  ),
                   */
                  // Analytics with submenu
                  MenuItemWithSubmenu(
                    icon: Icons.analytics_outlined,
                    title: 'Analytics',
                    isExpanded: isSidebarExpanded || isDrawer,
                    isActive: currentRoute.startsWith('/analytics'),
                    children: [
                      SubmenuItem(
                        title: 'Overview',
                        isActive: currentRoute == '/analytics/overview',
                        onTap:
                            () => _navigateTo(context, '/analytics/overview'),
                      ),
                      SubmenuItem(
                        title: 'Reports',
                        isActive: currentRoute == '/analytics/reports',
                        onTap: () => _navigateTo(context, '/analytics/reports'),
                      ),
                      SubmenuItem(
                        title: 'Real-time',
                        isActive: currentRoute == '/analytics/real-time',
                        onTap:
                            () => _navigateTo(context, '/analytics/real-time'),
                      ),
                    ],
                  ),

                  // User Management
                  /* MenuItem(
                    icon: Icons.people_outline,
                    title: 'Users',
                    isExpanded: isSidebarExpanded || isDrawer,
                    isActive: currentRoute == '/users',
                    onTap: () => _navigateTo(context, '/users'),
                  ), */

                  // Content Management
                  MenuItemWithSubmenu(
                    icon: Icons.article_outlined,
                    title: 'Content',
                    isExpanded: isSidebarExpanded || isDrawer,
                    isActive: currentRoute.startsWith('/content'),
                    children: [
                      SubmenuItem(
                        title: 'Pages',
                        isActive: currentRoute == '/content/pages',
                        onTap: () => _navigateTo(context, '/content/pages'),
                      ),
                      SubmenuItem(
                        title: 'Blog Posts',
                        isActive: currentRoute == '/content/posts',
                        onTap: () => _navigateTo(context, '/content/posts'),
                      ),
                      SubmenuItem(
                        title: 'Media',
                        isActive: currentRoute == '/content/media',
                        onTap: () => _navigateTo(context, '/content/media'),
                      ),
                    ],
                  ),

                  // Products
                  /* MenuItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Products',
                    isExpanded: isSidebarExpanded || isDrawer,
                    isActive: currentRoute == '/products',
                    onTap: () => _navigateTo(context, '/products'),
                  ),
                  
                  // Orders
                  MenuItem(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Orders',
                    isExpanded: isSidebarExpanded || isDrawer,
                    isActive: currentRoute == '/orders',
                    onTap: () => _navigateTo(context, '/orders'),
                    badge: '12',
                  ), */

                  // Divider
                  if (isSidebarExpanded || isDrawer)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(),
                    ),
                  if (!isSidebarExpanded && !isDrawer)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(indent: 16, endIndent: 16),
                    ),

                  // Settings
                  /* MenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    isExpanded: isSidebarExpanded || isDrawer,
                    isActive: currentRoute == '/settings',
                    onTap: () => _navigateTo(context, '/settings'),
                  ),
                  
                  // Help
                  MenuItem(
                    icon: Icons.help_outline,
                    title: 'Help',
                    isExpanded: isSidebarExpanded || isDrawer,
                    isActive: currentRoute == '/help',
                    onTap: () => _navigateTo(context, '/help'),
                  ), */
                ],
              ),
            ),
          ),

          // User profile section at bottom
          const Divider(height: 1),
          if (isSidebarExpanded || isDrawer)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'John Doe',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          'Administrator',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          if (!isSidebarExpanded && !isDrawer)
            Container(
              padding: const EdgeInsets.all(16),
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    if (isDrawer) {
      Navigator.of(context).pop();
    }
    // Navigate to the route
  }
}

// Menu Item Widget
/* class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onTap;
  final String? badge;
  
  const MenuItem({
    Key? key,
    required this.icon,
    required this.title,
    this.isActive = false,
    this.isExpanded = true,
    required this.onTap,
    this.badge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
 */
// Menu Item with Submenu
class MenuItemWithSubmenu extends ConsumerStatefulWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final bool isExpanded;
  final List<SubmenuItem> children;

  const MenuItemWithSubmenu({
    super.key,
    required this.icon,
    required this.title,
    this.isActive = false,
    this.isExpanded = true,
    required this.children,
  });

  @override
  ConsumerState<MenuItemWithSubmenu> createState() =>
      _MenuItemWithSubmenuState();
}

class _MenuItemWithSubmenuState extends ConsumerState<MenuItemWithSubmenu> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSidebarExpanded = ref.watch(sidebarExpandedProvider);

    return Column(
      children: [
        InkWell(
          onTap: () {
            if (widget.isExpanded) {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            }
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color:
                  widget.isActive
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color:
                      widget.isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                ),
                if (widget.isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color:
                            widget.isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            widget.isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_isExpanded && (widget.isExpanded || !isSidebarExpanded))
          Padding(
            padding: EdgeInsets.only(left: widget.isExpanded ? 30 : 0),
            child: Column(children: widget.children),
          ),
      ],
    );
  }
}

// Submenu Item
class SubmenuItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const SubmenuItem({
    super.key,
    required this.title,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color:
              isActive ? Theme.of(context).colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        child: Row(
          children: [
            Icon(
              Icons.circle,
              size: 8,
              color:
                  isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Current route provider
final currentRouteProvider = StateProvider<String>((ref) => '/dashboard');

// Main Dashboard Content
/* class DashboardContent2 extends ConsumerWidget {
  const DashboardContent2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }
  
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildStatCardsSection(isMobile: true),
          const SizedBox(height: 24),
          _buildRecentActivitySection(),
          const SizedBox(height: 24),
          _buildSalesChartSection(),
          const SizedBox(height: 24),
          _buildLatestTransactions(),
        ],
      ),
    );
  }
  
  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildStatCardsSection(isMobile: false),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildSalesChartSection(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: _buildRecentActivitySection(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildLatestTransactions(),
        ],
      ),
    );
  }
  
  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildStatCardsSection(isMobile: false),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(  */
