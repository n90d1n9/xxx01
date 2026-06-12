import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_metric_card.dart';
import 'package:kaysir/widgets/ui/app_search_field.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/bank_reconciliation_timing_register.dart';
import '../models/bank_reconciliation_timing_register_filter.dart';
import '../models/bank_reconciliation_timing_review.dart';

class BankReconciliationTimingRegisterSection extends StatefulWidget {
  final List<BankReconciliationTimingRegisterItem> items;
  final Map<String, BankReconciliationTimingReview> reviews;
  final NumberFormat currency;
  final DateFormat dateFormat;
  final BankReconciliationTimingRegisterFilter initialFilter;
  final ValueChanged<BankReconciliationTimingRegisterItem>? onReview;

  const BankReconciliationTimingRegisterSection({
    super.key,
    required this.items,
    required this.currency,
    required this.dateFormat,
    this.reviews = const {},
    this.initialFilter = BankReconciliationTimingRegisterFilter.all,
    this.onReview,
  });

  @override
  State<BankReconciliationTimingRegisterSection> createState() =>
      _BankReconciliationTimingRegisterSectionState();
}

class _BankReconciliationTimingRegisterSectionState
    extends State<BankReconciliationTimingRegisterSection> {
  late final TextEditingController _searchController = TextEditingController();
  late var _filter = widget.initialFilter;
  var _query = '';
  late var _sort = widget.initialFilter.defaultSort;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;
    final summary = BankReconciliationTimingRegisterSummary.fromItems(
      filteredItems,
    );
    final reviewSummary = BankReconciliationTimingReviewSummary.fromItems(
      items: filteredItems,
      reviews: widget.reviews,
    );

    return Column(
      key: const Key('bank-timing-register-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Timing Difference Register',
          trailing: '${filteredItems.length} / ${widget.items.length} item(s)',
        ),
        const SizedBox(height: 8),
        AppFilterChipGroup<BankReconciliationTimingRegisterFilter>(
          value: _filter,
          options: [
            for (final filter in BankReconciliationTimingRegisterFilter.values)
              AppFilterChipOption<BankReconciliationTimingRegisterFilter>(
                value: filter,
                label: filter.label,
                count: _countFor(filter),
              ),
          ],
          onChanged: _updateFilter,
        ),
        const SizedBox(height: 8),
        AppSearchField(
          controller: _searchController,
          hintText: 'Search reference, description, status, amount',
          width: 360,
          onChanged: (value) => setState(() => _query = value),
          trailing:
              _query.trim().isEmpty
                  ? null
                  : IconButton(
                    tooltip: 'Clear timing search',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _clearSearch,
                  ),
        ),
        const SizedBox(height: 8),
        _TimingRegisterSummaryGrid(
          summary: summary,
          reviewSummary: reviewSummary,
          currency: widget.currency,
        ),
        const SizedBox(height: 8),
        filteredItems.isEmpty
            ? const AppEmptyState(
              icon: Icons.check_circle_outline,
              title: 'No timing differences in this view',
              message: 'Choose another filter to review open timing items.',
            )
            : _TimingRegisterTable(
              items: filteredItems,
              reviews: widget.reviews,
              currency: widget.currency,
              dateFormat: widget.dateFormat,
              sort: _sort,
              onSortChanged: _updateSort,
              onReview: widget.onReview,
            ),
      ],
    );
  }

  List<BankReconciliationTimingRegisterItem> get _filteredItems {
    return _sort.apply(
      widget.items
          .where(_filter.matches)
          .where(
            (item) =>
                item.matchesSearch(_query) ||
                _reviewFor(item).matchesSearch(_query),
          ),
    );
  }

  BankReconciliationTimingReview _reviewFor(
    BankReconciliationTimingRegisterItem item,
  ) {
    return widget.reviews[item.reference] ??
        BankReconciliationTimingReview.open(item.reference);
  }

  int _countFor(BankReconciliationTimingRegisterFilter filter) {
    return widget.items.where(filter.matches).length;
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _updateFilter(BankReconciliationTimingRegisterFilter filter) {
    setState(() {
      _filter = filter;
      _sort = filter.defaultSort;
    });
  }

  void _updateSort(BankReconciliationTimingRegisterSort sort) {
    setState(() => _sort = sort);
  }
}

class _TimingRegisterSummaryGrid extends StatelessWidget {
  final BankReconciliationTimingRegisterSummary summary;
  final BankReconciliationTimingReviewSummary reviewSummary;
  final NumberFormat currency;

  const _TimingRegisterSummaryGrid({
    required this.summary,
    required this.reviewSummary,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _TimingMetricTile(
          title: 'Visible Net',
          value: currency.format(summary.netAmount),
          icon: Icons.account_balance_wallet_outlined,
          accentColor: colorScheme.primary,
          helper: '${summary.itemCount} item(s)',
        ),
        _TimingMetricTile(
          title: 'Deposits in Transit',
          value: currency.format(summary.depositAmount),
          icon: Icons.south_west_rounded,
          accentColor: Colors.teal.shade700,
          helper: '${summary.depositCount} item(s)',
        ),
        _TimingMetricTile(
          title: 'Outstanding Payments',
          value: currency.format(summary.absoluteOutstandingPaymentAmount),
          icon: Icons.north_east_rounded,
          accentColor: Colors.indigo.shade600,
          helper: '${summary.outstandingPaymentCount} item(s)',
        ),
        _TimingMetricTile(
          title: 'Stale Exposure',
          value: currency.format(summary.staleExposureAmount),
          icon: Icons.warning_amber_rounded,
          accentColor: colorScheme.error,
          helper: '${summary.staleCount} item(s)',
        ),
        _TimingMetricTile(
          title: 'Deadline Risk',
          value: summary.deadlineRiskCount.toString(),
          icon: Icons.event_busy_outlined,
          accentColor: Colors.deepOrange.shade700,
          helper:
              '${summary.overdueCount} overdue / '
              '${summary.dueSoonCount} due soon',
        ),
        _TimingMetricTile(
          title: 'Review Coverage',
          value: reviewSummary.coverageLabel,
          icon: Icons.assignment_turned_in_outlined,
          accentColor: _reviewCoverageColor,
          helper: reviewSummary.nextActionLabel,
        ),
        _TimingMetricTile(
          title: 'Unresolved Review',
          value: reviewSummary.unresolvedCount.toString(),
          icon: Icons.rule_folder_outlined,
          accentColor: _reviewResolutionColor,
          helper:
              '${reviewSummary.resolvedCount} resolved / '
              '${reviewSummary.unresolvedOverdueCount} overdue',
        ),
        _TimingMetricTile(
          title: 'Oldest Item',
          value: summary.oldestAgeLabel,
          icon: Icons.schedule_outlined,
          accentColor: Colors.amber.shade800,
          helper: 'Visible aging',
        ),
      ],
    );
  }

  Color get _reviewCoverageColor {
    if (reviewSummary.unresolvedOverdueCount > 0) {
      return Colors.redAccent;
    }
    if (reviewSummary.unreviewedCount > 0 ||
        reviewSummary.needsOwnerCount > 0) {
      return Colors.amber.shade800;
    }
    return Colors.teal.shade700;
  }

  Color get _reviewResolutionColor {
    if (reviewSummary.unresolvedOverdueCount > 0) {
      return Colors.redAccent;
    }
    if (reviewSummary.unresolvedCount > 0) {
      return Colors.indigo.shade600;
    }
    return Colors.teal.shade700;
  }
}

class _TimingMetricTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String helper;

  const _TimingMetricTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 172,
      child: AppMetricCard(
        title: title,
        value: value,
        icon: icon,
        accentColor: accentColor,
        helper: helper,
      ),
    );
  }
}

class _TimingRegisterTable extends StatelessWidget {
  final List<BankReconciliationTimingRegisterItem> items;
  final Map<String, BankReconciliationTimingReview> reviews;
  final NumberFormat currency;
  final DateFormat dateFormat;
  final BankReconciliationTimingRegisterSort sort;
  final ValueChanged<BankReconciliationTimingRegisterSort> onSortChanged;
  final ValueChanged<BankReconciliationTimingRegisterItem>? onReview;

  const _TimingRegisterTable({
    required this.items,
    required this.reviews,
    required this.currency,
    required this.dateFormat,
    required this.sort,
    required this.onSortChanged,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return _TableShell(
      child: DataTable(
        sortColumnIndex: _sortColumnIndex(sort.field),
        sortAscending: sort.ascending,
        columns: [
          DataColumn(
            label: const Text('Bucket'),
            onSort:
                (_, ascending) => _changeSort(
                  BankReconciliationTimingRegisterSortField.bucket,
                  ascending,
                ),
          ),
          DataColumn(
            label: const Text('Type'),
            onSort:
                (_, ascending) => _changeSort(
                  BankReconciliationTimingRegisterSortField.type,
                  ascending,
                ),
          ),
          DataColumn(
            label: const Text('Date'),
            onSort:
                (_, ascending) => _changeSort(
                  BankReconciliationTimingRegisterSortField.date,
                  ascending,
                ),
          ),
          DataColumn(
            label: const Text('Reference'),
            onSort:
                (_, ascending) => _changeSort(
                  BankReconciliationTimingRegisterSortField.reference,
                  ascending,
                ),
          ),
          const DataColumn(label: Text('Review')),
          DataColumn(
            label: const Text('Age'),
            onSort:
                (_, ascending) => _changeSort(
                  BankReconciliationTimingRegisterSortField.age,
                  ascending,
                ),
          ),
          DataColumn(
            label: const Text('Clear By'),
            onSort:
                (_, ascending) => _changeSort(
                  BankReconciliationTimingRegisterSortField.clearBy,
                  ascending,
                ),
          ),
          DataColumn(
            label: const Text('Deadline'),
            onSort:
                (_, ascending) => _changeSort(
                  BankReconciliationTimingRegisterSortField.deadline,
                  ascending,
                ),
          ),
          DataColumn(
            label: const Text('Amount'),
            numeric: true,
            onSort:
                (_, ascending) => _changeSort(
                  BankReconciliationTimingRegisterSortField.amount,
                  ascending,
                ),
          ),
          DataColumn(
            label: const Text('Status'),
            onSort:
                (_, ascending) => _changeSort(
                  BankReconciliationTimingRegisterSortField.status,
                  ascending,
                ),
          ),
          const DataColumn(label: Text('Follow-up')),
        ],
        rows: [
          for (final item in items)
            DataRow(
              cells: [
                DataCell(
                  AppStatusPill(
                    label: item.bucketLabel,
                    color: _bucketColor(item.bucket),
                  ),
                ),
                DataCell(Text(item.typeLabel)),
                DataCell(Text(dateFormat.format(item.date))),
                DataCell(Text(item.reference)),
                DataCell(
                  _TimingReviewCell(
                    review:
                        reviews[item.reference] ??
                        BankReconciliationTimingReview.open(item.reference),
                    onReview:
                        onReview == null ? null : () => onReview?.call(item),
                  ),
                ),
                DataCell(Text('${item.ageDays}d')),
                DataCell(Text(dateFormat.format(item.clearByDate))),
                DataCell(
                  AppStatusPill(
                    label: item.deadlineStatusLabel,
                    color: _deadlineColor(item.deadlineStatus),
                  ),
                ),
                DataCell(Text(currency.format(item.amount))),
                DataCell(Text(item.clearanceStatusLabel)),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(item.suggestedAction),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _changeSort(
    BankReconciliationTimingRegisterSortField field,
    bool ascending,
  ) {
    onSortChanged(
      BankReconciliationTimingRegisterSort(field: field, ascending: ascending),
    );
  }

  int _sortColumnIndex(BankReconciliationTimingRegisterSortField field) {
    switch (field) {
      case BankReconciliationTimingRegisterSortField.bucket:
        return 0;
      case BankReconciliationTimingRegisterSortField.type:
        return 1;
      case BankReconciliationTimingRegisterSortField.date:
        return 2;
      case BankReconciliationTimingRegisterSortField.reference:
        return 3;
      case BankReconciliationTimingRegisterSortField.age:
        return 5;
      case BankReconciliationTimingRegisterSortField.clearBy:
        return 6;
      case BankReconciliationTimingRegisterSortField.deadline:
        return 7;
      case BankReconciliationTimingRegisterSortField.amount:
        return 8;
      case BankReconciliationTimingRegisterSortField.status:
        return 9;
    }
  }

  Color _deadlineColor(BankReconciliationTimingDeadlineStatus status) {
    switch (status) {
      case BankReconciliationTimingDeadlineStatus.onTrack:
        return Colors.teal;
      case BankReconciliationTimingDeadlineStatus.dueSoon:
        return Colors.amber.shade800;
      case BankReconciliationTimingDeadlineStatus.overdue:
        return Colors.redAccent;
    }
  }

  Color _bucketColor(BankReconciliationTimingBucket bucket) {
    switch (bucket) {
      case BankReconciliationTimingBucket.current:
        return Colors.teal;
      case BankReconciliationTimingBucket.watch:
        return Colors.amber.shade800;
      case BankReconciliationTimingBucket.stale:
        return Colors.redAccent;
    }
  }
}

class _TimingReviewCell extends StatelessWidget {
  final BankReconciliationTimingReview review;
  final VoidCallback? onReview;

  const _TimingReviewCell({required this.review, this.onReview});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppStatusPill(
            label: review.status.label,
            color: _reviewStatusColor(review.status),
          ),
          if (review.hasEvidence)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                '${review.ownerLabel} / ${review.noteLabel}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          TextButton.icon(
            key: Key('bank-timing-review-action-${review.reference}'),
            onPressed: onReview,
            icon: const Icon(Icons.edit_note_rounded, size: 16),
            label: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Color _reviewStatusColor(BankReconciliationTimingReviewStatus status) {
    switch (status) {
      case BankReconciliationTimingReviewStatus.open:
        return Colors.blueGrey;
      case BankReconciliationTimingReviewStatus.inReview:
        return Colors.amber.shade800;
      case BankReconciliationTimingReviewStatus.cleared:
        return Colors.teal;
      case BankReconciliationTimingReviewStatus.adjusted:
        return Colors.deepOrange;
      case BankReconciliationTimingReviewStatus.deferred:
        return Colors.indigo;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _SectionHeader({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          trailing,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TableShell extends StatelessWidget {
  final Widget child;

  const _TableShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: child,
        ),
      ),
    );
  }
}
