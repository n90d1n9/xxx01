import 'package:flutter/material.dart';

import 'lb_visual.dart';

class LoadBalancingView extends StatefulWidget {
  const LoadBalancingView({Key? key}) : super(key: key);

  @override
  State<LoadBalancingView> createState() => _LoadBalancingViewState();
}

class _LoadBalancingViewState extends State<LoadBalancingView> {
  String _selectedAlgorithm = 'Round Robin';
  String _selectedDiscovery = 'Kubernetes';
  bool _healthChecksEnabled = true;
  int _healthCheckInterval = 5;
  int _healthCheckTimeout = 2;
  int _healthCheckThreshold = 3;

  final _algorithms = [
    'Round Robin',
    'Weighted Round Robin',
    'Least Connections',
    'Consistent Hashing (Ketama)',
    'IP Hash',
    'Random',
  ];

  final _discoveryOptions = [
    'Kubernetes',
    'Consul',
    'Nacos',
    'Eureka',
    'DNS',
    'Static Config',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dynamic Load Balancing',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Algorithm Selection
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Load Balancing Algorithm',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Algorithm options
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: _algorithms.length,
                    itemBuilder: (context, index) {
                      final algorithm = _algorithms[index];
                      final isSelected = algorithm == _selectedAlgorithm;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedAlgorithm = algorithm;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer
                                    : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            algorithm,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Algorithm visualization
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: LoadBalancerVisualization(
                      algorithm: _selectedAlgorithm,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Service Discovery
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Discovery',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Discovery options
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        _discoveryOptions.map((option) {
                          final isSelected = option == _selectedDiscovery;

                          return ChoiceChip(
                            label: Text(option),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedDiscovery = option;
                                });
                              }
                            },
                            labelStyle: TextStyle(
                              color:
                                  isSelected
                                      ? Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer
                                      : null,
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            selectedColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          );
                        }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Discovery settings
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildDiscoverySettings(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Health Checks
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Health Checks',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Switch(
                        value: _healthChecksEnabled,
                        onChanged: (value) {
                          setState(() {
                            _healthChecksEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_healthChecksEnabled) ...[
                    // Active health checks
                    ListTile(
                      title: Text(
                        'Active Health Checks',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: const Text(
                        'Periodically probe upstream services',
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.monitor_heart,
                          color: Colors.green,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Health check interval
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Check Interval:'),
                              const SizedBox(width: 8),
                              Text(
                                '$_healthCheckInterval seconds',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _healthCheckInterval.toDouble(),
                            min: 1,
                            max: 30,
                            divisions: 29,
                            label: '$_healthCheckInterval s',
                            onChanged: (value) {
                              setState(() {
                                _healthCheckInterval = value.round();
                              });
                            },
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Text('Timeout:'),
                              const SizedBox(width: 8),
                              Text(
                                '$_healthCheckTimeout seconds',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _healthCheckTimeout.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: '$_healthCheckTimeout s',
                            onChanged: (value) {
                              setState(() {
                                _healthCheckTimeout = value.round();
                              });
                            },
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Text('Failure Threshold:'),
                              const SizedBox(width: 8),
                              Text(
                                '$_healthCheckThreshold failures',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _healthCheckThreshold.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: '$_healthCheckThreshold',
                            onChanged: (value) {
                              setState(() {
                                _healthCheckThreshold = value.round();
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const Divider(),
                    const SizedBox(height: 8),

                    // Passive health checks
                    ListTile(
                      title: Text(
                        'Passive Health Checks',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: const Text('Detect failures from real traffic'),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.analytics_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                      ),
                    ),
                  ] else ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Text('Health checks are disabled'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Apply configuration
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Apply Load Balancing Configuration'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverySettings() {
    switch (_selectedDiscovery) {
      case 'Kubernetes':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Kubernetes Namespace',
                hintText: 'default',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Service Selector',
                hintText: 'app=backend',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      case 'Consul':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Consul Address',
                hintText: 'consul.example.com:8500',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Service Name',
                hintText: 'api-service',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Service Endpoint',
                hintText: 'https://api.example.com',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
    }
  }
}
