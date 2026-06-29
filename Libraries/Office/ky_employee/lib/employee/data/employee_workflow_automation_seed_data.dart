import '../models/employee_directory_models.dart';
import '../models/employee_workflow_automation_models.dart';

EmployeeWorkflowAutomationProfile buildEmployeeWorkflowAutomationProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  return EmployeeWorkflowAutomationProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    hooks: _hooksFor(member: member, today: today),
  );
}

EmployeeWorkflowAutomationHookDraft buildEmployeeWorkflowAutomationHookDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeWorkflowAutomationHookDraft.fromMember(
    member: member,
    asOfDate: asOfDate,
  );
}

List<EmployeeWorkflowAutomationHook> _hooksFor({
  required EmployeeDirectoryMember member,
  required DateTime today,
}) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      _hook(
        id: '${member.id}-automation-policy',
        employeeId: member.id,
        name: 'Approval policy repair task sync',
        trigger: EmployeeWorkflowAutomationTrigger.approvalPolicyIssue,
        delivery: EmployeeWorkflowAutomationDelivery.createWorkflowTask,
        owner: 'People Operations',
        sourceLabel: 'Approval policy',
        generatedTaskTitle: 'Resolve suspended approval policy',
        slaHours: 8,
        status: EmployeeWorkflowAutomationStatus.failed,
        risk: EmployeeWorkflowAutomationRisk.high,
        lastRunAt: today.subtract(const Duration(days: 1)),
        nextRunAt: today,
        generatedTaskCount: 2,
        failureReason: 'Fallback owner is missing for suspended policy queue.',
        notes: 'Failed sync must be repaired before policy tasks can fan out.',
      ),
      _hook(
        id: '${member.id}-automation-manager',
        employeeId: member.id,
        name: 'Manager-change blocker task sync',
        trigger: EmployeeWorkflowAutomationTrigger.managerChangeBlocker,
        delivery: EmployeeWorkflowAutomationDelivery.createWorkflowTask,
        owner: 'HR Business Partner',
        sourceLabel: 'Manager change readiness',
        generatedTaskTitle: 'Clear blocked manager change readiness',
        slaHours: 12,
        status: EmployeeWorkflowAutomationStatus.active,
        risk: EmployeeWorkflowAutomationRisk.high,
        lastRunAt: today.subtract(const Duration(days: 1)),
        nextRunAt: today,
        generatedTaskCount: 3,
        failureReason: '',
        notes: 'Creates recovery-plan follow-ups when manager change blocks.',
      ),
    ];
  }

  if (member.id == '2') {
    return [
      _hook(
        id: '${member.id}-automation-history',
        employeeId: member.id,
        name: 'Job-history evidence task sync',
        trigger: EmployeeWorkflowAutomationTrigger.jobHistoryEvidence,
        delivery: EmployeeWorkflowAutomationDelivery.createWorkflowTask,
        owner: 'Talent Operations',
        sourceLabel: 'Job history',
        generatedTaskTitle: 'Attach job history evidence',
        slaHours: 24,
        status: EmployeeWorkflowAutomationStatus.active,
        risk: EmployeeWorkflowAutomationRisk.medium,
        lastRunAt: today.subtract(const Duration(days: 2)),
        nextRunAt: today.add(const Duration(days: 1)),
        generatedTaskCount: 1,
        failureReason: '',
        notes: 'Keeps promotion evidence tasks aligned with the job ledger.',
      ),
      _hook(
        id: '${member.id}-automation-policy-draft',
        employeeId: member.id,
        name: 'Compensation policy activation hook',
        trigger: EmployeeWorkflowAutomationTrigger.approvalPolicyIssue,
        delivery: EmployeeWorkflowAutomationDelivery.escalateOwner,
        owner: 'People Operations',
        sourceLabel: 'Approval policy',
        generatedTaskTitle: 'Review approval policy routing',
        slaHours: 24,
        status: EmployeeWorkflowAutomationStatus.draft,
        risk: EmployeeWorkflowAutomationRisk.high,
        lastRunAt: null,
        nextRunAt: today.add(const Duration(days: 2)),
        generatedTaskCount: 0,
        failureReason: '',
        notes: 'Draft hook for promotion compensation routing activation.',
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      _hook(
        id: '${member.id}-automation-documents',
        employeeId: member.id,
        name: 'Onboarding document task sync',
        trigger: EmployeeWorkflowAutomationTrigger.approvalPolicyIssue,
        delivery: EmployeeWorkflowAutomationDelivery.notifyOwner,
        owner: 'HR Operations',
        sourceLabel: 'Approval policy',
        generatedTaskTitle: 'Review approval policy routing',
        slaHours: 24,
        status: EmployeeWorkflowAutomationStatus.paused,
        risk: EmployeeWorkflowAutomationRisk.medium,
        lastRunAt: today.subtract(const Duration(days: 3)),
        nextRunAt: today.add(const Duration(days: 1)),
        generatedTaskCount: 1,
        failureReason: '',
        notes: 'Paused until onboarding owner confirms document routing.',
      ),
    ];
  }

  return [
    _hook(
      id: '${member.id}-automation-next-action',
      employeeId: member.id,
      name: 'Next-action workflow task sync',
      trigger: EmployeeWorkflowAutomationTrigger.nextActionSignal,
      delivery: EmployeeWorkflowAutomationDelivery.createWorkflowTask,
      owner: 'People Operations',
      sourceLabel: 'Next best actions',
      generatedTaskTitle: 'Review employee readiness',
      slaHours: 48,
      status: EmployeeWorkflowAutomationStatus.active,
      risk:
          member.isHighPerformer
              ? EmployeeWorkflowAutomationRisk.medium
              : EmployeeWorkflowAutomationRisk.low,
      lastRunAt: today.subtract(const Duration(days: 1)),
      nextRunAt: today.add(const Duration(days: 5)),
      generatedTaskCount: 2,
      failureReason: '',
      notes: 'Keeps top employee actions synchronized into workflow tasks.',
    ),
  ];
}

EmployeeWorkflowAutomationHook _hook({
  required String id,
  required String employeeId,
  required String name,
  required EmployeeWorkflowAutomationTrigger trigger,
  required EmployeeWorkflowAutomationDelivery delivery,
  required String owner,
  required String sourceLabel,
  required String generatedTaskTitle,
  required int slaHours,
  required EmployeeWorkflowAutomationStatus status,
  required EmployeeWorkflowAutomationRisk risk,
  required DateTime? lastRunAt,
  required DateTime nextRunAt,
  required int generatedTaskCount,
  required String failureReason,
  required String notes,
}) {
  return EmployeeWorkflowAutomationHook(
    id: id,
    employeeId: employeeId,
    name: name,
    trigger: trigger,
    delivery: delivery,
    owner: owner,
    sourceLabel: sourceLabel,
    generatedTaskTitle: generatedTaskTitle,
    slaHours: slaHours,
    status: status,
    risk: risk,
    lastRunAt: lastRunAt == null ? null : _dateOnly(lastRunAt),
    nextRunAt: _dateOnly(nextRunAt),
    generatedTaskCount: generatedTaskCount,
    failureReason: failureReason,
    notes: notes,
  );
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
