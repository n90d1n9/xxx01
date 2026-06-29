import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/node_route_provider.dart';
import '../../states/snapshot_provider.dart';

class SnapshotDialog extends StatelessWidget {
  const SnapshotDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 700,
        height: 500,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor,
              child: Row(
                children: [
                  const Icon(Icons.history, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Route Snapshots',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final snapshots = ref.watch(snapshotsProvider);

                  if (snapshots.isEmpty) {
                    return const Center(child: Text('No snapshots yet'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshots.length,
                    itemBuilder: (context, index) {
                      final snapshot = snapshots[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: Text(snapshot.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.timestamp.toString().substring(0, 19),
                              ),
                              if (snapshot.comment != null)
                                Text(
                                  snapshot.comment!,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              Text('${snapshot.route.nodes.length} nodes'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.restore),
                                onPressed: () {
                                  ref
                                      .read(routesProvider.notifier)
                                      .updateRoute(
                                        snapshot.route.id,
                                        snapshot.route,
                                      );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Snapshot restored'),
                                    ),
                                  );
                                },
                                tooltip: 'Restore',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  ref
                                      .read(snapshotsProvider.notifier)
                                      .deleteSnapshot(snapshot.id);
                                },
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
