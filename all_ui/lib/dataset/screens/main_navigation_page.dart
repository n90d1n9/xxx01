import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/provider.dart';
import 'pipeline_page.dart';
import 'cot_page.dart';
import 'dashboard_page.dart';
import 'data_prepocessing_page.dart';
import 'deployment_page.dart';
import 'evaluation_page.dart';
import 'experiment_page.dart';
import 'mlops_page.dart';
import 'model_registry_page.dart';
import 'training_config_page.dart';

class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedTab,
            onDestinationSelected: (index) {
              ref.read(selectedTabProvider.notifier).state = index;
            },
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Icon(
                    Icons.smart_toy,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Wayang Academy',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_tree_outlined),
                selectedIcon: Icon(Icons.account_tree),
                label: Text('Pipelines'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.storage_outlined),
                selectedIcon: Icon(Icons.storage),
                label: Text('Data Prep'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.model_training_outlined),
                selectedIcon: Icon(Icons.model_training),
                label: Text('Training'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assessment_outlined),
                selectedIcon: Icon(Icons.assessment),
                label: Text('Evaluation'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.rocket_launch_outlined),
                selectedIcon: Icon(Icons.rocket_launch),
                label: Text('Deployment'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: Text('Models'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.science_outlined),
                selectedIcon: Icon(Icons.science),
                label: Text('Experiments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.psychology_outlined),
                selectedIcon: Icon(Icons.psychology),
                label: Text('CoT/Reasoning'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('MLOps'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: selectedTab,
              children: const [
                DashboardPage(),
                PipelinesPage(),
                DataPreparationPage(),
                TrainingConfigPage(),
                EvaluationPage(),
                DeploymentPage(),
                ModelRegistryPage(),
                ExperimentsPage(),
                ChainOfThoughtPage(),
                MLOpsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
