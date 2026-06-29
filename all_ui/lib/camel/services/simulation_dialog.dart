import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/base_log_entry.dart';
import '../models/execution_log_entry.dart';
import '../models/simulation_entry.dart';
import '../models/simulation_state.dart';
import '../states/select_route_provider.dart';
import '../states/simulation_provider.dart';

class SimulationDialog extends ConsumerWidget {
  const SimulationDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(selectedRouteProvider);
    if (route == null || route.nodes.isEmpty) {
      return _buildEmptyState(context);
    }

    return Dialog(
      child: SizedBox(
        width: 700,
        height: 500,
        child: Column(
          children: [
            _buildHeader(context, ref),
            Expanded(child: _buildSimulationContent(ref, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AlertDialog(
      title: const Text('Simulation'),
      content: const Text('Add nodes to the route first'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Route Simulation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildSimulationControls(ref),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationControls(WidgetRef ref) {
    final simulation = ref.watch(simulationProvider);

    return Row(
      children: [
        if (!simulation.isRunning)
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            onPressed: () {
              ref.read(simulationProvider.notifier).start({
                'id': '123',
                'data': 'Sample message',
                'timestamp': DateTime.now().toIso8601String(),
              });
            },
            tooltip: 'Start',
          ),
        if (simulation.isRunning && !simulation.isPaused)
          IconButton(
            icon: const Icon(Icons.pause, color: Colors.white),
            onPressed: () {
              ref.read(simulationProvider.notifier).pause();
            },
            tooltip: 'Pause',
          ),
        if (simulation.isPaused) ...[
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            onPressed: () {
              ref.read(simulationProvider.notifier).resume();
            },
            tooltip: 'Resume',
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white),
            onPressed: () {
              ref.read(simulationProvider.notifier).step();
            },
            tooltip: 'Step',
          ),
        ],
        if (simulation.isRunning)
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.white),
            onPressed: () {
              ref.read(simulationProvider.notifier).stop();
            },
            tooltip: 'Stop',
          ),
      ],
    );
  }

  Widget _buildSimulationContent(WidgetRef ref, BuildContext context) {
    final simulation = ref.watch(simulationProvider);

    return Row(
      children: [
        _buildExecutionLog(simulation, context),
        _buildMessageData(simulation),
      ],
    );
  }

  Widget _buildExecutionLog(SimulationState simulation, BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Execution Log',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: simulation.executionLog.length,
                itemBuilder: (context, index) {
                  final entry = simulation.executionLog[index];

                  // If using Option C with BaseLogEntry, handle both types:
                  if (entry is ExecutionLogEntry) {
                    return _buildLogEntry(entry, context);
                  } else if (entry is SimulationLogEntry) {
                    // Convert to ExecutionLogEntry for display
                    final executionEntry = entry.toExecutionLogEntry(
                      templateId: 'simulation',
                      templateName: 'Simulation',
                    );
                    return _buildLogEntry(executionEntry, context);
                  } else {
                    return const ListTile(
                      title: Text('Unknown log entry type'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated _buildLogEntry to handle any BaseLogEntry
  // Update the method signature to accept dynamic or create a union type
  Widget _buildLogEntry(dynamic entry, BuildContext context) {
    if (entry is SimulationLogEntry) {
      return _buildSimulationLogEntry(entry, context);
    } else if (entry is ExecutionLogEntry) {
      return _buildExecutionLogEntry(entry, context);
    } else {
      return const ListTile(title: Text('Unknown log entry type'));
    }
  }

  Widget _buildSimulationLogEntry(
    SimulationLogEntry entry,
    BuildContext context,
  ) {
    IconData icon;
    Color iconColor;

    switch (entry.status) {
      case SimulationStatus.success:
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case SimulationStatus.error:
        icon = Icons.error;
        iconColor = Colors.red;
        break;
      case SimulationStatus.warning:
        icon = Icons.warning;
        iconColor = Colors.orange;
        break;
      case SimulationStatus.info:
        icon = Icons.info;
        iconColor = Colors.blue;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: iconColor, size: 16),
        title: Text(
          entry.action,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: entry.status == SimulationStatus.error ? Colors.red : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.nodeName}${entry.nodeId != null ? ' (${entry.nodeId})' : ''}',
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              entry.formattedTimestamp,
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (entry.processingTime != null)
              Text(
                entry.formattedProcessingTime,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (entry.data != null)
              Text(
                '${entry.data!.length} items',
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionLogEntry(
    ExecutionLogEntry entry,
    BuildContext context,
  ) {
    IconData icon;
    Color iconColor;

    switch (entry.status) {
      case ExecutionStatus.success:
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case ExecutionStatus.error:
        icon = Icons.error;
        iconColor = Colors.red;
        break;
      case ExecutionStatus.warning:
        icon = Icons.warning;
        iconColor = Colors.orange;
        break;
      case ExecutionStatus.processing:
        icon = Icons.hourglass_empty;
        iconColor = Colors.blue;
        break;
      case ExecutionStatus.cancelled:
        icon = Icons.cancel;
        iconColor = Colors.grey;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: iconColor, size: 16),
        title: Text(
          entry.action,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: entry.status == ExecutionStatus.error ? Colors.red : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.templateName} • ${entry.nodeName}',
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              entry.formattedTimestamp,
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (entry.processingTime != null)
              Text(
                entry.formattedProcessingTime,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (entry.outputSize != null)
              Text(
                '${(entry.outputSize! / 1024).toStringAsFixed(1)}KB',
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogEntryDetails(SimulationLogEntry entry, BuildContext context) {
    // Show detailed log entry in a dialog or bottom sheet
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Log Entry Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Action: ${entry.action}'),
                  Text('Node: ${entry.nodeName} (${entry.nodeId ?? 'N/A'})'),
                  Text('Time: ${entry.formattedTimestamp}'),
                  if (entry.processingTime != null)
                    Text('Processing Time: ${entry.formattedProcessingTime}'),
                  if (entry.data != null) ...[
                    SizedBox(height: 8),
                    Text(
                      'Data:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(entry.data.toString()),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  /* 
  Widget _buildLogEntry(ExecutionLogEntry entry) {
    IconData icon;
    Color iconColor;

    switch (entry.status) {
      case ExecutionStatus.success:
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case ExecutionStatus.error:
        icon = Icons.error;
        iconColor = Colors.red;
        break;
      case ExecutionStatus.warning:
        icon = Icons.warning;
        iconColor = Colors.orange;
        break;
      case ExecutionStatus.processing:
        icon = Icons.hourglass_empty;
        iconColor = Colors.blue;
        break;
      case ExecutionStatus.cancelled:
        icon = Icons.cancel;
        iconColor = Colors.grey;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: iconColor, size: 16),
        title: Text(
          entry.action,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.templateName} • ${entry.nodeName}',
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              entry.formattedTimestamp,
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (entry.processingTime != null)
              Text(
                entry.formattedProcessingTime,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (entry.outputSize != null)
              Text(
                '${(entry.outputSize! / 1024).toStringAsFixed(1)}KB',
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              ),
          ],
        ),
        onTap: () {
          // Show detailed log entry
          _showLogEntryDetails(entry);
        },
      ),
    );
  } */
  /* 
  void _showLogEntryDetails(ExecutionLogEntry entry) {
    // Implementation for showing detailed log entry
  }
  */
  Widget _buildMessageData(SimulationState simulation) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Message Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _formatJson(simulation.messageData),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatJson(Map<String, dynamic> data) {
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }
}
