import '../models/financial_report_evidence_close_task.dart';
import '../models/financial_report_pack.dart';
import 'financial_report_schedule_evidence_health_service.dart';

class FinancialReportEvidenceCloseTaskService {
  final FinancialReportScheduleEvidenceHealthService evidenceHealthService;

  const FinancialReportEvidenceCloseTaskService({
    this.evidenceHealthService =
        const FinancialReportScheduleEvidenceHealthService(),
  });

  List<FinancialReportEvidenceCloseTask> buildTasks(
    Iterable<FinancialReportSupportingSchedule> schedules, {
    DateTime? generatedAt,
  }) {
    final taskDate = generatedAt ?? DateTime.now();
    final healthItems = evidenceHealthService.summarizeBySchedule(schedules);

    return healthItems
        .where((item) => !item.summary.isReady)
        .map((item) => _taskForHealthItem(item, taskDate))
        .toList(growable: false);
  }

  List<FinancialReportEvidenceCloseTaskReviewItem> buildReviewItems({
    required Iterable<FinancialReportSupportingSchedule> schedules,
    List<FinancialReportEvidenceCloseTaskResolution> resolutions = const [],
    DateTime? generatedAt,
  }) {
    final resolutionsByTask = {
      for (final resolution in resolutions) resolution.taskId: resolution,
    };
    return [
      for (final task in buildTasks(schedules, generatedAt: generatedAt))
        FinancialReportEvidenceCloseTaskReviewItem(
          task: task,
          resolution: resolutionsByTask[task.id],
        ),
    ];
  }

  FinancialReportEvidenceCloseTask _taskForHealthItem(
    FinancialReportScheduleEvidenceHealthItem item,
    DateTime generatedAt,
  ) {
    final priority =
        item.summary.criticalSignalCount > 0
            ? FinancialReportEvidenceCloseTaskPriority.action
            : FinancialReportEvidenceCloseTaskPriority.monitor;
    final assignee = _assigneeFor(item.scheduleKind);

    return FinancialReportEvidenceCloseTask(
      id: 'evidence-${item.scheduleKind.name}-${_slug(item.scheduleTitle)}',
      scheduleKind: item.scheduleKind,
      scheduleTitle: item.scheduleTitle,
      priority: priority,
      title: '${item.scheduleTitle} evidence follow-up',
      actionLabel: item.actionLabel,
      owner: assignee.owner,
      dueDate: _addBusinessDays(
        _dateOnly(generatedAt),
        priority == FinancialReportEvidenceCloseTaskPriority.action ? 1 : 3,
      ),
      reviewer: assignee.reviewer,
      evidenceLabel: _evidenceLabelFor(item.scheduleKind),
      reference: _referenceFor(item.scheduleKind),
      criticalSignalCount: item.summary.criticalSignalCount,
      watchSignalCount: item.summary.watchSignalCount,
      readySignalCount: item.summary.readySignalCount,
    );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _addBusinessDays(DateTime start, int days) {
    var remaining = days;
    var date = start;
    while (remaining > 0) {
      date = date.add(const Duration(days: 1));
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        remaining -= 1;
      }
    }
    return date;
  }

  _EvidenceTaskAssignee _assigneeFor(
    FinancialReportSupportingScheduleKind kind,
  ) {
    switch (kind) {
      case FinancialReportSupportingScheduleKind.cashRollForward:
        return const _EvidenceTaskAssignee(
          owner: 'GL accountant',
          reviewer: 'Controller',
        );
      case FinancialReportSupportingScheduleKind.bankReconciliation:
        return const _EvidenceTaskAssignee(
          owner: 'Treasury / Cash accountant',
          reviewer: 'Controller',
        );
      case FinancialReportSupportingScheduleKind.incomeTax:
      case FinancialReportSupportingScheduleKind.incomeTaxSettlement:
      case FinancialReportSupportingScheduleKind.incomeTaxReconciliation:
      case FinancialReportSupportingScheduleKind.valueAddedTaxSettlement:
        return const _EvidenceTaskAssignee(
          owner: 'Tax accountant',
          reviewer: 'Tax manager',
        );
      case FinancialReportSupportingScheduleKind.managementPerformanceMeasure:
        return const _EvidenceTaskAssignee(
          owner: 'Financial reporting lead',
          reviewer: 'Controller',
        );
      case FinancialReportSupportingScheduleKind.otherComprehensiveIncome:
        return const _EvidenceTaskAssignee(
          owner: 'Reporting accountant',
          reviewer: 'Controller',
        );
    }
  }

  String _evidenceLabelFor(FinancialReportSupportingScheduleKind kind) {
    switch (kind) {
      case FinancialReportSupportingScheduleKind.cashRollForward:
        return 'Cash movement tie-out and supporting bank evidence';
      case FinancialReportSupportingScheduleKind.bankReconciliation:
        return 'Bank statement, timing review, and clearing evidence';
      case FinancialReportSupportingScheduleKind.incomeTax:
        return 'Tax source lines and income tax expense support';
      case FinancialReportSupportingScheduleKind.incomeTaxSettlement:
        return 'Income tax payable, prepayment, and withholding support';
      case FinancialReportSupportingScheduleKind.incomeTaxReconciliation:
        return 'Fiscal reconciliation and rate benchmark support';
      case FinancialReportSupportingScheduleKind.valueAddedTaxSettlement:
        return 'PPN input, output, payable, and return support';
      case FinancialReportSupportingScheduleKind.managementPerformanceMeasure:
        return 'UKTM approval, reconciliation, and management measure support';
      case FinancialReportSupportingScheduleKind.otherComprehensiveIncome:
        return 'OCI movement support and classification review';
    }
  }

  String _referenceFor(FinancialReportSupportingScheduleKind kind) {
    switch (kind) {
      case FinancialReportSupportingScheduleKind.cashRollForward:
      case FinancialReportSupportingScheduleKind.bankReconciliation:
        return 'PSAK 207 / PSAK 201';
      case FinancialReportSupportingScheduleKind.incomeTax:
      case FinancialReportSupportingScheduleKind.incomeTaxSettlement:
      case FinancialReportSupportingScheduleKind.incomeTaxReconciliation:
        return 'PSAK 212 / Indonesia Tax';
      case FinancialReportSupportingScheduleKind.valueAddedTaxSettlement:
        return 'Indonesia VAT / PPN';
      case FinancialReportSupportingScheduleKind.managementPerformanceMeasure:
        return 'PSAK 118 / UKTM';
      case FinancialReportSupportingScheduleKind.otherComprehensiveIncome:
        return 'PSAK 201';
    }
  }

  String _slug(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return normalized.isEmpty ? 'schedule' : normalized;
  }
}

class _EvidenceTaskAssignee {
  final String owner;
  final String reviewer;

  const _EvidenceTaskAssignee({required this.owner, required this.reviewer});
}
