import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/service_center_models.dart';
import 'service_center_meta_label.dart';
import 'service_center_status_styles.dart';

class CaseQueuePanel extends StatelessWidget {
  final List<ServiceDeskCase> cases;

  const CaseQueuePanel({super.key, required this.cases});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Case Queue',
      icon: Icons.support_agent_outlined,
      subtitle: '${cases.length} employee requests',
      emptyMessage: 'No cases match filters',
      children:
          cases
              .map((serviceCase) => _CaseTile(serviceCase: serviceCase))
              .toList(),
    );
  }
}

class _CaseTile extends StatelessWidget {
  final ServiceDeskCase serviceCase;

  const _CaseTile({required this.serviceCase});

  @override
  Widget build(BuildContext context) {
    final color =
        serviceCase.isSlaAtRisk
            ? const Color(0xFFDC2626)
            : casePriorityColor(serviceCase.priority);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  serviceCase.subject,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: caseStatusLabel(serviceCase.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${serviceCase.requesterName} - ${serviceCase.category}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              ServiceCenterMetaLabel(
                icon: Icons.person_outline,
                label: serviceCase.assignedTo,
              ),
              ServiceCenterMetaLabel(
                icon: Icons.schedule_outlined,
                label:
                    serviceCase.isSlaAtRisk
                        ? 'SLA risk'
                        : 'Due ${DateFormat('MMM d, HH:mm').format(serviceCase.dueAt)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
