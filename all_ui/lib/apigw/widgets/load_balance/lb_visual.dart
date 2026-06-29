import 'package:flutter/material.dart';

import 'lb_connection_painter.dart';

class LoadBalancerVisualization extends StatelessWidget {
  final String algorithm;

  const LoadBalancerVisualization({Key? key, required this.algorithm})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Client icon
            Positioned(
              left: 24,
              top: constraints.maxHeight / 2 - 20,
              child: Column(
                children: [
                  const Icon(Icons.computer, size: 40),
                  const SizedBox(height: 4),
                  const Text('Client'),
                ],
              ),
            ),

            // Load balancer
            Positioned(
              left: constraints.maxWidth / 2 - 40,
              top: constraints.maxHeight / 2 - 40,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.balance,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LB',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Server nodes
            ..._buildServerNodes(context, constraints),

            // Connection lines
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: LoadBalancerConnectionPainter(algorithm: algorithm),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildServerNodes(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final nodes = <Widget>[];
    final count = 4;
    final spacing = constraints.maxHeight / (count + 1);

    for (int i = 0; i < count; i++) {
      final weight = i == 1 ? '2x' : '1x';
      final isActive = i != 3; // Make the last node inactive

      nodes.add(
        Positioned(
          right: 24,
          top: spacing * (i + 1) - 20,
          child: Row(
            children: [
              Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? Theme.of(context).colorScheme.tertiaryContainer
                          : Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isActive
                            ? Theme.of(context).colorScheme.tertiary
                            : Colors.grey,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'S${i + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            isActive
                                ? Theme.of(
                                  context,
                                ).colorScheme.onTertiaryContainer
                                : Colors.grey,
                      ),
                    ),
                    if (algorithm.contains('Weighted'))
                      Text(
                        weight,
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              isActive
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.onTertiaryContainer
                                  : Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              if (algorithm.contains('Least'))
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getConnectionColor(i).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getConnectionColor(i).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '${8 - i * 2}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getConnectionColor(i),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return nodes;
  }

  Color _getConnectionColor(int index) {
    switch (index) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
