import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_invoice_issue_outbox_entry.dart';
import '../models/billing_invoice_issue_outbox_filter.dart';
import '../models/billing_invoice_issue_outbox_retry_policy.dart';
import '../models/billing_invoice_issue_outbox_retry_snapshot.dart';
import '../models/billing_invoice_issue_outbox_saved_view.dart';
import '../models/billing_invoice_issue_outbox_selection.dart';
import '../models/billing_invoice_issue_outbox_sort.dart';
import '../models/billing_invoice_issue_outbox_sync_summary.dart';
import '../models/billing_invoice_issue_outbox_view_state.dart';
import '../states/billing_invoice_issue_outbox_provider.dart';
import 'billing_invoice_issue_outbox_active_view_banner.dart';
import 'billing_invoice_issue_outbox_bulk_action_bar.dart';
import 'billing_invoice_issue_outbox_entry_tile.dart';
import 'billing_invoice_issue_outbox_filter_bar.dart';
import 'billing_invoice_issue_outbox_saved_view_bar.dart';
import 'billing_invoice_issue_outbox_sort_menu.dart';
import 'billing_invoice_issue_outbox_sync_summary_banner.dart';

Future<void> showBillingInvoiceIssueOutboxInspectorSheet(
  BuildContext context, {
  required String tenantId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return FractionallySizedBox(
        heightFactor: 0.86,
        child: BillingInvoiceIssueOutboxInspectorPanel(
          tenantId: tenantId,
          onClose: () => Navigator.pop(sheetContext),
        ),
      );
    },
  );
}

class BillingInvoiceIssueOutboxInspectorPanel extends ConsumerWidget {
  final String tenantId;
  final VoidCallback? onClose;

  const BillingInvoiceIssueOutboxInspectorPanel({
    super.key,
    required this.tenantId,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(
      billingInvoiceIssueOutboxViewStateProvider(tenantId),
    );
    final selection = ref.watch(
      billingInvoiceIssueOutboxSelectionProvider(tenantId),
    );
    final entriesAsync = ref.watch(
      billingInvoiceIssueOutboxEntriesProvider(tenantId),
    );
    final retryPolicy = ref.watch(billingInvoiceIssueOutboxRetryPolicyProvider);
    final now = ref.watch(billingInvoiceIssueOutboxClockProvider)();
    final syncState = ref.watch(
      billingInvoiceIssueOutboxSyncControllerProvider,
    );
    final syncSummary = syncState.when(
      data: (summary) => summary,
      error: (error, stack) => null,
      loading: () => null,
    );

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          _IssueOutboxInspectorHeader(
            tenantId: tenantId,
            onRefresh:
                () => ref.invalidate(
                  billingInvoiceIssueOutboxEntriesProvider(tenantId),
                ),
            onClose: onClose,
          ),
          Expanded(
            child: entriesAsync.when(
              loading: () => const _IssueOutboxInspectorLoading(),
              error:
                  (error, stack) => const _IssueOutboxInspectorMessage(
                    icon: Icons.cloud_off_outlined,
                    title: 'Unable to load issue commands',
                    message: 'Refresh the outbox or try again later.',
                  ),
              data:
                  (entries) => _IssueOutboxInspectorEntries(
                    entries: entries,
                    retryPolicy: retryPolicy,
                    now: now,
                    isSyncing: syncState.isLoading,
                    syncSummary: syncSummary,
                    viewState: viewState,
                    selection: selection,
                    onViewSelected:
                        (view) => _setViewState(
                          ref,
                          BillingInvoiceIssueOutboxViewState.fromSavedView(
                            view,
                          ),
                        ),
                    onFilterChanged:
                        (filter) =>
                            _setViewState(ref, viewState.withFilter(filter)),
                    onSortChanged:
                        (sortOption) => _setViewState(
                          ref,
                          viewState.withSortOption(sortOption),
                        ),
                    onResetView:
                        () => _setViewState(
                          ref,
                          const BillingInvoiceIssueOutboxViewState(),
                        ),
                    onSelectionChanged:
                        (selection) => _setSelectionState(ref, selection),
                    onRetrySelected:
                        (idempotencyKeys) =>
                            _retrySelected(context, ref, idempotencyKeys),
                    onRetryReady: () => _retryReady(context, ref),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _retryReady(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(billingInvoiceIssueOutboxSyncControllerProvider.notifier)
          .sync(tenantId: tenantId);
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _setViewState(
    WidgetRef ref,
    BillingInvoiceIssueOutboxViewState viewState,
  ) {
    ref
        .read(billingInvoiceIssueOutboxViewStateProvider(tenantId).notifier)
        .state = viewState;
    _setSelectionState(ref, const BillingInvoiceIssueOutboxSelection());
  }

  void _setSelectionState(
    WidgetRef ref,
    BillingInvoiceIssueOutboxSelection selection,
  ) {
    ref
        .read(billingInvoiceIssueOutboxSelectionProvider(tenantId).notifier)
        .state = selection;
  }

  Future<void> _retrySelected(
    BuildContext context,
    WidgetRef ref,
    Set<String> idempotencyKeys,
  ) async {
    if (idempotencyKeys.isEmpty) return;

    try {
      await ref
          .read(billingInvoiceIssueOutboxSyncControllerProvider.notifier)
          .sync(tenantId: tenantId, idempotencyKeys: idempotencyKeys);
      _setSelectionState(ref, const BillingInvoiceIssueOutboxSelection());
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    }
  }
}

class _IssueOutboxInspectorHeader extends StatelessWidget {
  final String tenantId;
  final VoidCallback onRefresh;
  final VoidCallback? onClose;

  const _IssueOutboxInspectorHeader({
    required this.tenantId,
    required this.onRefresh,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.manage_search_outlined,
              color: Color(0xFF2563EB),
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Issue outbox',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tenant $tenantId command queue',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton.outlined(
            tooltip: 'Refresh issue outbox',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_outlined, size: 20),
            style: IconButton.styleFrom(
              foregroundColor: const Color(0xFF475569),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Close issue outbox',
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 20),
              color: const Color(0xFF475569),
            ),
          ],
        ],
      ),
    );
  }
}

class _IssueOutboxInspectorEntries extends StatelessWidget {
  final List<BillingInvoiceIssueOutboxEntry> entries;
  final BillingInvoiceIssueOutboxRetryPolicy retryPolicy;
  final DateTime now;
  final bool isSyncing;
  final BillingInvoiceIssueOutboxSyncSummary? syncSummary;
  final BillingInvoiceIssueOutboxViewState viewState;
  final BillingInvoiceIssueOutboxSelection selection;
  final ValueChanged<BillingInvoiceIssueOutboxSavedView> onViewSelected;
  final ValueChanged<BillingInvoiceIssueOutboxFilter> onFilterChanged;
  final ValueChanged<BillingInvoiceIssueOutboxSortOption> onSortChanged;
  final VoidCallback onResetView;
  final ValueChanged<BillingInvoiceIssueOutboxSelection> onSelectionChanged;
  final ValueChanged<Set<String>> onRetrySelected;
  final Future<void> Function()? onRetryReady;

  const _IssueOutboxInspectorEntries({
    required this.entries,
    required this.retryPolicy,
    required this.now,
    required this.isSyncing,
    this.syncSummary,
    required this.viewState,
    required this.selection,
    required this.onViewSelected,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onResetView,
    required this.onSelectionChanged,
    required this.onRetrySelected,
    this.onRetryReady,
  });

  @override
  Widget build(BuildContext context) {
    final filter = viewState.filter;
    final sortOption = viewState.sortOption;
    final retrySnapshots = {
      for (final entry in entries)
        entry.idempotencyKey: BillingInvoiceIssueOutboxRetrySnapshot.evaluate(
          entry,
          retryPolicy: retryPolicy,
          now: now,
        ),
    };
    final filteredEntries = filter.apply(
      entries,
      retrySnapshots: retrySnapshots,
    );
    final sortedEntries = sortBillingInvoiceIssueOutboxEntries(
      filteredEntries,
      retrySnapshots: retrySnapshots,
      option: sortOption,
    );
    final readyCount = _countReadiness(
      retrySnapshots.values,
      BillingInvoiceIssueOutboxRetryReadiness.ready,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _IssueOutboxInspectorSummary(entries: entries),
        ),
        const SizedBox(height: 12),
        _IssueOutboxRetryActionBar(
          readyCount: readyCount,
          waitingCount: _countReadiness(
            retrySnapshots.values,
            BillingInvoiceIssueOutboxRetryReadiness.waiting,
          ),
          exhaustedCount: _countReadiness(
            retrySnapshots.values,
            BillingInvoiceIssueOutboxRetryReadiness.exhausted,
          ),
          isSyncing: isSyncing,
          onRetryReady: readyCount == 0 || isSyncing ? null : onRetryReady,
        ),
        if (syncSummary != null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BillingInvoiceIssueOutboxSyncSummaryBanner(
              summary: syncSummary!,
            ),
          ),
        ],
        const SizedBox(height: 12),
        BillingInvoiceIssueOutboxSavedViewBar(
          entries: entries,
          retrySnapshots: retrySnapshots,
          selectedView: viewState.savedView,
          onSelected: onViewSelected,
        ),
        const SizedBox(height: 10),
        BillingInvoiceIssueOutboxFilterBar(
          entries: entries,
          retrySnapshots: retrySnapshots,
          filter: filter,
          onChanged: onFilterChanged,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _IssueOutboxSortToolbar(
            viewState: viewState,
            visibleCount: sortedEntries.length,
            totalCount: entries.length,
            visibleEntries: sortedEntries,
            retrySnapshots: retrySnapshots,
            selection: selection,
            isSyncing: isSyncing,
            onSortChanged: onSortChanged,
            onResetView: onResetView,
            onSelectionChanged: onSelectionChanged,
            onRetrySelected: onRetrySelected,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child:
              sortedEntries.isEmpty
                  ? _IssueOutboxInspectorEmptyState(filter: filter)
                  : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: sortedEntries.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final entry = sortedEntries[index];

                      return _SelectableIssueOutboxEntryTile(
                        entry: entry,
                        retrySnapshot: retrySnapshots[entry.idempotencyKey],
                        selected: selection.contains(entry.idempotencyKey),
                        onSelectedChanged:
                            (_) => onSelectionChanged(
                              selection.toggle(entry.idempotencyKey),
                            ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  int _countReadiness(
    Iterable<BillingInvoiceIssueOutboxRetrySnapshot> snapshots,
    BillingInvoiceIssueOutboxRetryReadiness readiness,
  ) {
    return snapshots
        .where((snapshot) => snapshot.readiness == readiness)
        .length;
  }
}

class _IssueOutboxSortToolbar extends StatelessWidget {
  final BillingInvoiceIssueOutboxViewState viewState;
  final int visibleCount;
  final int totalCount;
  final List<BillingInvoiceIssueOutboxEntry> visibleEntries;
  final Map<String, BillingInvoiceIssueOutboxRetrySnapshot> retrySnapshots;
  final BillingInvoiceIssueOutboxSelection selection;
  final bool isSyncing;
  final ValueChanged<BillingInvoiceIssueOutboxSortOption> onSortChanged;
  final VoidCallback onResetView;
  final ValueChanged<BillingInvoiceIssueOutboxSelection> onSelectionChanged;
  final ValueChanged<Set<String>> onRetrySelected;

  const _IssueOutboxSortToolbar({
    required this.viewState,
    required this.visibleCount,
    required this.totalCount,
    required this.visibleEntries,
    required this.retrySnapshots,
    required this.selection,
    required this.isSyncing,
    required this.onSortChanged,
    required this.onResetView,
    required this.onSelectionChanged,
    required this.onRetrySelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final activeViewBanner = BillingInvoiceIssueOutboxActiveViewBanner(
          viewState: viewState,
          visibleCount: visibleCount,
          totalCount: totalCount,
          onReset: onResetView,
        );
        final bulkActions = BillingInvoiceIssueOutboxBulkActionBar(
          visibleEntries: visibleEntries,
          retrySnapshots: retrySnapshots,
          selection: selection,
          isSyncing: isSyncing,
          onSelectionChanged: onSelectionChanged,
          onRetrySelected: onRetrySelected,
        );
        final sortMenu = BillingInvoiceIssueOutboxSortMenu(
          value: viewState.sortOption,
          onChanged: onSortChanged,
        );

        if (constraints.maxWidth < 700) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: activeViewBanner),
                  const SizedBox(width: 10),
                  Flexible(child: sortMenu),
                ],
              ),
              const SizedBox(height: 8),
              bulkActions,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: activeViewBanner),
            const SizedBox(width: 10),
            SizedBox(width: 278, child: bulkActions),
            const SizedBox(width: 10),
            Flexible(child: sortMenu),
          ],
        );
      },
    );
  }
}

class _SelectableIssueOutboxEntryTile extends StatelessWidget {
  final BillingInvoiceIssueOutboxEntry entry;
  final BillingInvoiceIssueOutboxRetrySnapshot? retrySnapshot;
  final bool selected;
  final ValueChanged<bool?> onSelectedChanged;

  const _SelectableIssueOutboxEntryTile({
    required this.entry,
    this.retrySnapshot,
    required this.selected,
    required this.onSelectedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 8),
          child: Tooltip(
            message: 'Select issue command',
            child: Checkbox(
              value: selected,
              onChanged: onSelectedChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
        ),
        Expanded(
          child: BillingInvoiceIssueOutboxEntryTile(
            entry: entry,
            retrySnapshot: retrySnapshot,
          ),
        ),
      ],
    );
  }
}

class _IssueOutboxInspectorSummary extends StatelessWidget {
  final List<BillingInvoiceIssueOutboxEntry> entries;

  const _IssueOutboxInspectorSummary({required this.entries});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;
        final metrics = [
          _IssueOutboxSummaryMetric(
            label: 'Total',
            value: entries.length,
            icon: Icons.all_inbox_outlined,
            color: const Color(0xFF2563EB),
          ),
          _IssueOutboxSummaryMetric(
            label: 'Queued',
            value: _count(BillingInvoiceIssueOutboxStatus.queued),
            icon: Icons.schedule_send_outlined,
            color: const Color(0xFF1D4ED8),
          ),
          _IssueOutboxSummaryMetric(
            label: 'Failed',
            value: _count(BillingInvoiceIssueOutboxStatus.failed),
            icon: Icons.error_outline,
            color: const Color(0xFFDC2626),
          ),
          _IssueOutboxSummaryMetric(
            label: 'Synced',
            value: _count(BillingInvoiceIssueOutboxStatus.synced),
            icon: Icons.cloud_done_outlined,
            color: const Color(0xFF059669),
          ),
        ];

        if (isCompact) {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                metrics
                    .map(
                      (metric) => SizedBox(
                        width: (constraints.maxWidth - 10) / 2,
                        child: metric,
                      ),
                    )
                    .toList(),
          );
        }

        return Row(
          children: List.generate(metrics.length, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == metrics.length - 1 ? 0 : 10,
                ),
                child: metrics[index],
              ),
            );
          }),
        );
      },
    );
  }

  int _count(BillingInvoiceIssueOutboxStatus status) {
    return entries.where((entry) => entry.status == status).length;
  }
}

class _IssueOutboxSummaryMetric extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _IssueOutboxSummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueOutboxRetryActionBar extends StatelessWidget {
  final int readyCount;
  final int waitingCount;
  final int exhaustedCount;
  final bool isSyncing;
  final Future<void> Function()? onRetryReady;

  const _IssueOutboxRetryActionBar({
    required this.readyCount,
    required this.waitingCount,
    required this.exhaustedCount,
    required this.isSyncing,
    this.onRetryReady,
  });

  @override
  Widget build(BuildContext context) {
    final summary =
        '$readyCount ready, $waitingCount waiting, '
        '$exhaustedCount review';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final button = FilledButton.icon(
            onPressed: onRetryReady == null ? null : () => onRetryReady!.call(),
            icon:
                isSyncing
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.sync_outlined, size: 18),
            label: Text(isSyncing ? 'Retrying' : 'Retry ready'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE2E8F0),
              disabledForegroundColor: const Color(0xFF64748B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          final body = Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bolt_outlined,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Retry readiness',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child:
                constraints.maxWidth < 520
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [body, const SizedBox(height: 10), button],
                    )
                    : Row(
                      children: [
                        Expanded(child: body),
                        const SizedBox(width: 12),
                        button,
                      ],
                    ),
          );
        },
      ),
    );
  }
}

class _IssueOutboxInspectorLoading extends StatelessWidget {
  const _IssueOutboxInspectorLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _IssueOutboxInspectorEmptyState extends StatelessWidget {
  final BillingInvoiceIssueOutboxFilter filter;

  const _IssueOutboxInspectorEmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final filteredLabel = _filterLabel(filter);

    return _IssueOutboxInspectorMessage(
      icon: Icons.inventory_2_outlined,
      title:
          filter.isDefault ? 'No issue commands' : 'No $filteredLabel commands',
      message:
          filter.isDefault
              ? 'Invoice issue attempts for this tenant will appear here.'
              : 'Try another filter to review the rest of the queue.',
    );
  }
}

class _IssueOutboxInspectorMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _IssueOutboxInspectorMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 150;

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!compact) ...[
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: const Color(0xFF64748B), size: 25),
                  ),
                  const SizedBox(height: 14),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _filterLabel(BillingInvoiceIssueOutboxFilter filter) {
  if (filter.status != null &&
      filter.readiness != BillingInvoiceIssueOutboxReadinessFilter.all) {
    return '${billingInvoiceIssueOutboxStatusLabel(filter.status!)} '
        '${filter.readiness.label}';
  }
  if (filter.status != null) {
    return billingInvoiceIssueOutboxStatusLabel(filter.status!);
  }
  return filter.readiness.label;
}
