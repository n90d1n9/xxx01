import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/follow_up_work_item.dart';
import '../models/follow_up_work_queue_filter.dart';

/// Compact filter controls for reusable billing follow-up work queues.
class BillingFollowUpWorkQueueFilterBar extends StatelessWidget {
  final BillingFollowUpWorkQueue queue;
  final BillingFollowUpWorkQueueFilter filter;
  final ValueChanged<BillingFollowUpWorkStatus?>? onStatusChanged;
  final ValueChanged<BillingFollowUpWorkSource?>? onSourceChanged;
  final ValueChanged<String?>? onOwnerRoleChanged;
  final VoidCallback? onReset;

  const BillingFollowUpWorkQueueFilterBar({
    super.key,
    required this.queue,
    this.filter = const BillingFollowUpWorkQueueFilter(),
    this.onStatusChanged,
    this.onSourceChanged,
    this.onOwnerRoleChanged,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final statusCounts = _statusCounts(queue);
    final sourceCounts = _sourceCounts(queue);
    final ownerCounts = _ownerCounts(queue);

    return Container(
      key: const ValueKey('billing-follow-up-work-filter-bar'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FilterRow(
            label: 'Status',
            children: [
              _FilterChip(
                label: 'All ${queue.totalCount}',
                selected: filter.status == null,
                onSelected:
                    onStatusChanged == null
                        ? null
                        : () => onStatusChanged?.call(null),
              ),
              for (final status in BillingFollowUpWorkStatus.values)
                if (statusCounts[status] != null || filter.status == status)
                  _FilterChip(
                    label: '${status.label} ${statusCounts[status] ?? 0}',
                    selected: filter.status == status,
                    color: _statusColor(status),
                    onSelected:
                        onStatusChanged == null
                            ? null
                            : () => onStatusChanged?.call(status),
                  ),
            ],
          ),
          if (sourceCounts.isNotEmpty) ...[
            const SizedBox(height: 8),
            _FilterRow(
              label: 'Source',
              children: [
                _FilterChip(
                  label: 'All sources',
                  selected: filter.source == null,
                  onSelected:
                      onSourceChanged == null
                          ? null
                          : () => onSourceChanged?.call(null),
                ),
                for (final source in _sortedSources(sourceCounts.keys))
                  _FilterChip(
                    label: '${source.label} ${sourceCounts[source] ?? 0}',
                    selected: filter.source == source,
                    color: const Color(0xFF2563EB),
                    onSelected:
                        onSourceChanged == null
                            ? null
                            : () => onSourceChanged?.call(source),
                  ),
              ],
            ),
          ],
          if (ownerCounts.isNotEmpty) ...[
            const SizedBox(height: 8),
            _FilterRow(
              label: 'Owner',
              children: [
                _FilterChip(
                  label: 'All owners',
                  selected: filter.normalizedOwnerRole == null,
                  onSelected:
                      onOwnerRoleChanged == null
                          ? null
                          : () => onOwnerRoleChanged?.call(null),
                ),
                for (final entry in _sortedOwnerEntries(ownerCounts))
                  _FilterChip(
                    label: '${entry.key} ${entry.value}',
                    selected: filter.normalizedOwnerRole == entry.key,
                    color: const Color(0xFF7C3AED),
                    onSelected:
                        onOwnerRoleChanged == null
                            ? null
                            : () => onOwnerRoleChanged?.call(entry.key),
                  ),
              ],
            ),
          ],
          if (filter.isNotDefault && onReset != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const ValueKey('billing-follow-up-work-reset-filters'),
                onPressed: onReset,
                icon: const Icon(Icons.close_rounded, size: 16),
                label: Text('${filter.activeFilterCount} active'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 34),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Follow-up work queue filter bar')
Widget billingFollowUpWorkQueueFilterBarPreview() {
  final queue = BillingFollowUpWorkQueue(
    title: 'Billing work center',
    sourceLabel: 'All sources',
    items: [
      BillingFollowUpWorkItem(
        id: 'collect-1',
        source: BillingFollowUpWorkSource.collections,
        priority: BillingFollowUpWorkPriority.urgent,
        status: BillingFollowUpWorkStatus.ready,
        title: 'Collect invoice',
        description: 'Follow up overdue receivable.',
        ownerRole: 'Accounts receivable',
        dueInDays: 0,
      ),
      BillingFollowUpWorkItem(
        id: 'policy-1',
        source: BillingFollowUpWorkSource.reliefMonitoring,
        priority: BillingFollowUpWorkPriority.high,
        status: BillingFollowUpWorkStatus.blocked,
        title: 'Resolve policy blocker',
        description: 'Capture missing approval.',
        ownerRole: 'Finance owner',
        dueInDays: 1,
      ),
    ],
  );

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SizedBox(
          width: 760,
          child: BillingFollowUpWorkQueueFilterBar(
            queue: queue,
            filter: const BillingFollowUpWorkQueueFilter(
              status: BillingFollowUpWorkStatus.ready,
              ownerRole: 'Accounts receivable',
            ),
          ),
        ),
      ),
    ),
  );
}

class _FilterRow extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _FilterRow({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [_FilterGroupLabel(label: label), ...children],
    );
  }
}

class _FilterGroupLabel extends StatelessWidget {
  final String label;

  const _FilterGroupLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback? onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color = const Color(0xFF475569),
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected == null ? null : (_) => onSelected?.call(),
      labelStyle: TextStyle(
        color: selected ? color : const Color(0xFF475569),
        fontSize: 11,
        fontWeight: FontWeight.w900,
      ),
      avatar:
          selected ? Icon(Icons.check_rounded, size: 14, color: color) : null,
      selectedColor: color.withValues(alpha: 0.1),
      backgroundColor: Colors.white,
      disabledColor: Colors.white,
      side: BorderSide(
        color:
            selected ? color.withValues(alpha: 0.35) : const Color(0xFFE2E8F0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

Map<BillingFollowUpWorkStatus, int> _statusCounts(
  BillingFollowUpWorkQueue queue,
) {
  final counts = <BillingFollowUpWorkStatus, int>{};
  for (final item in queue.items) {
    counts[item.status] = (counts[item.status] ?? 0) + 1;
  }
  return counts;
}

Map<BillingFollowUpWorkSource, int> _sourceCounts(
  BillingFollowUpWorkQueue queue,
) {
  final counts = <BillingFollowUpWorkSource, int>{};
  for (final item in queue.items) {
    counts[item.source] = (counts[item.source] ?? 0) + 1;
  }
  return counts;
}

Map<String, int> _ownerCounts(BillingFollowUpWorkQueue queue) {
  final counts = <String, int>{};
  for (final item in queue.items) {
    final ownerRole = item.ownerRole.trim();
    if (ownerRole.isEmpty) continue;
    counts[ownerRole] = (counts[ownerRole] ?? 0) + 1;
  }
  return counts;
}

List<BillingFollowUpWorkSource> _sortedSources(
  Iterable<BillingFollowUpWorkSource> sources,
) {
  return sources.toList()..sort((a, b) => a.label.compareTo(b.label));
}

List<MapEntry<String, int>> _sortedOwnerEntries(Map<String, int> counts) {
  return counts.entries.toList()
    ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
}

Color _statusColor(BillingFollowUpWorkStatus status) {
  return switch (status) {
    BillingFollowUpWorkStatus.blocked => const Color(0xFFB45309),
    BillingFollowUpWorkStatus.ready => const Color(0xFF1D4ED8),
    BillingFollowUpWorkStatus.scheduled => const Color(0xFF047857),
    BillingFollowUpWorkStatus.optional => const Color(0xFF64748B),
  };
}
