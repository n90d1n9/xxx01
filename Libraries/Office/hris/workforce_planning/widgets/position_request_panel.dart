import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/workforce_planning_models.dart';
import 'workforce_planning_status_styles.dart';

class PositionRequestPanel extends StatelessWidget {
  final List<PositionRequest> requests;

  const PositionRequestPanel({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.assignment_ind_outlined,
      title: 'Position Requests',
      subtitle: '${requests.length} requests',
      emptyMessage: 'No matching position requests',
      children:
          requests.map((request) => _PositionTile(request: request)).toList(),
    );
  }
}

class _PositionTile extends StatelessWidget {
  final PositionRequest request;

  const _PositionTile({required this.request});

  @override
  Widget build(BuildContext context) {
    final statusColor = positionStatusColor(request.status);
    final formatter = DateFormat('MMM d');

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${request.department} - ${request.hiringManager}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              HrisStatusPill(
                label: positionStatusLabel(request.status),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Requested',
                value: '${request.requestedHeadcount}',
              ),
              HrisMetricStripItem(
                label: 'Approved',
                value: '${request.approvedHeadcount}',
              ),
              HrisMetricStripItem(
                label: 'Start',
                value: formatter.format(request.targetStartDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
