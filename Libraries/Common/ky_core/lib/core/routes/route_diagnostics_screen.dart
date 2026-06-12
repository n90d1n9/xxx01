import 'package:flutter/material.dart';

import 'routes.dart';

class RouteDiagnosticsScreen extends StatelessWidget {
  final RouteDiagnosticsSnapshot? snapshot;

  const RouteDiagnosticsScreen({super.key, this.snapshot});

  @override
  Widget build(BuildContext context) {
    final data = snapshot ?? Routes.diagnostics();
    final items = data.paths;
    final named = data.namedRoutes;
    return Scaffold(
      appBar: AppBar(title: const Text('Route Diagnostics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatRow(label: 'Total Routes', value: data.totalRoutes.toString()),
          _StatRow(label: 'Total Branches', value: data.totalBranches.toString()),
          _StatRow(
            label: 'Generated',
            value: data.generatedAt.toLocal().toIso8601String(),
          ),
          const SizedBox(height: 16),
          Text(
            'Paths (${items.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...items.map((path) => ListTile(title: Text(path))),
          const SizedBox(height: 16),
          Text(
            'Named Routes (${named.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...named.entries.map(
            (entry) => ListTile(
              title: Text(entry.key),
              subtitle: Text(entry.value),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
