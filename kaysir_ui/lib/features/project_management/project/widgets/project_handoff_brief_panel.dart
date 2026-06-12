import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/project_portfolio_item.dart';
import '../services/project_handoff_brief_service.dart';

class ProjectHandoffBriefPanel extends StatefulWidget {
  const ProjectHandoffBriefPanel({required this.brief, super.key});

  final ProjectHandoffBrief brief;

  @override
  State<ProjectHandoffBriefPanel> createState() =>
      _ProjectHandoffBriefPanelState();
}

class _ProjectHandoffBriefPanelState extends State<ProjectHandoffBriefPanel> {
  var _briefCopied = false;

  @override
  Widget build(BuildContext context) {
    final brief = widget.brief;
    final colorScheme = Theme.of(context).colorScheme;
    final urgencyColor = brief.urgency.color(colorScheme);
    final briefText = brief.briefText.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: brief.title,
          subtitle: brief.detail,
          icon: brief.urgency.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: urgencyColor.withValues(alpha: 0.12),
          iconForegroundColor: urgencyColor,
          titleMaxLines: 2,
          subtitleMaxLines: 3,
          trailing: AppStatusPill(
            label: brief.urgency.label,
            icon: brief.urgency.icon,
            color: urgencyColor,
            maxWidth: 118,
          ),
        ),
        const SizedBox(height: 10),
        AppInfoRow(
          title: 'Owner handoff',
          subtitle: brief.ownerLine,
          icon: Icons.assignment_ind_outlined,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: colorScheme.primary.withValues(alpha: 0.12),
          iconForegroundColor: colorScheme.primary,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: '${brief.timelineTaskCount} tasks',
            icon: Icons.timeline_outlined,
            color: colorScheme.primary,
            maxWidth: 112,
          ),
        ),
        const SizedBox(height: 10),
        _HandoffMilestoneRow(brief: brief),
        const SizedBox(height: 10),
        _HandoffRiskRow(brief: brief),
        if (briefText.isNotEmpty) ...[
          const SizedBox(height: 10),
          AppCopyBriefCard(
            title: 'Handoff brief',
            text: briefText,
            icon: Icons.assignment_turned_in_outlined,
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Handoff brief copied')));
  }
}

class _HandoffMilestoneRow extends StatelessWidget {
  const _HandoffMilestoneRow({required this.brief});

  final ProjectHandoffBrief brief;

  @override
  Widget build(BuildContext context) {
    final milestone = brief.nextMilestone;
    final colorScheme = Theme.of(context).colorScheme;

    if (milestone == null) {
      return AppInfoRow(
        title: 'No open milestone',
        subtitle: 'There is no milestone due in the current project plan.',
        icon: Icons.flag_outlined,
        iconStyle: AppInfoRowIconStyle.badge,
        contained: true,
        iconBackgroundColor: Colors.green.shade700.withValues(alpha: 0.12),
        iconForegroundColor: Colors.green.shade700,
        subtitleMaxLines: 2,
      );
    }

    final milestoneColor =
        milestone.isOverdue ? colorScheme.error : colorScheme.primary;
    final dateFormat = DateFormat('MMM d');

    return AppInfoRow(
      title: milestone.label,
      subtitle:
          '${milestone.dueLabel} - ${dateFormat.format(milestone.dueDate)}',
      icon: Icons.flag_outlined,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: milestoneColor.withValues(alpha: 0.12),
      iconForegroundColor: milestoneColor,
      titleMaxLines: 1,
      subtitleMaxLines: 2,
      trailing: AppStatusPill(
        label: milestone.dueLabel,
        icon:
            milestone.isOverdue
                ? Icons.event_busy_outlined
                : Icons.event_available_outlined,
        color: milestoneColor,
        maxWidth: 126,
      ),
    );
  }
}

class _HandoffRiskRow extends StatelessWidget {
  const _HandoffRiskRow({required this.brief});

  final ProjectHandoffBrief brief;

  @override
  Widget build(BuildContext context) {
    final risk = brief.topRisk;
    final colorScheme = Theme.of(context).colorScheme;

    if (risk == null) {
      return AppInfoRow(
        title: 'No active handoff risk',
        subtitle:
            'The handoff can focus on progress, milestone, and team sync.',
        icon: Icons.health_and_safety_outlined,
        iconStyle: AppInfoRowIconStyle.badge,
        contained: true,
        iconBackgroundColor: Colors.green.shade700.withValues(alpha: 0.12),
        iconForegroundColor: Colors.green.shade700,
        subtitleMaxLines: 2,
      );
    }

    final riskColor = risk.severity.color(colorScheme);

    return AppInfoRow(
      title: risk.title,
      subtitle: risk.detail,
      icon: risk.severity.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: riskColor.withValues(alpha: 0.12),
      iconForegroundColor: riskColor,
      titleMaxLines: 1,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: risk.severity.label,
        icon: risk.severity.icon,
        color: riskColor,
        maxWidth: 118,
      ),
    );
  }
}
