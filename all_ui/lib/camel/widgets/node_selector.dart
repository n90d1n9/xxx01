// Route Selector Widget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/node_route_provider.dart';
import '../states/select_route_provider.dart';

class NodeSelector extends ConsumerWidget {
  const NodeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(routesProvider);
    final selectedRouteId = ref.watch(selectedRouteIdProvider);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: routes.length,
        itemExtent: 120,
        itemBuilder: (context, index) {
          final route = routes[index];
          final isSelected = route.id == selectedRouteId;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ref.read(selectedRouteIdProvider.notifier).state = route.id;
                  ref.read(selectedNodeIdProvider.notifier).state = null;
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  // REMOVE vertical padding - let the container expand naturally
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  // REMOVE vertical: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.indigo : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.indigo : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 1), // Reduce from 2 to 1
                      Text(
                        '${route.nodes.length} nodes',
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.black54,
                          fontSize: 9, // Reduce from 10 to 9
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
