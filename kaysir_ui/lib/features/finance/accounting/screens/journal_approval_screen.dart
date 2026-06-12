import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../accounting_core/models/accounting_account.dart';
import '../accounting_path.dart';
import '../models/journal_approval.dart';
import '../services/journal_approval_service.dart';
import '../states/accounting_core_provider.dart';
import '../states/financial_period_posting_guard_provider.dart';
import '../states/journal_approval_provider.dart';
import '../widgets/journal_approval_components.dart';
import '../widgets/journal_request_form_components.dart';

/// Journal approval workspace for reviewer release and controlled GL posting.
class JournalApprovalScreen extends ConsumerStatefulWidget {
  const JournalApprovalScreen({super.key});

  @override
  ConsumerState<JournalApprovalScreen> createState() =>
      _JournalApprovalScreenState();
}

class _JournalApprovalScreenState extends ConsumerState<JournalApprovalScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  JournalApprovalStatus? _status;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(journalApprovalQueueProvider);
    final readinessById = ref.watch(journalApprovalReadinessProvider);
    final postingTraceById = ref.watch(journalPostingTraceProvider);
    final summary = ref.watch(journalApprovalSummaryProvider);
    final chart = ref.watch(accountingChartProvider);
    final filteredRequests = _filteredRequests(requests);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Journal Approval'),
        actions: [
          IconButton(
            tooltip: 'Chart of accounts',
            onPressed: () => context.go(AccountingPath.chartOfAccounts),
            icon: const Icon(Icons.account_tree_rounded),
          ),
          IconButton(
            tooltip: 'General ledger',
            onPressed: () => context.go(AccountingPath.gl),
            icon: const Icon(Icons.menu_book_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Approval queue',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Review manual and close journals before GL posting with evidence, '
            'segregation, and duplicate-posting controls.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          JournalApprovalSummaryStrip(summary: summary),
          const SizedBox(height: 14),
          JournalApprovalToolbar(
            controller: _searchController,
            status: _status,
            onQueryChanged: (value) => setState(() => _query = value.trim()),
            onStatusChanged: (value) => setState(() => _status = value),
            onCreateRequest: () => _showRequestDialog(chart),
          ),
          const SizedBox(height: 14),
          if (filteredRequests.isEmpty)
            _JournalApprovalEmptyState(query: _query)
          else
            for (final request in filteredRequests) ...[
              JournalApprovalRequestCard(
                request: request,
                readiness: readinessById[request.id]!,
                postingTrace: postingTraceById[request.id]!,
                onApprove: _approveAction(request, readinessById[request.id]!),
                onReturn: _returnAction(request),
                onResubmit: _resubmitAction(request),
                onPost: _postAction(request, readinessById[request.id]!),
                onRequestReversal: _requestReversalAction(request),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  List<JournalApprovalRequest> _filteredRequests(
    List<JournalApprovalRequest> requests,
  ) {
    final terms = _query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList(growable: false);

    return [
      for (final request in requests)
        if ((_status == null || request.status == _status) &&
            _matches(request, terms))
          request,
    ];
  }

  bool _matches(JournalApprovalRequest request, List<String> terms) {
    if (terms.isEmpty) return true;

    final value =
        [
          request.draft.reference,
          request.draft.description,
          request.draft.source.label,
          request.preparerName,
          request.reviewerName,
          request.evidenceReference,
          request.status.label,
          request.risk.label,
        ].whereType<String>().join(' ').toLowerCase();

    return terms.every(value.contains);
  }

  VoidCallback? _approveAction(
    JournalApprovalRequest request,
    JournalApprovalReadinessResult readiness,
  ) {
    if (!readiness.canApprove) return null;

    return () {
      ref.read(journalApprovalQueueProvider.notifier).approve(request.id);
      _showMessage('Journal approved for posting');
    };
  }

  VoidCallback? _returnAction(JournalApprovalRequest request) {
    if (request.status != JournalApprovalStatus.pendingReview) return null;

    return () async {
      final reason = await showDialog<String>(
        context: context,
        builder: (context) => const JournalApprovalReturnDialog(),
      );
      if (reason == null || reason.trim().isEmpty) return;

      ref
          .read(journalApprovalQueueProvider.notifier)
          .returnForCorrection(request.id, reason);
      _showMessage('Journal returned for correction');
    };
  }

  VoidCallback? _resubmitAction(JournalApprovalRequest request) {
    if (request.status != JournalApprovalStatus.returned) return null;

    return () {
      ref.read(journalApprovalQueueProvider.notifier).resubmit(request.id);
      _showMessage('Journal resubmitted for review');
    };
  }

  VoidCallback? _postAction(
    JournalApprovalRequest request,
    JournalApprovalReadinessResult readiness,
  ) {
    if (!readiness.canPost) return null;

    return () {
      try {
        ref
            .read(financialPeriodPostingGuardProvider)
            .ensureDateIsOpen(
              request.draft.date,
              actionLabel: 'post this journal',
            );
        final posting = ref
            .read(ledgerPostingServiceProvider)
            .post(request.draft, ref.read(accountingChartProvider));
        ref.read(postedLedgerProvider.notifier).addPosting(posting);
        ref
            .read(journalApprovalQueueProvider.notifier)
            .markPosted(request.id, postingId: posting.id);
        _showMessage('Journal posted to general ledger');
      } on Object catch (error) {
        _showMessage('Posting failed: $error');
      }
    };
  }

  VoidCallback? _requestReversalAction(JournalApprovalRequest request) {
    if (request.status != JournalApprovalStatus.posted ||
        request.reversalRequested) {
      return null;
    }

    return () async {
      final reversalDate = await showDialog<DateTime>(
        context: context,
        builder:
            (context) => JournalReversalRequestDialog(
              defaultDate: _defaultReversalDate(
                request,
                ref.read(journalApprovalClockProvider)(),
              ),
              minimumDate: request.draft.date,
            ),
      );
      if (reversalDate == null) return;

      try {
        final reversalRequest = ref
            .read(journalReversalServiceProvider)
            .createReversalRequest(
              original: request,
              reversalDate: reversalDate,
            );
        ref
            .read(journalApprovalQueueProvider.notifier)
            .addReversalRequest(
              originalRequestId: request.id,
              reversalRequest: reversalRequest,
            );
        if (!mounted) return;
        setState(() {
          _status = JournalApprovalStatus.pendingReview;
          _query = '';
          _searchController.clear();
        });
        _showMessage('Reversal journal submitted for approval');
      } on Object catch (error) {
        _showMessage('Reversal failed: $error');
      }
    };
  }

  Future<void> _showRequestDialog(List<AccountingAccount> accounts) async {
    JournalApprovalRequest? createdRequest;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return JournalRequestDialog(
          accounts: accounts,
          service: ref.read(journalRequestServiceProvider),
          onSubmit: (request) {
            createdRequest = request;
            ref.read(journalApprovalQueueProvider.notifier).addRequest(request);
          },
        );
      },
    );

    if (!mounted || createdRequest == null) return;
    setState(() {
      _status = JournalApprovalStatus.pendingReview;
      _query = '';
      _searchController.clear();
    });
    _showMessage('Journal submitted for approval');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

DateTime _defaultReversalDate(JournalApprovalRequest request, DateTime now) {
  final base = request.postedAt ?? now;
  final candidate = DateTime(
    base.year,
    base.month,
    base.day,
  ).add(const Duration(days: 1));
  final minimum = DateTime(
    request.draft.date.year,
    request.draft.date.month,
    request.draft.date.day,
  );
  return candidate.isBefore(minimum) ? minimum : candidate;
}

class _JournalApprovalEmptyState extends StatelessWidget {
  const _JournalApprovalEmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          query.isEmpty
              ? 'No journal approvals in this view.'
              : 'No journal approvals match "$query".',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

@Preview(name: 'Journal approval screen')
Widget journalApprovalScreenPreview() {
  return const ProviderScope(child: MaterialApp(home: JournalApprovalScreen()));
}
