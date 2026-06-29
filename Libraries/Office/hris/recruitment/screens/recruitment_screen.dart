import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/candidate_ramp_provider.dart';
import '../states/candidate_decision_provider.dart';
import '../states/candidate_skill_fit_provider.dart';
import '../states/recruitment_provider.dart';
import '../widgets/candidate_ramp_action_panel.dart';
import '../widgets/candidate_ramp_panel.dart';
import '../widgets/candidate_decision_panel.dart';
import '../widgets/candidate_development_calibration_panel.dart';
import '../widgets/candidate_development_check_in_panel.dart';
import '../widgets/candidate_development_intervention_panel.dart';
import '../widgets/candidate_development_panel.dart';
import '../widgets/candidate_pipeline_panel.dart';
import '../widgets/candidate_skill_evidence_panel.dart';
import '../widgets/candidate_skill_fit_panel.dart';
import '../widgets/candidate_talent_handoff_panel.dart';
import '../widgets/candidate_talent_handoff_checklist_panel.dart';
import '../widgets/interview_schedule_panel.dart';
import '../widgets/offer_tracker_panel.dart';
import '../widgets/recruitment_summary_grid.dart';
import '../widgets/requisition_panel.dart';
import '../widgets/source_effectiveness_panel.dart';

class RecruitmentScreen extends ConsumerWidget {
  const RecruitmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(recruitmentDepartmentsProvider);
    final selectedDepartment = ref.watch(recruitmentDepartmentProvider);
    final priorityOnly = ref.watch(recruitmentPriorityOnlyProvider);
    final summary = ref.watch(recruitmentSummaryProvider);
    final requisitions = ref.watch(filteredJobRequisitionsProvider);
    final candidates = ref.watch(filteredCandidateProfilesProvider);
    final interviews = ref.watch(filteredInterviewSlotsProvider);
    final offers = ref.watch(filteredOfferTrackersProvider);
    final sources = ref.watch(filteredSourceMetricsProvider);
    final rampPlans = ref.watch(filteredRecruitmentCandidateRampPlansProvider);
    final rampSummary = ref.watch(recruitmentCandidateRampSummaryProvider);
    final skillFitProfiles = ref.watch(
      filteredRecruitmentCandidateSkillFitProfilesProvider,
    );
    final skillFitSummary = ref.watch(
      recruitmentCandidateSkillFitSummaryProvider,
    );
    final decisionPackets = ref.watch(
      filteredRecruitmentCandidateDecisionPacketsProvider,
    );
    final decisionSummary = ref.watch(
      recruitmentCandidateDecisionSummaryProvider,
    );
    final asOfDate = ref.watch(recruitmentAsOfDateProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Recruitment Center'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(jobRequisitionsProvider);
              ref.invalidate(candidateProfilesProvider);
              ref.invalidate(interviewSlotsProvider);
              ref.invalidate(offerTrackersProvider);
              ref.invalidate(sourceMetricsProvider);
              ref.invalidate(candidateRampPlansProvider);
            },
          ),
          IconButton(
            tooltip: 'New requisition',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New requisition draft created')),
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
                icon: Icons.manage_search_outlined,
                title: 'Recruiting Command Center',
                subtitle: 'Requisitions, pipeline, interviews, and offers',
                departments: departments,
                selectedDepartment: selectedDepartment,
                attentionOnly: priorityOnly,
                attentionLabel: 'Priority hiring',
                onDepartmentChanged: (value) {
                  if (value != null) {
                    ref.read(recruitmentDepartmentProvider.notifier).state =
                        value;
                  }
                },
                onAttentionChanged: (value) {
                  ref.read(recruitmentPriorityOnlyProvider.notifier).state =
                      value;
                },
              ),
              const SizedBox(height: 16),
              RecruitmentSummaryGrid(summary: summary),
              const SizedBox(height: 16),
              HrisResponsivePanelGrid(
                breakpoint: 920,
                panels: [
                  RequisitionPanel(requisitions: requisitions),
                  CandidatePipelinePanel(candidates: candidates),
                  CandidateSkillFitPanel(
                    title: 'Candidate skill fit',
                    subtitle:
                        '${skillFitSummary.totalProfiles} role scorecards',
                    profiles: skillFitProfiles,
                    summary: skillFitSummary,
                  ),
                  CandidateSkillEvidencePanel(
                    title: 'Scorecard evidence',
                    subtitle: 'Update skill levels from interview feedback',
                    profiles: skillFitProfiles,
                  ),
                  CandidateDecisionPanel(
                    title: 'Decision packets',
                    subtitle:
                        '${decisionSummary.totalPackets} approval packets',
                    packets: decisionPackets,
                    summary: decisionSummary,
                    asOfDate: asOfDate,
                  ),
                  CandidateDevelopmentPanel(
                    title: 'Development objectives',
                    subtitle: '${decisionPackets.length} packet-ready goals',
                    packets: decisionPackets,
                    asOfDate: asOfDate,
                  ),
                  CandidateDevelopmentCheckInPanel(
                    title: 'Development check-ins',
                    subtitle: 'Manager confidence and blocker tracking',
                    packets: decisionPackets,
                    asOfDate: asOfDate,
                  ),
                  CandidateDevelopmentInterventionPanel(
                    title: 'Development interventions',
                    subtitle: 'Unblock coaching and escalation actions',
                    packets: decisionPackets,
                    asOfDate: asOfDate,
                  ),
                  CandidateDevelopmentCalibrationPanel(
                    title: 'Development calibration',
                    subtitle: 'Readiness review before ramp commitment',
                    packets: decisionPackets,
                    asOfDate: asOfDate,
                  ),
                  CandidateTalentHandoffPanel(
                    title: 'Candidate talent handoff',
                    subtitle: 'Release calibrated candidates into ramp owners',
                    packets: decisionPackets,
                    asOfDate: asOfDate,
                  ),
                  CandidateTalentHandoffChecklistPanel(
                    title: 'Handoff checklist',
                    subtitle: 'Preboarding tasks before ramp start',
                    packets: decisionPackets,
                    asOfDate: asOfDate,
                  ),
                  CandidateRampPanel(
                    title: 'Candidate ramp plans',
                    subtitle: '${rampSummary.totalPlans} hire-to-skill plans',
                    plans: rampPlans,
                    summary: rampSummary,
                    asOfDate: asOfDate,
                  ),
                  CandidateRampActionPanel(
                    title: 'Ramp action form',
                    subtitle: 'Convert candidates into mentor-led plans',
                    plans: rampPlans,
                  ),
                  InterviewSchedulePanel(interviews: interviews),
                  OfferTrackerPanel(offers: offers),
                ],
              ),
              const SizedBox(height: 16),
              SourceEffectivenessPanel(sources: sources),
            ],
          ),
        ),
      ),
    );
  }
}
