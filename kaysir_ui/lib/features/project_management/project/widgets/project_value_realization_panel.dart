import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_value_realization_service.dart';

class ProjectValueRealizationPanel extends StatefulWidget {
  const ProjectValueRealizationPanel({
    required this.summary,
    this.maxItems = 5,
    super.key,
  });

  final ProjectValueRealizationSummary summary;
  final int maxItems;

  @override
  State<ProjectValueRealizationPanel> createState() =>
      _ProjectValueRealizationPanelState();
}

class _ProjectValueRealizationPanelState
    extends State<ProjectValueRealizationPanel> {
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
            maxWidth: 118,
          ),
        ),
        const SizedBox(height: 12),
        AppInfoRow(
          title: 'Value thesis',
          subtitle: summary.valueThesis,
          icon: Icons.lightbulb_outline,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconForegroundColor: colorScheme.primary,
          titleMaxLines: 1,
          subtitleMaxLines: 3,
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: ProjectValueRealizationLevel.recover.label,
              value: summary.recoverCount.toString(),
              icon: ProjectValueRealizationLevel.recover.icon,
              accentColor:
                  summary.recoverCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
            ),
            AppMetricGridItem(
              title: ProjectValueRealizationLevel.protect.label,
              value: summary.protectCount.toString(),
              icon: ProjectValueRealizationLevel.protect.icon,
              accentColor:
                  summary.protectCount == 0
                      ? colorScheme.primary
                      : Colors.orange.shade700,
            ),
            AppMetricGridItem(
              title: ProjectValueRealizationLevel.validate.label,
              value: summary.validateCount.toString(),
              icon: ProjectValueRealizationLevel.validate.icon,
              accentColor: colorScheme.primary,
            ),
            AppMetricGridItem(
              title: ProjectValueRealizationLevel.realizing.label,
              value: summary.realizingCount.toString(),
              icon: ProjectValueRealizationLevel.realizing.icon,
              accentColor: Colors.green.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _ProjectValueRealizationTile(item: visibleItems[index]),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
        if (briefText.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCopyBriefCard(
            title: 'Value realization brief',
            text: briefText,
            icon: Icons.insights_outlined,
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
      const SnackBar(content: Text('Value realization brief copied')),
    );
  }
}

class _ProjectValueRealizationTile extends StatelessWidget {
  const _ProjectValueRealizationTile({required this.item});

  final ProjectValueRealizationItem item;

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
        maxWidth: 118,
      ),
    );
  }
}
