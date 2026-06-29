import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/cloud_sync_provider.dart';
import 'cloud_workflow_card.dart';

class CloudWorkflowsBrowser extends ConsumerStatefulWidget {
  const CloudWorkflowsBrowser({super.key});

  @override
  ConsumerState<CloudWorkflowsBrowser> createState() =>
      _CloudWorkflowsBrowserState();
}

class _CloudWorkflowsBrowserState extends ConsumerState<CloudWorkflowsBrowser> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cloudSyncProvider.notifier).listCloudWorkflows();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cloudState = ref.watch(cloudSyncProvider);

    return Dialog(
      child: Container(
        width: 700,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud, size: 32),
                const SizedBox(width: 12),
                Text(
                  'My Workflows',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search workflows...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: 'recent',
                  items: const [
                    DropdownMenuItem(value: 'recent', child: Text('Recent')),
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(
                      value: 'modified',
                      child: Text('Modified'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Workflows list
            Expanded(
              child: cloudState.cloudWorkflows.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No workflows found'),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.5,
                          ),
                      itemCount: cloudState.cloudWorkflows.length,
                      itemBuilder: (context, index) {
                        final workflow = cloudState.cloudWorkflows[index];
                        return CloudWorkflowCard(workflow: workflow);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
