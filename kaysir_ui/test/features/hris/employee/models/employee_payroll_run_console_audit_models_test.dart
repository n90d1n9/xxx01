import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_access_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_archive_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_decision_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_decision_receipt_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_export_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_handoff_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_package_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_command_models.dart';

void main() {
  test('payroll run console audit summary filters event outcomes', () {
    final summary = EmployeePayrollRunConsoleAuditSummary(
      events: [
        _event(id: 'completed', completedCount: 2, skippedCount: 1),
        _event(
          id: 'review',
          completedCount: 0,
          skippedCount: 3,
          errors: const ['Maya Santoso: Verify bank account first.'],
        ),
        _event(id: 'no-change', completedCount: 0, skippedCount: 0),
      ],
    );

    expect(summary.eventCount, 3);
    expect(summary.completedCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.noChangeCount, 1);
    expect(summary.countFor(EmployeePayrollRunConsoleAuditFilter.all), 3);
    expect(
      summary
          .eventsFor(EmployeePayrollRunConsoleAuditFilter.attention)
          .single
          .id,
      'review',
    );
    expect(
      summary
          .eventsFor(EmployeePayrollRunConsoleAuditFilter.noChange)
          .single
          .id,
      'no-change',
    );
  });

  test('payroll run console audit evidence recommends close action', () {
    final summary = EmployeePayrollRunConsoleAuditSummary(
      events: [
        _event(id: 'completed', completedCount: 2, skippedCount: 1),
        _event(
          id: 'review',
          completedCount: 0,
          skippedCount: 3,
          errors: const ['Maya Santoso: Verify bank account first.'],
        ),
      ],
    );
    final report = EmployeePayrollRunConsoleAuditEvidenceReport(
      summary: summary,
    );

    expect(
      report.status,
      EmployeePayrollRunConsoleAuditEvidenceStatus.reviewNeeded,
    );
    expect(report.headline, 'Review 1 payroll console event.');
    expect(
      report.nextAction,
      'Resolve review items before closing this payroll run.',
    );
    expect(report.coverageLabel, '2 completed updates, 4 skipped');
    expect(report.runReferenceLabel, 'RUN-202605-001');
    expect(report.operatorLabel, 'Payroll Lead');
    expect(report.latestLabel, 'Latest: Prepare export by Payroll Lead');
  });

  test('payroll run console audit package tracks handoff readiness', () {
    final report = EmployeePayrollRunConsoleAuditEvidenceReport(
      summary: EmployeePayrollRunConsoleAuditSummary(
        events: [
          _event(id: 'completed', completedCount: 2, skippedCount: 1),
          _event(
            id: 'review',
            commandType: EmployeePayrollRunConsoleCommandType.settlePayment,
            completedCount: 0,
            skippedCount: 3,
            errors: const ['Maya Santoso: Verify bank account first.'],
          ),
        ],
      ),
    );
    final package = EmployeePayrollRunConsoleAuditEvidencePackage(
      report: report,
    );

    expect(package.packageReference, 'PKG-RUN-202605-001-02');
    expect(package.readyItemCount, 3);
    expect(package.totalItemCount, 5);
    expect(package.readinessLabel, '3/5 ready');
    expect(package.handoffLabel, 'Clear review items before package handoff.');
    expect(
      package.items
          .singleWhere((item) => item.title == 'Review clearance')
          .detail,
      '1 event needs review',
    );
    expect(package.items.last.detail, '2/4 stages evidenced');
    expect(package.items.last.isReady, isFalse);
    expect(package.evidencedCommandCount, 2);
    expect(package.totalCommandCount, 4);
    expect(
      package.commandCoverage[0].status,
      EmployeePayrollRunConsoleAuditCommandCoverageStatus.ready,
    );
    expect(
      package.commandCoverage[1].status,
      EmployeePayrollRunConsoleAuditCommandCoverageStatus.reviewNeeded,
    );
    expect(
      package.commandCoverage[2].status,
      EmployeePayrollRunConsoleAuditCommandCoverageStatus.missing,
    );
  });

  test('payroll run console audit handoff blocks incomplete package', () {
    final package = EmployeePayrollRunConsoleAuditEvidencePackage(
      report: EmployeePayrollRunConsoleAuditEvidenceReport(
        summary: EmployeePayrollRunConsoleAuditSummary(
          events: [
            _event(id: 'completed', completedCount: 2, skippedCount: 1),
            _event(
              id: 'review',
              commandType: EmployeePayrollRunConsoleCommandType.settlePayment,
              completedCount: 0,
              skippedCount: 3,
              errors: const ['Maya Santoso: Verify bank account first.'],
            ),
          ],
        ),
      ),
    );
    final review = EmployeePayrollRunConsoleAuditHandoffReview.fromState(
      package: package,
      draft: EmployeePayrollRunConsoleAuditHandoffDraft(
        reviewer: 'Alya Rahman',
        approver: 'Rafi Pratama',
        dueDate: DateTime(2026, 6, 1),
        note: 'Reviewed payroll evidence before handoff.',
      ),
      handoffs: const [],
    );

    expect(review.canSubmit, isFalse);
    expect(review.statusLabel, 'Needs review');
    expect(
      review.errors,
      contains('Resolve 1 audit review event before handoff.'),
    );
    expect(
      review.errors,
      contains('Capture evidence for all 4 payroll command stages.'),
    );
  });

  test('payroll run console audit handoff records approval outcome', () {
    final package = _readyPackage();
    final review = EmployeePayrollRunConsoleAuditHandoffReview.fromState(
      package: package,
      draft: EmployeePayrollRunConsoleAuditHandoffDraft(
        reviewer: 'Alya Rahman',
        approver: 'Rafi Pratama',
        dueDate: DateTime(2026, 6, 1),
        note: 'Reviewed payroll evidence before handoff.',
      ),
      handoffs: const [],
    );

    expect(review.canSubmit, isTrue);
    expect(review.statusLabel, 'Ready for review');
    expect(review.completionRatio, 1);

    final record = review.toRecord(
      id: 'PAH-1',
      submittedAt: DateTime(2026, 5, 31, 10),
    );
    expect(
      () => record.approve(
        approvedAt: DateTime(2026, 5, 31, 11),
        attestations: const {},
      ),
      throwsStateError,
    );

    final approved = record.approve(
      approvedAt: DateTime(2026, 5, 31, 11),
      attestations:
          EmployeePayrollRunConsoleAuditDecisionAttestation.values.toSet(),
    );
    final approvedWithNote = record.approve(
      approvedAt: DateTime(2026, 5, 31, 11),
      attestations:
          EmployeePayrollRunConsoleAuditDecisionAttestation.values.toSet(),
      note: 'Close archive approved after bank proof review.',
    );
    final returned = record.returnForRevision(
      returnedAt: DateTime(2026, 5, 31, 11),
      reason: 'Refresh close evidence.',
    );

    expect(
      record.status,
      EmployeePayrollRunConsoleAuditHandoffStatus.submitted,
    );
    expect(record.summaryLabel, '5/5 package checks, 4/4 command stages.');
    expect(
      approved.status,
      EmployeePayrollRunConsoleAuditHandoffStatus.approved,
    );
    expect(
      approved.summaryLabel,
      'Approved by Rafi Pratama for payroll close archive.',
    );
    expect(approved.isDecided, isTrue);
    expect(approved.hasCompleteDecisionAttestation, isTrue);
    expect(approved.decisionAttestationLabel, '3/3 controls');
    expect(
      approvedWithNote.summaryLabel,
      'Approved by Rafi Pratama: Close archive approved after bank proof review.',
    );
    expect(
      returned.status,
      EmployeePayrollRunConsoleAuditHandoffStatus.returned,
    );
    expect(
      returned.summaryLabel,
      'Returned by Rafi Pratama: Refresh close evidence.',
    );
    expect(returned.decisionAttestationLabel, 'Return note captured');
  });

  test(
    'payroll run console audit decision receipt summarizes close outcome',
    () {
      final record = EmployeePayrollRunConsoleAuditHandoffReview.fromState(
            package: _readyPackage(),
            draft: EmployeePayrollRunConsoleAuditHandoffDraft(
              reviewer: 'Alya Rahman',
              approver: 'Rafi Pratama',
              dueDate: DateTime(2026, 6, 1),
              note: 'Reviewed payroll evidence before handoff.',
            ),
            handoffs: const [],
          )
          .toRecord(id: 'PAH-1', submittedAt: DateTime(2026, 5, 31, 10))
          .approve(
            approvedAt: DateTime(2026, 5, 31, 11),
            attestations:
                EmployeePayrollRunConsoleAuditDecisionAttestation.values
                    .toSet(),
            note: 'Close archive approved after bank proof review.',
          );
      final receipt = EmployeePayrollRunConsoleAuditDecisionReceipt(
        record: record,
      );

      expect(receipt.isVisible, isTrue);
      expect(receipt.isApproval, isTrue);
      expect(receipt.title, 'Close approval receipt');
      expect(receipt.controlsLabel, '3/3 controls');
      expect(receipt.evidenceLabel, '5/5 package, 4/4 commands');
      expect(receipt.reviewerApproverLabel, 'Alya Rahman to Rafi Pratama');
      expect(
        receipt.decisionNoteLabel,
        'Close archive approved after bank proof review.',
      );
      expect(receipt.attestations.length, 3);
    },
  );

  test('payroll run console audit decision draft gates approval', () {
    var draft = const EmployeePayrollRunConsoleAuditDecisionDraft(
      note: 'Return evidence.',
    );

    expect(draft.canApprove, isFalse);
    expect(draft.canReturn, isTrue);
    expect(draft.attestationLabel, '0/3');
    expect(
      draft.approvalHint,
      'Acknowledge all close controls before approval.',
    );

    for (final attestation
        in EmployeePayrollRunConsoleAuditDecisionAttestation.values) {
      draft = draft.toggleAttestation(attestation, true);
    }

    expect(draft.canApprove, isTrue);
    expect(draft.attestationLabel, '3/3');
    expect(draft.approvalHint, 'Approval controls acknowledged.');
  });

  test('payroll run console audit export preview builds ready csv', () {
    final preview = EmployeePayrollRunConsoleAuditExportPreview(
      package: _readyPackage(),
      generatedAt: DateTime(2026, 6, 1, 12),
    );

    expect(preview.status, EmployeePayrollRunConsoleAuditExportStatus.ready);
    expect(preview.isReady, isTrue);
    expect(preview.fileName, 'pkg-run-202605-001-04-audit-events.csv');
    expect(preview.rowCountLabel, '4 audit events');
    expect(
      preview.manifestItems
          .singleWhere((item) => item.label == 'Readiness')
          .value,
      '5/5 ready',
    );
    expect(
      preview.csvContent,
      contains('event_id,run_reference,command,status,operator'),
    );
    expect(preview.csvContent, contains('RUN-202605-001'));
    expect(preview.csvContent, contains('Prepare export'));
  });

  test('payroll run console audit export preview blocks review package', () {
    final package = EmployeePayrollRunConsoleAuditEvidencePackage(
      report: EmployeePayrollRunConsoleAuditEvidenceReport(
        summary: EmployeePayrollRunConsoleAuditSummary(
          events: [
            _event(id: 'completed', completedCount: 2, skippedCount: 1),
            _event(
              id: 'review',
              commandType: EmployeePayrollRunConsoleCommandType.settlePayment,
              completedCount: 0,
              skippedCount: 3,
              errors: const ['Maya Santoso: Verify bank account first.'],
            ),
          ],
        ),
      ),
    );
    final preview = EmployeePayrollRunConsoleAuditExportPreview(
      package: package,
      generatedAt: DateTime(2026, 6, 1, 12),
    );

    expect(
      preview.status,
      EmployeePayrollRunConsoleAuditExportStatus.needsReview,
    );
    expect(preview.isReady, isFalse);
    expect(preview.exportActionLabel, 'Resolve package checks first');
    expect(preview.rowCount, 2);
  });

  test('payroll run console audit archive pack waits for handoff', () {
    final pack = _archivePack();

    expect(
      pack.status,
      EmployeePayrollRunConsoleAuditArchiveStatus.handoffRequired,
    );
    expect(pack.isReady, isFalse);
    expect(pack.statusLabel, 'Handoff required');
    expect(pack.handoffLabel, 'Not submitted');
    expect(pack.receiptLabel, 'Missing');
    expect(
      pack.blockers,
      contains('Payroll close handoff has not been submitted.'),
    );
  });

  test('payroll run console audit archive pack is ready after approval', () {
    final approved = _approvedHandoff();
    final pack = _archivePack(handoffs: [approved]);

    expect(pack.status, EmployeePayrollRunConsoleAuditArchiveStatus.ready);
    expect(pack.isReady, isTrue);
    expect(pack.actionLabel, 'Archive pack ready for retention.');
    expect(pack.handoffLabel, 'Approved');
    expect(pack.receiptLabel, '3/3 controls');
    expect(pack.fileName, 'arc-run-202605-001-04-close-archive.zip');
    expect(
      pack.manifestItems.singleWhere((item) => item.label == 'Receipt').value,
      '3/3 controls',
    );
  });

  test('payroll run console audit archive pack surfaces return state', () {
    final returned = _readyHandoffReview()
        .toRecord(id: 'PAH-1', submittedAt: DateTime(2026, 5, 31, 10))
        .returnForRevision(
          returnedAt: DateTime(2026, 5, 31, 11),
          reason: 'Refresh close evidence.',
        );
    final pack = _archivePack(handoffs: [returned]);

    expect(pack.status, EmployeePayrollRunConsoleAuditArchiveStatus.returned);
    expect(pack.isReady, isFalse);
    expect(pack.receiptLabel, 'Return note captured');
    expect(pack.blockers, contains('Refresh close evidence.'));
  });

  test('payroll run console audit archive pack detects incomplete receipt', () {
    final base = _readyHandoffReview().toRecord(
      id: 'PAH-1',
      submittedAt: DateTime(2026, 5, 31, 10),
    );
    final incompleteApproval = base.copyWith(
      status: EmployeePayrollRunConsoleAuditHandoffStatus.approved,
      decidedAt: DateTime(2026, 5, 31, 11),
      decisionAttestations: const {},
    );
    final pack = _archivePack(handoffs: [incompleteApproval]);

    expect(
      pack.status,
      EmployeePayrollRunConsoleAuditArchiveStatus.receiptIncomplete,
    );
    expect(pack.isReady, isFalse);
    expect(
      pack.blockers,
      contains('Approval receipt does not include every required attestation.'),
    );
  });

  test('payroll run console audit access gates export by role', () {
    final preview = EmployeePayrollRunConsoleAuditExportPreview(
      package: _readyPackage(),
      generatedAt: DateTime(2026, 6, 1, 12),
    );

    final officerReview = EmployeePayrollRunConsoleAuditAccessReview(
      role: EmployeePayrollRunConsoleAuditRole.payrollOfficer,
      exportPreview: preview,
    );
    final reviewerReview = EmployeePayrollRunConsoleAuditAccessReview(
      role: EmployeePayrollRunConsoleAuditRole.payrollReviewer,
      exportPreview: preview,
    );

    expect(officerReview.copyExportPermission.allowed, isTrue);
    expect(
      officerReview.copyExportPermission.reason,
      'Payroll officer can copy a ready audit export.',
    );
    expect(reviewerReview.copyExportPermission.allowed, isFalse);
    expect(
      reviewerReview.copyExportPermission.reason,
      'Switch to payroll officer to copy audit exports.',
    );
  });

  test('payroll run console audit access gates handoff decisions by role', () {
    final draftReview = _readyHandoffReview();
    final record = draftReview.toRecord(
      id: 'PAH-1',
      submittedAt: DateTime(2026, 5, 31, 10),
    );
    final submittedReview =
        EmployeePayrollRunConsoleAuditHandoffReview.fromState(
          package: _readyPackage(),
          draft: const EmployeePayrollRunConsoleAuditHandoffDraft(),
          handoffs: [record],
        );

    final reviewerAccess = EmployeePayrollRunConsoleAuditAccessReview(
      role: EmployeePayrollRunConsoleAuditRole.payrollReviewer,
      handoffReview: draftReview,
    );
    final approverAccess = EmployeePayrollRunConsoleAuditAccessReview(
      role: EmployeePayrollRunConsoleAuditRole.payrollApprover,
      handoffReview: submittedReview,
    );
    final auditorAccess = EmployeePayrollRunConsoleAuditAccessReview(
      role: EmployeePayrollRunConsoleAuditRole.auditor,
      handoffReview: submittedReview,
    );

    expect(reviewerAccess.submitHandoffPermission.allowed, isTrue);
    expect(reviewerAccess.approveHandoffPermission.allowed, isFalse);
    expect(approverAccess.approveHandoffPermission.allowed, isTrue);
    expect(approverAccess.returnHandoffPermission.allowed, isTrue);
    expect(approverAccess.submitHandoffPermission.allowed, isFalse);
    expect(auditorAccess.allowedCount, 0);
    expect(auditorAccess.statusLabel, 'View only');
    expect(
      auditorAccess.approveHandoffPermission.reason,
      'Auditor can review evidence but cannot approve payroll close handoffs.',
    );
  });

  test('payroll run console audit access describes next role step', () {
    final draftReview = _readyHandoffReview();
    final submitted = draftReview.toRecord(
      id: 'PAH-1',
      submittedAt: DateTime(2026, 5, 31, 10),
    );
    final submittedReview =
        EmployeePayrollRunConsoleAuditHandoffReview.fromState(
          package: _readyPackage(),
          draft: const EmployeePayrollRunConsoleAuditHandoffDraft(),
          handoffs: [submitted],
        );

    final reviewerAccess = EmployeePayrollRunConsoleAuditAccessReview(
      role: EmployeePayrollRunConsoleAuditRole.payrollReviewer,
      handoffReview: draftReview,
    );
    final approverAccess = EmployeePayrollRunConsoleAuditAccessReview(
      role: EmployeePayrollRunConsoleAuditRole.payrollApprover,
      handoffReview: submittedReview,
    );
    const auditorAccess = EmployeePayrollRunConsoleAuditAccessReview(
      role: EmployeePayrollRunConsoleAuditRole.auditor,
    );

    expect(reviewerAccess.guidance.title, 'Submit close handoff');
    expect(reviewerAccess.guidance.isReady, isTrue);
    expect(approverAccess.guidance.title, 'Decide submitted handoff');
    expect(approverAccess.guidance.isReady, isTrue);
    expect(auditorAccess.guidance.title, 'Review evidence only');
    expect(auditorAccess.guidance.isReady, isFalse);
  });
}

EmployeePayrollRunConsoleAuditEvent _event({
  required String id,
  required int completedCount,
  required int skippedCount,
  EmployeePayrollRunConsoleCommandType commandType =
      EmployeePayrollRunConsoleCommandType.prepareExport,
  List<String> errors = const [],
}) {
  return EmployeePayrollRunConsoleAuditEvent(
    id: id,
    runReference: 'RUN-202605-001',
    commandType: commandType,
    scopeLabel: 'All 5 run employees',
    operatorName: 'Payroll Lead',
    occurredAt: DateTime(2026, 5, 30),
    targetEmployeeCount: completedCount + skippedCount,
    completedCount: completedCount,
    skippedCount: skippedCount,
    errors: errors,
    message: '$id message',
  );
}

EmployeePayrollRunConsoleAuditEvidencePackage _readyPackage() {
  return EmployeePayrollRunConsoleAuditEvidencePackage(
    report: EmployeePayrollRunConsoleAuditEvidenceReport(
      summary: EmployeePayrollRunConsoleAuditSummary(
        events: [
          _event(
            id: 'prepare',
            commandType: EmployeePayrollRunConsoleCommandType.prepareExport,
            completedCount: 2,
            skippedCount: 0,
          ),
          _event(
            id: 'settle',
            commandType: EmployeePayrollRunConsoleCommandType.settlePayment,
            completedCount: 2,
            skippedCount: 0,
          ),
          _event(
            id: 'publish',
            commandType: EmployeePayrollRunConsoleCommandType.publishPayslip,
            completedCount: 2,
            skippedCount: 0,
          ),
          _event(
            id: 'close',
            commandType: EmployeePayrollRunConsoleCommandType.closePeriod,
            completedCount: 1,
            skippedCount: 1,
          ),
        ],
      ),
    ),
  );
}

EmployeePayrollRunConsoleAuditHandoffReview _readyHandoffReview() {
  return EmployeePayrollRunConsoleAuditHandoffReview.fromState(
    package: _readyPackage(),
    draft: EmployeePayrollRunConsoleAuditHandoffDraft(
      reviewer: 'Alya Rahman',
      approver: 'Rafi Pratama',
      dueDate: DateTime(2026, 6, 1),
      note: 'Reviewed payroll evidence before handoff.',
    ),
    handoffs: const [],
  );
}

EmployeePayrollRunConsoleAuditHandoffRecord _approvedHandoff() {
  return _readyHandoffReview()
      .toRecord(id: 'PAH-1', submittedAt: DateTime(2026, 5, 31, 10))
      .approve(
        approvedAt: DateTime(2026, 5, 31, 11),
        attestations:
            EmployeePayrollRunConsoleAuditDecisionAttestation.values.toSet(),
      );
}

EmployeePayrollRunConsoleAuditArchivePack _archivePack({
  List<EmployeePayrollRunConsoleAuditHandoffRecord> handoffs = const [],
}) {
  final package = _readyPackage();
  return EmployeePayrollRunConsoleAuditArchivePack(
    package: package,
    exportPreview: EmployeePayrollRunConsoleAuditExportPreview(
      package: package,
      generatedAt: DateTime(2026, 6, 1, 12),
    ),
    handoffReview: EmployeePayrollRunConsoleAuditHandoffReview.fromState(
      package: package,
      draft: const EmployeePayrollRunConsoleAuditHandoffDraft(),
      handoffs: handoffs,
    ),
  );
}
