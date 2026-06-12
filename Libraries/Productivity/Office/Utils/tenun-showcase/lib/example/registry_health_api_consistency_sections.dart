import 'package:flutter/material.dart';

import 'registry_health_api_conformance_checklist_panel.dart';
import 'registry_health_api_conformance_evidence_panel.dart';
import 'registry_health_api_conformance_gate_panel.dart';
import 'registry_health_api_conformance_panel.dart';
import 'registry_health_api_conformance_verification_panel.dart';
import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan_panel.dart';
import 'registry_health_api_consistency_attention_table.dart';
import 'registry_health_api_consistency_concern_summary_panel.dart';
import 'registry_health_api_consistency_family_remediation_panel.dart';
import 'registry_health_api_consistency_field_remediation_panel.dart';
import 'registry_health_api_consistency_implementation_plan_panel.dart';
import 'registry_health_api_consistency_panel_options.dart';
import 'registry_health_api_consistency_pipeline.dart';
import 'registry_health_api_consistency_primitive_remediation_panel.dart';
import 'registry_health_api_consistency_release_brief_panel.dart';
import 'registry_health_api_consistency_score_projection_panel.dart';
import 'registry_health_api_consistency_scorecard_panel.dart';
import 'registry_health_api_consistency_source_checklist_panel.dart';
import 'registry_health_api_consistency_source_milestones_panel.dart';
import 'registry_health_api_consistency_source_plan_panel.dart';
import 'registry_health_api_consistency_source_queue_panel.dart';
import 'registry_health_api_consistency_source_release_gates_panel.dart';
import 'registry_health_api_consistency_source_verification_panel.dart';
import 'registry_health_api_consistency_traceability_panel.dart';

class RegistryHealthApiConsistencySections extends StatelessWidget {
  const RegistryHealthApiConsistencySections({
    super.key,
    required this.report,
    required this.options,
  });

  final RegistryHealthApiConsistencyReport report;
  final RegistryHealthApiConsistencyPanelOptions options;

  @override
  Widget build(BuildContext context) {
    final pipeline = registryHealthApiConsistencyPipeline(report);
    final sections = _apiConsistencySectionRegistry(
      report: report,
      pipeline: pipeline,
      options: options,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildApiConsistencySections(sections),
    );
  }
}

class _ApiConsistencySection {
  const _ApiConsistencySection({
    required this.isVisible,
    required this.build,
    this.leading = const [],
    this.trailingSpacing = 12,
  });

  final bool isVisible;
  final Widget Function() build;
  final List<Widget> leading;
  final double trailingSpacing;
}

List<_ApiConsistencySection> _apiConsistencySectionRegistry({
  required RegistryHealthApiConsistencyReport report,
  required RegistryHealthApiConsistencyPipeline pipeline,
  required RegistryHealthApiConsistencyPanelOptions options,
}) {
  final actionPlan = pipeline.actionPlan;
  final scoreProjection = pipeline.scoreProjection;
  final releaseBrief = pipeline.releaseBrief;
  final conformance = pipeline.conformance;
  final conformanceGate = pipeline.conformanceGate;
  final conformanceVerification = pipeline.conformanceVerification;
  final conformanceChecklist = pipeline.conformanceChecklist;
  final conformanceEvidence = pipeline.conformanceEvidence;
  final implementationPlan = pipeline.implementationPlan;
  final traceabilityReport = pipeline.traceability;
  final sourceQueueReport = pipeline.sourceQueue;
  final sourcePlanReport = pipeline.sourcePlan;
  final sourceChecklistReport = pipeline.sourceChecklist;
  final sourceMilestonesReport = pipeline.sourceMilestones;
  final sourceReleaseGatesReport = pipeline.sourceReleaseGates;
  final sourceVerificationReport = pipeline.sourceVerification;
  final familyRemediation = pipeline.familyRemediation;
  final primitiveRemediation = pipeline.primitiveRemediation;
  final fieldRemediation = pipeline.fieldRemediation;
  final concernSummary = pipeline.concernSummary;

  return [
    _ApiConsistencySection(
      isVisible: options.showScorecard,
      build: () => RegistryHealthApiConsistencyScorecardPanel(
        scorecard: pipeline.scorecard,
      ),
    ),
    _ApiConsistencySection(
      isVisible: options.showScoreProjection && !scoreProjection.isClear,
      build: () => RegistryHealthApiConsistencyScoreProjectionPanel(
        projection: scoreProjection,
      ),
    ),
    _ApiConsistencySection(
      isVisible: options.showReleaseBrief && !releaseBrief.isClear,
      build: () => RegistryHealthApiConsistencyReleaseBriefPanel(
        report: releaseBrief,
        itemLimit: options.releaseBriefLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible: options.showConformance && !conformance.isClear,
      build: () => RegistryHealthApiConformancePanel(
        report: conformance,
        caseLimit: options.conformanceCaseLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible: options.showConformanceGate && !conformanceGate.isClear,
      build: () => RegistryHealthApiConformanceGatePanel(
        report: conformanceGate,
        gateLimit: options.conformanceGateLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible:
          options.showConformanceVerification &&
          !conformanceVerification.isClear,
      build: () => RegistryHealthApiConformanceVerificationPanel(
        report: conformanceVerification,
        verificationLimit: options.conformanceVerificationLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible:
          options.showConformanceChecklist && !conformanceChecklist.isClear,
      build: () => RegistryHealthApiConformanceChecklistPanel(
        report: conformanceChecklist,
        stepLimit: options.conformanceChecklistLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible:
          options.showConformanceEvidence && !conformanceEvidence.isClear,
      build: () => RegistryHealthApiConformanceEvidencePanel(
        report: conformanceEvidence,
        evidenceLimit: options.conformanceEvidenceLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible: options.showImplementationPlan && !implementationPlan.isClear,
      build: () => RegistryHealthApiConsistencyImplementationPlanPanel(
        plan: implementationPlan,
        actionLimit: options.actionLimit,
        familyLimit: options.familyLimit,
        primitiveLimit: options.primitiveLimit,
        fieldLimit: options.fieldLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible: options.showTraceability && !traceabilityReport.isClear,
      build: () => RegistryHealthApiConsistencyTraceabilityPanel(
        report: traceabilityReport,
        traceLimit: options.traceLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible: options.showSourceQueue && !sourceQueueReport.isClear,
      build: () => RegistryHealthApiConsistencySourceQueuePanel(
        report: sourceQueueReport,
        sourceLimit: options.sourceQueueLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible: options.showSourcePlan && !sourcePlanReport.isClear,
      build: () => RegistryHealthApiConsistencySourcePlanPanel(
        report: sourcePlanReport,
        batchLimit: options.sourcePlanLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible: options.showSourceChecklist && !sourceChecklistReport.isClear,
      build: () => RegistryHealthApiConsistencySourceChecklistPanel(
        report: sourceChecklistReport,
        stageLimit: options.sourceChecklistLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible:
          options.showSourceMilestones && !sourceMilestonesReport.isClear,
      build: () => RegistryHealthApiConsistencySourceMilestonesPanel(
        report: sourceMilestonesReport,
        milestoneLimit: options.sourceMilestoneLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible:
          options.showSourceReleaseGates && !sourceReleaseGatesReport.isClear,
      build: () => RegistryHealthApiConsistencySourceReleaseGatesPanel(
        report: sourceReleaseGatesReport,
        gateLimit: options.sourceReleaseGateLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible:
          options.showSourceVerification && !sourceVerificationReport.isClear,
      build: () => RegistryHealthApiConsistencySourceVerificationPanel(
        report: sourceVerificationReport,
        verificationLimit: options.sourceVerificationLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible: options.showFamilyRemediation && !familyRemediation.isClear,
      build: () => RegistryHealthApiConsistencyFamilyRemediationPanel(
        report: familyRemediation,
        familyLimit: options.familyLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible:
          options.showPrimitiveRemediation && !primitiveRemediation.isClear,
      build: () => RegistryHealthApiConsistencyPrimitiveRemediationPanel(
        report: primitiveRemediation,
        primitiveLimit: options.primitiveLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible: options.showFieldRemediation && !fieldRemediation.isClear,
      build: () => RegistryHealthApiConsistencyFieldRemediationPanel(
        report: fieldRemediation,
        fieldLimit: options.fieldLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible: options.showConcernSummary,
      build: () => RegistryHealthApiConsistencyConcernSummaryPanel(
        report: concernSummary,
        summaryLimit: options.concernLimit,
      ),
    ),
    _ApiConsistencySection(
      isVisible: options.showAttentionTable,
      build: () => RegistryHealthApiConsistencyAttentionTable(
        report: report,
        rowLimit: options.rowLimit,
      ),
      trailingSpacing: 0,
    ),
    _ApiConsistencySection(
      isVisible: options.showActionPlan && !actionPlan.isClear,
      leading: const [
        SizedBox(height: 14),
        Divider(height: 1),
        SizedBox(height: 12),
      ],
      build: () => RegistryHealthApiConsistencyActionPlanPanel(
        plan: actionPlan,
        actionLimit: options.actionLimit,
      ),
      trailingSpacing: 0,
    ),
  ];
}

List<Widget> _buildApiConsistencySections(
  List<_ApiConsistencySection> sections,
) {
  final widgets = <Widget>[];
  for (final section in sections) {
    if (!section.isVisible) continue;
    widgets
      ..addAll(section.leading)
      ..add(section.build());
    if (section.trailingSpacing > 0) {
      widgets.add(SizedBox(height: section.trailingSpacing));
    }
  }
  return widgets;
}
