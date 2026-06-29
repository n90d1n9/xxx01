import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/integration_route.dart';
import '../states/current_route_notifier.dart';
import '../states/route_notifier.dart';

class RoutePropertiesDialog extends ConsumerStatefulWidget {
  final IntegrationRoute route;

  const RoutePropertiesDialog({super.key, required this.route});

  @override
  ConsumerState<RoutePropertiesDialog> createState() =>
      _RoutePropertiesDialogState();
}

class _RoutePropertiesDialogState extends ConsumerState<RoutePropertiesDialog> {
  late TextEditingController nameController;
  late TextEditingController descController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.route.name);
    descController = TextEditingController(text: widget.route.description);
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Route Properties'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Route Name',
                  prefixIcon: Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'Statistics',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Components',
                widget.route.components.length.toString(),
              ),
              _buildInfoRow(
                'Connections',
                widget.route.connections.length.toString(),
              ),
              _buildInfoRow('Created', _formatDateTime(widget.route.createdAt)),
              _buildInfoRow(
                'Last Modified',
                _formatDateTime(widget.route.updatedAt),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updated = widget.route.copyWith(
              name: nameController.text,
              description: descController.text,
            );
            ref.read(currentRouteProvider.notifier).setRoute(updated);
            ref.read(routesProvider.notifier).updateRoute(updated);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
