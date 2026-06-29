import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/current_route_notifier.dart';

class StatusBar extends ConsumerWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(currentRouteProvider);

    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16),
          const SizedBox(width: 8),
          if (route != null)
            Text(
              'Last updated: ${_formatDateTime(route.updatedAt)}',
              style: const TextStyle(fontSize: 12),
            )
          else
            const Text('No route selected', style: TextStyle(fontSize: 12)),
          const Spacer(),
          const Text(
            'Apache Camel Integration Builder v1.0',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day}/${dt.month}/${dt.year}';
  }
}
