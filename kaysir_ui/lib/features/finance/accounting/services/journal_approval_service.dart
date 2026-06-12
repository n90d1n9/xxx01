import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/models/ledger_posting.dart';
import '../accounting_core/services/ledger_posting_service.dart';
import '../models/financial_period_close.dart';
import '../models/journal_approval.dart';
import 'financial_period_posting_guard_service.dart';

/// Severity for a journal approval readiness issue.
enum JournalApprovalIssueSeverity { error, warning }

/// One control finding raised before a journal can be approved or posted.
class JournalApprovalReadinessIssue {
  const JournalApprovalReadinessIssue({
    required this.message,
    required this.severity,
  });

  final String message;
  final JournalApprovalIssueSeverity severity;

  bool get isError => severity == JournalApprovalIssueSeverity.error;
}

/// Readiness result for one journal approval request.
class JournalApprovalReadinessResult {
  const JournalApprovalReadinessResult({
    required this.requestId,
    required this.status,
    required this.issues,
  });

  final String requestId;
  final JournalApprovalStatus status;
  final List<JournalApprovalReadinessIssue> issues;

  int get errorCount => issues.where((issue) => issue.isError).length;

  int get warningCount => issues.length - errorCount;

  bool get hasErrors => errorCount > 0;

  bool get canApprove =>
      status == JournalApprovalStatus.pendingReview && !hasErrors;

  bool get canPost => status == JournalApprovalStatus.approved && !hasErrors;
}

/// Applies journal approval release rules before a request reaches the GL.
class JournalApprovalService {
  const JournalApprovalService({
    this.highValueEvidenceThreshold = 25000000,
    this.postingGuardService = const FinancialPeriodPostingGuardService(),
  });

  final double highValueEvidenceThreshold;
  final FinancialPeriodPostingGuardService postingGuardService;

  JournalApprovalReadinessResult evaluate({
    required JournalApprovalRequest request,
    required List<AccountingAccount> chartOfAccounts,
    required LedgerPostingService postingService,
    Iterable<LedgerPosting> postedLedger = const [],
    Iterable<FinancialPeriodCloseRecord> periodCloseRecords = const [],
  }) {
    final issues = <JournalApprovalReadinessIssue>[];
    final postingValidation = postingService.validate(
      request.draft,
      chartOfAccounts,
    );

    for (final issue in postingValidation.issues) {
      issues.add(_error(issue));
    }

    _addApprovalControlIssues(
      request,
      chartOfAccounts,
      postedLedger,
      periodCloseRecords,
      issues,
    );

    return JournalApprovalReadinessResult(
      requestId: request.id,
      status: request.status,
      issues: List.unmodifiable(issues),
    );
  }

  void _addApprovalControlIssues(
    JournalApprovalRequest request,
    List<AccountingAccount> chartOfAccounts,
    Iterable<LedgerPosting> postedLedger,
    Iterable<FinancialPeriodCloseRecord> periodCloseRecords,
    List<JournalApprovalReadinessIssue> issues,
  ) {
    final preparer = request.preparerName.trim().toLowerCase();
    final reviewer = request.reviewerName.trim().toLowerCase();
    if (preparer.isEmpty) {
      issues.add(_error('Preparer is required.'));
    }
    if (reviewer.isEmpty) {
      issues.add(_error('Reviewer is required.'));
    }
    if (preparer.isNotEmpty && preparer == reviewer) {
      issues.add(_error('Reviewer must be different from preparer.'));
    }

    if (_requiresEvidence(request) && !request.hasEvidence) {
      issues.add(_error('Evidence reference is required for this journal.'));
    }

    final accountsById = {
      for (final account in chartOfAccounts) account.id: account,
    };
    for (final line in request.draft.lines) {
      final account = accountsById[line.accountId];
      if (account == null) continue;
      if (!account.allowPosting) {
        issues.add(
          _error('Account does not allow direct posting: ${account.name}.'),
        );
      }
      if ((line.memo ?? '').trim().isEmpty) {
        issues.add(_warning('Line memo is missing for ${line.accountName}.'));
      }
    }

    final duplicatePosting = postedLedger.any(
      (posting) =>
          posting.journalId == request.draft.id ||
          posting.reference == request.draft.reference,
    );
    if (duplicatePosting && request.status != JournalApprovalStatus.posted) {
      issues.add(_error('Journal was already posted to the ledger.'));
    }

    final closedRecord = postingGuardService.closedRecordForDate(
      entryDate: request.draft.date,
      records: periodCloseRecords,
    );
    if (closedRecord != null &&
        request.status != JournalApprovalStatus.posted) {
      issues.add(
        _error(
          'Journal date is inside closed period ${closedRecord.periodLabel}. '
          'Reopen the period before approval or posting.',
        ),
      );
    }

    if (request.status == JournalApprovalStatus.returned &&
        (request.returnReason ?? '').trim().isEmpty) {
      issues.add(_warning('Returned journal has no correction note.'));
    }
  }

  bool _requiresEvidence(JournalApprovalRequest request) {
    return request.requiresEvidence ||
        request.totalAmount >= highValueEvidenceThreshold;
  }

  JournalApprovalReadinessIssue _error(String message) {
    return JournalApprovalReadinessIssue(
      message: message,
      severity: JournalApprovalIssueSeverity.error,
    );
  }

  JournalApprovalReadinessIssue _warning(String message) {
    return JournalApprovalReadinessIssue(
      message: message,
      severity: JournalApprovalIssueSeverity.warning,
    );
  }
}
