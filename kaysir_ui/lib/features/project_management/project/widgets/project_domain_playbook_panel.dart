import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_playbook_service.dart';

class ProjectDomainPlaybookPanel extends StatelessWidget {
  const ProjectDomainPlaybookPanel({
    required this.summary,
    this.maxItems = 5,
    super.key,
  });

  final ProjectDomainPlaybookSummary summary;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final summaryColor = summary.level.color(colorScheme);
    final visibleItems = summary.items.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: summary.title,
          subtitle: summary.subtitle,
          icon: summary.level.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: summaryColor.withValues(alpha: 0.12),
          iconForegroundColor: summaryColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.level.label,
            icon: summary.level.icon,
            color: summaryColor,
            maxWidth: 112,
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _ProjectDomainPlaybookTile(item: visibleItems[index]),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ProjectDomainPlaybookTile extends StatelessWidget {
  const _ProjectDomainPlaybookTile({required this.item});

  final ProjectDomainPlaybookItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemColor = item.level.color(colorScheme);

    return AppInfoRow(
      title: item.title,
      subtitle: item.detail,
      icon: item.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: itemColor.withValues(alpha: 0.12),
      iconForegroundColor: itemColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: item.level.label,
        icon: item.level.icon,
        color: itemColor,
        maxWidth: 96,
      ),
    );
  }
}
