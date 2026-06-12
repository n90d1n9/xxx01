import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_domain_registry.dart';
import '../services/project_status_update_domain_profile_service.dart';
import '../services/project_status_update_service.dart';
import 'project_domain_risk_rule_preview_list.dart';

class ProjectDomainPackSummaryPanel extends StatelessWidget {
  const ProjectDomainPackSummaryPanel({
    required this.businessDomain,
    this.elevated = false,
    super.key,
  });

  final String businessDomain;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pack = projectDomainPackForBusinessDomain(businessDomain);
    final profile = projectStatusUpdateDomainProfileFor(businessDomain);
    final milestoneTemplate = pack.milestoneTemplate;
    final teamTemplate = pack.teamTemplate;
    final extensionLabels = [
      for (final template in pack.customAttributeTemplates) template.label,
    ];
    final milestoneLabels = [
      milestoneTemplate.kickoffLabel,
      milestoneTemplate.reviewLabel.trim().isEmpty
          ? '${pack.businessDomain} Review'
          : milestoneTemplate.reviewLabel,
      milestoneTemplate.handoverLabel,
    ];

    return AppContentPanel(
      title: 'Domain Pack',
      subtitle: pack.businessDomain,
      leadingIcon: Icons.schema_outlined,
      elevated: elevated,
      trailing: AppStatusPill(
        label: profile.vocabulary.label,
        icon: profile.vocabulary.icon,
        color: colorScheme.tertiary,
        maxWidth: 150,
      ),
      child: Column(
        children: [
          AppInfoRow(
            title: '${profile.vocabulary.label} / ${profile.audience.label}',
            subtitle:
                '${profile.vocabulary.workLabel} - ${profile.vocabulary.audienceLabel}',
            icon: Icons.record_voice_over_outlined,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
            iconBackgroundColor: colorScheme.tertiary.withValues(alpha: 0.12),
            iconForegroundColor: colorScheme.tertiary,
            titleMaxLines: 1,
            subtitleMaxLines: 2,
          ),
          const SizedBox(height: 10),
          AppInfoRow(
            title: extensionLabels.join(', '),
            subtitle: 'Extension fields',
            icon: Icons.extension_outlined,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
            iconBackgroundColor: colorScheme.secondary.withValues(alpha: 0.12),
            iconForegroundColor: colorScheme.secondary,
            titleMaxLines: 2,
            subtitleMaxLines: 1,
          ),
          const SizedBox(height: 10),
          AppInfoRow(
            title: pack.playbookControlTemplate.title,
            subtitle: pack.playbookControlTemplate.detail,
            icon: Icons.fact_check_outlined,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
            iconBackgroundColor: colorScheme.primary.withValues(alpha: 0.12),
            iconForegroundColor: colorScheme.primary,
            titleMaxLines: 2,
            subtitleMaxLines: 2,
          ),
          const SizedBox(height: 10),
          ProjectDomainRiskRulePreviewList(rules: pack.riskRules),
          const SizedBox(height: 10),
          AppInfoRow(
            title: milestoneLabels.join(' -> '),
            subtitle: 'Milestone pattern',
            icon: Icons.flag_outlined,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
            iconBackgroundColor: colorScheme.primary.withValues(alpha: 0.12),
            iconForegroundColor: colorScheme.primary,
            titleMaxLines: 2,
            subtitleMaxLines: 1,
          ),
          const SizedBox(height: 10),
          AppInfoRow(
            title:
                '${teamTemplate.leadRole}, ${teamTemplate.sponsorRole}, ${teamTemplate.supportRole}',
            subtitle: 'Starter role set',
            icon: Icons.groups_outlined,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
            iconBackgroundColor: colorScheme.primary.withValues(alpha: 0.12),
            iconForegroundColor: colorScheme.primary,
            titleMaxLines: 2,
            subtitleMaxLines: 1,
          ),
        ],
      ),
    );
  }
}
