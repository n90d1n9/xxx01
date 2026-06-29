import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/providers.dart';
import '../widgets/create_topic_dialog.dart';
import 'broker_screen.dart';
import 'monitor_screen.dart';
import 'overview_screen.dart';
import 'setup_screen.dart';
import 'topic_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(endpointConfigProvider);
    final clustersAsync = ref.watch(clustersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kafka Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SetupScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 1200,
            minExtendedWidth: 200,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.topic),
                label: Text('Topics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.computer),
                label: Text('Brokers'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.insights),
                label: Text('Monitoring'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: clustersAsync.when(
              data: (clusters) {
                if (clusters.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Kafka clusters found. Check your API configuration.',
                    ),
                  );
                }

                // Auto-select the first cluster if none is selected
                if (ref.read(selectedClusterIdProvider) == null &&
                    clusters.isNotEmpty) {
                  ref.read(selectedClusterIdProvider.notifier).state =
                      clusters.first.id;
                }

                // Different screens based on the selected index
                switch (_selectedIndex) {
                  case 0:
                    return OverviewScreen(clusters: clusters);
                  case 1:
                    return const TopicsScreen();
                  case 2:
                    return const BrokersScreen();
                  case 3:
                    return const MonitoringScreen();
                  default:
                    return const Center(child: Text('Unknown screen'));
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stackTrace) => Center(
                    child: Text('Error loading clusters: ${error.toString()}'),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 1
              ? FloatingActionButton(
                onPressed: () {
                  _showCreateTopicDialog(context);
                },
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  void _showCreateTopicDialog(BuildContext context) {
    final clusterId = ref.read(selectedClusterIdProvider);
    if (clusterId == null) return;

    showDialog(
      context: context,
      builder: (context) => CreateTopicDialog(clusterId: clusterId),
    );
  }
}
