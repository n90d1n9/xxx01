import 'package:flutter/material.dart';

import '../workflow/components/palette/node_pallete.dart';
import 'node_comparison_chart.dart';
import 'univ_node_widget.dart';

class CompleteWorkflowDemo extends StatelessWidget {
  const CompleteWorkflowDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text('Complete AI Agent Workflow Demo'),
      ),
      body: Row(
        children: [
          // Node Palette
          NodePalette(
            onNodeSelected: (nodeType) {
              print('Selected node: $nodeType');
              // Open editor or add to canvas
            },
          ),

          // Main Canvas
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Example Workflow: Customer Support System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Demonstrates all node types working together',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // Workflow visualization
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      UniversalNodeWidget(
                        nodeType: 'if_else',
                        definition: {
                          'name': 'Classify Request',
                          'description': 'Route by urgency',
                          'conditions': [
                            {'label': 'Urgent'},
                            {'label': 'Normal'},
                          ],
                          'hasElse': true,
                        },
                      ),
                      UniversalNodeWidget(
                        nodeType: 'router',
                        definition: {
                          'name': 'Load Balancer',
                          'description': 'Distribute to agents',
                          'routes': [
                            {'label': 'Agent 1'},
                            {'label': 'Agent 2'},
                            {'label': 'Agent 3'},
                          ],
                          'strategy': 'leastLoad',
                        },
                      ),
                      UniversalNodeWidget(
                        nodeType: 'try_catch',
                        definition: {
                          'name': 'API Call with Retry',
                          'description': 'Fetch customer data',
                          'maxRetries': 3,
                          'retryStrategy': 'exponential',
                        },
                        isExecuting: true,
                      ),
                      UniversalNodeWidget(
                        nodeType: 'cache',
                        definition: {
                          'name': 'Response Cache',
                          'description': 'Cache frequent queries',
                          'strategy': 'ttl',
                          'maxSize': 100,
                        },
                      ),
                      UniversalNodeWidget(
                        nodeType: 'human_in_loop',
                        definition: {
                          'name': 'Quality Check',
                          'description': 'Human review required',
                          'approvalType': 'binary',
                          'timeout': 30,
                        },
                        isSelected: true,
                      ),
                      UniversalNodeWidget(
                        nodeType: 'batch',
                        definition: {
                          'name': 'Email Batch',
                          'description': 'Send notifications',
                          'batchSize': 10,
                          'batchTimeout': 30,
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),
                  const Text(
                    'Node Comparison',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const NodeComparisonChart(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
