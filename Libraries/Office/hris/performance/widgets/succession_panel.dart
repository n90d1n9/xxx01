import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/performance_models.dart';
import 'performance_status_styles.dart';

class SuccessionPanel extends StatelessWidget {
  final List<SuccessionCandidate> successors;

  const SuccessionPanel({super.key, required this.successors});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Succession Bench',
      icon: Icons.account_tree_outlined,
      subtitle: '${successors.length} candidates',
      emptyMessage: 'No successors match filters',
      children:
          successors
              .map((successor) => _SuccessionTile(successor: successor))
              .toList(),
    );
  }
}

class _SuccessionTile extends StatelessWidget {
  final SuccessionCandidate successor;

  const _SuccessionTile({required this.successor});

  @override
  Widget build(BuildContext context) {
    final color = readinessColor(successor.readiness);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  successor.role,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: readinessLabel(successor.readiness),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${successor.candidateName} - sponsor: ${successor.sponsorName}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: successor.readinessScore / 100,
            color: color,
            label: '${successor.readinessScore}% readiness',
          ),
        ],
      ),
    );
  }
}
