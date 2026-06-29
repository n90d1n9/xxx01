import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Console State Providers

// StatusBadge widget for displaying project status


// ApiKeyStatusBadge widget for displaying API key status


// AlertCard widget for displaying system alerts


// Enums

// Model for Alerts


// Main Console Screen


// Dashboard Tab


// Projects Tab


// API Keys Tab




// Models for Analytics data



// Providers and Controllers




// ApiUsageData class to represent API usage metrics


// Alerts tab for displaying system notifications and alerts


// Settings tab for configuring developer portal settings


// DocumentationTab for API documentation


// SupportTab for providing help and support resources

// UserProfile widget for displaying and editing user information


// Main navigation structure with all tabs
class MainNavigationWidget extends ConsumerWidget {
  const MainNavigationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      appBar:
          selectedTab == 'profile'
              ? null
              : AppBar(
                title: const Text('Developer Console'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      ref.read(selectedTabProvider.notifier).state =
                          0; //'alerts';
                    },
                    tooltip: 'Notifications',
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=12',
                    ),
                    child: Material(
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ref.read(selectedTabProvider.notifier).state = 0;
                          //'profile';
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
      body: _buildBody('selectedTab', ref),
      bottomNavigationBar:
          selectedTab == 'profile'
              ? null
              : NavigationBar(
                selectedIndex: _getNavIndex('selectedTab'),
                onDestinationSelected: (index) {
                  ref.read(selectedTabProvider.notifier).state = 0;
                  //_getTabName(0);
                  /* index,
                  ); */
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.folder_outlined),
                    selectedIcon: Icon(Icons.folder),
                    label: 'Projects',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.vpn_key_outlined),
                    selectedIcon: Icon(Icons.vpn_key),
                    label: 'API Keys',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.analytics_outlined),
                    selectedIcon: Icon(Icons.analytics),
                    label: 'Analytics',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book),
                    label: 'Docs',
                  ),
                ],
              ),
    );
  }

  Widget _buildBody(String tab, WidgetRef ref) {
    switch (tab) {
      case 'dashboard':
        return const DashboardTab(isDarkMode: false);
      case 'projects':
        return const ProjectsTab(isDarkMode: false);
      case 'apikeys':
        return const ApiKeysTab(isDarkMode: false);
      case 'analytics':
        return const AnalyticsTab();
      case 'alerts':
        return const AlertsTab();
      case 'docs':
        return const DocumentationTab();
      case 'settings':
        return const SettingsTab();
      case 'support':
        return const SupportTab();
      case 'profile':
        return const UserProfile();
      default:
        return const DashboardTab(isDarkMode: false);
    }
  }

  int _getNavIndex(String tab) {
    switch (tab) {
      case 'dashboard':
        return 0;
      case 'projects':
        return 1;
      case 'apikeys':
        return 2;
      case 'analytics':
        return 3;
      case 'docs':
        return 4;
      default:
        return 0;
    }
  }

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'dashboard';
      case 1:
        return 'projects';
      case 2:
        return 'apikeys';
      case 3:
        return 'analytics';
      case 4:
        return 'docs';
      default:
        return 'dashboard';
    }
  }
}
