import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/dashboard_workspace_entry.dart';

class DashboardWorkspaceAttentionActions extends StatelessWidget {
  final DashboardWorkspaceEntry entry;
  final VoidCallback onFocusAttention;

  const DashboardWorkspaceAttentionActions({
    super.key,
    required this.entry,
    required this.onFocusAttention,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: onFocusAttention,
          icon: const Icon(Icons.filter_alt_outlined, size: 18),
          label: const Text('Show attention'),
        ),
        FilledButton.icon(
          onPressed: () => context.go(entry.path),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: Text('Open ${entry.title}'),
        ),
      ],
    );
  }
}
