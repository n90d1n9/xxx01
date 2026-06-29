import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_detail.dart';
import '../models/dashboard_action_detail_snapshot.dart';
import 'dashboard_action_detail_snapshot_grid.dart';

class DashboardActionDetailOverviewSection extends StatelessWidget {
  final DashboardActionDetail detail;
  final DashboardActionDetailSnapshot snapshot;

  const DashboardActionDetailOverviewSection({
    super.key,
    required this.detail,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardActionDetailSnapshotGrid(snapshot: snapshot),
        const SizedBox(height: 12),
        _DetailNarrative(detail: detail),
      ],
    );
  }
}

class _DetailNarrative extends StatelessWidget {
  final DashboardActionDetail detail;

  const _DetailNarrative({required this.detail});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.action.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            detail.rationale,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}
