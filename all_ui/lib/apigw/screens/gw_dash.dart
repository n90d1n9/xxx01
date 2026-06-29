import 'package:flutter/material.dart';

import '../widgets/dash_view.dart';
import '../widgets/load_balance/lb_view.dart';
import '../widgets/protocol_support_view.dart';
import '../widgets/settings_view.dart';
import '../widgets/traffic_control_view.dart';

class GWDashboard extends StatefulWidget {
  const GWDashboard({super.key});

  @override
  State<GWDashboard> createState() => _GWDashboardState();
}

class _GWDashboardState extends State<GWDashboard>
    with SingleTickerProviderStateMixin {
  final tabs = [
    'Dashboard',
    'Load Balancing',
    'Traffic Control',
    'Protocols',
    'Settings',
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Side Navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: Column(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.api_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Iket ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: Text(tabs[0]),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.balance_outlined),
                selectedIcon: const Icon(Icons.balance),
                label: Text(tabs[1]),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.shuffle_outlined),
                selectedIcon: const Icon(Icons.shuffle),
                label: Text(tabs[2]),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_ethernet_outlined),
                selectedIcon: const Icon(Icons.settings_ethernet),
                label: Text(tabs[3]),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: Text(tabs[4]),
              ),
            ],
          ),

          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  const DashboardView(),
                  const LoadBalancingView(),
                  const TrafficControlView(),
                  const ProtocolSupportView(),
                  const SettingsView(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
