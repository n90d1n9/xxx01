import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_governance_action_filter.dart';
import '../models/company_governance_action_item.dart';

/// Displays prioritized statutory and company administration actions.
class CompanyGovernanceActionQueuePanel extends StatefulWidget {
  final List<CompanyGovernanceActionItem> items;
  final CompanyGovernanceActionFilter initialFilter;
  final String? selectedOwnerName;
  final VoidCallback? onOwnerFilterCleared;
  final ValueChanged<CompanyGovernanceActionItem>? onActionSelected;

  const CompanyGovernanceActionQueuePanel({
    super.key,
    required this.items,
    this.initialFilter = CompanyGovernanceActionFilter.all,
    this.selectedOwnerName,
    this.onOwnerFilterCleared,
    this.onActionSelected,
  });

  @override
  State<CompanyGovernanceActionQueuePanel> createState() =>
      _CompanyGovernanceActionQueuePanelState();
}

/// Presentation state for the governance queue triage filter.
class _CompanyGovernanceActionQueuePanelState
    extends State<CompanyGovernanceActionQueuePanel> {
  late CompanyGovernanceActionFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  void didUpdateWidget(covariant CompanyGovernanceActionQueuePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilter != widget.initialFilter) {
      _filter = widget.initialFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final criticalCount =
        widget.items
            .where(
              (item) =>
                  item.severity == CompanyGovernanceActionSeverity.critical,
            )
            .length;
    final highCount =
        widget.items
            .where(
              (item) => item.severity == CompanyGovernanceActionSeverity.high,
            )
            .length;
    final filterCounts = countCompanyGovernanceActionFilters(widget.items);
    final visibleItems = filterCompanyGovernanceActionItems(
      items: widget.items,
      filter: _filter,
      ownerName: widget.selectedOwnerName,
    );
    final selectedOwnerName = widget.selectedOwnerName?.trim() ?? '';

    return HrisSectionPanel(
      icon: Icons.assignment_late_outlined,
      title: 'Governance Action Queue',
      subtitle:
          widget.items.isEmpty
              ? 'No statutory or company governance actions'
              : '$criticalCount critical, $highCount high priority',
      emptyMessage: 'No company governance actions ready',
      children:
          widget.items.isEmpty
              ? const []
              : [
                _GovernanceActionSummary(items: widget.items),
                _GovernanceActionFilterBar(
                  selectedFilter: _filter,
                  counts: filterCounts,
                  onFilterChanged: (filter) {
                    setState(() {
                      _filter = filter;
                    });
                  },
                ),
                if (selectedOwnerName.isNotEmpty)
                  _GovernanceOwnerScopeBanner(
                    ownerName: selectedOwnerName,
                    onCleared: widget.onOwnerFilterCleared,
                  ),
                if (visibleItems.isEmpty)
                  HrisEmptyState(message: 'No actions match current filters')
                else
                  for (final item in visibleItems)
                    _GovernanceActionTile(
                      item: item,
                      onActionSelected:
                          widget.onActionSelected == null
                              ? null
                              : () => widget.onActionSelected!(item),
                    ),
              ],
    );
  }
}

/// Shows the active owner scope applied from the owner load panel.
class _GovernanceOwnerScopeBanner extends StatelessWidget {
  final String ownerName;
  final VoidCallback? onCleared;

  const _GovernanceOwnerScopeBanner({
    required this.ownerName,
    required this.onCleared,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HrisColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_search_outlined, color: HrisColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Owner scope: $ownerName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton.icon(
            key: const Key('company-governance-owner-filter-clear'),
            onPressed: onCleared,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

/// Filter chips for narrowing governance actions by severity or source.
class _GovernanceActionFilterBar extends StatelessWidget {
  final CompanyGovernanceActionFilter selectedFilter;
  final Map<CompanyGovernanceActionFilter, int> counts;
  final ValueChanged<CompanyGovernanceActionFilter> onFilterChanged;

  const _GovernanceActionFilterBar({
    required this.selectedFilter,
    required this.counts,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in CompanyGovernanceActionFilter.values)
          ChoiceChip(
            key: Key('company-governance-filter-${filter.name}'),
            label: Text('${filter.label} ${counts[filter] ?? 0}'),
            selected: selectedFilter == filter,
            onSelected: (_) => onFilterChanged(filter),
          ),
      ],
    );
  }
}

/// Compact counts for the current governance action queue.
class _GovernanceActionSummary extends StatelessWidget {
  final List<CompanyGovernanceActionItem> items;

  const _GovernanceActionSummary({required this.items});

  @override
  Widget build(BuildContext context) {
    final criticalCount =
        items
            .where(
              (item) =>
                  item.severity == CompanyGovernanceActionSeverity.critical,
            )
            .length;
    final highCount =
        items
            .where(
              (item) => item.severity == CompanyGovernanceActionSeverity.high,
            )
            .length;
    final sourceCount = items.map((item) => item.source).toSet().length;

    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Actions', value: '${items.length}'),
        HrisMetricStripItem(label: 'Critical', value: '$criticalCount'),
        HrisMetricStripItem(label: 'High', value: '$highCount'),
        HrisMetricStripItem(label: 'Sources', value: '$sourceCount'),
      ],
    );
  }
}

/// One prioritized governance queue row with its source command.
class _GovernanceActionTile extends StatelessWidget {
  final CompanyGovernanceActionItem item;
  final VoidCallback? onActionSelected;

  const _GovernanceActionTile({
    required this.item,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor(item.severity);
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
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.source.label} - ${item.entityLabel}',
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
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
                  HrisStatusPill(
                    label: item.source.label,
                    color: _sourceColor(item.source),
                  ),
                  HrisStatusPill(
                    label: item.severity.label,
                    color: severityColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Owner', value: item.ownerLabel),
              HrisMetricStripItem(label: 'Timing', value: item.dueLabel),
              HrisMetricStripItem(label: 'Action', value: item.resolveLabel),
            ],
          ),
          const SizedBox(height: 12),
          _GovernanceActionDetail(item: item, color: severityColor),
          if (item.issueLabels.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final issue in item.issueLabels.take(4))
                  HrisStatusPill(label: issue, color: severityColor),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: Key('company-governance-action-${item.id}'),
              onPressed: onActionSelected,
              icon: const Icon(Icons.playlist_add_check_outlined),
              label: Text(item.resolveLabel),
            ),
          ),
        ],
      ),
    );
  }
}

/// Explanatory note for why the queue item needs attention.
class _GovernanceActionDetail extends StatelessWidget {
  final CompanyGovernanceActionItem item;
  final Color color;

  const _GovernanceActionDetail({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.rule_folder_outlined, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.actionLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.detail,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _severityColor(CompanyGovernanceActionSeverity severity) {
  switch (severity) {
    case CompanyGovernanceActionSeverity.critical:
      return Colors.red;
    case CompanyGovernanceActionSeverity.high:
      return Colors.orange;
    case CompanyGovernanceActionSeverity.medium:
      return Colors.blueGrey;
  }
}

Color _sourceColor(CompanyGovernanceActionSource source) {
  switch (source) {
    case CompanyGovernanceActionSource.filing:
      return Colors.indigo;
    case CompanyGovernanceActionSource.employerAccount:
      return Colors.teal;
    case CompanyGovernanceActionSource.vendorAgreement:
      return Colors.deepPurple;
    case CompanyGovernanceActionSource.signatory:
      return Colors.brown;
  }
}

@Preview(name: 'Company governance action queue panel')
Widget companyGovernanceActionQueuePanelPreview() {
  final asOfDate = DateTime(2026, 6, 10);
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyGovernanceActionQueuePanel(
          items: [
            CompanyGovernanceActionItem(
              id: 'filing-preview',
              recordId: 'filing-preview',
              source: CompanyGovernanceActionSource.filing,
              severity: CompanyGovernanceActionSeverity.critical,
              resolution: CompanyGovernanceActionResolution.markFilingFiled,
              title: 'Annual WLK labor report',
              entityName: 'PT Kaysir Nusantara',
              ownerName: 'People Operations',
              dueDate: asOfDate.subtract(const Duration(days: 3)),
              dueLabel: 'Overdue 3d',
              actionLabel: 'Submit labor report receipt',
              detail: 'Labor report annual filing with 2 open issues.',
              issueLabels: const ['Filing overdue', 'Attach evidence'],
            ),
            CompanyGovernanceActionItem(
              id: 'vendor-preview',
              recordId: 'vendor-preview',
              source: CompanyGovernanceActionSource.vendorAgreement,
              severity: CompanyGovernanceActionSeverity.high,
              resolution:
                  CompanyGovernanceActionResolution.renewVendorAgreement,
              title: 'SignFlow Indonesia',
              entityName: 'PT Kaysir Nusantara',
              ownerName: 'Legal Operations',
              dueDate: asOfDate.add(const Duration(days: 12)),
              dueLabel: 'Contract ends in 12d',
              actionLabel: 'Renew e-signature agreement',
              detail: 'E-signature agreement with 2 open vendor issues.',
              issueLabels: const ['Renew agreement', 'Review due soon'],
            ),
          ],
          onActionSelected: _previewGovernanceActionSelected,
        ),
      ),
    ),
  );
}

void _previewGovernanceActionSelected(CompanyGovernanceActionItem item) {}
