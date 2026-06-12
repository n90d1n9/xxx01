import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_management_summary.dart';

class CompanySummaryGrid extends StatelessWidget {
  final CompanyManagementSummary summary;

  const CompanySummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSummaryGrid(
      metrics: [
        HrisSummaryMetric(
          title: 'Readiness',
          value: '${(summary.readinessScore * 100).round()}%',
          detail: summary.nextAction,
          icon: Icons.verified_user_outlined,
          color: Colors.green,
        ),
        HrisSummaryMetric(
          title: 'Legal entities',
          value: '${summary.legalEntities}',
          detail:
              '${summary.verifiedLegalEntities} verified, ${summary.documentAuditEventCount} audit events',
          icon: Icons.business_outlined,
          color: Colors.indigo,
        ),
        HrisSummaryMetric(
          title: 'Headcount',
          value: '${summary.activeHeadcount}',
          detail:
              '${summary.positionControlReadyCount}/${summary.positionControlCount} positions ready',
          icon: Icons.groups_2_outlined,
          color: Colors.blue,
        ),
        HrisSummaryMetric(
          title: 'Positions',
          value:
              '${summary.positionControlReadyCount}/${summary.positionControlCount}',
          detail: '${summary.positionControlRiskCount} position risks',
          icon: Icons.work_outline,
          color:
              summary.positionControlRiskCount == 0
                  ? Colors.green
                  : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Jobs',
          value: '${summary.jobProfileReadyCount}/${summary.jobProfileCount}',
          detail: '${summary.jobProfileRiskCount} job profile risks',
          icon: Icons.badge_outlined,
          color:
              summary.jobProfileRiskCount == 0 ? Colors.green : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Contracts',
          value:
              '${summary.contractTemplateReadyCount}/${summary.contractTemplateCount}',
          detail: '${summary.contractTemplateRiskCount} template risks',
          icon: Icons.article_outlined,
          color:
              summary.contractTemplateRiskCount == 0
                  ? Colors.green
                  : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Onboarding',
          value:
              '${summary.onboardingPackReadyCount}/${summary.onboardingPackCount}',
          detail: '${summary.onboardingPackRiskCount} pack risks',
          icon: Icons.playlist_add_check_outlined,
          color:
              summary.onboardingPackRiskCount == 0
                  ? Colors.green
                  : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Probation',
          value:
              '${summary.probationPlanReadyCount}/${summary.probationPlanCount}',
          detail: '${summary.probationPlanRiskCount} plan risks',
          icon: Icons.fact_check_outlined,
          color:
              summary.probationPlanRiskCount == 0
                  ? Colors.green
                  : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Offboarding',
          value:
              '${summary.offboardingPackReadyCount}/${summary.offboardingPackCount}',
          detail: '${summary.offboardingPackRiskCount} exit risks',
          icon: Icons.logout_outlined,
          color:
              summary.offboardingPackRiskCount == 0
                  ? Colors.green
                  : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Doc Matrix',
          value:
              '${summary.documentRequirementReadyCount}/${summary.documentRequirementCount}',
          detail: '${summary.documentRequirementRiskCount} document risks',
          icon: Icons.folder_copy_outlined,
          color:
              summary.documentRequirementRiskCount == 0
                  ? Colors.green
                  : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Employee Docs',
          value:
              '${summary.employeeDocumentGapReadyCount}/${summary.employeeDocumentGapCount}',
          detail: '${summary.employeeDocumentGapRiskCount} evidence risks',
          icon: Icons.assignment_late_outlined,
          color:
              summary.employeeDocumentGapRiskCount == 0
                  ? Colors.green
                  : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Bands',
          value:
              '${summary.compensationBandReadyCount}/${summary.compensationBandCount}',
          detail: '${summary.compensationBandRiskCount} band risks',
          icon: Icons.price_change_outlined,
          color:
              summary.compensationBandRiskCount == 0
                  ? Colors.green
                  : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Owners',
          value:
              '${summary.governanceContactReadyCount}/${summary.governanceContactCount}',
          detail: '${summary.governanceContactRiskCount} owner risks',
          icon: Icons.contact_mail_outlined,
          color:
              summary.governanceContactRiskCount == 0
                  ? Colors.green
                  : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Lifecycle',
          value:
              '${summary.entityLifecycleReadyCount}/${summary.entityLifecycleCount}',
          detail: '${summary.entityLifecycleRiskCount} milestone risks',
          icon: Icons.timeline_outlined,
          color:
              summary.entityLifecycleRiskCount == 0
                  ? Colors.green
                  : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Controls',
          value: '${summary.controlReadyCount}/${summary.controlCount}',
          detail: '${summary.controlRiskCount} control risks',
          icon: Icons.fact_check_outlined,
          color: summary.controlRiskCount == 0 ? Colors.green : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Accounts',
          value:
              '${summary.employerAccountReadyCount}/${summary.employerAccountCount}',
          detail: '${summary.employerAccountRiskCount} account risks',
          icon: Icons.account_balance_outlined,
          color:
              summary.employerAccountRiskCount == 0
                  ? Colors.green
                  : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Vendors',
          value:
              '${summary.vendorAgreementReadyCount}/${summary.vendorAgreementCount}',
          detail: '${summary.vendorAgreementRiskCount} agreement risks',
          icon: Icons.handshake_outlined,
          color:
              summary.vendorAgreementRiskCount == 0
                  ? Colors.green
                  : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Filings',
          value: '${summary.filingReadyCount}/${summary.filingCount}',
          detail: '${summary.filingRiskCount} filing risks',
          icon: Icons.event_note_outlined,
          color: summary.filingRiskCount == 0 ? Colors.green : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Signers',
          value: '${summary.signatoryReadyCount}/${summary.signatoryCount}',
          detail: '${summary.signatoryRiskCount} signer risks',
          icon: Icons.assignment_ind_outlined,
          color: summary.signatoryRiskCount == 0 ? Colors.green : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Changes',
          value: '${summary.openChangeCount}',
          detail:
              '${summary.changeRequestCount} requests, ${summary.changeRequestRiskCount} risks',
          icon: Icons.sync_alt_outlined,
          color:
              summary.changeRequestRiskCount == 0
                  ? Colors.green
                  : Colors.orange,
        ),
        HrisSummaryMetric(
          title: 'Risks',
          value: '${summary.totalRisks}',
          detail:
              '${summary.employeeDocumentGapRiskCount} employee docs, ${summary.documentRequirementRiskCount} matrix',
          icon: Icons.priority_high_outlined,
          color: summary.totalRisks == 0 ? Colors.green : Colors.orange,
        ),
      ],
    );
  }
}
