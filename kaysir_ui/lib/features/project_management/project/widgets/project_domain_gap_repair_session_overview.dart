import 'package:flutter/material.dart';

import '../services/project_domain_gap_repair_impact_service.dart';
import '../services/project_domain_gap_repair_service.dart';
import '../services/project_domain_gap_repair_session_focus_service.dart';
import '../services/project_domain_gap_repair_session_path_service.dart';
import '../services/project_domain_gap_repair_session_playbook_service.dart';
import '../services/project_domain_gap_repair_session_service.dart';
import 'project_domain_gap_repair_impact_strip.dart';
import 'project_domain_gap_repair_session_focus_strip.dart';
import 'project_domain_gap_repair_session_path_strip.dart';
import 'project_domain_gap_repair_session_playbook_strip.dart';
import 'project_domain_gap_repair_session_strip.dart';

class ProjectDomainGapRepairSessionOverview extends StatelessWidget {
  const ProjectDomainGapRepairSessionOverview({
    required this.plan,
    required this.onRepair,
    super.key,
  });

  final ProjectDomainGapRepairPlan plan;
  final ValueChanged<ProjectDomainGapRepairTarget> onRepair;

  @override
  Widget build(BuildContext context) {
    if (plan.isEmpty) return const SizedBox.shrink();

    final impactSummary = buildProjectDomainGapRepairImpactSummary(plan: plan);
    final sessionSummary = buildProjectDomainGapRepairSessionSummary(
      plan: plan,
    );
    final sessionFocusSummary = buildProjectDomainGapRepairSessionFocusSummary(
      plan: plan,
    );
    final sessionPathSummary = buildProjectDomainGapRepairSessionPathSummary(
      plan: plan,
    );
    final sessionPlaybookSummary =
        buildProjectDomainGapRepairSessionPlaybookSummary(plan: plan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectDomainGapRepairImpactStrip(summary: impactSummary),
        const SizedBox(height: 10),
        ProjectDomainGapRepairSessionFocusStrip(summary: sessionFocusSummary),
        const SizedBox(height: 10),
        ProjectDomainGapRepairSessionPlaybookStrip(
          summary: sessionPlaybookSummary,
        ),
        const SizedBox(height: 10),
        ProjectDomainGapRepairSessionStrip(
          summary: sessionSummary,
          onRepair: onRepair,
        ),
        if (sessionPathSummary.hasPath) ...[
          const SizedBox(height: 10),
          ProjectDomainGapRepairSessionPathStrip(
            summary: sessionPathSummary,
            onRepair: onRepair,
          ),
        ],
      ],
    );
  }
}
