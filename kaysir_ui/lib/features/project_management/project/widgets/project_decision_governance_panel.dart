import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_decision_governance_service.dart';

class ProjectDecisionGovernancePanel extends StatefulWidget {
  const ProjectDecisionGovernancePanel({
    required this.summary,
    this.maxItems = 5,
    super.key,
  });

  final ProjectDecisionGovernanceSummary summary;
  final int maxItems;

  @override
  State<ProjectDecisionGovernancePanel> createState() =>
      _ProjectDecisionGovernancePanelState();
}

class _ProjectDecisionGovernancePanelState
    extends State<ProjectDecisionGovernancePanel> {
  var _briefCopied = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final summary = widget.summary;
    final summaryColor = summary.level.color(colorScheme);
    final visibleItems = summary.items.take(widget.maxItems).toList();
    final briefText = summary.briefText.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: summary.title,
          subtitle: summary.subtitle,
          icon: summary.primaryItem.icon,
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
            maxWidth: 124,
          ),
        ),
        const SizedBox(height: 12),
        AppInfoRow(
          title: 'Decision route',
          subtitle: summary.decisionRoute,
          icon: Icons.account_tree_outlined,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconForegroundColor: colorScheme.primary,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: ProjectDecisionGovernanceLevel.escalate.label,
              value: summary.escalateCount.toString(),
              icon: ProjectDecisionGovernanceLevel.escalate.icon,
              accentColor:
                  summary.escalateCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
            ),
            AppMetricGridItem(
              title: ProjectDecisionGovernanceLevel.approve.label,
              value: summary.approveCount.toString(),
              icon: ProjectDecisionGovernanceLevel.approve.icon,
              accentColor:
                  summary.approveCount == 0
                      ? colorScheme.primary
                      : Colors.orange.shade700,
            ),
            AppMetricGridItem(
              title: ProjectDecisionGovernanceLevel.coordinate.label,
              value: summary.coordinateCount.toString(),
              icon: ProjectDecisionGovernanceLevel.coordinate.icon,
              accentColor: colorScheme.primary,
            ),
            AppMetricGridItem(
              title: ProjectDecisionGovernanceLevel.delegated.label,
              value: summary.delegatedCount.toString(),
              icon: ProjectDecisionGovernanceLevel.delegated.icon,
              accentColor: Colors.green.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _ProjectDecisionGovernanceTile(item: visibleItems[index]),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
        if (briefText.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCopyBriefCard(
            title: 'Decision governance brief',
            text: briefText,
            icon: Icons.account_tree_outlined,
            copied: _briefCopied,
            onCopy: () => _copyBrief(briefText),
          ),
        ],
      ],
    );
  }

  Future<void> _copyBrief(String briefText) async {
    setState(() => _briefCopied = true);
    await Clipboard.setData(ClipboardData(text: briefText));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Decision governance brief copied')),
    );
  }
}

class _ProjectDecisionGovernanceTile extends StatelessWidget {
  const _ProjectDecisionGovernanceTile({required this.item});

  final ProjectDecisionGovernanceItem item;

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
        maxWidth: 124,
      ),
    );
  }
}
