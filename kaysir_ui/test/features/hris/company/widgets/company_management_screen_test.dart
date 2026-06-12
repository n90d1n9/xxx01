import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/company/models/company_compensation_band.dart';
import 'package:kaysir/features/hris/company/models/company_cost_center.dart';
import 'package:kaysir/features/hris/company/models/company_employee_document_workload.dart';
import 'package:kaysir/features/hris/company/models/company_employee_document_workload_digest_status.dart';
import 'package:kaysir/features/hris/company/models/company_governance_action_filter.dart';
import 'package:kaysir/features/hris/company/models/company_governance_action_item.dart';
import 'package:kaysir/features/hris/company/models/company_governance_command_brief.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_cadence.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_policy.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_policy_approval.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_policy_history.dart';
import 'package:kaysir/features/hris/company/models/company_governance_follow_up_policy_impact.dart';
import 'package:kaysir/features/hris/company/models/company_governance_owner_handoff.dart';
import 'package:kaysir/features/hris/company/models/company_governance_owner_handoff_history.dart';
import 'package:kaysir/features/hris/company/models/company_governance_owner_handoff_record.dart';
import 'package:kaysir/features/hris/company/models/company_governance_owner_load.dart';
import 'package:kaysir/features/hris/company/models/company_governance_saved_view.dart';
import 'package:kaysir/features/hris/company/models/company_headcount_requisition.dart';
import 'package:kaysir/features/hris/company/models/company_headcount_requisition_activity.dart';
import 'package:kaysir/features/hris/company/models/company_job_profile.dart';
import 'package:kaysir/features/hris/company/models/company_position_control.dart';
import 'package:kaysir/features/hris/company/models/company_workforce_plan.dart';
import 'package:kaysir/features/hris/company/models/employee_document_digest_history.dart';
import 'package:kaysir/features/hris/company/models/employee_document_digest_preview.dart';
import 'package:kaysir/features/hris/company/models/employee_document_escalation_follow_up.dart';
import 'package:kaysir/features/hris/company/models/employee_document_escalation_history.dart';
import 'package:kaysir/features/hris/company/models/employee_document_escalation_plan.dart';
import 'package:kaysir/features/hris/company/models/employee_document_escalation_preview.dart';
import 'package:kaysir/features/hris/company/states/company_management_provider.dart';
import 'package:kaysir/features/hris/company/widgets/company_employee_document_workload_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_governance_action_queue_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_governance_command_brief_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_governance_follow_up_cadence_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_governance_follow_up_policy_approval_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_governance_follow_up_policy_history_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_governance_follow_up_policy_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_governance_owner_handoff_history_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_governance_owner_handoff_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_governance_owner_load_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_governance_saved_views_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_headcount_requisition_activity_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_headcount_requisition_board.dart';
import 'package:kaysir/features/hris/company/widgets/company_headcount_requisition_form_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_org_unit_form_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_profile_form_panel.dart';
import 'package:kaysir/features/hris/company/widgets/company_workforce_plan_panel.dart';
import 'package:kaysir/features/hris/company/widgets/employee_document_digest_history_panel.dart';
import 'package:kaysir/features/hris/company/widgets/employee_document_digest_preview_dialog.dart';
import 'package:kaysir/features/hris/company/widgets/employee_document_escalation_follow_up_panel.dart';
import 'package:kaysir/features/hris/company/widgets/employee_document_escalation_history_panel.dart';
import 'package:kaysir/features/hris/company/widgets/employee_document_escalation_panel.dart';
import 'package:kaysir/features/hris/company/widgets/employee_document_escalation_preview_dialog.dart';

void main() {
  testWidgets('company profile panel saves edited profile fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: _CompanyProfilePanelHarness()),
    );

    expect(find.text('Company Profile'), findsOneWidget);
    expect(find.byKey(const Key('company-legal-name-field')), findsOneWidget);
    expect(
      find.byKey(const Key('company-employee-count-field')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('company-legal-name-field')),
      'PT Kaysir Global',
    );
    await tester.enterText(
      find.byKey(const Key('company-employee-count-field')),
      '120',
    );
    await tester.ensureVisible(
      find.byKey(const Key('company-profile-save-button')),
    );
    await tester.tap(find.byKey(const Key('company-profile-save-button')));
    await tester.pump();

    expect(find.text('Kaysir profile saved'), findsOneWidget);
    expect(find.text('PT Kaysir Global'), findsWidgets);
    expect(find.text('120 employees'), findsOneWidget);
  });

  testWidgets('company org unit panel submits and lists a new unit', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: _CompanyOrgUnitPanelHarness()),
    );

    expect(find.text('Org Unit Form'), findsOneWidget);
    expect(find.byKey(const Key('company-org-name-field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('company-org-name-field')),
      'Legal Affairs',
    );
    await tester.enterText(
      find.byKey(const Key('company-org-code-field')),
      'legal',
    );
    await tester.enterText(
      find.byKey(const Key('company-org-manager-field')),
      'Sari Wibowo',
    );
    await tester.enterText(
      find.byKey(const Key('company-org-location-field')),
      'Jakarta Central HQ',
    );
    await tester.enterText(
      find.byKey(const Key('company-org-planned-field')),
      '4',
    );
    await tester.enterText(
      find.byKey(const Key('company-org-active-field')),
      '2',
    );
    await tester.ensureVisible(
      find.byKey(const Key('company-org-save-button')),
    );
    await tester.tap(find.byKey(const Key('company-org-save-button')));
    await tester.pump();

    expect(
      find.text('Legal Affairs added to company structure'),
      findsOneWidget,
    );
    expect(find.text('Legal Affairs (LEGAL)'), findsOneWidget);
  });

  testWidgets('employee workload panel sends only due owner digests', (
    tester,
  ) async {
    final sentOwners = <List<String>>[];
    final asOfDate = DateTime(2026, 6, 9);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: CompanyEmployeeDocumentWorkloadPanel(
              workloads: const [
                CompanyEmployeeDocumentWorkload(
                  ownerName: 'Fajar Prakoso',
                  entityNames: ['PT Kaysir Nusantara'],
                  gapIds: ['gap-1'],
                  score: 120,
                  gapCount: 1,
                  criticalCount: 1,
                  highCount: 0,
                  overdueCount: 1,
                  dueSoonCount: 0,
                  openRequestCount: 1,
                  missingDocumentCount: 3,
                  pendingDocumentCount: 0,
                  rejectedDocumentCount: 1,
                  primaryAction: 'Review rejected evidence',
                  primaryGapId: 'gap-1',
                  primaryEmployeeName: 'David Kim',
                ),
                CompanyEmployeeDocumentWorkload(
                  ownerName: 'Dewi Lestari',
                  entityNames: ['Kaysir Retail Services'],
                  gapIds: ['gap-2'],
                  score: 84,
                  gapCount: 1,
                  criticalCount: 1,
                  highCount: 0,
                  overdueCount: 1,
                  dueSoonCount: 0,
                  openRequestCount: 1,
                  missingDocumentCount: 2,
                  pendingDocumentCount: 0,
                  rejectedDocumentCount: 0,
                  primaryAction: 'Generate request',
                  primaryGapId: 'gap-2',
                  primaryEmployeeName: 'Nadia Safitri',
                ),
              ],
              digestStatuses: [
                CompanyEmployeeDocumentWorkloadDigestStatus(
                  ownerName: 'Fajar Prakoso',
                  digestCount: 1,
                  lastSentAt: asOfDate.subtract(const Duration(days: 1)),
                  lastAuditEventId: 'audit-1',
                ),
                CompanyEmployeeDocumentWorkloadDigestStatus(
                  ownerName: 'Dewi Lestari',
                  digestCount: 1,
                  lastSentAt: asOfDate,
                  lastAuditEventId: 'audit-2',
                ),
              ],
              asOfDate: asOfDate,
              onSendDigest: (_) {},
              onSendDueDigests: sentOwners.add,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Employee Document Workload'), findsOneWidget);
    expect(find.text('1 due of 2 owner lanes'), findsOneWidget);
    expect(find.text('Send due digests'), findsOneWidget);

    await tester.tap(find.text('Send due digests'));
    await tester.pump();

    expect(sentOwners, [
      ['Fajar Prakoso'],
    ]);
  });

  testWidgets('employee workload panel filters no-digest owner lanes', (
    tester,
  ) async {
    final asOfDate = DateTime(2026, 6, 9);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: CompanyEmployeeDocumentWorkloadPanel(
              workloads: const [_digestPreviewWorkload, _noDigestWorkload],
              digestStatuses: [
                CompanyEmployeeDocumentWorkloadDigestStatus(
                  ownerName: 'Fajar Prakoso',
                  digestCount: 1,
                  lastSentAt: asOfDate,
                  lastAuditEventId: 'audit-1',
                ),
              ],
              asOfDate: asOfDate,
              onSendDigest: (_) {},
              onSendDueDigests: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Fajar Prakoso'), findsOneWidget);
    expect(find.text('People Operations'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('employee-workload-filter-noDigest')),
    );
    await tester.pump();

    expect(find.text('Fajar Prakoso'), findsNothing);
    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('1 of 2 owner lanes shown'), findsOneWidget);
  });

  testWidgets('company workforce plan panel routes headcount actions', (
    tester,
  ) async {
    final plan = buildCompanyWorkforcePlan(
      positions: [
        _workforcePosition(
          id: 'position-retail',
          title: 'Retail Supervisor',
          entityName: 'Kaysir Retail Services',
          orgUnitName: 'Retail Operations',
          status: CompanyPositionControlStatus.pendingApproval,
          authorizedSeats: 4,
          filledSeats: 5,
          compensationBand: 'OPS-4',
        ),
        _workforcePosition(
          id: 'position-engineer',
          title: 'Product Engineer',
          orgUnitName: 'Product & Commerce',
          status: CompanyPositionControlStatus.recruiting,
          authorizedSeats: 8,
          filledSeats: 6,
          compensationBand: 'ENG-4',
        ),
        _workforcePosition(
          id: 'position-people',
          title: 'People Partner',
          orgUnitName: 'People Operations',
          status: CompanyPositionControlStatus.approved,
          authorizedSeats: 3,
          filledSeats: 2,
          compensationBand: 'HR-4',
        ),
      ],
      costCenters: [
        _workforceCostCenter(
          id: 'cc-retail',
          code: 'CC-OPS',
          entityName: 'Kaysir Retail Services',
          orgUnitName: 'Retail Operations',
        ),
        _workforceCostCenter(
          id: 'cc-product',
          code: 'CC-PROD',
          orgUnitName: 'Product & Commerce',
        ),
        _workforceCostCenter(
          id: 'cc-people',
          code: 'CC-POPS',
          orgUnitName: 'People Operations',
          status: CompanyCostCenterStatus.needsReview,
        ),
      ],
      compensationBands: [
        _workforceBand('OPS-4', entityName: 'Kaysir Retail Services'),
        _workforceBand('ENG-4'),
        _workforceBand('HR-4'),
      ],
      jobProfiles: [
        _workforceJobProfile(
          code: 'OPS-JP-04',
          title: 'Retail Supervisor',
          entityName: 'Kaysir Retail Services',
          orgUnitName: 'Retail Operations',
          compensationBand: 'OPS-4',
        ),
        _workforceJobProfile(
          code: 'ENG-JP-04',
          title: 'Product Engineer',
          orgUnitName: 'Product & Commerce',
          compensationBand: 'ENG-4',
        ),
        _workforceJobProfile(
          code: 'HR-JP-04',
          title: 'People Partner',
          orgUnitName: 'People Operations',
          compensationBand: 'HR-4',
        ),
      ],
      asOfDate: DateTime(2026, 6, 12),
    );
    String? approvedPositionId;
    String? closedPositionId;
    String? reviewedCostCenterId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyWorkforcePlanPanel(
              plan: plan,
              onApprovePosition: (id) {
                approvedPositionId = id;
              },
              onCloseRecruiting: (id) {
                closedPositionId = id;
              },
              onReviewCostCenter: (id) {
                reviewedCostCenterId = id;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Workforce Plan'), findsOneWidget);
    expect(find.text('3 actions, 3 open seats'), findsOneWidget);
    expect(find.text('Retail Supervisor'), findsOneWidget);
    expect(
      find.text('Filled headcount is 1 above authorized seats.'),
      findsOneWidget,
    );

    final approveButton = find.byKey(
      const Key('company-workforce-plan-approve-position-retail'),
    );
    await tester.ensureVisible(approveButton);
    await tester.tap(approveButton);
    await tester.pump();
    expect(approvedPositionId, 'position-retail');

    final closeButton = find.byKey(
      const Key('company-workforce-plan-close-position-engineer'),
    );
    await tester.ensureVisible(closeButton);
    await tester.tap(closeButton);
    await tester.pump();
    expect(closedPositionId, 'position-engineer');

    final costButton = find.byKey(
      const Key('company-workforce-plan-cost-position-people'),
    );
    await tester.ensureVisible(costButton);
    await tester.tap(costButton);
    await tester.pump();
    expect(reviewedCostCenterId, 'cc-people');
  });

  testWidgets('company headcount requisition board routes hiring actions', (
    tester,
  ) async {
    String? approvedId;
    String? recruitingId;
    String? filledId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyHeadcountRequisitionBoard(
              requisitions: [
                _headcountRequest(
                  id: 'hreq-retail',
                  roleTitle: 'Retail Supervisor',
                  status: CompanyHeadcountRequisitionStatus.awaitingApproval,
                ),
                _headcountRequest(
                  id: 'hreq-people',
                  roleTitle: 'People Partner',
                  status: CompanyHeadcountRequisitionStatus.approved,
                ),
                _headcountRequest(
                  id: 'hreq-engineer',
                  roleTitle: 'Product Engineer',
                  status: CompanyHeadcountRequisitionStatus.recruiting,
                ),
              ],
              asOfDate: DateTime(2026, 6, 12),
              onApprove: (id) {
                approvedId = id;
              },
              onOpenRecruiting: (id) {
                recruitingId = id;
              },
              onMarkFilled: (id) {
                filledId = id;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Headcount Requisition Board'), findsOneWidget);
    expect(find.text('3 open of 3 requisitions'), findsOneWidget);
    expect(find.text('Retail Supervisor'), findsOneWidget);

    final approveButton = find.byKey(
      const Key('company-headcount-approve-hreq-retail'),
    );
    await tester.ensureVisible(approveButton);
    await tester.tap(approveButton);
    await tester.pump();
    expect(approvedId, 'hreq-retail');

    final recruitingButton = find.byKey(
      const Key('company-headcount-recruiting-hreq-people'),
    );
    await tester.ensureVisible(recruitingButton);
    await tester.tap(recruitingButton);
    await tester.pump();
    expect(recruitingId, 'hreq-people');

    final filledButton = find.byKey(
      const Key('company-headcount-filled-hreq-engineer'),
    );
    await tester.ensureVisible(filledButton);
    await tester.tap(filledButton);
    await tester.pump();
    expect(filledId, 'hreq-engineer');
  });

  testWidgets('company headcount requisition activity panel shows timeline', (
    tester,
  ) async {
    final request = _headcountRequest(
      id: 'hreq-engineer',
      roleTitle: 'Product Engineer',
      status: CompanyHeadcountRequisitionStatus.recruiting,
    );
    final timeline = CompanyHeadcountRequisitionActivityTimeline(
      records: [
        CompanyHeadcountRequisitionActivityRecord.fromRequisition(
          id: 'hreq-activity-001',
          requisition: request,
          type: CompanyHeadcountRequisitionActivityType.submitted,
          happenedAt: DateTime(2026, 6, 10),
        ),
        CompanyHeadcountRequisitionActivityRecord.fromRequisition(
          id: 'hreq-activity-002',
          requisition: request,
          type: CompanyHeadcountRequisitionActivityType.recruitingOpened,
          happenedAt: DateTime(2026, 6, 12),
          note: 'Recruiting opened for product engineer.',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyHeadcountRequisitionActivityPanel(timeline: timeline),
          ),
        ),
      ),
    );

    expect(find.text('Headcount Activity'), findsOneWidget);
    expect(find.text('0 approvals, 1 recruiting opens'), findsOneWidget);
    expect(find.text('Recruiting opened - Product Engineer'), findsOneWidget);
    expect(
      find.text('Recruiting opened for product engineer.'),
      findsOneWidget,
    );
  });

  testWidgets('company headcount requisition form submits ready draft', (
    tester,
  ) async {
    var submitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyHeadcountRequisitionFormPanel(
              draft: CompanyHeadcountRequisitionDraft.empty(
                orgUnitName: 'Product & Commerce',
              ).copyWith(
                roleTitle: 'Product Designer',
                hiringManagerName: 'Fajar Prakoso',
                positionControlId: 'position-product-engineer',
                jobProfileCode: 'ENG-JP-04',
                costCenterCode: 'CC-PROD',
                requestedSeatsText: '1',
                targetStartDateText: '2026-07-15',
                businessCase: 'Add design capacity',
                budgetImpact: 'Uses product hiring plan',
                approverRole: 'Head of Product',
              ),
              entities: const ['All', 'PT Kaysir Nusantara'],
              orgUnits: const ['Product & Commerce', 'People Operations'],
              positionControlIds: const ['position-product-engineer'],
              jobProfileCodes: const ['ENG-JP-04'],
              costCenterCodes: const ['CC-PROD'],
              onRoleTitleChanged: (_) {},
              onEntityChanged: (_) {},
              onOrgUnitChanged: (_) {},
              onHiringManagerChanged: (_) {},
              onPositionControlChanged: (_) {},
              onJobProfileChanged: (_) {},
              onCostCenterChanged: (_) {},
              onTypeChanged: (_) {},
              onPriorityChanged: (_) {},
              onStatusChanged: (_) {},
              onRequestedSeatsChanged: (_) {},
              onTargetStartChanged: (_) {},
              onBusinessCaseChanged: (_) {},
              onBudgetImpactChanged: (_) {},
              onApproverChanged: (_) {},
              onSubmit: () {
                submitCount++;
              },
              onClear: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Headcount Requisition Form'), findsOneWidget);
    expect(
      find.byKey(const Key('company-headcount-role-field')),
      findsOneWidget,
    );

    final submitButton = find.byKey(
      const Key('company-headcount-submit-button'),
    );
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();

    expect(submitCount, 1);
  });

  testWidgets('employee escalation panel escalates selected owner', (
    tester,
  ) async {
    String? selectedOwner;
    List<String>? selectedOwners;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: EmployeeDocumentEscalationPanel(
              plans: const [_escalationPlan, _coolingDownEscalationPlan],
              onEscalateOwner: (ownerName) {
                selectedOwner = ownerName;
              },
              onEscalateOwners: (ownerNames) {
                selectedOwners = ownerNames;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Owner Escalations'), findsOneWidget);
    expect(find.text('Fajar Prakoso'), findsOneWidget);
    expect(find.text('Dewi Lestari'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('Escalate owner'), findsOneWidget);
    expect(find.text('2 of 2 escalation lanes shown'), findsOneWidget);
    expect(find.text('Escalate ready lanes'), findsOneWidget);

    await tester.tap(find.text('Escalate ready lanes'));
    await tester.pump();

    expect(selectedOwners, ['Fajar Prakoso']);

    await tester.tap(
      find.byKey(const Key('employee-escalation-filter-coolingDown')),
    );
    await tester.pump();

    expect(find.text('Fajar Prakoso'), findsNothing);
    expect(find.text('Dewi Lestari'), findsOneWidget);
    expect(find.text('1 of 2 escalation lanes shown'), findsOneWidget);

    await tester.tap(find.byKey(const Key('employee-escalation-filter-ready')));
    await tester.pump();

    expect(find.text('Fajar Prakoso'), findsOneWidget);
    expect(find.text('Dewi Lestari'), findsNothing);

    await tester.ensureVisible(find.text('Escalate owner'));
    await tester.tap(find.text('Escalate owner'));
    await tester.pump();

    expect(selectedOwner, 'Fajar Prakoso');
  });

  testWidgets('employee escalation follow-up panel selects audit event', (
    tester,
  ) async {
    String? selectedAuditEventId;
    String? recordedOwnerName;
    final asOfDate = DateTime(2026, 6, 10);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: EmployeeDocumentEscalationFollowUpPanel(
              asOfDate: asOfDate,
              followUps: [
                EmployeeDocumentEscalationFollowUp(
                  ownerName: 'Fajar Prakoso',
                  entitySummary: 'PT Kaysir Nusantara',
                  priority: EmployeeDocumentEscalationPriority.critical,
                  actionLabel: 'Review rejected evidence',
                  primaryEmployeeName: 'David Kim',
                  workloadScore: 120,
                  missingDocumentCount: 3,
                  openRequestCount: 1,
                  lastEscalationAuditEventId: 'audit-escalation-1',
                  lastEscalatedAt: asOfDate.subtract(const Duration(days: 2)),
                  nextTouchDate: asOfDate.subtract(const Duration(days: 1)),
                  state: EmployeeDocumentEscalationFollowUpState.overdue,
                  rationale:
                      'Critical owner lane with 3 missing evidence items and 1 open request. Follow-up is overdue.',
                ),
              ],
              onAuditEventSelected: (id) {
                selectedAuditEventId = id;
              },
              onRecordFollowUp: (ownerName) {
                recordedOwnerName = ownerName;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Escalation Follow-up Queue'), findsOneWidget);
    expect(find.text('Fajar Prakoso'), findsOneWidget);
    expect(find.text('1d overdue'), findsOneWidget);
    expect(find.text('Record follow-up'), findsOneWidget);

    await tester.tap(find.text('Record follow-up'));
    await tester.pump();

    expect(recordedOwnerName, 'Fajar Prakoso');

    await tester.tap(
      find.byKey(const Key('employee-escalation-follow-up-audit-escalation-1')),
    );
    await tester.pump();

    expect(selectedAuditEventId, 'audit-escalation-1');
  });

  testWidgets(
    'company governance action queue panel resolves selected action',
    (tester) async {
      CompanyGovernanceActionItem? selectedAction;
      final filingAction = CompanyGovernanceActionItem(
        id: 'filing-labor-report',
        recordId: 'labor-report',
        source: CompanyGovernanceActionSource.filing,
        severity: CompanyGovernanceActionSeverity.critical,
        resolution: CompanyGovernanceActionResolution.markFilingFiled,
        title: 'Annual WLK labor report',
        entityName: 'PT Kaysir Nusantara',
        ownerName: 'People Operations',
        dueDate: DateTime(2026, 6, 7),
        dueLabel: 'Overdue 3d',
        actionLabel: 'Submit labor report receipt',
        detail: 'Labor report annual filing with 2 open issues.',
        issueLabels: const ['Filing overdue', 'Attach evidence'],
      );
      final vendorAction = CompanyGovernanceActionItem(
        id: 'vendor-signflow',
        recordId: 'signflow',
        source: CompanyGovernanceActionSource.vendorAgreement,
        severity: CompanyGovernanceActionSeverity.high,
        resolution: CompanyGovernanceActionResolution.renewVendorAgreement,
        title: 'SignFlow Indonesia',
        entityName: 'PT Kaysir Nusantara',
        ownerName: 'Legal Operations',
        dueDate: DateTime(2026, 6, 22),
        dueLabel: 'Contract ends in 12d',
        actionLabel: 'Renew e-signature agreement',
        detail: 'E-signature agreement with 2 open vendor issues.',
        issueLabels: const ['Renew agreement', 'Review due soon'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CompanyGovernanceActionQueuePanel(
                items: [filingAction, vendorAction],
                onActionSelected: (item) {
                  selectedAction = item;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Governance Action Queue'), findsOneWidget);
      expect(find.text('Annual WLK labor report'), findsOneWidget);
      expect(find.text('Critical'), findsWidgets);
      expect(find.text('Vendors 1'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('company-governance-filter-vendors')),
      );
      await tester.pump();

      expect(find.text('Annual WLK labor report'), findsNothing);
      expect(find.text('SignFlow Indonesia'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('company-governance-action-vendor-signflow')),
      );
      await tester.pump();

      expect(selectedAction?.id, 'vendor-signflow');
    },
  );

  testWidgets('company governance action queue scopes selected owner', (
    tester,
  ) async {
    String? selectedOwnerName = 'Legal Operations';
    final filingAction = CompanyGovernanceActionItem(
      id: 'filing-labor-report',
      recordId: 'labor-report',
      source: CompanyGovernanceActionSource.filing,
      severity: CompanyGovernanceActionSeverity.critical,
      resolution: CompanyGovernanceActionResolution.markFilingFiled,
      title: 'Annual WLK labor report',
      entityName: 'PT Kaysir Nusantara',
      ownerName: 'People Operations',
      dueDate: DateTime(2026, 6, 7),
      dueLabel: 'Overdue 3d',
      actionLabel: 'Submit labor report receipt',
      detail: 'Labor report annual filing with 2 open issues.',
      issueLabels: const ['Filing overdue', 'Attach evidence'],
    );
    final vendorAction = CompanyGovernanceActionItem(
      id: 'vendor-signflow',
      recordId: 'signflow',
      source: CompanyGovernanceActionSource.vendorAgreement,
      severity: CompanyGovernanceActionSeverity.high,
      resolution: CompanyGovernanceActionResolution.renewVendorAgreement,
      title: 'SignFlow Indonesia',
      entityName: 'PT Kaysir Nusantara',
      ownerName: 'Legal Operations',
      dueDate: DateTime(2026, 6, 22),
      dueLabel: 'Contract ends in 12d',
      actionLabel: 'Renew e-signature agreement',
      detail: 'E-signature agreement with 2 open vendor issues.',
      issueLabels: const ['Renew agreement', 'Review due soon'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return CompanyGovernanceActionQueuePanel(
                  items: [filingAction, vendorAction],
                  selectedOwnerName: selectedOwnerName,
                  onOwnerFilterCleared: () {
                    setState(() {
                      selectedOwnerName = null;
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Owner scope: Legal Operations'), findsOneWidget);
    expect(find.text('SignFlow Indonesia'), findsOneWidget);
    expect(find.text('Annual WLK labor report'), findsNothing);

    await tester.tap(
      find.byKey(const Key('company-governance-owner-filter-clear')),
    );
    await tester.pump();

    expect(find.text('Owner scope: Legal Operations'), findsNothing);
    expect(find.text('Annual WLK labor report'), findsOneWidget);
  });

  testWidgets('company governance owner load panel selects owner lane', (
    tester,
  ) async {
    String? selectedOwnerName;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyGovernanceOwnerLoadPanel(
              loads: [
                CompanyGovernanceOwnerLoad(
                  ownerName: 'People Operations',
                  actionCount: 2,
                  criticalCount: 1,
                  highCount: 1,
                  mediumCount: 0,
                  filingCount: 1,
                  employerAccountCount: 1,
                  vendorAgreementCount: 0,
                  signatoryCount: 0,
                  nextDueDate: DateTime(2026, 6, 7),
                  nextDueLabel: 'Overdue 3d',
                  primaryActionLabel: 'Submit labor report receipt',
                  risk: CompanyGovernanceOwnerLoadRisk.critical,
                ),
              ],
              onOwnerSelected: (ownerName) {
                selectedOwnerName = ownerName;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Governance Owner Load'), findsOneWidget);
    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('1 filing, 1 account'), findsOneWidget);
    expect(find.text('Critical load'), findsOneWidget);

    await tester.tap(find.text('Review owner'));
    await tester.pump();

    expect(selectedOwnerName, 'People Operations');
  });

  testWidgets('company governance saved views panel applies selected view', (
    tester,
  ) async {
    CompanyGovernanceSavedView? selectedView;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyGovernanceSavedViewsPanel(
              selectedType: CompanyGovernanceSavedViewType.commandCenter,
              views: const [
                CompanyGovernanceSavedView(
                  type: CompanyGovernanceSavedViewType.commandCenter,
                  title: 'Command center',
                  description:
                      'All governance actions, owners, handoffs, and follow-ups.',
                  metricLabel: 'Actions',
                  metricValue: 4,
                  queueFilter: CompanyGovernanceActionFilter.all,
                  clearOwnerScope: true,
                ),
                CompanyGovernanceSavedView(
                  type: CompanyGovernanceSavedViewType.followUpsDue,
                  title: 'Follow-ups due',
                  description: 'Handoffs that need a same-day touch.',
                  metricLabel: 'Due',
                  metricValue: 1,
                  queueFilter: CompanyGovernanceActionFilter.all,
                  ownerName: 'People Operations',
                ),
              ],
              onViewSelected: (view) {
                selectedView = view;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Governance Saved Views'), findsOneWidget);
    expect(find.text('Command center active, 2 with work'), findsOneWidget);
    expect(find.text('4 Actions'), findsOneWidget);
    expect(find.text('1 Due'), findsOneWidget);
    expect(find.text('People Operations'), findsOneWidget);

    final followUpViewButton = find.byKey(
      const Key('company-governance-saved-view-followUpsDue'),
    );
    await tester.ensureVisible(followUpViewButton);
    await tester.tap(followUpViewButton);
    await tester.pump();

    expect(selectedView?.type, CompanyGovernanceSavedViewType.followUpsDue);
    expect(selectedView?.ownerName, 'People Operations');
  });

  testWidgets('company governance command brief panel routes actions', (
    tester,
  ) async {
    String? selectedOwnerName;
    CompanyGovernanceActionItem? selectedAction;
    CompanyGovernanceFollowUpLane? recordedFollowUp;
    final action = CompanyGovernanceActionItem(
      id: 'filing-labor-report',
      recordId: 'filing-001',
      source: CompanyGovernanceActionSource.filing,
      severity: CompanyGovernanceActionSeverity.critical,
      resolution: CompanyGovernanceActionResolution.markFilingFiled,
      title: 'Annual WLK labor report',
      entityName: 'PT Kaysir Nusantara',
      ownerName: 'People Operations',
      dueDate: DateTime(2026, 6, 8),
      dueLabel: 'Overdue 3d',
      actionLabel: 'Submit labor report receipt',
      detail: 'Labor filing with missing evidence and an overdue due date.',
      issueLabels: const ['Filing overdue'],
    );
    final followUpLane = CompanyGovernanceFollowUpLane(
      ownerName: 'People Operations',
      risk: CompanyGovernanceOwnerLoadRisk.critical,
      actionCount: 2,
      criticalCount: 1,
      highCount: 1,
      sourceSummary: '1 filing, 1 account',
      primaryActionLabel: 'Submit labor report receipt',
      queueDueLabel: 'Overdue 3d',
      handoffRecordId: 'handoff-people',
      handoffAuditEventId: 'audit-handoff',
      lastHandoffAt: DateTime(2026, 6, 10),
      nextTouchDate: DateTime(2026, 6, 11),
      state: CompanyGovernanceFollowUpState.dueToday,
      rationale:
          'Critical load with 2 active actions across 1 filing, 1 account. Follow-up is due today.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyGovernanceCommandBriefPanel(
              brief: CompanyGovernanceCommandBrief(
                selectedView: const CompanyGovernanceSavedView(
                  type: CompanyGovernanceSavedViewType.followUpsDue,
                  title: 'Follow-ups due',
                  description: 'Handoffs that need a same-day touch.',
                  metricLabel: 'Due',
                  metricValue: 1,
                  queueFilter: CompanyGovernanceActionFilter.all,
                  ownerName: 'People Operations',
                ),
                intent: CompanyGovernanceCommandBriefIntent.recordFollowUp,
                headline: 'Follow up with People Operations',
                recommendation: followUpLane.rationale,
                ownerName: 'People Operations',
                queueFilter: CompanyGovernanceActionFilter.all,
                visibleActionCount: 2,
                criticalActionCount: 1,
                highActionCount: 1,
                needsHandoffCount: 0,
                dueFollowUpCount: 1,
                primaryAction: action,
                primaryFollowUpLane: followUpLane,
              ),
              onOwnerSelected: (ownerName) {
                selectedOwnerName = ownerName;
              },
              onActionSelected: (item) {
                selectedAction = item;
              },
              onRecordFollowUp: (lane) {
                recordedFollowUp = lane;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Governance Command Brief'), findsOneWidget);
    expect(find.text('Follow up with People Operations'), findsOneWidget);
    expect(find.text('Record follow-up'), findsWidgets);
    expect(find.text('Annual WLK labor report'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('company-governance-brief-record-follow-up')),
    );
    await tester.pump();
    expect(recordedFollowUp?.ownerLabel, 'People Operations');

    await tester.tap(
      find.byKey(const Key('company-governance-brief-review-owner')),
    );
    await tester.pump();
    expect(selectedOwnerName, 'People Operations');

    final actionButton = find.byKey(
      const Key('company-governance-brief-action-filing-labor-report'),
    );
    await tester.ensureVisible(actionButton);
    await tester.tap(actionButton);
    await tester.pump();
    expect(selectedAction?.id, 'filing-labor-report');
  });

  testWidgets('company governance owner handoff panel shows selected brief', (
    tester,
  ) async {
    CompanyGovernanceOwnerHandoff? recordedHandoff;
    final handoff = CompanyGovernanceOwnerHandoff(
      ownerName: 'People Operations',
      actionCount: 2,
      criticalCount: 1,
      highCount: 1,
      sourceSummary: '1 filing, 1 employer account',
      nextDueLabel: 'Overdue 3d',
      handoffMessage:
          'People Operations has 2 governance actions across 1 filing, 1 employer account. Priority is 1 critical, next touch is Overdue 3d. Start with: Submit labor report receipt.',
      actions: const [
        CompanyGovernanceOwnerHandoffAction(
          id: 'filing-labor-report',
          title: 'Annual WLK labor report',
          sourceLabel: 'Filing',
          severityLabel: 'Critical',
          dueLabel: 'Overdue 3d',
          resolveLabel: 'Mark filed',
          actionLabel: 'Submit labor report receipt',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyGovernanceOwnerHandoffPanel(
              handoff: handoff,
              lastRecord: CompanyGovernanceOwnerHandoffRecord(
                id: 'handoff-001',
                ownerName: 'People Operations',
                actionCount: 2,
                criticalCount: 1,
                highCount: 1,
                sourceSummary: '1 filing, 1 employer account',
                nextDueLabel: 'Overdue 3d',
                message: 'Recorded handoff',
                recordedAt: DateTime(2026, 6, 10),
                actorName: 'People Operations',
              ),
              onRecordHandoff: (handoff) {
                recordedHandoff = handoff;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Governance Owner Handoff'), findsOneWidget);
    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Annual WLK labor report'), findsOneWidget);
    expect(find.text('Submit labor report receipt'), findsOneWidget);
    expect(
      find.text('Last recorded 2026-06-10 by People Operations'),
      findsOneWidget,
    );

    await tester.tap(find.text('Record handoff'));
    await tester.pump();

    expect(recordedHandoff?.ownerLabel, 'People Operations');
  });

  testWidgets(
    'company governance handoff history panel prioritizes selected owner',
    (tester) async {
      String? selectedOwnerName;
      String? selectedAuditEventId;
      final history = CompanyGovernanceOwnerHandoffHistory.fromRecords(
        records: [
          CompanyGovernanceOwnerHandoffRecord(
            id: 'handoff-legal',
            ownerName: 'Legal Operations',
            actionCount: 1,
            criticalCount: 0,
            highCount: 1,
            sourceSummary: '1 vendor agreement',
            nextDueLabel: 'Contract ends in 12d',
            message:
                'Legal Operations has 1 governance action across 1 vendor agreement.',
            recordedAt: DateTime(2026, 6, 11),
            actorName: 'People Operations',
          ),
          CompanyGovernanceOwnerHandoffRecord(
            id: 'handoff-people',
            ownerName: 'People Operations',
            actionCount: 2,
            criticalCount: 1,
            highCount: 1,
            sourceSummary: '1 filing, 1 employer account',
            nextDueLabel: 'Overdue 3d',
            message:
                'People Operations has 2 governance actions across 1 filing, 1 employer account.',
            recordedAt: DateTime(2026, 6, 10),
            actorName: 'People Operations',
            auditEventId: 'audit-091',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CompanyGovernanceOwnerHandoffHistoryPanel(
                history: history,
                selectedOwnerName: 'People Operations',
                onOwnerSelected: (ownerName) {
                  selectedOwnerName = ownerName;
                },
                onAuditEventSelected: (auditEventId) {
                  selectedAuditEventId = auditEventId;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Governance Handoff History'), findsOneWidget);
      expect(find.text('2 records, 2 owner lanes'), findsOneWidget);
      expect(find.text('Scoped'), findsOneWidget);
      expect(find.text('View audit'), findsOneWidget);
      expect(find.text('2026-06-10'), findsOneWidget);
      expect(find.text('2026-06-11'), findsWidgets);

      final viewAuditButton = find.byKey(
        const Key('company-governance-handoff-history-audit-handoff-people'),
      );
      await tester.ensureVisible(viewAuditButton);
      await tester.tap(viewAuditButton);
      await tester.pump();

      expect(selectedAuditEventId, 'audit-091');

      final reviewOwnerButton = find.byKey(
        const Key('company-governance-handoff-history-owner-handoff-people'),
      );
      await tester.ensureVisible(reviewOwnerButton);
      await tester.tap(reviewOwnerButton);
      await tester.pump();

      expect(selectedOwnerName, 'People Operations');
    },
  );

  testWidgets('company governance follow-up cadence panel records touch', (
    tester,
  ) async {
    String? selectedOwnerName;
    String? selectedAuditEventId;
    CompanyGovernanceFollowUpLane? recordedLane;
    final asOfDate = DateTime(2026, 6, 11);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyGovernanceFollowUpCadencePanel(
              asOfDate: asOfDate,
              lanes: [
                CompanyGovernanceFollowUpLane(
                  ownerName: 'People Operations',
                  risk: CompanyGovernanceOwnerLoadRisk.critical,
                  actionCount: 2,
                  criticalCount: 1,
                  highCount: 1,
                  sourceSummary: '1 filing, 1 account',
                  primaryActionLabel: 'Submit labor report receipt',
                  queueDueLabel: 'Overdue 3d',
                  handoffRecordId: 'handoff-people',
                  handoffAuditEventId: 'audit-handoff',
                  lastHandoffAt: DateTime(2026, 6, 10),
                  nextTouchDate: asOfDate,
                  state: CompanyGovernanceFollowUpState.dueToday,
                  rationale:
                      'Critical load with 2 active actions across 1 filing, 1 account. Follow-up is due today.',
                ),
                CompanyGovernanceFollowUpLane(
                  ownerName: 'Legal Operations',
                  risk: CompanyGovernanceOwnerLoadRisk.high,
                  actionCount: 1,
                  criticalCount: 0,
                  highCount: 1,
                  sourceSummary: '1 vendor',
                  primaryActionLabel: 'Renew e-signature agreement',
                  queueDueLabel: 'Contract ends in 12d',
                  nextTouchDate: asOfDate,
                  state: CompanyGovernanceFollowUpState.needsHandoff,
                  rationale:
                      'Legal Operations has 1 active governance action and no recorded handoff.',
                ),
              ],
              onOwnerSelected: (ownerName) {
                selectedOwnerName = ownerName;
              },
              onAuditEventSelected: (auditEventId) {
                selectedAuditEventId = auditEventId;
              },
              onRecordFollowUp: (lane) {
                recordedLane = lane;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Governance Follow-up Cadence'), findsOneWidget);
    expect(find.text('1 need handoff, 0 overdue'), findsOneWidget);
    expect(find.text('Due today'), findsWidgets);
    expect(find.text('Needs handoff'), findsOneWidget);

    final auditButton = find.byKey(
      const Key('company-governance-follow-up-audit-People Operations'),
    );
    await tester.ensureVisible(auditButton);
    await tester.tap(auditButton);
    await tester.pump();
    expect(selectedAuditEventId, 'audit-handoff');

    final ownerButton = find.byKey(
      const Key('company-governance-follow-up-owner-People Operations'),
    );
    await tester.ensureVisible(ownerButton);
    await tester.tap(ownerButton);
    await tester.pump();
    expect(selectedOwnerName, 'People Operations');

    final recordButton = find.byKey(
      const Key('company-governance-follow-up-record-People Operations'),
    );
    await tester.ensureVisible(recordButton);
    await tester.tap(recordButton);
    await tester.pump();
    expect(recordedLane?.ownerLabel, 'People Operations');
  });

  testWidgets('company governance follow-up SLA panel saves valid policy', (
    tester,
  ) async {
    const policy = CompanyGovernanceFollowUpPolicy(
      criticalCadenceDays: 1,
      highCadenceDays: 2,
      steadyCadenceDays: 3,
    );
    const impact = CompanyGovernanceFollowUpPolicyImpact(
      isValid: true,
      laneCount: 2,
      needsHandoffCount: 0,
      overdueCount: 0,
      dueTodayCount: 1,
      scheduledCount: 1,
      changedLaneCount: 1,
      newlyDueCount: 1,
      changedLanes: [
        CompanyGovernanceFollowUpPolicyImpactLane(
          ownerName: 'People Operations',
          currentTouchLabel: 'Due tomorrow',
          previewTouchLabel: 'Due today',
          previewState: CompanyGovernanceFollowUpState.dueToday,
          becomesDueNow: true,
        ),
      ],
    );
    String? highCadenceText;
    var saveCount = 0;
    var resetCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyGovernanceFollowUpPolicyPanel(
              policy: policy,
              draft: CompanyGovernanceFollowUpPolicyDraft.fromPolicy(policy),
              impact: impact,
              onCriticalChanged: (_) {},
              onHighChanged: (value) {
                highCadenceText = value;
              },
              onSteadyChanged: (_) {},
              onReset: () {
                resetCount++;
              },
              onSave: () {
                saveCount++;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Governance Follow-up SLA'), findsOneWidget);
    expect(find.text('Critical 1d, high 2d, steady 3d'), findsOneWidget);
    expect(find.text('1 day'), findsOneWidget);
    expect(find.text('1 lane becomes due now'), findsOneWidget);
    expect(find.text('Due tomorrow -> Due today'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('company-governance-sla-high-field')),
      '4',
    );
    expect(highCadenceText, '4');

    final saveButton = find.byKey(
      const Key('company-governance-sla-save-button'),
    );
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
    expect(saveCount, 1);

    await tester.enterText(
      find.byKey(const Key('company-governance-sla-critical-field')),
      '0',
    );
    await tester.tap(saveButton);
    await tester.pump();
    expect(saveCount, 1);
    expect(
      find.text('Critical cadence must be between 1 and 30 days'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('company-governance-sla-reset-button')),
    );
    await tester.pump();
    expect(resetCount, 1);
  });

  testWidgets('company governance SLA approval panel routes review actions', (
    tester,
  ) async {
    const currentPolicy = CompanyGovernanceFollowUpPolicy(
      criticalCadenceDays: 1,
      highCadenceDays: 2,
      steadyCadenceDays: 3,
    );
    const requestedPolicy = CompanyGovernanceFollowUpPolicy(
      criticalCadenceDays: 4,
      highCadenceDays: 5,
      steadyCadenceDays: 6,
    );
    final request = CompanyGovernanceFollowUpPolicyApprovalRequest.create(
      id: 'governance-sla-approval-001',
      previousPolicy: currentPolicy,
      requestedPolicy: requestedPolicy,
      impact: const CompanyGovernanceFollowUpPolicyImpact(
        isValid: true,
        laneCount: 2,
        needsHandoffCount: 0,
        overdueCount: 0,
        dueTodayCount: 1,
        scheduledCount: 1,
        changedLaneCount: 1,
        newlyDueCount: 1,
        changedLanes: [
          CompanyGovernanceFollowUpPolicyImpactLane(
            ownerName: 'People Operations',
            currentTouchLabel: 'Due tomorrow',
            previewTouchLabel: 'Due today',
            previewState: CompanyGovernanceFollowUpState.dueToday,
            becomesDueNow: true,
          ),
        ],
      ),
      entityName: 'Company Governance',
      requestedBy: 'People Operations',
      requestedAt: DateTime(2026, 6, 12),
    );
    CompanyGovernanceFollowUpPolicyApprovalRequest? approvedRequest;
    CompanyGovernanceFollowUpPolicyApprovalRequest? rejectedRequest;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyGovernanceFollowUpPolicyApprovalPanel(
              currentPolicy: currentPolicy,
              queue: CompanyGovernanceFollowUpPolicyApprovalQueue(
                records: [request],
              ),
              onApprove: (request) {
                approvedRequest = request;
              },
              onReject: (request) {
                rejectedRequest = request;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Governance SLA Approvals'), findsOneWidget);
    expect(find.text('1 pending, 0 approved, 0 rejected'), findsOneWidget);
    expect(find.text('Pending approval'), findsOneWidget);
    expect(
      find.text('People Operations: Due tomorrow -> Due today'),
      findsOneWidget,
    );

    final approveButton = find.byKey(
      const Key(
        'company-governance-sla-approval-approve-governance-sla-approval-001',
      ),
    );
    await tester.ensureVisible(approveButton);
    await tester.tap(approveButton);
    await tester.pump();
    expect(approvedRequest?.id, 'governance-sla-approval-001');

    final rejectButton = find.byKey(
      const Key(
        'company-governance-sla-approval-reject-governance-sla-approval-001',
      ),
    );
    await tester.ensureVisible(rejectButton);
    await tester.tap(rejectButton);
    await tester.pump();
    expect(rejectedRequest?.id, 'governance-sla-approval-001');
  });

  testWidgets('company governance SLA history panel restores policy', (
    tester,
  ) async {
    const previousPolicy = CompanyGovernanceFollowUpPolicy(
      criticalCadenceDays: 1,
      highCadenceDays: 2,
      steadyCadenceDays: 3,
    );
    const currentPolicy = CompanyGovernanceFollowUpPolicy(
      criticalCadenceDays: 4,
      highCadenceDays: 5,
      steadyCadenceDays: 6,
    );
    final record = CompanyGovernanceFollowUpPolicyChangeRecord(
      id: 'governance-sla-001',
      previousPolicy: previousPolicy,
      nextPolicy: currentPolicy,
      entityName: 'Company Governance',
      actorName: 'People Operations',
      recordedAt: DateTime(2026, 6, 12),
      impactHeadline: '1 lane shifts timing',
      dueNowCount: 0,
      changedLaneCount: 1,
      needsHandoffCount: 1,
      scheduledCount: 2,
      topOwnerName: 'People Operations',
      topOwnerBeforeLabel: 'Due tomorrow',
      topOwnerAfterLabel: 'Due in 4d',
      auditEventId: 'audit-sla',
    );
    CompanyGovernanceFollowUpPolicyChangeRecord? restoredRecord;
    String? selectedAuditEventId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyGovernanceFollowUpPolicyHistoryPanel(
              currentPolicy: currentPolicy,
              history: CompanyGovernanceFollowUpPolicyHistory(
                records: [record],
              ),
              onRestorePolicy: (record) {
                restoredRecord = record;
              },
              onAuditEventSelected: (auditEventId) {
                selectedAuditEventId = auditEventId;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Governance SLA History'), findsOneWidget);
    expect(find.text('1 changes, 1 audited'), findsOneWidget);
    expect(find.text('2026-06-12'), findsWidgets);
    expect(
      find.text('People Operations: Due tomorrow -> Due in 4d'),
      findsOneWidget,
    );

    final auditButton = find.byKey(
      const Key('company-governance-sla-history-audit-button'),
    );
    await tester.ensureVisible(auditButton);
    await tester.tap(auditButton);
    await tester.pump();
    expect(selectedAuditEventId, 'audit-sla');

    final restoreButton = find.byKey(
      const Key('company-governance-sla-history-restore-button'),
    );
    await tester.ensureVisible(restoreButton);
    await tester.tap(restoreButton);
    await tester.pump();
    expect(restoredRecord?.id, 'governance-sla-001');
  });

  testWidgets('employee escalation history panel selects audit event', (
    tester,
  ) async {
    String? selectedAuditEventId;
    final asOfDate = DateTime(2026, 6, 9);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: EmployeeDocumentEscalationHistoryPanel(
              asOfDate: asOfDate,
              history: EmployeeDocumentEscalationHistory(
                totalEscalationCount: 1,
                ownerCount: 1,
                items: [
                  EmployeeDocumentEscalationHistoryItem(
                    id: 'audit-escalation-1',
                    ownerName: 'Fajar Prakoso',
                    entityName: 'PT Kaysir Nusantara',
                    actorName: 'People Operations',
                    happenedAt: asOfDate,
                    note:
                        'Escalated owner workload for 1 employee document gap: '
                        'Critical priority, 3 missing evidence items.',
                    auditEventId: 'audit-escalation-1',
                  ),
                ],
              ),
              onAuditEventSelected: (id) {
                selectedAuditEventId = id;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Escalation History'), findsOneWidget);
    expect(find.text('Fajar Prakoso'), findsOneWidget);
    expect(find.text('Escalated today'), findsWidgets);

    await tester.tap(
      find.byKey(const Key('employee-escalation-history-audit-escalation-1')),
    );
    await tester.pump();

    expect(selectedAuditEventId, 'audit-escalation-1');
  });

  testWidgets('employee digest history panel selects audit event', (
    tester,
  ) async {
    String? selectedAuditEventId;
    final asOfDate = DateTime(2026, 6, 9);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: EmployeeDocumentDigestHistoryPanel(
              asOfDate: asOfDate,
              history: EmployeeDocumentDigestHistory(
                totalDigestCount: 1,
                ownerCount: 1,
                items: [
                  EmployeeDocumentDigestHistoryItem(
                    id: 'audit-1',
                    ownerName: 'Fajar Prakoso',
                    entityName: 'PT Kaysir Nusantara',
                    actorName: 'People Operations',
                    happenedAt: asOfDate,
                    note:
                        'Sent owner digest for 1 employee document gap: '
                        '3 missing evidence items, 1 open request.',
                    auditEventId: 'audit-1',
                  ),
                ],
              ),
              onAuditEventSelected: (id) {
                selectedAuditEventId = id;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Digest Dispatch History'), findsOneWidget);
    expect(find.text('Fajar Prakoso'), findsOneWidget);
    expect(find.text('Sent today'), findsWidgets);

    await tester.tap(find.byKey(const Key('employee-digest-history-audit-1')));
    await tester.pump();

    expect(selectedAuditEventId, 'audit-1');
  });

  testWidgets('employee digest preview dialog returns confirmation', (
    tester,
  ) async {
    bool? confirmed;
    final asOfDate = DateTime(2026, 6, 9);
    final preview = EmployeeDocumentDigestPreview(
      owners: [
        EmployeeDocumentDigestPreviewOwner(
          workload: _digestPreviewWorkload,
          digestStatus: CompanyEmployeeDocumentWorkloadDigestStatus(
            ownerName: 'Fajar Prakoso',
            digestCount: 1,
            lastSentAt: asOfDate.subtract(const Duration(days: 1)),
            lastAuditEventId: 'audit-1',
          ),
          asOfDate: asOfDate,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () async {
                    confirmed = await showEmployeeDocumentDigestPreviewDialog(
                      context: context,
                      preview: preview,
                    );
                  },
                  child: const Text('Open preview'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open preview'));
    await tester.pumpAndSettle();

    expect(find.text('Digest preview'), findsOneWidget);
    expect(find.text('Review rejected evidence for David Kim'), findsOneWidget);
    expect(find.text('Send digest'), findsOneWidget);

    await tester.tap(find.text('Send digest'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });

  testWidgets('employee escalation preview dialog returns confirmation', (
    tester,
  ) async {
    bool? confirmed;
    const preview = EmployeeDocumentEscalationPreview(
      owners: [EmployeeDocumentEscalationPreviewOwner(plan: _escalationPlan)],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () async {
                    confirmed =
                        await showEmployeeDocumentEscalationPreviewDialog(
                          context: context,
                          preview: preview,
                        );
                  },
                  child: const Text('Open escalation preview'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open escalation preview'));
    await tester.pumpAndSettle();

    expect(find.text('Escalation preview'), findsOneWidget);
    expect(find.text('Review rejected evidence for David Kim'), findsOneWidget);
    expect(find.text('Record escalation'), findsOneWidget);

    await tester.tap(find.text('Record escalation'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });
}

const _digestPreviewWorkload = CompanyEmployeeDocumentWorkload(
  ownerName: 'Fajar Prakoso',
  entityNames: ['PT Kaysir Nusantara'],
  gapIds: ['gap-1'],
  score: 120,
  gapCount: 1,
  criticalCount: 1,
  highCount: 0,
  overdueCount: 1,
  dueSoonCount: 0,
  openRequestCount: 1,
  missingDocumentCount: 3,
  pendingDocumentCount: 0,
  rejectedDocumentCount: 1,
  primaryAction: 'Review rejected evidence',
  primaryGapId: 'gap-1',
  primaryEmployeeName: 'David Kim',
);

const _noDigestWorkload = CompanyEmployeeDocumentWorkload(
  ownerName: 'People Operations',
  entityNames: ['PT Kaysir Nusantara'],
  gapIds: ['gap-2'],
  score: 64,
  gapCount: 1,
  criticalCount: 0,
  highCount: 1,
  overdueCount: 0,
  dueSoonCount: 1,
  openRequestCount: 1,
  missingDocumentCount: 5,
  pendingDocumentCount: 0,
  rejectedDocumentCount: 0,
  primaryAction: 'Generate request',
  primaryGapId: 'gap-2',
  primaryEmployeeName: 'Alya Rahman',
);

const _escalationPlan = EmployeeDocumentEscalationPlan(
  ownerName: 'Fajar Prakoso',
  entitySummary: 'PT Kaysir Nusantara',
  priority: EmployeeDocumentEscalationPriority.critical,
  workloadScore: 120,
  gapCount: 1,
  criticalCount: 1,
  highCount: 0,
  overdueCount: 1,
  dueSoonCount: 0,
  missingDocumentCount: 3,
  openRequestCount: 1,
  actionLabel: 'Review rejected evidence',
  primaryEmployeeName: 'David Kim',
  digestFreshnessLabel: 'Digest due',
  digestCadenceLabel: 'Daily',
  digestDue: true,
  rationale: '1 critical and 1 overdue document gap need owner escalation.',
);

const _coolingDownEscalationPlan = EmployeeDocumentEscalationPlan(
  ownerName: 'Dewi Lestari',
  entitySummary: 'Kaysir Retail Services',
  priority: EmployeeDocumentEscalationPriority.critical,
  workloadScore: 96,
  gapCount: 1,
  criticalCount: 1,
  highCount: 0,
  overdueCount: 1,
  dueSoonCount: 0,
  missingDocumentCount: 4,
  openRequestCount: 1,
  actionLabel: 'Generate request',
  primaryEmployeeName: 'Nadia Safitri',
  digestFreshnessLabel: 'Digest due',
  digestCadenceLabel: 'Daily',
  digestDue: true,
  escalationFreshnessLabel: 'Escalated today',
  escalationCount: 1,
  escalationCoolingDown: true,
  rationale: '1 critical and 1 overdue document gap need owner escalation.',
);

class _CompanyProfilePanelHarness extends ConsumerWidget {
  const _CompanyProfilePanelHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(companyProfileProvider);
    final draft = ref.watch(companyProfileDraftProvider);

    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CompanyProfileFormPanel(
                    profile: profile,
                    draft: draft,
                    onLegalNameChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setLegalName,
                    onDisplayNameChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setDisplayName,
                    onRegistrationNumberChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setRegistrationNumber,
                    onTaxIdChanged:
                        ref.read(companyProfileDraftProvider.notifier).setTaxId,
                    onIndustryChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setIndustry,
                    onWebsiteChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setWebsite,
                    onHeadquartersChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setHeadquarters,
                    onPrimaryContactChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setPrimaryContact,
                    onStatusChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setStatus,
                    onEmployeeCountChanged:
                        ref
                            .read(companyProfileDraftProvider.notifier)
                            .setEmployeeCount,
                    onSave: () {
                      final saved = ref
                          .read(companyProfileProvider.notifier)
                          .saveDraft(ref.read(companyProfileDraftProvider));
                      ref
                          .read(companyProfileDraftProvider.notifier)
                          .loadProfile(saved);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${saved.displayName} profile saved'),
                        ),
                      );
                    },
                    onReset: () {
                      ref
                          .read(companyProfileDraftProvider.notifier)
                          .loadProfile(ref.read(companyProfileProvider));
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(ref.watch(companyProfileProvider).legalName),
                  Text(
                    '${ref.watch(companyProfileProvider).employeeCount} employees',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CompanyOrgUnitPanelHarness extends ConsumerWidget {
  const _CompanyOrgUnitPanelHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(companyOrgUnitDraftProvider);
    final units = ref.watch(companyOrgUnitsProvider);

    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CompanyOrgUnitFormPanel(
                    draft: draft,
                    entities: ref.watch(companyEntitiesProvider),
                    onNameChanged:
                        ref.read(companyOrgUnitDraftProvider.notifier).setName,
                    onCodeChanged:
                        ref.read(companyOrgUnitDraftProvider.notifier).setCode,
                    onEntityChanged:
                        ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .setEntityName,
                    onParentChanged:
                        ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .setParentName,
                    onManagerChanged:
                        ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .setManagerName,
                    onLocationChanged:
                        ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .setLocation,
                    onPlannedHeadcountChanged:
                        ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .setPlannedHeadcount,
                    onActiveHeadcountChanged:
                        ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .setActiveHeadcount,
                    onStatusChanged:
                        ref
                            .read(companyOrgUnitDraftProvider.notifier)
                            .setStatus,
                    onSubmit: () {
                      final unit = ref
                          .read(companyOrgUnitsProvider.notifier)
                          .submitDraft(ref.read(companyOrgUnitDraftProvider));
                      ref
                          .read(companyOrgUnitDraftProvider.notifier)
                          .clear(entityName: unit.entityName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${unit.name} added to company structure',
                          ),
                        ),
                      );
                    },
                    onClear: () {
                      ref.read(companyOrgUnitDraftProvider.notifier).clear();
                    },
                  ),
                  const SizedBox(height: 16),
                  for (final unit in units)
                    Text('${unit.name} (${unit.code.toUpperCase()})'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

CompanyPositionControl _workforcePosition({
  required String id,
  required String title,
  required String orgUnitName,
  required CompanyPositionControlStatus status,
  required int authorizedSeats,
  required int filledSeats,
  required String compensationBand,
  String entityName = 'PT Kaysir Nusantara',
}) {
  return CompanyPositionControl(
    id: id,
    positionTitle: title,
    entityName: entityName,
    orgUnitName: orgUnitName,
    type: CompanyPositionControlType.permanent,
    status: status,
    ownerName: 'People Operations',
    authorizedSeats: authorizedSeats,
    filledSeats: filledSeats,
    fte: 1,
    compensationBand: compensationBand,
    nextReviewDate: DateTime(2026, 9, 30),
    hiringPlan: 'Planned workforce demand',
    linkedRequisition: 'REQ-2026-01',
  );
}

CompanyHeadcountRequisition _headcountRequest({
  required String id,
  required String roleTitle,
  required CompanyHeadcountRequisitionStatus status,
}) {
  return CompanyHeadcountRequisition(
    id: id,
    roleTitle: roleTitle,
    entityName: 'PT Kaysir Nusantara',
    orgUnitName: 'Product & Commerce',
    hiringManagerName: 'Fajar Prakoso',
    positionControlId: 'position-product-engineer',
    jobProfileCode: 'ENG-JP-04',
    costCenterCode: 'CC-PROD',
    type: CompanyHeadcountRequisitionType.growth,
    priority: CompanyHeadcountRequisitionPriority.high,
    status: status,
    requestedSeats: 1,
    targetStartDate: DateTime(2026, 7, 1),
    businessCase: 'Add delivery capacity for commerce roadmap',
    budgetImpact: 'Uses product hiring plan',
    approverRole: 'Head of Product',
  );
}

CompanyCostCenter _workforceCostCenter({
  required String id,
  required String code,
  required String orgUnitName,
  String entityName = 'PT Kaysir Nusantara',
  CompanyCostCenterStatus status = CompanyCostCenterStatus.active,
}) {
  return CompanyCostCenter(
    id: id,
    code: code,
    name: orgUnitName,
    entityName: entityName,
    orgUnitName: orgUnitName,
    ownerName: 'People Operations',
    annualBudget: 1200000000,
    allocatedHeadcount: 12,
    activeHeadcount: 11,
    status: status,
  );
}

CompanyCompensationBand _workforceBand(
  String code, {
  String entityName = 'PT Kaysir Nusantara',
}) {
  return CompanyCompensationBand(
    id: 'band-$code',
    bandCode: code,
    entityName: entityName,
    family: CompanyCompensationBandFamily.general,
    levelName: 'Specialist',
    status: CompanyCompensationBandStatus.active,
    minSalary: 120000000,
    midpointSalary: 150000000,
    maxSalary: 180000000,
    currency: 'IDR',
    ownerName: 'People Operations',
    approverName: 'Head of People',
    effectiveDate: DateTime(2026, 1, 1),
    nextReviewDate: DateTime(2026, 12, 31),
    linkedPolicy: 'Workforce architecture',
  );
}

CompanyJobProfile _workforceJobProfile({
  required String code,
  required String title,
  required String orgUnitName,
  required String compensationBand,
  String entityName = 'PT Kaysir Nusantara',
}) {
  return CompanyJobProfile(
    id: 'job-$code',
    jobCode: code,
    jobTitle: title,
    entityName: entityName,
    orgUnitName: orgUnitName,
    family: CompanyJobFamily.general,
    levelName: 'Specialist',
    status: CompanyJobProfileStatus.active,
    compensationBand: compensationBand,
    ownerName: 'People Operations',
    nextReviewDate: DateTime(2026, 12, 31),
    jobDescription: 'Owns workforce operations for this role.',
    skillsSummary: 'Operations, collaboration, compliance',
    linkedPolicy: 'Workforce architecture',
  );
}
