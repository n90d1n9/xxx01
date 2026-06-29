import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/deployment_target.dart';
import '../states/provider.dart';

class DeploymentPage extends ConsumerStatefulWidget {
  const DeploymentPage({super.key});

  @override
  ConsumerState<DeploymentPage> createState() => _DeploymentPageState();
}

class _DeploymentPageState extends ConsumerState<DeploymentPage> {
  DeploymentTarget selectedTarget = DeploymentTarget.cloud;
  bool enableAutoScaling = false;
  int replicas = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Model Deployment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deploy your model to production',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Select Model
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Model Version',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      value: 'Medical QA v2.0 (latest)',
                      items:
                          [
                                'Medical QA v2.0 (latest)',
                                'Medical QA v1.5',
                                'Medical QA v1.0',
                              ]
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Deployment Target
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deployment Target',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          DeploymentTarget.values.map((target) {
                            return ChoiceChip(
                              label: Text(_getTargetLabel(target)),
                              avatar: Icon(_getTargetIcon(target), size: 18),
                              selected: selectedTarget == target,
                              onSelected: (selected) {
                                if (selected)
                                  setState(() => selectedTarget = target);
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Endpoint Name',
                        hintText: 'medical-qa-api',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Text('Number of Replicas: $replicas')),
                        Text(
                          replicas.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: replicas.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (v) => setState(() => replicas = v.toInt()),
                    ),
                    SwitchListTile(
                      title: const Text('Enable Auto-scaling'),
                      subtitle: const Text('Automatically scale based on load'),
                      value: enableAutoScaling,
                      onChanged: (v) => setState(() => enableAutoScaling = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Hardware Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hardware',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'GPU/Accelerator',
                        border: OutlineInputBorder(),
                      ),
                      value: 'NVIDIA A100',
                      items:
                          [
                                'NVIDIA A100',
                                'NVIDIA V100',
                                'NVIDIA T4',
                                'CPU Only',
                              ]
                              .map(
                                (h) =>
                                    DropdownMenuItem(value: h, child: Text(h)),
                              )
                              .toList(),
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Monitoring & Logging
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monitoring & Logging',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Enable Monitoring'),
                      subtitle: const Text(
                        'Track performance metrics and usage',
                      ),
                      value: true,
                      onChanged: (_) {},
                    ),
                    SwitchListTile(
                      title: const Text('Enable Request Logging'),
                      subtitle: const Text('Log all API requests for analysis'),
                      value: true,
                      onChanged: (_) {},
                    ),
                    SwitchListTile(
                      title: const Text('Enable Alerting'),
                      subtitle: const Text('Get notified of issues'),
                      value: false,
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Deploy Button
            FilledButton.icon(
              onPressed: () => _deployModel(context, ref),
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Deploy Model'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTargetLabel(DeploymentTarget target) {
    switch (target) {
      case DeploymentTarget.local:
        return 'Local';
      case DeploymentTarget.cloud:
        return 'Cloud';
      case DeploymentTarget.edge:
        return 'Edge';
      case DeploymentTarget.api:
        return 'API';
      case DeploymentTarget.huggingface:
        return 'HuggingFace';
      case DeploymentTarget.custom:
        return 'Custom';
    }
  }

  IconData _getTargetIcon(DeploymentTarget target) {
    switch (target) {
      case DeploymentTarget.local:
        return Icons.computer;
      case DeploymentTarget.cloud:
        return Icons.cloud;
      case DeploymentTarget.edge:
        return Icons.device_hub;
      case DeploymentTarget.api:
        return Icons.api;
      case DeploymentTarget.huggingface:
        return Icons.hub;
      case DeploymentTarget.custom:
        return Icons.settings;
    }
  }

  void _deployModel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Deploying model...'),
                SizedBox(height: 8),
                Text(
                  'This may take several minutes',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
                  SizedBox(width: 12),
                  Text('Deployment Successful!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your model has been deployed successfully!'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Endpoint URL:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'https://api.example.com/v1/medical-qa',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'API Key:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'sk_live_xxxxxxxxxxxxxxxxxxx',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Status: ✓ Active'),
                  const Text('Replicas: 1/1 running'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(selectedTabProvider.notifier).state = 6;
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View in Registry'),
                ),
              ],
            ),
      );
    });
  }
}
