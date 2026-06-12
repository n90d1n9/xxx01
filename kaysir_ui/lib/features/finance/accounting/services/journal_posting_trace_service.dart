import '../accounting_core/models/ledger_posting.dart';
import '../models/journal_approval.dart';
import '../models/journal_posting_trace.dart';

/// Builds reviewer-facing posting trace links from approvals and GL postings.
class JournalPostingTraceService {
  const JournalPostingTraceService();

  Map<String, JournalPostingTrace> buildTraces({
    required Iterable<JournalApprovalRequest> requests,
    required Iterable<LedgerPosting> postedLedger,
  }) {
    final requestsById = {for (final request in requests) request.id: request};
    final originalsByReversalId = <String, JournalApprovalRequest>{};
    for (final request in requests) {
      final reversalRequestId = request.reversalRequestId;
      if (reversalRequestId != null && reversalRequestId.trim().isNotEmpty) {
        originalsByReversalId[reversalRequestId] = request;
      }
    }

    return {
      for (final request in requests)
        request.id: _buildTrace(
          request: request,
          requestsById: requestsById,
          originalsByReversalId: originalsByReversalId,
          postedLedger: postedLedger,
        ),
    };
  }

  JournalPostingTrace _buildTrace({
    required JournalApprovalRequest request,
    required Map<String, JournalApprovalRequest> requestsById,
    required Map<String, JournalApprovalRequest> originalsByReversalId,
    required Iterable<LedgerPosting> postedLedger,
  }) {
    final originalPosting = _matchingPosting(request, postedLedger);
    final reversalRequest =
        request.reversalRequestId == null
            ? null
            : requestsById[request.reversalRequestId];
    final reversalPosting =
        reversalRequest == null
            ? null
            : _matchingPosting(reversalRequest, postedLedger);
    final originalRequest = originalsByReversalId[request.id];

    return JournalPostingTrace(
      requestId: request.id,
      reference: request.draft.reference,
      amount: request.totalAmount,
      status: request.status,
      postingId: request.postingId,
      postedAt: originalPosting?.postedAt ?? request.postedAt,
      postingFoundInLedger: originalPosting != null,
      originalRequestId: originalRequest?.id,
      originalReference: originalRequest?.draft.reference,
      reversalRequestId: reversalRequest?.id ?? request.reversalRequestId,
      reversalReference: reversalRequest?.draft.reference,
      reversalStatus: reversalRequest?.status,
      reversalPostingId: reversalRequest?.postingId,
      reversalPostedAt: reversalPosting?.postedAt ?? reversalRequest?.postedAt,
      reversalAmount: reversalRequest?.totalAmount ?? 0,
      reversalPostingFoundInLedger: reversalPosting != null,
    );
  }

  LedgerPosting? _matchingPosting(
    JournalApprovalRequest request,
    Iterable<LedgerPosting> postedLedger,
  ) {
    for (final posting in postedLedger) {
      if (posting.id == request.postingId ||
          posting.journalId == request.draft.id ||
          posting.reference == request.draft.reference) {
        return posting;
      }
    }

    return null;
  }
}
