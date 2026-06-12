import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/project_form_draft.dart';
import '../models/project_portfolio_item.dart';
import '../services/project_domain_milestone_template_service.dart';
import '../services/project_domain_risk_template_service.dart';
import '../services/project_domain_team_template_service.dart';

class ProjectDraftPreviewPanel extends StatelessWidget {
  const ProjectDraftPreviewPanel({required this.draft, super.key});

  final ProjectFormDraft draft;

  @override
  Widget build(BuildContext context) {
    final milestones = const ProjectDomainMilestoneTemplateService()
        .buildMilestones(draft);
    final risks = const ProjectDomainRiskTemplateService().buildRisks(draft);
    final team = const ProjectDomainTeamTemplateService().buildTeam(draft);

    return AppContentPanel(
      title: 'Draft Preview',
      subtitle: 'Domain-specific milestone plan and saved intake state.',
      leadingIcon: Icons.fact_check_outlined,
      elevated: false,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppStatusPill(
            label: draft.businessDomain,
            icon: Icons.category_outlined,
            color: Theme.of(context).colorScheme.primary,
            maxWidth: 220,
          ),
          AppStatusPill(
            label:
                draft.name.trim().isEmpty
                    ? 'Unnamed project'
                    : draft.name.trim(),
            icon: Icons.work_outline,
            color: Theme.of(context).colorScheme.secondary,
            maxWidth: 240,
          ),
          AppStatusPill(
            label: '${draft.durationDays.clamp(0, 999)} days',
            icon: Icons.date_range_outlined,
            color: Colors.green.shade700,
            maxWidth: 130,
          ),
          AppStatusPill(
            label:
                '${draft.customAttributes.where((item) => item.hasValue).length} custom',
            icon: Icons.extension_outlined,
            color: Colors.blueGrey.shade700,
            maxWidth: 130,
          ),
          AppStatusPill(
            label: milestones.length > 1 ? milestones[1].label : 'Milestones',
            icon: Icons.flag_outlined,
            color: Colors.deepPurple.shade600,
            maxWidth: 260,
          ),
          AppStatusPill(
            label: risks.isEmpty ? 'No risk signals' : risks.first.title,
            icon: Icons.health_and_safety_outlined,
            color:
                risks.firstOrNull?.severity.color(
                  Theme.of(context).colorScheme,
                ) ??
                Colors.green.shade700,
            maxWidth: 260,
          ),
          AppStatusPill(
            label: '${team.length} starter roles',
            icon: Icons.groups_outlined,
            color: Theme.of(context).colorScheme.tertiary,
            maxWidth: 150,
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;

    return iterator.current;
  }
}
