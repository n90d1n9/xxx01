import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/company/models/company_management_summary.dart';
import 'package:kaysir/features/hris/compensation/models/compensation_models.dart';
import 'package:kaysir/features/hris/compliance/models/compliance_models.dart';
import 'package:kaysir/features/hris/engagement/models/engagement_models.dart';
import 'package:kaysir/features/hris/people_ops/models/people_ops_models.dart';
import 'package:kaysir/features/hris/performance/models/performance_models.dart';
import 'package:kaysir/features/hris/recruitment/models/recruitment_models.dart';
import 'package:kaysir/features/hris/service_center/models/service_center_models.dart';
import 'package:kaysir/features/hris/talent/models/talent_models.dart';
import 'package:kaysir/features/hris/workforce_planning/models/workforce_planning_models.dart';

import '../models/dashboard_workspace_entry.dart';
import '../models/dashboard_workspace_risk_signal.dart';
import '../models/hris_workspace.dart';

class DashboardStrategicWorkspaceSummaries {
  final CompanyManagementSummary companyManagement;
  final PeopleOpsSummary peopleOps;
  final ComplianceSummary compliance;
  final WorkforcePlanningSummary workforcePlanning;
  final RecruitmentSummary recruitment;
  final TalentSummary talent;
  final PerformanceSummary performance;
  final CompensationSummary compensation;
  final EngagementSummary engagement;
  final ServiceCenterSummary serviceCenter;

  const DashboardStrategicWorkspaceSummaries({
    required this.companyManagement,
    required this.peopleOps,
    required this.compliance,
    required this.workforcePlanning,
    required this.recruitment,
    required this.talent,
    required this.performance,
    required this.compensation,
    required this.engagement,
    required this.serviceCenter,
  });
}

List<DashboardWorkspaceEntry> buildStrategicDashboardWorkspaceEntries(
  DashboardStrategicWorkspaceSummaries summaries, {
  Map<HrisWorkspaceId, DashboardWorkspaceRiskSignal> riskSignals = const {},
}) {
  return [
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.companyManagement),
      description:
          'Legal entities, documents, org structure, policies, and readiness',
      riskSignal: riskSignals[HrisWorkspaceId.companyManagement],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.business_outlined,
          label: 'Entities',
          value: '${summaries.companyManagement.legalEntities}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.sync_alt_outlined,
          label: 'Changes',
          value:
              '${summaries.companyManagement.openChangeCount}/${summaries.companyManagement.changeRequestCount}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.policy_outlined,
          label: 'Risks',
          value: '${summaries.companyManagement.totalRisks}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.peopleOps),
      description: 'Workforce, onboarding, compliance, and pulse signals',
      riskSignal: riskSignals[HrisWorkspaceId.peopleOps],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.person_search_outlined,
          label: 'Hires',
          value: '${summaries.peopleOps.hiresNeeded}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.fact_check_outlined,
          label: 'Tasks',
          value: '${summaries.peopleOps.onboardingTasksDue}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.policy_outlined,
          label: 'Risks',
          value: '${summaries.peopleOps.complianceRisks}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.compliance),
      description: 'Controls, policies, documents, and audit findings',
      riskSignal: riskSignals[HrisWorkspaceId.compliance],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.fact_check_outlined,
          label: 'Controls',
          value: '${summaries.compliance.controlsDue}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.badge_outlined,
          label: 'Docs',
          value: '${summaries.compliance.documentRisks}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.priority_high_outlined,
          label: 'Critical',
          value: '${summaries.compliance.criticalFindings}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.workforcePlanning),
      description: 'Headcount plans, vacancies, capacity, and scenarios',
      riskSignal: riskSignals[HrisWorkspaceId.workforcePlanning],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.groups_outlined,
          label: 'Actual',
          value: '${summaries.workforcePlanning.totalActual}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.person_add_alt_outlined,
          label: 'Open',
          value: '${summaries.workforcePlanning.openPositions}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.speed_outlined,
          label: 'Risks',
          value: '${summaries.workforcePlanning.highRisks}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.recruitment),
      description: 'Requisitions, pipeline, interviews, and offers',
      riskSignal: riskSignals[HrisWorkspaceId.recruitment],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.assignment_ind_outlined,
          label: 'Reqs',
          value: '${summaries.recruitment.openRequisitions}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.people_alt_outlined,
          label: 'Pipeline',
          value: '${summaries.recruitment.activeCandidates}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.event_available_outlined,
          label: 'Today',
          value: '${summaries.recruitment.interviewsToday}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.talent),
      description: 'Skills, learning, certifications, and mentoring',
      riskSignal: riskSignals[HrisWorkspaceId.talent],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.psychology_alt_outlined,
          label: 'Gaps',
          value: '${summaries.talent.skillGaps}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.menu_book_outlined,
          label: 'Due',
          value: '${summaries.talent.learningDue}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.workspace_premium_outlined,
          label: 'Certs',
          value: '${summaries.talent.certificationRisks}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.performance),
      description: 'Goals, reviews, calibration, succession, and risk',
      riskSignal: riskSignals[HrisWorkspaceId.performance],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.flag_outlined,
          label: 'Goals',
          value: '${summaries.performance.activeGoals}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.rate_review_outlined,
          label: 'Reviews',
          value: '${summaries.performance.reviewsDue}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.tune_outlined,
          label: 'Flags',
          value: '${summaries.performance.calibrationFlags}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.compensation),
      description: 'Comp reviews, benefits, allowances, and incentives',
      riskSignal: riskSignals[HrisWorkspaceId.compensation],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.payments_outlined,
          label: 'Reviews',
          value: '${summaries.compensation.reviewItems}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.health_and_safety_outlined,
          label: 'Benefits',
          value: '${summaries.compensation.benefitIssues}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Budgets',
          value: '${summaries.compensation.allowanceWatch}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.engagement),
      description: 'Pulse surveys, recognition, wellbeing, and actions',
      riskSignal: riskSignals[HrisWorkspaceId.engagement],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.fact_check_outlined,
          label: 'Surveys',
          value: '${summaries.engagement.liveSurveys}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.spa_outlined,
          label: 'Risks',
          value: '${summaries.engagement.highRisks}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.task_alt_outlined,
          label: 'Actions',
          value: '${summaries.engagement.actionItems}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.serviceCenter),
      description: 'Cases, documents, policies, and broadcasts',
      riskSignal: riskSignals[HrisWorkspaceId.serviceCenter],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.support_agent_outlined,
          label: 'Cases',
          value: '${summaries.serviceCenter.openCases}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.warning_amber_outlined,
          label: 'SLA',
          value: '${summaries.serviceCenter.slaRisks}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.description_outlined,
          label: 'Docs',
          value: '${summaries.serviceCenter.documentBacklog}',
        ),
      ],
    ),
  ];
}
