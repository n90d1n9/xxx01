import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_stakeholder_alignment_service.dart';

class ProjectStakeholderAlignmentPanel extends StatelessWidget {
  const ProjectStakeholderAlignmentPanel({
    required this.summary,
    this.maxItems = 5,
    super.key,
  });

  final ProjectStakeholderAlignmentSummary summary;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final summaryColor = summary.status.color(colorScheme);
    final visibleItems = summary.items.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: summary.title,
          subtitle: '${summary.subtitle} - ${summary.items.length} routes',
          icon: summary.primaryItem.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: summaryColor.withValues(alpha: 0.12),
          iconForegroundColor: summaryColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.status.label,
            icon: summary.status.icon,
            color: summaryColor,
            maxWidth: 112,
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _ProjectStakeholderAlignmentTile(item: visibleItems[index]),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ProjectStakeholderAlignmentTile extends StatelessWidget {
  const _ProjectStakeholderAlignmentTile({required this.item});

  final ProjectStakeholderAlignmentItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = item.status.color(colorScheme);

    return AppInfoRow(
      title: item.title,
      subtitle: item.detail,
      icon: item.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: statusColor.withValues(alpha: 0.12),
      iconForegroundColor: statusColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: item.status.label,
        icon: item.status.icon,
        color: statusColor,
        maxWidth: 112,
      ),
    );
  }
}
