import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_governance_action_filter.dart';
import '../models/company_governance_saved_view.dart';

/// Shows saved governance work modes for quickly focusing company operations.
class CompanyGovernanceSavedViewsPanel extends StatelessWidget {
  final List<CompanyGovernanceSavedView> views;
  final CompanyGovernanceSavedViewType selectedType;
  final ValueChanged<CompanyGovernanceSavedView>? onViewSelected;

  const CompanyGovernanceSavedViewsPanel({
    super.key,
    required this.views,
    required this.selectedType,
    this.onViewSelected,
  });

  @override
  Widget build(BuildContext context) {
    final activeViewCount = views.where((view) => view.hasAttention).length;
    final selectedView = selectedCompanyGovernanceSavedView(
      views: views,
      selectedType: selectedType,
    );

    return HrisSectionPanel(
      icon: Icons.dashboard_customize_outlined,
      title: 'Governance Saved Views',
      subtitle: '${selectedView.title} active, $activeViewCount with work',
      emptyMessage: 'No governance saved views',
      children:
          views.isEmpty
              ? const []
              : [
                _SavedViewsSummary(views: views),
                for (final view in views)
                  _SavedViewTile(
                    view: view,
                    isSelected: view.type == selectedType,
                    onSelected:
                        onViewSelected == null
                            ? null
                            : () => onViewSelected!(view),
                  ),
              ],
    );
  }
}

/// High-level saved-view counts.
class _SavedViewsSummary extends StatelessWidget {
  final List<CompanyGovernanceSavedView> views;

  const _SavedViewsSummary({required this.views});

  @override
  Widget build(BuildContext context) {
    final actionCount = _metricValue(
      views,
      CompanyGovernanceSavedViewType.commandCenter,
    );
    final criticalCount = _metricValue(
      views,
      CompanyGovernanceSavedViewType.criticalActions,
    );
    final handoffCount = _metricValue(
      views,
      CompanyGovernanceSavedViewType.ownerHandoffs,
    );
    final followUpCount = _metricValue(
      views,
      CompanyGovernanceSavedViewType.followUpsDue,
    );

    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Actions', value: '$actionCount'),
        HrisMetricStripItem(label: 'Critical', value: '$criticalCount'),
        HrisMetricStripItem(label: 'Handoffs', value: '$handoffCount'),
        HrisMetricStripItem(label: 'Due touches', value: '$followUpCount'),
      ],
    );
  }
}

/// One selectable governance saved-view row.
class _SavedViewTile extends StatelessWidget {
  final CompanyGovernanceSavedView view;
  final bool isSelected;
  final VoidCallback? onSelected;

  const _SavedViewTile({
    required this.view,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = _viewColor(view);
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.18)),
                ),
                child: Icon(_viewIcon(view.type), color: color, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            view.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const HrisStatusPill(
                            label: 'Active',
                            color: HrisColors.primary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      view.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(
                label: '${view.metricValue} ${view.metricLabel}',
                color: view.hasAttention ? color : Colors.blueGrey,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Queue',
                value: view.queueFilter.label,
              ),
              HrisMetricStripItem(label: 'Owner', value: view.ownerLabel),
            ],
          ),
          if (onSelected != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                key: Key('company-governance-saved-view-${view.type.name}'),
                onPressed: onSelected,
                icon: Icon(isSelected ? Icons.check : Icons.open_in_new),
                label: Text(isSelected ? 'Applied' : 'Apply view'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

int _metricValue(
  List<CompanyGovernanceSavedView> views,
  CompanyGovernanceSavedViewType type,
) {
  return views
          .where((view) => view.type == type)
          .map((view) => view.metricValue)
          .firstOrNull ??
      0;
}

IconData _viewIcon(CompanyGovernanceSavedViewType type) {
  switch (type) {
    case CompanyGovernanceSavedViewType.commandCenter:
      return Icons.space_dashboard_outlined;
    case CompanyGovernanceSavedViewType.criticalActions:
      return Icons.priority_high_outlined;
    case CompanyGovernanceSavedViewType.ownerHandoffs:
      return Icons.forward_to_inbox_outlined;
    case CompanyGovernanceSavedViewType.followUpsDue:
      return Icons.event_repeat_outlined;
    case CompanyGovernanceSavedViewType.vendorRenewals:
      return Icons.handshake_outlined;
  }
}

Color _viewColor(CompanyGovernanceSavedView view) {
  switch (view.type) {
    case CompanyGovernanceSavedViewType.commandCenter:
      return HrisColors.primary;
    case CompanyGovernanceSavedViewType.criticalActions:
      return Colors.red;
    case CompanyGovernanceSavedViewType.ownerHandoffs:
      return Colors.deepPurple;
    case CompanyGovernanceSavedViewType.followUpsDue:
      return Colors.orange;
    case CompanyGovernanceSavedViewType.vendorRenewals:
      return Colors.teal;
  }
}

@Preview(name: 'Company governance saved views panel')
Widget companyGovernanceSavedViewsPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyGovernanceSavedViewsPanel(
          selectedType: CompanyGovernanceSavedViewType.followUpsDue,
          views: const [
            CompanyGovernanceSavedView(
              type: CompanyGovernanceSavedViewType.commandCenter,
              title: 'Command center',
              description:
                  'All governance actions, owners, handoffs, and follow-ups.',
              metricLabel: 'Actions',
              metricValue: 6,
              queueFilter: CompanyGovernanceActionFilter.all,
              clearOwnerScope: true,
            ),
            CompanyGovernanceSavedView(
              type: CompanyGovernanceSavedViewType.followUpsDue,
              title: 'Follow-ups due',
              description: 'Handoffs that need a same-day or overdue touch.',
              metricLabel: 'Due',
              metricValue: 2,
              queueFilter: CompanyGovernanceActionFilter.all,
              ownerName: 'People Operations',
            ),
            CompanyGovernanceSavedView(
              type: CompanyGovernanceSavedViewType.vendorRenewals,
              title: 'Vendor renewals',
              description:
                  'Vendor agreements with renewal or implementation risk.',
              metricLabel: 'Vendors',
              metricValue: 1,
              queueFilter: CompanyGovernanceActionFilter.vendors,
              clearOwnerScope: true,
            ),
          ],
          onViewSelected: _previewViewSelected,
        ),
      ),
    ),
  );
}

void _previewViewSelected(CompanyGovernanceSavedView view) {}
