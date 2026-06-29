import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/workflow_provider.dart';

class ExecutionLog extends ConsumerStatefulWidget {
  const ExecutionLog({super.key});

  @override
  ConsumerState<ExecutionLog> createState() => _ExecutionLogState();
}

class _ExecutionLogState extends ConsumerState<ExecutionLog> {
  @override
  Widget build(BuildContext context) {
    final workflowState = ref.watch(workflowProvider);
    return Positioned(
      bottom: 0,
      left: 280,
      right: workflowState.selectedNodeId != null ? 320 : 0,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.terminal, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Execution Log',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.clear_all, size: 16),
                    color: Colors.white70,
                    onPressed: () {},
                    tooltip: 'Clear Log',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    color: Colors.white70,
                    onPressed: () {
                      setState(() {
                        ref.watch(executionLogProvider.notifier).state = false;
                      });
                    },
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: workflowState.executionLog.length,
                itemBuilder: (context, index) {
                  final log = workflowState.executionLog[index];
                  Color logColor = Colors.white70;
                  IconData logIcon = Icons.info_outline;

                  if (log.contains('Error')) {
                    logColor = Colors.red;
                    logIcon = Icons.error_outline;
                  } else if (log.contains('Completed')) {
                    logColor = Colors.green;
                    logIcon = Icons.check_circle_outline;
                  } else if (log.contains('Executing')) {
                    logColor = Colors.blue;
                    logIcon = Icons.play_circle_outline;
                  } else if (log.contains('Starting')) {
                    logColor = Colors.orange;
                    logIcon = Icons.rocket_launch;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(logIcon, size: 14, color: logColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            log,
                            style: TextStyle(
                              color: logColor,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        Text(
                          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
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
