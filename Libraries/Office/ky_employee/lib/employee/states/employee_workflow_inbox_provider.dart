import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_action_workflow_models.dart';
import '../models/employee_data_correction_models.dart';
import '../models/employee_data_quality_models.dart';
import '../models/employee_job_assignment_models.dart';
import '../models/employee_next_action_models.dart';
import '../models/employee_profile_change_governance_models.dart';
import '../models/employee_workflow_inbox_models.dart';
import 'employee_action_workflow_provider.dart';
import 'employee_data_correction_provider.dart';
import 'employee_job_assignment_provider.dart';
import 'employee_profile_change_governance_provider.dart';

/// Aggregates an employee's active HR workflow work into one inbox profile.
final employeeWorkflowInboxProvider = Provider.family<
  EmployeeWorkflowInboxProfile?,
  String
>((ref, employeeId) {
  final actionWorkflow = ref.watch(employeeActionWorkflowProvider(employeeId));
  if (actionWorkflow == null) return null;

  final profileChanges = ref.watch(
    employeeProfileChangeGovernanceProvider(employeeId),
  );
  final dataCorrections = ref.watch(employeeDataCorrectionProvider(employeeId));
  final jobAssignments = ref.watch(
    employeeJobAssignmentProfileProvider(employeeId),
  );

  return EmployeeWorkflowInboxProfile(
    employeeId: actionWorkflow.employeeId,
    employeeName: actionWorkflow.employeeName,
    asOfDate: actionWorkflow.asOfDate,
    items: [
      ...actionWorkflow.activeTasks.map(_fromActionTask),
      if (profileChanges != null)
        ...profileChanges.sortedRequests
            .where((request) => request.isOpen)
            .map(
              (request) => _fromProfileChange(
                request,
                asOfDate: actionWorkflow.asOfDate,
              ),
            ),
      if (dataCorrections != null)
        ...dataCorrections.sortedRequests
            .where((request) => request.isOpen)
            .map(_fromDataCorrection),
      if (jobAssignments != null)
        ...jobAssignments.assignments
            .where(
              (assignment) =>
                  assignment.needsAttention(jobAssignments.asOfDate),
            )
            .map(
              (assignment) =>
                  _fromJobAssignment(assignment, profile: jobAssignments),
            ),
    ],
  );
});

EmployeeWorkflowInboxItem _fromActionTask(EmployeeActionTask task) {
  return EmployeeWorkflowInboxItem(
    id: 'action-${task.id}',
    sourceRecordId: task.id,
    employeeId: task.employeeId,
    employeeName: task.employeeName,
    title: task.title,
    detail: task.description,
    owner: task.owner,
    source: EmployeeWorkflowInboxSource.actionWorkflow,
    area: task.area,
    priority: task.priority,
    statusLabel: task.status.label,
    dueDate: task.dueDate,
    isReady:
        task.status == EmployeeActionTaskStatus.open ||
        task.status == EmployeeActionTaskStatus.inProgress,
    primaryAction: _actionTaskPrimaryAction(task),
  );
}

EmployeeWorkflowInboxItem _fromProfileChange(
  EmployeeProfileChangeRequest request, {
  required DateTime asOfDate,
}) {
  return EmployeeWorkflowInboxItem(
    id: 'profile-change-${request.id}',
    sourceRecordId: request.id,
    employeeId: request.employeeId,
    employeeName: request.employeeName,
    title: '${request.field.label} change',
    detail: request.impactLabel,
    owner: _profileChangeOwner(request, asOfDate: asOfDate),
    source: EmployeeWorkflowInboxSource.profileChange,
    area:
        request.field.affectsPayroll
            ? EmployeeNextActionArea.pay
            : EmployeeNextActionArea.work,
    priority: _profileChangePriority(request, asOfDate: asOfDate),
    statusLabel: request.status.label,
    dueDate: request.effectiveDate,
    isReady:
        request.canStartReview ||
        request.canApprove ||
        request.canSchedule ||
        request.canApply(asOfDate),
    primaryAction: _profileChangePrimaryAction(request, asOfDate: asOfDate),
  );
}

EmployeeWorkflowInboxItem _fromDataCorrection(
  EmployeeDataCorrectionRequest request,
) {
  return EmployeeWorkflowInboxItem(
    id: 'data-correction-${request.id}',
    sourceRecordId: request.id,
    employeeId: request.employeeId,
    employeeName: request.employeeName,
    title: '${request.field} correction',
    detail: '${request.currentValue} -> ${request.proposedValue}',
    owner: _dataCorrectionOwner(request),
    source: EmployeeWorkflowInboxSource.dataCorrection,
    area: EmployeeNextActionArea.profile,
    priority: _severityPriority(request.severity),
    statusLabel: request.status.label,
    dueDate: request.dueDate,
    isReady: request.canReview || request.canApprove || request.canApply,
    primaryAction: _dataCorrectionPrimaryAction(request),
  );
}

EmployeeWorkflowInboxItem _fromJobAssignment(
  EmployeeJobAssignmentRecord assignment, {
  required EmployeeJobAssignmentProfile profile,
}) {
  final ready =
      assignment.canApprove || assignment.canActivate(profile.asOfDate);
  return EmployeeWorkflowInboxItem(
    id: 'job-assignment-${assignment.id}',
    sourceRecordId: assignment.id,
    employeeId: assignment.employeeId,
    employeeName: profile.employeeName,
    title: '${assignment.position} assignment',
    detail: '${assignment.department} under ${assignment.manager}',
    owner: 'HR Business Partner',
    source: EmployeeWorkflowInboxSource.jobAssignment,
    area: EmployeeNextActionArea.work,
    priority:
        ready
            ? EmployeeNextActionPriority.high
            : EmployeeNextActionPriority.medium,
    statusLabel: assignment.status.label,
    dueDate: assignment.startDate,
    isReady: ready,
    primaryAction: _jobAssignmentPrimaryAction(
      assignment,
      asOfDate: profile.asOfDate,
    ),
  );
}

EmployeeWorkflowInboxAction _actionTaskPrimaryAction(EmployeeActionTask task) {
  if (task.canStart) return EmployeeWorkflowInboxAction.start;
  if (task.canComplete) return EmployeeWorkflowInboxAction.complete;
  return EmployeeWorkflowInboxAction.none;
}

EmployeeWorkflowInboxAction _profileChangePrimaryAction(
  EmployeeProfileChangeRequest request, {
  required DateTime asOfDate,
}) {
  if (request.canStartReview) return EmployeeWorkflowInboxAction.review;
  if (request.canApprove) return EmployeeWorkflowInboxAction.approve;
  if (request.canSchedule) return EmployeeWorkflowInboxAction.schedule;
  if (request.canApply(asOfDate)) return EmployeeWorkflowInboxAction.apply;
  return EmployeeWorkflowInboxAction.none;
}

EmployeeWorkflowInboxAction _dataCorrectionPrimaryAction(
  EmployeeDataCorrectionRequest request,
) {
  if (request.canReview) return EmployeeWorkflowInboxAction.review;
  if (request.canApprove) return EmployeeWorkflowInboxAction.approve;
  if (request.canApply) return EmployeeWorkflowInboxAction.apply;
  return EmployeeWorkflowInboxAction.none;
}

EmployeeWorkflowInboxAction _jobAssignmentPrimaryAction(
  EmployeeJobAssignmentRecord assignment, {
  required DateTime asOfDate,
}) {
  if (assignment.canApprove) return EmployeeWorkflowInboxAction.approve;
  if (assignment.canActivate(asOfDate)) {
    return EmployeeWorkflowInboxAction.activate;
  }
  return EmployeeWorkflowInboxAction.none;
}

String _profileChangeOwner(
  EmployeeProfileChangeRequest request, {
  required DateTime asOfDate,
}) {
  if (request.canStartReview) return request.reviewer;
  if (request.canApprove) return request.approver;
  if (request.canSchedule || request.canApply(asOfDate)) {
    return request.requester;
  }
  return request.ownerFallback;
}

String _dataCorrectionOwner(EmployeeDataCorrectionRequest request) {
  if (request.canReview || request.canApprove) return request.reviewer;
  if (request.canApply) return request.requester;
  return request.reviewer;
}

EmployeeNextActionPriority _profileChangePriority(
  EmployeeProfileChangeRequest request, {
  required DateTime asOfDate,
}) {
  if (request.canApply(asOfDate)) return EmployeeNextActionPriority.high;
  if (request.field.affectsPayroll) return EmployeeNextActionPriority.high;
  if (request.canApprove || request.canSchedule) {
    return EmployeeNextActionPriority.medium;
  }
  return EmployeeNextActionPriority.low;
}

EmployeeNextActionPriority _severityPriority(
  EmployeeDataQualitySeverity severity,
) {
  return switch (severity) {
    EmployeeDataQualitySeverity.critical => EmployeeNextActionPriority.critical,
    EmployeeDataQualitySeverity.high => EmployeeNextActionPriority.high,
    EmployeeDataQualitySeverity.medium => EmployeeNextActionPriority.medium,
    EmployeeDataQualitySeverity.low => EmployeeNextActionPriority.low,
  };
}

extension on EmployeeProfileChangeRequest {
  String get ownerFallback {
    if (approver.trim().isNotEmpty) return approver;
    if (reviewer.trim().isNotEmpty) return reviewer;
    return requester;
  }
}
