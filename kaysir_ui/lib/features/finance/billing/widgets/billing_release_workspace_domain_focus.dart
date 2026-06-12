import 'package:flutter/material.dart';

import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_navigation_destination.dart';
import 'billing_release_workspace_action.dart';

class BillingReleaseWorkspaceFocusItem {
  final String label;
  final String detail;
  final IconData icon;
  final Color color;

  const BillingReleaseWorkspaceFocusItem({
    required this.label,
    required this.detail,
    required this.icon,
    required this.color,
  });
}

class BillingReleaseWorkspaceDomainFocus {
  final String title;
  final String summary;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final List<BillingReadinessMetric> metrics;
  final List<BillingReleaseWorkspaceFocusItem> items;
  final List<BillingReleaseWorkspaceAction> actions;

  BillingReleaseWorkspaceDomainFocus({
    required this.title,
    required this.summary,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    Iterable<BillingReadinessMetric> metrics = const [],
    Iterable<BillingReleaseWorkspaceFocusItem> items = const [],
    Iterable<BillingReleaseWorkspaceAction> actions = const [],
  }) : metrics = List.unmodifiable(metrics),
       items = List.unmodifiable(items),
       actions = List.unmodifiable(actions);
}

class BillingReleaseWorkspaceDomainFocusPanel extends StatelessWidget {
  final BillingReleaseWorkspaceDomainFocus focus;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingReleaseWorkspaceDomainFocusPanel({
    super.key,
    required this.focus,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BillingReadinessPanelScaffold(
      title: focus.title,
      summary: focus.summary,
      icon: focus.icon,
      iconColor: focus.iconColor,
      iconBackgroundColor: focus.iconBackgroundColor,
      metrics: focus.metrics,
      backgroundColor: const Color(0xFFFAFBFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReleaseWorkspaceFocusGrid(items: focus.items),
          if (focus.actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            BillingReleaseWorkspaceActionStrip(
              actions: focus.actions,
              onDestinationSelected: onDestinationSelected,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReleaseWorkspaceFocusGrid extends StatelessWidget {
  final List<BillingReleaseWorkspaceFocusItem> items;

  const _ReleaseWorkspaceFocusGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 720 ? 1 : 3;
        final spacing = columns == 1 ? 0.0 : 10.0;
        final itemWidth =
            columns == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 10,
          children:
              items
                  .map(
                    (item) => SizedBox(
                      width: itemWidth,
                      child: _ReleaseWorkspaceFocusTile(item: item),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

class _ReleaseWorkspaceFocusTile extends StatelessWidget {
  final BillingReleaseWorkspaceFocusItem item;

  const _ReleaseWorkspaceFocusTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.detail,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
