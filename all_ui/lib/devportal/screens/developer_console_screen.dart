import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/provider.dart';
import '../widgets/analytic_tab.dart';
import '../widgets/api_key_tab.dart';
import '../widgets/dashboard_tab.dart';
import '../widgets/project_tab.dart';
import '../widgets/settings_tab.dart';

class DeveloperConsoleScreen extends ConsumerWidget {
  const DeveloperConsoleScreen({super.key});

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
            backgroundColor:
                isDarkMode ? const Color(0xFF1E1E2D) : const Color(0xFFF8F9FC),
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
                    color: isDarkMode ? const Color(0xFF2D2D42) : Colors.white,
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
                          color:
                              isDarkMode
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
                          color:
                              isDarkMode
                                  ? const Color(0xFF1E1E2D)
                                  : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white30
                                            : Colors.black38,
                                  ),
                                ),
                                style: TextStyle(
                                  color:
                                      isDarkMode
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
                Expanded(child: _buildTabContent(selectedTab, ref, isDarkMode)),
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
        return AnalyticsTab();
      case 4:
        return SettingsTab();
      default:
        return const Center(child: Text('Unknown Tab'));
    }
  }
}
