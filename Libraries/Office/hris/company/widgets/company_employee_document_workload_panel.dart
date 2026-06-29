import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_employee_document_workload.dart';
import '../models/company_employee_document_workload_digest_status.dart';
import '../models/employee_document_workload_filter.dart';

/// Presents owner-level employee document workload lanes and digest actions.
class CompanyEmployeeDocumentWorkloadPanel extends StatefulWidget {
  final List<CompanyEmployeeDocumentWorkload> workloads;
  final List<CompanyEmployeeDocumentWorkloadDigestStatus> digestStatuses;
  final DateTime asOfDate;
  final ValueChanged<String> onSendDigest;
  final ValueChanged<List<String>> onSendDueDigests;

  const CompanyEmployeeDocumentWorkloadPanel({
    super.key,
    required this.workloads,
    required this.digestStatuses,
    required this.asOfDate,
    required this.onSendDigest,
    required this.onSendDueDigests,
  });

  @override
  State<CompanyEmployeeDocumentWorkloadPanel> createState() =>
      _CompanyEmployeeDocumentWorkloadPanelState();
}

class _CompanyEmployeeDocumentWorkloadPanelState
    extends State<CompanyEmployeeDocumentWorkloadPanel> {
  EmployeeDocumentWorkloadFilter _filter = EmployeeDocumentWorkloadFilter.all;

  @override
  Widget build(BuildContext context) {
    final escalationCount =
        widget.workloads
            .where((workload) => workload.requiresEscalation)
            .length;
    final openRequestCount = widget.workloads.fold<int>(
      0,
      (total, workload) => total + workload.openRequestCount,
    );
    final digestStatusByOwner = {
      for (final status in widget.digestStatuses) status.ownerName: status,
    };
    CompanyEmployeeDocumentWorkloadDigestStatus statusFor(
      CompanyEmployeeDocumentWorkload workload,
    ) {
      return digestStatusByOwner[workload.ownerName] ??
          CompanyEmployeeDocumentWorkloadDigestStatus(
            ownerName: workload.ownerName,
            digestCount: 0,
            lastSentAt: null,
            lastAuditEventId: '',
          );
    }

    final filterCounts = countEmployeeDocumentWorkloadFilters(
      workloads: widget.workloads,
      digestStatuses: widget.digestStatuses,
      asOfDate: widget.asOfDate,
    );
    final filteredWorkloads = filterEmployeeDocumentWorkloads(
      workloads: widget.workloads,
      digestStatuses: widget.digestStatuses,
      filter: _filter,
      asOfDate: widget.asOfDate,
    );
    final allDigestDueCount =
        widget.workloads
            .where(
              (workload) => statusFor(
                workload,
              ).isDueFor(workload: workload, asOfDate: widget.asOfDate),
            )
            .length;
    final filteredDueOwnerNames = [
      for (final workload in filteredWorkloads)
        if (statusFor(
          workload,
        ).isDueFor(workload: workload, asOfDate: widget.asOfDate))
          workload.ownerName,
    ];
    final filteredDigestDueCount = filteredDueOwnerNames.length;

    return HrisSectionPanel(
      icon: Icons.supervisor_account_outlined,
      title: 'Employee Document Workload',
      subtitle:
          '${widget.workloads.length} owners, $escalationCount escalation lanes, '
          '$openRequestCount open requests, $allDigestDueCount digests due',
      emptyMessage: 'No employee document owner workloads',
      children:
          widget.workloads.isEmpty
              ? const []
              : [
                _EmployeeDocumentWorkloadFilterBar(
                  selectedFilter: _filter,
                  counts: filterCounts,
                  visibleCount: filteredWorkloads.length,
                  totalCount: widget.workloads.length,
                  onFilterChanged: (filter) {
                    setState(() {
                      _filter = filter;
                    });
                  },
                ),
                _DigestBatchTile(
                  totalCount: filteredWorkloads.length,
                  dueCount: filteredDigestDueCount,
                  onSendDueDigests:
                      filteredDueOwnerNames.isEmpty
                          ? null
                          : () =>
                              widget.onSendDueDigests(filteredDueOwnerNames),
                ),
                if (filteredWorkloads.isEmpty)
                  HrisEmptyState(
                    message: 'No owner workloads match ${_filter.label}',
                  )
                else
                  for (final workload in filteredWorkloads)
                    _EmployeeDocumentWorkloadTile(
                      workload: workload,
                      digestStatus: statusFor(workload),
                      asOfDate: widget.asOfDate,
                      onSendDigest:
                          () => widget.onSendDigest(workload.ownerName),
                    ),
              ],
    );
  }
}

/// Filter chips for narrowing employee document workload lanes.
class _EmployeeDocumentWorkloadFilterBar extends StatelessWidget {
  final EmployeeDocumentWorkloadFilter selectedFilter;
  final Map<EmployeeDocumentWorkloadFilter, int> counts;
  final int visibleCount;
  final int totalCount;
  final ValueChanged<EmployeeDocumentWorkloadFilter> onFilterChanged;

  const _EmployeeDocumentWorkloadFilterBar({
    required this.selectedFilter,
    required this.counts,
    required this.visibleCount,
    required this.totalCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$visibleCount of $totalCount owner lanes shown',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                EmployeeDocumentWorkloadFilter.values.map((filter) {
                  final selected = filter == selectedFilter;
                  final count = counts[filter] ?? 0;
                  return ChoiceChip(
                    key: Key('employee-workload-filter-${filter.name}'),
                    label: Text('${filter.label} ($count)'),
                    selected: selected,
                    onSelected: (_) => onFilterChanged(filter),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    selectedColor: HrisColors.primary.withValues(alpha: 0.12),
                    side: BorderSide(
                      color: selected ? HrisColors.primary : HrisColors.border,
                    ),
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(
                      color: selected ? HrisColors.primary : HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Compact batch action row for owner digests that are currently due.
class _DigestBatchTile extends StatelessWidget {
  final int totalCount;
  final int dueCount;
  final VoidCallback? onSendDueDigests;

  const _DigestBatchTile({
    required this.totalCount,
    required this.dueCount,
    required this.onSendDueDigests,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = dueCount == 0 ? Colors.green : Colors.orange;
    final statusLabel = dueCount == 0 ? 'All fresh' : '$dueCount due';

    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final summary = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.forward_to_inbox_outlined,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Digest dispatch',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$dueCount due of $totalCount owner lanes',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: statusLabel, color: statusColor),
            ],
          );
          final action = FilledButton.icon(
            onPressed: onSendDueDigests,
            icon: const Icon(Icons.forward_to_inbox_outlined),
            label: const Text('Send due digests'),
          );

          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: action),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: summary),
              const SizedBox(width: 12),
              action,
            ],
          );
        },
      ),
    );
  }
}

/// Displays one owner lane with workload metrics, digest freshness, and action.
class _EmployeeDocumentWorkloadTile extends StatelessWidget {
  final CompanyEmployeeDocumentWorkload workload;
  final CompanyEmployeeDocumentWorkloadDigestStatus digestStatus;
  final DateTime asOfDate;
  final VoidCallback onSendDigest;

  const _EmployeeDocumentWorkloadTile({
    required this.workload,
    required this.digestStatus,
    required this.asOfDate,
    required this.onSendDigest,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = workload.requiresEscalation ? Colors.red : Colors.green;
    final statusLabel = workload.requiresEscalation ? 'Escalate' : 'Watchlist';
    final digestDue = digestStatus.isDueFor(
      workload: workload,
      asOfDate: asOfDate,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workload.ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workload.entitySummary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  HrisStatusPill(label: statusLabel, color: statusColor),
                  const SizedBox(height: 6),
                  HrisStatusPill(
                    label: digestDue ? 'Digest due' : 'Digest fresh',
                    color: digestDue ? Colors.orange : Colors.green,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Gaps', value: '${workload.gapCount}'),
              HrisMetricStripItem(
                label: 'Missing',
                value: '${workload.missingDocumentCount}',
              ),
              HrisMetricStripItem(
                label: 'Requests',
                value: '${workload.openRequestCount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Critical',
                value: '${workload.criticalCount}',
              ),
              HrisMetricStripItem(
                label: 'High',
                value: '${workload.highCount}',
              ),
              HrisMetricStripItem(
                label: 'Due risk',
                value: '${workload.overdueCount + workload.dueSoonCount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Digest',
                value: digestStatus.freshnessLabel(
                  workload: workload,
                  asOfDate: asOfDate,
                ),
              ),
              HrisMetricStripItem(
                label: 'Last sent',
                value: digestStatus.label(asOfDate),
              ),
              HrisMetricStripItem(
                label: 'Cadence',
                value: digestStatus.cadenceLabel(workload),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withValues(alpha: 0.22)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  workload.requiresEscalation
                      ? Icons.priority_high_outlined
                      : Icons.task_alt_outlined,
                  color: statusColor,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workload.primaryAction,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _primaryContext(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: HrisColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onSendDigest,
              icon: const Icon(Icons.mark_email_read_outlined),
              label: Text(digestDue ? 'Send digest' : 'Resend digest'),
            ),
          ),
        ],
      ),
    );
  }

  String _primaryContext() {
    if (workload.primaryEmployeeName.trim().isEmpty) {
      return '${workload.score} workload score';
    }
    return '${workload.primaryEmployeeName} is the top priority, '
        '${workload.score} workload score';
  }
}

@Preview(name: 'Employee document workload panel')
Widget employeeDocumentWorkloadPanelPreview() {
  final asOfDate = DateTime(2026, 6, 9);
  final workloads = [
    const CompanyEmployeeDocumentWorkload(
      ownerName: 'Fajar Prakoso',
      entityNames: ['PT Kaysir Nusantara'],
      gapIds: ['gap-1', 'gap-2'],
      score: 186,
      gapCount: 2,
      criticalCount: 1,
      highCount: 1,
      overdueCount: 1,
      dueSoonCount: 1,
      openRequestCount: 2,
      missingDocumentCount: 9,
      pendingDocumentCount: 1,
      rejectedDocumentCount: 1,
      primaryAction: 'Review rejected evidence',
      primaryGapId: 'gap-1',
      primaryEmployeeName: 'David Kim',
    ),
    const CompanyEmployeeDocumentWorkload(
      ownerName: 'People Operations',
      entityNames: ['PT Kaysir Nusantara', 'Kaysir Retail Services'],
      gapIds: ['gap-3'],
      score: 72,
      gapCount: 1,
      criticalCount: 0,
      highCount: 1,
      overdueCount: 0,
      dueSoonCount: 1,
      openRequestCount: 1,
      missingDocumentCount: 4,
      pendingDocumentCount: 0,
      rejectedDocumentCount: 0,
      primaryAction: 'Generate request',
      primaryGapId: 'gap-3',
      primaryEmployeeName: 'Alya Rahman',
    ),
  ];

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyEmployeeDocumentWorkloadPanel(
          workloads: workloads,
          digestStatuses: [
            CompanyEmployeeDocumentWorkloadDigestStatus(
              ownerName: 'Fajar Prakoso',
              digestCount: 1,
              lastSentAt: asOfDate.subtract(const Duration(days: 1)),
              lastAuditEventId: 'audit-preview-1',
            ),
            const CompanyEmployeeDocumentWorkloadDigestStatus(
              ownerName: 'People Operations',
              digestCount: 0,
              lastSentAt: null,
              lastAuditEventId: '',
            ),
          ],
          asOfDate: asOfDate,
          onSendDigest: _previewSendDigest,
          onSendDueDigests: _previewSendDueDigests,
        ),
      ),
    ),
  );
}

void _previewSendDigest(String ownerName) {}

void _previewSendDueDigests(List<String> ownerNames) {}
