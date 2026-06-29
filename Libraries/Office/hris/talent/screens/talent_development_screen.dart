import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_decision_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_ramp_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_skill_fit_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/recruitment/widgets/candidate_decision_panel.dart';
import 'package:kaysir/features/hris/recruitment/widgets/candidate_development_calibration_panel.dart';
import 'package:kaysir/features/hris/recruitment/widgets/candidate_development_check_in_panel.dart';
import 'package:kaysir/features/hris/recruitment/widgets/candidate_development_intervention_panel.dart';
import 'package:kaysir/features/hris/recruitment/widgets/candidate_development_panel.dart';
import 'package:kaysir/features/hris/recruitment/widgets/candidate_ramp_action_panel.dart';
import 'package:kaysir/features/hris/recruitment/widgets/candidate_ramp_panel.dart';
import 'package:kaysir/features/hris/recruitment/widgets/candidate_skill_evidence_panel.dart';
import 'package:kaysir/features/hris/recruitment/widgets/candidate_skill_fit_panel.dart';
import 'package:kaysir/features/hris/recruitment/widgets/candidate_talent_handoff_panel.dart';
import 'package:kaysir/features/hris/recruitment/widgets/candidate_talent_handoff_checklist_panel.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/talent_provider.dart';
import '../states/incoming_talent_readiness_provider.dart';
import '../widgets/certification_panel.dart';
import '../widgets/incoming_talent_activation_checkpoint_panel.dart';
import '../widgets/incoming_talent_activation_follow_up_panel.dart';
import '../widgets/incoming_talent_activation_outcome_panel.dart';
import '../widgets/incoming_talent_activation_panel.dart';
import '../widgets/incoming_talent_calibration_panel.dart';
import '../widgets/incoming_talent_career_framework_level_panel.dart';
import '../widgets/incoming_talent_career_path_panel.dart';
import '../widgets/incoming_talent_career_path_review_panel.dart';
import '../widgets/incoming_talent_career_path_support_action_panel.dart';
import '../widgets/incoming_talent_career_path_support_outcome_panel.dart';
import '../widgets/incoming_talent_development_check_in_panel.dart';
import '../widgets/incoming_talent_development_intervention_panel.dart';
import '../widgets/incoming_talent_development_intervention_outcome_follow_up_panel.dart';
import '../widgets/incoming_talent_development_intervention_outcome_follow_up_resolution_panel.dart';
import '../widgets/incoming_talent_development_intervention_outcome_panel.dart';
import '../widgets/incoming_talent_development_portfolio_panel.dart';
import '../widgets/incoming_talent_development_program_completion_panel.dart';
import '../widgets/incoming_talent_development_program_milestone_panel.dart';
import '../widgets/incoming_talent_development_program_panel.dart';
import '../widgets/incoming_talent_development_roadmap_panel.dart';
import '../widgets/incoming_talent_growth_alignment_panel.dart';
import '../widgets/incoming_talent_governance_command_center_panel.dart';
import '../widgets/incoming_talent_governance_execution_closure_panel.dart';
import '../widgets/incoming_talent_governance_decision_ledger_panel.dart';
import '../widgets/incoming_talent_governance_execution_action_panel.dart';
import '../widgets/incoming_talent_governance_execution_evidence_panel.dart';
import '../widgets/incoming_talent_governance_execution_owner_workload_panel.dart';
import '../widgets/incoming_talent_governance_execution_panel.dart';
import '../widgets/incoming_talent_governance_review_pack_panel.dart';
import '../widgets/incoming_talent_governance_review_readiness_panel.dart';
import '../widgets/incoming_talent_health_dashboard_panel.dart';
import '../widgets/incoming_talent_mobility_first_review_panel.dart';
import '../widgets/incoming_talent_mobility_cadence_intervention_panel.dart';
import '../widgets/incoming_talent_mobility_cadence_intervention_outcome_panel.dart';
import '../widgets/incoming_talent_mobility_cadence_panel.dart';
import '../widgets/incoming_talent_mobility_launch_panel.dart';
import '../widgets/incoming_talent_mobility_match_panel.dart';
import '../widgets/incoming_talent_mobility_stabilization_outcome_panel.dart';
import '../widgets/incoming_talent_mobility_stabilization_panel.dart';
import '../widgets/incoming_talent_operating_assurance_panel.dart';
import '../widgets/incoming_talent_operating_assurance_execution_panel.dart';
import '../widgets/incoming_talent_operating_assurance_remediation_panel.dart';
import '../widgets/incoming_talent_operating_cadence_forecast_panel.dart';
import '../widgets/incoming_talent_operating_escalation_board_panel.dart';
import '../widgets/incoming_talent_operating_evidence_gap_panel.dart';
import '../widgets/incoming_talent_operating_inbox_panel.dart';
import '../widgets/incoming_talent_operating_inbox_owner_digest_panel.dart';
import '../widgets/incoming_talent_operating_inbox_owner_rebalance_panel.dart';
import '../widgets/incoming_talent_operating_sla_panel.dart';
import '../widgets/incoming_talent_operating_workstream_pressure_panel.dart';
import '../widgets/incoming_talent_profile_timeline_panel.dart';
import '../widgets/incoming_talent_promotion_decision_panel.dart';
import '../widgets/incoming_talent_promotion_implementation_panel.dart';
import '../widgets/incoming_talent_promotion_readiness_panel.dart';
import '../widgets/incoming_talent_promotion_stabilization_follow_up_action_panel.dart';
import '../widgets/incoming_talent_promotion_stabilization_follow_up_resolution_panel.dart';
import '../widgets/incoming_talent_promotion_stabilization_review_panel.dart';
import '../widgets/incoming_talent_readiness_panel.dart';
import '../widgets/incoming_talent_risk_council_agenda_panel.dart';
import '../widgets/incoming_talent_risk_council_brief_panel.dart';
import '../widgets/incoming_talent_risk_council_commitment_action_panel.dart';
import '../widgets/incoming_talent_risk_council_commitment_log_panel.dart';
import '../widgets/incoming_talent_risk_council_commitment_owner_rebalance_panel.dart';
import '../widgets/incoming_talent_risk_council_commitment_owner_workload_panel.dart';
import '../widgets/incoming_talent_risk_council_decision_panel.dart';
import '../widgets/incoming_talent_risk_council_follow_up_panel.dart';
import '../widgets/incoming_talent_risk_council_queue_panel.dart';
import '../widgets/incoming_talent_risk_council_readiness_checklist_panel.dart';
import '../widgets/incoming_talent_risk_council_sla_panel.dart';
import '../widgets/incoming_talent_risk_council_source_filter_bar.dart';
import '../widgets/incoming_talent_risk_council_source_drill_down_panel.dart';
import '../widgets/incoming_talent_risk_council_source_pressure_panel.dart';
import '../widgets/incoming_talent_succession_activation_check_in_panel.dart';
import '../widgets/incoming_talent_succession_activation_closure_panel.dart';
import '../widgets/incoming_talent_succession_activation_escalation_panel.dart';
import '../widgets/incoming_talent_succession_activation_panel.dart';
import '../widgets/incoming_talent_succession_activation_resolution_review_panel.dart';
import '../widgets/incoming_talent_succession_bench_action_panel.dart';
import '../widgets/incoming_talent_succession_bench_check_in_panel.dart';
import '../widgets/incoming_talent_succession_bench_replenishment_panel.dart';
import '../widgets/incoming_talent_succession_coverage_action_panel.dart';
import '../widgets/incoming_talent_succession_coverage_action_outcome_panel.dart';
import '../widgets/incoming_talent_succession_coverage_council_agenda_panel.dart';
import '../widgets/incoming_talent_succession_coverage_council_decision_panel.dart';
import '../widgets/incoming_talent_succession_coverage_council_follow_up_panel.dart';
import '../widgets/incoming_talent_succession_coverage_dashboard_panel.dart';
import '../widgets/incoming_talent_succession_coverage_governance_panel.dart';
import '../widgets/incoming_talent_succession_coverage_review_panel.dart';
import '../widgets/incoming_talent_succession_coverage_sla_panel.dart';
import '../widgets/incoming_talent_succession_nomination_panel.dart';
import '../widgets/incoming_talent_succession_panel_decision_panel.dart';
import '../widgets/incoming_talent_succession_panel.dart';
import '../widgets/incoming_talent_succession_transition_intervention_panel.dart';
import '../widgets/incoming_talent_succession_transition_outcome_review_panel.dart';
import '../widgets/incoming_talent_succession_transition_pulse_panel.dart';
import '../widgets/incoming_talent_training_session_panel.dart';
import '../widgets/learning_plan_panel.dart';
import '../widgets/mentorship_panel.dart';
import '../widgets/skill_matrix_panel.dart';
import '../widgets/talent_summary_grid.dart';

class TalentDevelopmentScreen extends ConsumerWidget {
  const TalentDevelopmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(talentDepartmentsProvider);
    final selectedDepartment = ref.watch(talentDepartmentProvider);
    final attentionOnly = ref.watch(talentNeedsAttentionProvider);
    final summary = ref.watch(talentSummaryProvider);
    final skillGaps = ref.watch(filteredSkillGapsProvider);
    final learningPlans = ref.watch(filteredLearningPlansProvider);
    final certifications = ref.watch(filteredCertificationsProvider);
    final mentorshipPairs = ref.watch(filteredMentorshipPairsProvider);
    final rampPlans = ref.watch(filteredTalentCandidateRampPlansProvider);
    final rampSummary = ref.watch(talentCandidateRampSummaryProvider);
    final skillFitProfiles = ref.watch(
      filteredTalentCandidateSkillFitProfilesProvider,
    );
    final skillFitSummary = ref.watch(talentCandidateSkillFitSummaryProvider);
    final decisionPackets = ref.watch(
      filteredTalentCandidateDecisionPacketsProvider,
    );
    final decisionSummary = ref.watch(talentCandidateDecisionSummaryProvider);
    final incomingReadiness = ref.watch(
      filteredIncomingTalentReadinessWithDevelopmentEvidenceProvider,
    );
    final incomingReadinessSummary = ref.watch(
      incomingTalentReadinessWithDevelopmentEvidenceSummaryProvider,
    );
    final rampAsOfDate = ref.watch(recruitmentAsOfDateProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Talent Development'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(skillGapsProvider);
              ref.invalidate(learningPlansProvider);
              ref.invalidate(certificationsProvider);
              ref.invalidate(mentorshipPairsProvider);
              ref.invalidate(candidateRampPlansProvider);
            },
          ),
          IconButton(
            tooltip: 'Export',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Talent snapshot exported')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisCommandHeader(
                icon: Icons.psychology_alt_outlined,
                title: 'Talent Growth Center',
                subtitle:
                    'Skills, learning plans, certifications, and mentorship health',
                departments: departments,
                selectedDepartment: selectedDepartment,
                attentionOnly: attentionOnly,
                attentionLabel: 'Needs coaching',
                onDepartmentChanged: (value) {
                  if (value != null) {
                    ref.read(talentDepartmentProvider.notifier).state = value;
                  }
                },
                onAttentionChanged: (value) {
                  ref.read(talentNeedsAttentionProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 16),
              TalentSummaryGrid(summary: summary),
              const SizedBox(height: 16),
              const IncomingTalentRiskCouncilSourceFilterBar(),
              const SizedBox(height: 16),
              HrisResponsivePanelGrid(
                breakpoint: 920,
                panels: [
                  const IncomingTalentGovernanceCommandCenterPanel(),
                  const IncomingTalentGovernanceReviewPackPanel(),
                  const IncomingTalentGovernanceReviewReadinessPanel(),
                  const IncomingTalentGovernanceDecisionLedgerPanel(),
                  const IncomingTalentGovernanceExecutionPanel(),
                  const IncomingTalentGovernanceExecutionActionPanel(),
                  const IncomingTalentGovernanceExecutionOwnerWorkloadPanel(),
                  const IncomingTalentGovernanceExecutionClosurePanel(),
                  const IncomingTalentGovernanceExecutionEvidencePanel(),
                  const IncomingTalentHealthDashboardPanel(),
                  const IncomingTalentOperatingInboxPanel(),
                  const IncomingTalentOperatingInboxOwnerDigestPanel(),
                  const IncomingTalentOperatingInboxOwnerRebalancePanel(),
                  const IncomingTalentOperatingWorkstreamPressurePanel(),
                  const IncomingTalentOperatingCadenceForecastPanel(),
                  const IncomingTalentOperatingEscalationBoardPanel(),
                  const IncomingTalentOperatingEvidenceGapPanel(),
                  const IncomingTalentOperatingAssurancePanel(),
                  const IncomingTalentOperatingAssuranceRemediationPanel(),
                  const IncomingTalentOperatingAssuranceExecutionPanel(),
                  const IncomingTalentOperatingSlaPanel(),
                  const IncomingTalentRiskCouncilQueuePanel(),
                  const IncomingTalentRiskCouncilDecisionPanel(),
                  const IncomingTalentRiskCouncilFollowUpPanel(),
                  const IncomingTalentRiskCouncilSlaPanel(),
                  const IncomingTalentRiskCouncilSourcePressurePanel(),
                  const IncomingTalentRiskCouncilSourceDrillDownPanel(),
                  const IncomingTalentRiskCouncilBriefPanel(),
                  const IncomingTalentRiskCouncilReadinessChecklistPanel(),
                  const IncomingTalentRiskCouncilAgendaPanel(),
                  const IncomingTalentRiskCouncilCommitmentLogPanel(),
                  const IncomingTalentRiskCouncilCommitmentActionPanel(),
                  const IncomingTalentRiskCouncilCommitmentOwnerWorkloadPanel(),
                  const IncomingTalentRiskCouncilCommitmentOwnerRebalancePanel(),
                  SkillMatrixPanel(skillGaps: skillGaps),
                  CandidateSkillFitPanel(
                    title: 'Incoming skill fit',
                    subtitle:
                        '${skillFitSummary.totalProfiles} hire scorecards',
                    profiles: skillFitProfiles,
                    summary: skillFitSummary,
                  ),
                  CandidateSkillEvidencePanel(
                    title: 'Incoming evidence',
                    subtitle: 'Capture skill proof for talent handoff',
                    profiles: skillFitProfiles,
                  ),
                  CandidateDecisionPanel(
                    title: 'Talent handoff decisions',
                    subtitle:
                        '${decisionSummary.totalPackets} onboarding gates',
                    packets: decisionPackets,
                    summary: decisionSummary,
                    asOfDate: rampAsOfDate,
                  ),
                  CandidateDevelopmentPanel(
                    title: 'Incoming development goals',
                    subtitle: '${decisionPackets.length} handoff objectives',
                    packets: decisionPackets,
                    asOfDate: rampAsOfDate,
                  ),
                  CandidateDevelopmentCheckInPanel(
                    title: 'Development check-ins',
                    subtitle: 'Confidence, blockers, and next reviews',
                    packets: decisionPackets,
                    asOfDate: rampAsOfDate,
                  ),
                  CandidateDevelopmentInterventionPanel(
                    title: 'Development interventions',
                    subtitle: 'Coaching, blockers, and escalation actions',
                    packets: decisionPackets,
                    asOfDate: rampAsOfDate,
                  ),
                  CandidateDevelopmentCalibrationPanel(
                    title: 'Development calibration',
                    subtitle: 'Readiness review for talent handoff',
                    packets: decisionPackets,
                    asOfDate: rampAsOfDate,
                  ),
                  CandidateTalentHandoffPanel(
                    title: 'Candidate talent handoff',
                    subtitle: 'Manager ownership before ramp execution',
                    packets: decisionPackets,
                    asOfDate: rampAsOfDate,
                  ),
                  CandidateTalentHandoffChecklistPanel(
                    title: 'Handoff checklist',
                    subtitle: 'Operational readiness before ramp execution',
                    packets: decisionPackets,
                    asOfDate: rampAsOfDate,
                  ),
                  IncomingTalentReadinessPanel(
                    readiness: incomingReadiness,
                    summary: incomingReadinessSummary,
                  ),
                  IncomingTalentActivationPanel(readiness: incomingReadiness),
                  const IncomingTalentActivationCheckpointPanel(),
                  const IncomingTalentActivationFollowUpPanel(),
                  const IncomingTalentActivationOutcomePanel(),
                  const IncomingTalentDevelopmentRoadmapPanel(),
                  const IncomingTalentDevelopmentPortfolioPanel(),
                  const IncomingTalentDevelopmentProgramPanel(),
                  const IncomingTalentTrainingSessionPanel(),
                  const IncomingTalentDevelopmentProgramMilestonePanel(),
                  const IncomingTalentDevelopmentProgramCompletionPanel(),
                  const IncomingTalentGrowthAlignmentPanel(),
                  const IncomingTalentCareerFrameworkLevelPanel(),
                  const IncomingTalentCareerPathPanel(),
                  const IncomingTalentPromotionReadinessPanel(),
                  const IncomingTalentPromotionDecisionPanel(),
                  const IncomingTalentPromotionImplementationPanel(),
                  const IncomingTalentPromotionStabilizationReviewPanel(),
                  const IncomingTalentPromotionStabilizationFollowUpActionPanel(),
                  const IncomingTalentPromotionStabilizationFollowUpResolutionPanel(),
                  const IncomingTalentCareerPathReviewPanel(),
                  const IncomingTalentCareerPathSupportActionPanel(),
                  const IncomingTalentCareerPathSupportOutcomePanel(),
                  const IncomingTalentDevelopmentCheckInPanel(),
                  const IncomingTalentDevelopmentInterventionPanel(),
                  const IncomingTalentDevelopmentInterventionOutcomePanel(),
                  const IncomingTalentDevelopmentInterventionOutcomeFollowUpPanel(),
                  const IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionPanel(),
                  const IncomingTalentCalibrationPanel(),
                  const IncomingTalentProfileTimelinePanel(),
                  const IncomingTalentSuccessionCoverageDashboardPanel(),
                  const IncomingTalentSuccessionCoverageReviewPanel(),
                  const IncomingTalentSuccessionCoverageActionPanel(),
                  const IncomingTalentSuccessionCoverageActionOutcomePanel(),
                  const IncomingTalentSuccessionCoverageGovernancePanel(),
                  const IncomingTalentSuccessionCoverageCouncilAgendaPanel(),
                  const IncomingTalentSuccessionCoverageCouncilDecisionPanel(),
                  const IncomingTalentSuccessionCoverageCouncilFollowUpPanel(),
                  const IncomingTalentSuccessionCoverageSlaPanel(),
                  const IncomingTalentSuccessionPanel(),
                  const IncomingTalentSuccessionNominationPanel(),
                  const IncomingTalentSuccessionPanelDecisionPanel(),
                  const IncomingTalentMobilityMatchPanel(),
                  const IncomingTalentMobilityLaunchPanel(),
                  const IncomingTalentMobilityFirstReviewPanel(),
                  const IncomingTalentMobilityStabilizationPanel(),
                  const IncomingTalentMobilityStabilizationOutcomePanel(),
                  const IncomingTalentMobilityCadencePanel(),
                  const IncomingTalentMobilityCadenceInterventionPanel(),
                  const IncomingTalentMobilityCadenceInterventionOutcomePanel(),
                  const IncomingTalentSuccessionActivationPanel(),
                  const IncomingTalentSuccessionActivationCheckInPanel(),
                  const IncomingTalentSuccessionActivationEscalationPanel(),
                  const IncomingTalentSuccessionActivationResolutionReviewPanel(),
                  const IncomingTalentSuccessionActivationClosurePanel(),
                  const IncomingTalentSuccessionTransitionPulsePanel(),
                  const IncomingTalentSuccessionTransitionInterventionPanel(),
                  const IncomingTalentSuccessionTransitionOutcomeReviewPanel(),
                  const IncomingTalentSuccessionBenchReplenishmentPanel(),
                  const IncomingTalentSuccessionBenchCheckInPanel(),
                  const IncomingTalentSuccessionBenchActionPanel(),
                  CandidateRampPanel(
                    title: 'Hiring ramp plans',
                    subtitle: '${rampSummary.totalPlans} incoming talent plans',
                    plans: rampPlans,
                    summary: rampSummary,
                    asOfDate: rampAsOfDate,
                  ),
                  CandidateRampActionPanel(
                    title: 'Talent ramp form',
                    subtitle: 'Assign mentor, learning, and readiness dates',
                    plans: rampPlans,
                  ),
                  LearningPlanPanel(plans: learningPlans),
                  CertificationPanel(certifications: certifications),
                  MentorshipPanel(pairs: mentorshipPairs),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
