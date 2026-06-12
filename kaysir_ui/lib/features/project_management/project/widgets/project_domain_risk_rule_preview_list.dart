import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/project_domain_pack.dart';
import '../models/project_portfolio_item.dart';

class ProjectDomainRiskRulePreviewList extends StatelessWidget {
  const ProjectDomainRiskRulePreviewList({
    required this.rules,
    this.maxItems = 3,
    super.key,
  });

  final List<ProjectDomainRiskRule> rules;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return AppInfoRow(
        title: 'No domain risk signals',
        subtitle:
            'This domain pack does not define automated risk prompts yet.',
        icon: Icons.shield_outlined,
        iconStyle: AppInfoRowIconStyle.badge,
        contained: true,
        iconBackgroundColor: colorScheme.surfaceContainerHighest,
        iconForegroundColor: colorScheme.onSurfaceVariant,
        titleMaxLines: 2,
        subtitleMaxLines: 2,
      );
    }

    final visibleLimit =
        maxItems == null ? rules.length : maxItems!.clamp(0, rules.length);
    final visibleRules = rules.take(visibleLimit).toList();
    final hiddenCount = rules.length - visibleRules.length;

    return Column(
      children: [
        for (var index = 0; index < visibleRules.length; index++) ...[
          _ProjectDomainRiskRuleRow(rule: visibleRules[index]),
          if (index != visibleRules.length - 1) const SizedBox(height: 10),
        ],
        if (hiddenCount > 0) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: AppStatusPill(
              label: '+$hiddenCount more risk signals',
              icon: Icons.more_horiz_rounded,
              color: Theme.of(context).colorScheme.primary,
              maxWidth: 190,
            ),
          ),
        ],
      ],
    );
  }
}

class _ProjectDomainRiskRuleRow extends StatelessWidget {
  const _ProjectDomainRiskRuleRow({required this.rule});

  final ProjectDomainRiskRule rule;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final severity = _severityFor(rule.severityId);
    final severityColor = severity.color(colorScheme);

    return AppInfoRow(
      title: rule.title,
      subtitle: '${_triggerLabel(rule)} - ${rule.detail}',
      icon: _triggerIcon(rule.trigger),
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: severityColor.withValues(alpha: 0.12),
      iconForegroundColor: severityColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: severity.label,
        icon: severity.icon,
        color: severityColor,
        maxWidth: 116,
      ),
    );
  }

  String _triggerLabel(ProjectDomainRiskRule rule) {
    switch (rule.trigger) {
      case ProjectDomainRiskRuleTrigger.missingAttribute:
        return 'Missing field';
      case ProjectDomainRiskRuleTrigger.attributeEquals:
        return 'Equals ${rule.expectedValue}';
      case ProjectDomainRiskRuleTrigger.booleanMissing:
        return 'Unconfirmed';
      case ProjectDomainRiskRuleTrigger.booleanFalse:
        return 'No or disabled';
      case ProjectDomainRiskRuleTrigger.booleanTrue:
        return 'Yes or enabled';
      case ProjectDomainRiskRuleTrigger.numberAtLeast:
        return 'At least ${_formatNumber(rule.threshold)}';
      case ProjectDomainRiskRuleTrigger.attributeEqualsWhenProgressBelow:
        return '${rule.expectedValue} before ${(rule.progressBelow * 100).round()}% progress';
    }
  }

  IconData _triggerIcon(ProjectDomainRiskRuleTrigger trigger) {
    switch (trigger) {
      case ProjectDomainRiskRuleTrigger.missingAttribute:
      case ProjectDomainRiskRuleTrigger.booleanMissing:
        return Icons.manage_search_outlined;
      case ProjectDomainRiskRuleTrigger.attributeEquals:
        return Icons.tune_outlined;
      case ProjectDomainRiskRuleTrigger.booleanFalse:
        return Icons.toggle_off_outlined;
      case ProjectDomainRiskRuleTrigger.booleanTrue:
        return Icons.toggle_on_outlined;
      case ProjectDomainRiskRuleTrigger.numberAtLeast:
        return Icons.pin_outlined;
      case ProjectDomainRiskRuleTrigger.attributeEqualsWhenProgressBelow:
        return Icons.timeline_outlined;
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(1);
  }

  ProjectHealth _severityFor(String severityId) {
    switch (severityId) {
      case 'blocked':
        return ProjectHealth.blocked;
      case 'atRisk':
        return ProjectHealth.atRisk;
      case 'onTrack':
      default:
        return ProjectHealth.onTrack;
    }
  }
}
