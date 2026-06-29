import 'package:flutter/material.dart';

import '../models/dashboard_action_detail.dart';
import '../models/dashboard_action_detail_section.dart';
import '../models/dashboard_action_detail_snapshot.dart';
import '../models/dashboard_action_evidence_timeline.dart';
import '../models/dashboard_action_execution_guidance.dart';
import '../models/dashboard_action_handoff_brief.dart';
import 'dashboard_action_detail_evidence_section.dart';
import 'dashboard_action_detail_overview_section.dart';
import 'dashboard_action_detail_playbook.dart';
import 'dashboard_action_execution_guidance_card.dart';
import 'dashboard_action_handoff_brief_card.dart';
import 'dashboard_action_impact_preview.dart';

class DashboardActionDetailSectionStack extends StatelessWidget {
  final DashboardActionDetail detail;
  final GlobalKey Function(DashboardActionDetailSection section) sectionKey;

  const DashboardActionDetailSectionStack({
    super.key,
    required this.detail,
    required this.sectionKey,
  });

  @override
  Widget build(BuildContext context) {
    final guidance = DashboardActionExecutionGuidance.fromStatus(
      status: detail.status,
      steps: detail.playbookSteps,
    );
    final snapshot = DashboardActionDetailSnapshot.fromDetail(detail);
    final timeline = DashboardActionEvidenceTimeline.fromDetail(detail);
    final handoffBrief = DashboardActionHandoffBrief.fromDetail(detail);

    return Column(
      children: _withSectionGaps([
        _buildOverviewSection(snapshot),
        _buildEvidenceSection(timeline),
        _buildHandoffSection(handoffBrief),
        _buildImpactSection(guidance),
        _buildPlaybookSection(guidance),
      ]),
    );
  }

  Widget _buildOverviewSection(DashboardActionDetailSnapshot snapshot) {
    return _SectionSlot(
      sectionKey: sectionKey(DashboardActionDetailSection.overview),
      child: DashboardActionDetailOverviewSection(
        detail: detail,
        snapshot: snapshot,
      ),
    );
  }

  Widget _buildEvidenceSection(DashboardActionEvidenceTimeline timeline) {
    return _SectionSlot(
      sectionKey: sectionKey(DashboardActionDetailSection.evidence),
      child: DashboardActionDetailEvidenceSection(
        detail: detail,
        timeline: timeline,
      ),
    );
  }

  Widget _buildHandoffSection(DashboardActionHandoffBrief handoffBrief) {
    return _SectionSlot(
      sectionKey: sectionKey(DashboardActionDetailSection.handoff),
      child: DashboardActionHandoffBriefCard(brief: handoffBrief),
    );
  }

  Widget _buildImpactSection(DashboardActionExecutionGuidance guidance) {
    return _SectionSlot(
      sectionKey: sectionKey(DashboardActionDetailSection.impact),
      children: [
        DashboardActionImpactPreview(impact: detail.impactEstimate),
        DashboardActionExecutionGuidanceCard(
          guidance: guidance,
          status: detail.status,
        ),
      ],
    );
  }

  Widget _buildPlaybookSection(DashboardActionExecutionGuidance guidance) {
    return _SectionSlot(
      sectionKey: sectionKey(DashboardActionDetailSection.playbook),
      child: DashboardActionDetailPlaybook(
        steps: detail.playbookSteps,
        activeStepIndex: guidance.activeStepIndex,
        marksAllStepsComplete: guidance.marksAllStepsComplete,
      ),
    );
  }
}

class _SectionSlot extends StatelessWidget {
  final GlobalKey sectionKey;
  final Widget? child;
  final List<Widget> children;

  const _SectionSlot({
    required this.sectionKey,
    this.child,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    final content = child ?? Column(children: _withSectionGaps(children));

    return KeyedSubtree(key: sectionKey, child: content);
  }
}

List<Widget> _withSectionGaps(List<Widget> children) {
  final spacedChildren = <Widget>[];

  for (final child in children) {
    if (spacedChildren.isNotEmpty) {
      spacedChildren.add(const SizedBox(height: 12));
    }
    spacedChildren.add(child);
  }

  return spacedChildren;
}
