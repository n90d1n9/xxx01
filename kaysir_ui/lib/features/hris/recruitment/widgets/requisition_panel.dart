import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/recruitment_models.dart';
import 'recruitment_meta_label.dart';
import 'recruitment_status_styles.dart';

class RequisitionPanel extends StatelessWidget {
  final List<JobRequisition> requisitions;

  const RequisitionPanel({super.key, required this.requisitions});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Requisition Board',
      icon: Icons.assignment_ind_outlined,
      subtitle: '${requisitions.length} requisitions',
      emptyMessage: 'No requisitions match filters',
      children:
          requisitions
              .map((requisition) => _RequisitionTile(requisition: requisition))
              .toList(),
    );
  }
}

class _RequisitionTile extends StatelessWidget {
  final JobRequisition requisition;

  const _RequisitionTile({required this.requisition});

  @override
  Widget build(BuildContext context) {
    final color = recruitmentPriorityColor(requisition.priority);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  requisition.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: requisitionStatusLabel(requisition.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              RecruitmentMetaLabel(
                icon: Icons.apartment,
                label: requisition.department,
              ),
              RecruitmentMetaLabel(
                icon: Icons.person_outline,
                label: requisition.hiringManager,
              ),
              RecruitmentMetaLabel(
                icon: Icons.place_outlined,
                label: requisition.location,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: requisition.fillProgress,
            color: color,
            label:
                '${requisition.filled}/${requisition.openings} filled, ${requisition.pipelineCount} candidates',
          ),
          const SizedBox(height: 8),
          Text(
            'Target ${DateFormat('MMM d').format(requisition.targetDate)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}
