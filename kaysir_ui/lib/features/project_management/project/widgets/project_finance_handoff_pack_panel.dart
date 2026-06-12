import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_finance_handoff_pack_service.dart';
import '../services/project_finance_workspace_service.dart';

/// Audit-ready finance handoff package panel for one project workspace.
class ProjectFinanceHandoffPackPanel extends StatefulWidget {
  const ProjectFinanceHandoffPackPanel({
    required this.summary,
    this.maxSections = 6,
    super.key,
  });

  final ProjectFinanceWorkspaceSummary summary;
  final int maxSections;

  @override
  State<ProjectFinanceHandoffPackPanel> createState() =>
      _ProjectFinanceHandoffPackPanelState();
}

/// Presentation state for copying the generated finance handoff brief.
class _ProjectFinanceHandoffPackPanelState
    extends State<ProjectFinanceHandoffPackPanel> {
  var _briefCopied = false;

  @override
  Widget build(BuildContext context) {
    final pack = buildProjectFinanceHandoffPackSummary(widget.summary);
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = pack.level.color(colorScheme);
    final visibleSections = pack.sections.take(widget.maxSections).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: pack.title,
          subtitle: pack.detail,
          icon: pack.level.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: levelColor.withValues(alpha: 0.12),
          iconForegroundColor: levelColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: pack.level.label,
            icon: pack.level.icon,
            color: levelColor,
            maxWidth: 128,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Sections',
              value: pack.sectionCount.toString(),
              icon: Icons.inventory_2_outlined,
              accentColor: colorScheme.primary,
              helper: 'Package areas',
            ),
            AppMetricGridItem(
              title: 'Ready',
              value: pack.readyCount.toString(),
              icon: Icons.verified_outlined,
              accentColor: Colors.green.shade700,
              helper: 'Can hand off',
            ),
            AppMetricGridItem(
              title: 'Review',
              value: pack.reviewCount.toString(),
              icon: Icons.rate_review_outlined,
              accentColor:
                  pack.reviewCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Needs cleanup',
            ),
            AppMetricGridItem(
              title: 'Blocked',
              value: pack.blockedCount.toString(),
              icon: Icons.priority_high_rounded,
              accentColor:
                  pack.blockedCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Cannot hand off',
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppInfoRow(
          title: 'Recipients',
          subtitle: 'Package ${pack.packageId}',
          icon: Icons.groups_outlined,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: colorScheme.primary.withValues(alpha: 0.12),
          iconForegroundColor: colorScheme.primary,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final recipient in pack.recipients)
              AppStatusPill(
                label: recipient,
                icon: Icons.person_outline,
                color: colorScheme.primary,
                maxWidth: 190,
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleSections.length; index++) ...[
          _HandoffPackSectionTile(section: visibleSections[index]),
          if (index != visibleSections.length - 1) const SizedBox(height: 10),
        ],
        const SizedBox(height: 12),
        AppCopyBriefCard(
          title: 'Finance handoff brief',
          text: pack.briefText,
          icon: Icons.assignment_turned_in_outlined,
          copied: _briefCopied,
          onCopy: () => _copyBrief(pack.briefText),
        ),
      ],
    );
  }

  Future<void> _copyBrief(String briefText) async {
    setState(() => _briefCopied = true);
    await Clipboard.setData(ClipboardData(text: briefText));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Finance handoff brief copied')),
    );
  }
}

/// Finance handoff package section row with owner and readiness state.
class _HandoffPackSectionTile extends StatelessWidget {
  const _HandoffPackSectionTile({required this.section});

  final ProjectFinanceHandoffPackSection section;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sectionColor = section.level.color(colorScheme);

    return AppInfoRow(
      title: section.title,
      subtitle: '${section.detail} Owner: ${section.ownerLabel}.',
      icon: section.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: sectionColor.withValues(alpha: 0.12),
      iconForegroundColor: sectionColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: section.level.label,
        icon: section.level.icon,
        color: sectionColor,
        maxWidth: 128,
      ),
    );
  }
}

@Preview(name: 'Project finance handoff pack panel')
Widget projectFinanceHandoffPackPanelPreview() {
  final project = const ProjectPortfolioRepository().fetchProjects().first;

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectFinanceHandoffPackPanel(
          summary: buildProjectFinanceWorkspaceSummary(project),
        ),
      ),
    ),
  );
}
