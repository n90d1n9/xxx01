import 'registry_health_api_consistency.dart';
import 'registry_health_api_consistency_action_plan.dart';
import 'registry_health_api_consistency_concern_summary.dart';
import 'registry_health_api_consistency_family_remediation.dart';
import 'registry_health_api_consistency_field_remediation.dart';
import 'registry_health_api_consistency_implementation_plan.dart';
import 'registry_health_api_consistency_primitive_remediation.dart';
import 'registry_health_api_consistency_release_brief.dart';
import 'registry_health_api_consistency_release_brief_builder.dart';
import 'registry_health_api_consistency_score_projection.dart';
import 'registry_health_api_consistency_scorecard.dart';
import 'registry_health_api_consistency_source_checklist.dart';
import 'registry_health_api_consistency_source_milestones.dart';
import 'registry_health_api_consistency_source_plan.dart';
import 'registry_health_api_consistency_source_queue.dart';
import 'registry_health_api_consistency_source_release_gates.dart';
import 'registry_health_api_consistency_source_verification.dart';
import 'registry_health_api_consistency_traceability.dart';
import 'registry_health_api_conformance.dart';
import 'registry_health_api_conformance_checklist.dart';
import 'registry_health_api_conformance_evidence.dart';
import 'registry_health_api_conformance_gate.dart';
import 'registry_health_api_conformance_gate_builder.dart';
import 'registry_health_api_conformance_verification.dart';

class RegistryHealthApiConsistencyPipeline {
  final RegistryHealthApiConsistencyReport report;
  final RegistryHealthApiConsistencyScorecard scorecard;
  final RegistryHealthApiConsistencyActionPlan actionPlan;
  final RegistryHealthApiConsistencyScoreProjection scoreProjection;
  final RegistryHealthApiConsistencyImplementationPlan implementationPlan;
  final RegistryHealthApiConsistencyTraceabilityReport traceability;
  final RegistryHealthApiConsistencySourceQueueReport sourceQueue;
  final RegistryHealthApiConsistencySourcePlanReport sourcePlan;
  final RegistryHealthApiConsistencySourceChecklistReport sourceChecklist;
  final RegistryHealthApiConsistencySourceMilestonesReport sourceMilestones;
  final RegistryHealthApiConsistencySourceReleaseGatesReport sourceReleaseGates;
  final RegistryHealthApiConsistencySourceVerificationReport sourceVerification;
  final RegistryHealthApiConsistencyConcernSummaryReport concernSummary;
  final RegistryHealthApiConsistencyReleaseBriefReport releaseBrief;
  final RegistryHealthApiConformanceReport conformance;
  final RegistryHealthApiConformanceGateReport conformanceGate;
  final RegistryHealthApiConformanceVerificationReport conformanceVerification;
  final RegistryHealthApiConformanceChecklistReport conformanceChecklist;
  final RegistryHealthApiConformanceEvidenceReport conformanceEvidence;

  const RegistryHealthApiConsistencyPipeline({
    required this.report,
    required this.scorecard,
    required this.actionPlan,
    required this.scoreProjection,
    required this.implementationPlan,
    required this.traceability,
    required this.sourceQueue,
    required this.sourcePlan,
    required this.sourceChecklist,
    required this.sourceMilestones,
    required this.sourceReleaseGates,
    required this.sourceVerification,
    required this.concernSummary,
    required this.releaseBrief,
    required this.conformance,
    required this.conformanceGate,
    required this.conformanceVerification,
    required this.conformanceChecklist,
    required this.conformanceEvidence,
  });

  RegistryHealthApiConsistencyFamilyRemediationReport get familyRemediation =>
      implementationPlan.familyRemediation;

  RegistryHealthApiConsistencyPrimitiveRemediationReport
  get primitiveRemediation => implementationPlan.primitiveRemediation;

  RegistryHealthApiConsistencyFieldRemediationReport get fieldRemediation =>
      implementationPlan.fieldRemediation;

  Map<String, dynamic> toJsonSections() => {
    'apiConsistency': report.toJson(),
    'apiConsistencyScorecard': scorecard.toJson(),
    'apiConsistencyScoreProjection': scoreProjection.toJson(),
    'apiConsistencyActionPlan': actionPlan.toJson(),
    'apiConsistencyImplementationPlan': implementationPlan.toJson(),
    'apiConsistencyTraceability': traceability.toJson(),
    'apiConsistencySourceQueue': sourceQueue.toJson(),
    'apiConsistencySourcePlan': sourcePlan.toJson(),
    'apiConsistencySourceChecklist': sourceChecklist.toJson(),
    'apiConsistencySourceMilestones': sourceMilestones.toJson(),
    'apiConsistencySourceReleaseGates': sourceReleaseGates.toJson(),
    'apiConsistencySourceVerification': sourceVerification.toJson(),
    'apiConsistencyFamilyRemediation': familyRemediation.toJson(),
    'apiConsistencyPrimitiveRemediation': primitiveRemediation.toJson(),
    'apiConsistencyFieldRemediation': fieldRemediation.toJson(),
    'apiConsistencyConcernSummary': concernSummary.toJson(),
    'apiConsistencyReleaseBrief': releaseBrief.toJson(),
    'apiConsistencyConformance': conformance.toJson(),
    'apiConsistencyConformanceGate': conformanceGate.toJson(),
    'apiConsistencyConformanceVerification': conformanceVerification.toJson(),
    'apiConsistencyConformanceChecklist': conformanceChecklist.toJson(),
    'apiConsistencyConformanceEvidence': conformanceEvidence.toJson(),
  };
}

RegistryHealthApiConsistencyPipeline registryHealthApiConsistencyPipeline(
  RegistryHealthApiConsistencyReport report,
) {
  final scorecard = registryHealthApiConsistencyScorecard(report);
  final actionPlan = registryHealthApiConsistencyActionPlan(report);
  final scoreProjection = registryHealthApiConsistencyScoreProjection(
    scorecard: scorecard,
    actionPlan: actionPlan,
  );
  final implementationPlan = registryHealthApiConsistencyImplementationPlan(
    actionPlan,
  );
  final traceability = registryHealthApiConsistencyTraceabilityReport(
    implementationPlan,
  );
  final sourceQueue = registryHealthApiConsistencySourceQueueReport(
    traceability,
  );
  final sourcePlan = registryHealthApiConsistencySourcePlanReport(sourceQueue);
  final sourceChecklist = registryHealthApiConsistencySourceChecklistReport(
    sourcePlan,
  );
  final sourceMilestones = registryHealthApiConsistencySourceMilestonesReport(
    sourceChecklist,
  );
  final sourceReleaseGates =
      registryHealthApiConsistencySourceReleaseGatesReport(sourceMilestones);
  final sourceVerification =
      registryHealthApiConsistencySourceVerificationReport(sourceReleaseGates);
  final concernSummary = registryHealthApiConsistencyConcernSummaryReport(
    report,
  );
  final conformance = registryHealthApiConformanceReport(report);
  final conformanceGate = registryHealthApiConformanceGateReport(conformance);
  final conformanceVerification =
      registryHealthApiConformanceVerificationReport(conformanceGate);
  final conformanceChecklist = registryHealthApiConformanceChecklistReport(
    conformanceVerification,
  );
  final conformanceEvidence = registryHealthApiConformanceEvidenceReport(
    conformanceChecklist,
  );
  final releaseBrief = registryHealthApiConsistencyReleaseBriefReport(
    scoreProjection: scoreProjection,
    conformanceGate: conformanceGate,
    sourceReleaseGates: sourceReleaseGates,
    sourceVerification: sourceVerification,
    conformanceEvidence: conformanceEvidence,
  );

  return RegistryHealthApiConsistencyPipeline(
    report: report,
    scorecard: scorecard,
    actionPlan: actionPlan,
    scoreProjection: scoreProjection,
    implementationPlan: implementationPlan,
    traceability: traceability,
    sourceQueue: sourceQueue,
    sourcePlan: sourcePlan,
    sourceChecklist: sourceChecklist,
    sourceMilestones: sourceMilestones,
    sourceReleaseGates: sourceReleaseGates,
    sourceVerification: sourceVerification,
    concernSummary: concernSummary,
    releaseBrief: releaseBrief,
    conformance: conformance,
    conformanceGate: conformanceGate,
    conformanceVerification: conformanceVerification,
    conformanceChecklist: conformanceChecklist,
    conformanceEvidence: conformanceEvidence,
  );
}
