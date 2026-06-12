import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/journal_approval.dart';
import '../models/journal_posting_trace.dart';
import '../repositories/journal_approval_repository_provider.dart';
import '../services/journal_approval_service.dart';
import '../services/journal_posting_trace_service.dart';
import '../services/journal_reversal_service.dart';
import '../services/journal_request_service.dart';
import 'accounting_core_provider.dart';
import 'fin_statement/financial_period_close_provider.dart';

/// Clock used by journal approval state transitions.
final journalApprovalClockProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

/// Service provider for journal approval readiness rules.
final journalApprovalServiceProvider = Provider<JournalApprovalService>((ref) {
  return const JournalApprovalService();
});

/// Service provider for building journal approval requests from form input.
final journalRequestServiceProvider = Provider<JournalRequestService>((ref) {
  return JournalRequestService(now: ref.watch(journalApprovalClockProvider));
});

/// Service provider for creating reversing journal approval requests.
final journalReversalServiceProvider = Provider<JournalReversalService>((ref) {
  return JournalReversalService(now: ref.watch(journalApprovalClockProvider));
});

/// Service provider for deriving posting and reversal traceability metadata.
final journalPostingTraceServiceProvider = Provider<JournalPostingTraceService>(
  (ref) {
    return const JournalPostingTraceService();
  },
);

/// Editable journal approval queue for manual and close-related journal drafts.
final journalApprovalQueueProvider = StateNotifierProvider<
  JournalApprovalQueueNotifier,
  List<JournalApprovalRequest>
>((ref) {
  final repository = ref.watch(journalApprovalRepositoryProvider);
  return JournalApprovalQueueNotifier(
    repository: repository,
    now: ref.watch(journalApprovalClockProvider),
  );
});

/// Readiness results keyed by journal approval request id.
final journalApprovalReadinessProvider =
    Provider<Map<String, JournalApprovalReadinessResult>>((ref) {
      final service = ref.watch(journalApprovalServiceProvider);
      final chart = ref.watch(accountingChartProvider);
      final postingService = ref.watch(ledgerPostingServiceProvider);
      final postedLedger = ref.watch(postedLedgerProvider);
      final periodCloseRecords =
          ref.watch(financialPeriodCloseRecordsProvider).values;

      return {
        for (final request in ref.watch(journalApprovalQueueProvider))
          request.id: service.evaluate(
            request: request,
            chartOfAccounts: chart,
            postingService: postingService,
            postedLedger: postedLedger,
            periodCloseRecords: periodCloseRecords,
          ),
      };
    });

/// Summary counts for the current journal approval queue.
final journalApprovalSummaryProvider = Provider<JournalApprovalQueueSummary>((
  ref,
) {
  return JournalApprovalQueueSummary.fromRequests(
    ref.watch(journalApprovalQueueProvider),
  );
});

/// Posting trace metadata keyed by journal approval request id.
final journalPostingTraceProvider = Provider<Map<String, JournalPostingTrace>>((
  ref,
) {
  return ref
      .watch(journalPostingTraceServiceProvider)
      .buildTraces(
        requests: ref.watch(journalApprovalQueueProvider),
        postedLedger: ref.watch(postedLedgerProvider),
      );
});

/// Mutation controller for journal approval workflow transitions.
class JournalApprovalQueueNotifier
    extends StateNotifier<List<JournalApprovalRequest>> {
  JournalApprovalQueueNotifier({required this.repository, required this.now})
    : super(repository.loadRequests()) {
    unawaited(_hydrateFromRepository());
  }

  final JournalApprovalRepository repository;
  final DateTime Function() now;
  var _isDisposed = false;

  Future<void> _hydrateFromRepository() async {
    final repository = this.repository;
    if (repository is! HydratableJournalApprovalRepository) {
      return;
    }

    await repository.hydrate();
    if (!_isDisposed) {
      state = repository.loadRequests();
    }
  }

  void addRequest(JournalApprovalRequest request) {
    final requestWithAudit =
        request.auditTrail.isEmpty
            ? _appendAudit(
              request,
              action: JournalApprovalAuditAction.submitted,
              actorName: request.preparerName,
              note: 'Submitted for reviewer approval.',
            )
            : request;
    _setState([...state, requestWithAudit]);
  }

  void approve(String requestId, {String note = 'Approved for posting.'}) {
    _update(
      requestId,
      (request) => _appendAudit(
        request.copyWith(
          status: JournalApprovalStatus.approved,
          approvalNote: note,
          returnReason: null,
          reviewedAt: now(),
        ),
        action: JournalApprovalAuditAction.approved,
        actorName: request.reviewerName,
        note: note,
      ),
    );
  }

  void returnForCorrection(String requestId, String reason) {
    _update(
      requestId,
      (request) => _appendAudit(
        request.copyWith(
          status: JournalApprovalStatus.returned,
          returnReason: reason.trim(),
          approvalNote: null,
          reviewedAt: now(),
        ),
        action: JournalApprovalAuditAction.returned,
        actorName: request.reviewerName,
        note: reason.trim(),
      ),
    );
  }

  void resubmit(String requestId, {String? evidenceReference}) {
    _update(
      requestId,
      (request) => _appendAudit(
        request.copyWith(
          status: JournalApprovalStatus.pendingReview,
          evidenceReference:
              evidenceReference?.trim().isEmpty ?? true
                  ? request.evidenceReference
                  : evidenceReference?.trim(),
          returnReason: null,
          approvalNote: null,
          reviewedAt: null,
        ),
        action: JournalApprovalAuditAction.resubmitted,
        actorName: request.preparerName,
        note: 'Resubmitted for reviewer approval.',
      ),
    );
  }

  void markPosted(String requestId, {required String postingId}) {
    _update(
      requestId,
      (request) => _appendAudit(
        request.copyWith(
          status: JournalApprovalStatus.posted,
          postingId: postingId,
          postedAt: now(),
        ),
        action: JournalApprovalAuditAction.posted,
        actorName: request.reviewerName,
        note: 'Posted to GL as $postingId.',
      ),
    );
  }

  void addReversalRequest({
    required String originalRequestId,
    required JournalApprovalRequest reversalRequest,
  }) {
    final hasOriginal = state.any((request) => request.id == originalRequestId);
    final alreadyQueued = state.any(
      (request) => request.id == reversalRequest.id,
    );
    if (!hasOriginal || alreadyQueued) return;

    final reversalDate =
        reversalRequest.reversalDate ?? reversalRequest.draft.date;
    _setState([
      for (final request in state)
        if (request.id == originalRequestId)
          _appendAudit(
            request.copyWith(
              reversalDate: reversalDate,
              reversalRequestId: reversalRequest.id,
            ),
            action: JournalApprovalAuditAction.reversalRequested,
            actorName: request.reviewerName,
            note:
                'Reversal ${reversalRequest.draft.reference} requested for '
                '${_formatDate(reversalDate)}.',
          )
        else
          request,
      reversalRequest,
    ]);
  }

  void _update(
    String requestId,
    JournalApprovalRequest Function(JournalApprovalRequest request) transform,
  ) {
    _setState([
      for (final request in state)
        request.id == requestId ? transform(request) : request,
    ]);
  }

  void _setState(Iterable<JournalApprovalRequest> requests) {
    final nextState = List<JournalApprovalRequest>.unmodifiable(requests);
    repository.replaceAll(nextState);
    state = repository.loadRequests();
  }

  JournalApprovalRequest _appendAudit(
    JournalApprovalRequest request, {
    required JournalApprovalAuditAction action,
    required String actorName,
    String? note,
  }) {
    final nextEventNumber = request.auditTrail.length + 1;
    final trimmedNote = note?.trim();
    return request.copyWith(
      auditTrail: [
        ...request.auditTrail,
        JournalApprovalAuditEvent(
          id: '${request.id}-audit-$nextEventNumber',
          action: action,
          actorName: actorName.trim().isEmpty ? 'System' : actorName.trim(),
          occurredAt: now(),
          note: trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
