import 'package:flutter/material.dart';

import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_navigation_coverage_summary.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_dispatch_snapshot.dart';
import 'billing_navigation_launch_center_components.dart';
import 'billing_navigation_launch_center_model.dart';
import 'billing_navigation_launch_snapshot.dart';

class BillingNavigationLaunchCenter extends StatefulWidget {
  final BillingNavigationLaunchSnapshot launchSnapshot;
  final BillingNavigationDispatchSnapshot? dispatchSnapshot;
  final BillingNavigationCoverageSummary? coverageSummary;
  final BillingNavigationDestinationId? selectedDestination;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;
  final String title;
  final String? subtitle;
  final bool showSearch;

  const BillingNavigationLaunchCenter({
    super.key,
    required this.launchSnapshot,
    this.dispatchSnapshot,
    this.coverageSummary,
    this.selectedDestination,
    this.onDestinationSelected,
    this.title = 'Route launch center',
    this.subtitle,
    this.showSearch = true,
  });

  @override
  State<BillingNavigationLaunchCenter> createState() {
    return _BillingNavigationLaunchCenterState();
  }
}

class _BillingNavigationLaunchCenterState
    extends State<BillingNavigationLaunchCenter> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final sections = billingNavigationLaunchCenterFilteredSections(
      _query,
      widget.dispatchSnapshot == null
          ? billingNavigationLaunchCenterSectionsFromLaunchSnapshot(
            widget.launchSnapshot,
          )
          : billingNavigationLaunchCenterSectionsFromDispatchSnapshot(
            widget.dispatchSnapshot!,
          ),
    );
    final entryCount = sections.fold<int>(
      0,
      (count, section) => count + section.entries.length,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BillingNavigationLaunchCenterHeader(
            title: widget.title,
            subtitle:
                widget.subtitle ??
                'Inspect and open registered billing routes by module.',
            coverageSummary: widget.coverageSummary,
          ),
          const SizedBox(height: 16),
          BillingReadinessMetricStrip(
            metrics: [
              BillingReadinessMetric(
                label: 'Routes',
                value: '$_routeCount',
                icon: Icons.alt_route_outlined,
                color: const Color(0xFF2563EB),
              ),
              BillingReadinessMetric(
                label: 'Actionable',
                value: '$_actionableCount',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF059669),
              ),
              BillingReadinessMetric(
                label: 'Needs work',
                value: '$_blockedCount',
                icon: Icons.report_problem_outlined,
                color: const Color(0xFFD97706),
              ),
            ],
          ),
          if (widget.showSearch) ...[
            const SizedBox(height: 14),
            TextField(
              key: const ValueKey('billing-launch-center-search'),
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 20),
                hintText: 'Search routes',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2563EB)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (entryCount == 0)
            const BillingNavigationLaunchCenterEmptyState()
          else
            ...sections.map(
              (section) => BillingNavigationLaunchCenterSection(
                section: section,
                selectedDestination: widget.selectedDestination,
                onDestinationSelected: widget.onDestinationSelected,
              ),
            ),
        ],
      ),
    );
  }

  int get _actionableCount {
    final dispatchSnapshot = widget.dispatchSnapshot;
    if (dispatchSnapshot != null) {
      return dispatchSnapshot.summary.actionableCount;
    }

    return widget.launchSnapshot.enabledStates.length;
  }

  int get _blockedCount {
    final dispatchSnapshot = widget.dispatchSnapshot;
    if (dispatchSnapshot != null) {
      return dispatchSnapshot.summary.blockedCount;
    }

    return widget.launchSnapshot.disabledStates.length;
  }

  int get _routeCount {
    final dispatchSnapshot = widget.dispatchSnapshot;
    if (dispatchSnapshot != null) {
      return dispatchSnapshot.summary.totalCount;
    }

    return widget.launchSnapshot.states.length;
  }
}
