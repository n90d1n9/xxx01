import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_evidence_pack_service.dart';

class ProjectEvidencePackPanel extends StatelessWidget {
  const ProjectEvidencePackPanel({
    required this.summary,
    this.maxItems = 5,
    super.key,
  });

  final ProjectEvidencePackSummary summary;
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
          subtitle: '${summary.subtitle} - ${summary.readinessPercent}% ready',
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
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: (summary.readinessPercent / 100).clamp(0, 1),
            color: summaryColor,
            backgroundColor: summaryColor.withValues(alpha: 0.14),
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _ProjectEvidencePackTile(item: visibleItems[index]),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ProjectEvidencePackTile extends StatelessWidget {
  const _ProjectEvidencePackTile({required this.item});

  final ProjectEvidencePackItem item;

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
        maxWidth: 110,
      ),
    );
  }
}
