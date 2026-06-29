import 'package:flutter/material.dart';

import 'connection_painter.dart';

class ApiGatewayVisualization extends StatelessWidget {
  const ApiGatewayVisualization({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Client Section
            Positioned(
              left: 24,
              top: constraints.maxHeight / 2 - 100,
              child: Column(
                children: [
                  const Icon(Icons.devices, size: 40),
                  const SizedBox(height: 8),
                  const Text('Clients'),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      _clientBox(context, 'Mobile'),
                      const SizedBox(height: 8),
                      _clientBox(context, 'Web'),
                      const SizedBox(height: 8),
                      _clientBox(context, 'IoT'),
                    ],
                  ),
                ],
              ),
            ),

            // Iket  Section
            Positioned(
              left: constraints.maxWidth / 2 - 80,
              top: constraints.maxHeight / 2 - 100,
              child: Column(
                children: [
                  Container(
                    width: 160,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.api,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Iket ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _gatewayFeature(context, 'Load Balancing'),
                              const SizedBox(height: 4),
                              _gatewayFeature(context, 'Traffic Control'),
                              const SizedBox(height: 4),
                              _gatewayFeature(context, 'Multi-Protocol'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Services Section
            Positioned(
              right: 24,
              top: constraints.maxHeight / 2 - 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cloud, size: 40),
                  const SizedBox(height: 8),
                  const Text('Services'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Column(
                        children: [
                          _serviceBox(context, 'REST API', Colors.blue),
                          const SizedBox(height: 8),
                          _serviceBox(context, 'GraphQL', Colors.purple),
                          const SizedBox(height: 8),
                          _serviceBox(context, 'gRPC', Colors.green),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          _serviceBox(context, 'WebSocket', Colors.orange),
                          const SizedBox(height: 8),
                          _serviceBox(context, 'Database', Colors.red),
                          const SizedBox(height: 8),
                          _serviceBox(context, 'Kafka', Colors.teal),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Connection Lines
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: ConnectionPainter(),
            ),
          ],
        );
      },
    );
  }

  Widget _clientBox(BuildContext context, String name) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(name, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _serviceBox(BuildContext context, String name, Color color) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      alignment: Alignment.center,
      child: Text(
        name,
        style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
      ),
    );
  }

  Widget _gatewayFeature(BuildContext context, String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        name,
        style: TextStyle(
          fontSize: 10,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
