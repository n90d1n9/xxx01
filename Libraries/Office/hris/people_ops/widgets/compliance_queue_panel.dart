import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/people_ops_models.dart';
import 'people_ops_meta_label.dart';
import 'people_ops_status_styles.dart';

class ComplianceQueuePanel extends StatelessWidget {
  final List<ComplianceItem> items;

  const ComplianceQueuePanel({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Compliance Queue',
      icon: Icons.policy_outlined,
      subtitle: '${items.length} controls',
      emptyMessage: 'No compliance items match filters',
      children: items.map((item) => _ComplianceTile(item: item)).toList(),
    );
  }
}

class _ComplianceTile extends StatelessWidget {
  final ComplianceItem item;

  const _ComplianceTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = complianceStatusColor(item.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(complianceStatusIcon(item.status), color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(
                      label: complianceStatusLabel(item.status),
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.requirement,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    PeopleOpsMetaLabel(
                      icon: Icons.person_outline,
                      label: item.owner,
                    ),
                    PeopleOpsMetaLabel(
                      icon: Icons.apartment_outlined,
                      label: item.department,
                    ),
                    PeopleOpsMetaLabel(
                      icon: Icons.calendar_today_outlined,
                      label: DateFormat('MMM d').format(item.dueDate),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
