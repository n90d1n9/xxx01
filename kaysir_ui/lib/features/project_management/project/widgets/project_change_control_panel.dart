import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_change_control_service.dart';

class ProjectChangeControlPanel extends StatefulWidget {
  const ProjectChangeControlPanel({
    required this.summary,
    this.maxItems = 5,
    super.key,
  });

  final ProjectChangeControlSummary summary;
  final int maxItems;

  @override
  State<ProjectChangeControlPanel> createState() =>
      _ProjectChangeControlPanelState();
}

class _ProjectChangeControlPanelState extends State<ProjectChangeControlPanel> {
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
        for (var index = 0; index < visibleItems.length; index++) ...[
          _ProjectChangeControlTile(item: visibleItems[index]),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
        if (briefText.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCopyBriefCard(
            title: 'Change control brief',
            text: briefText,
            icon: Icons.rule_folder_outlined,
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
      const SnackBar(content: Text('Change control brief copied')),
    );
  }
}

class _ProjectChangeControlTile extends StatelessWidget {
  const _ProjectChangeControlTile({required this.item});

  final ProjectChangeControlItem item;

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
