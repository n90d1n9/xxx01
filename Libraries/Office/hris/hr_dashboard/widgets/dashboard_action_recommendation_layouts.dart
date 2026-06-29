import 'package:flutter/material.dart';

import '../models/dashboard_action_summary.dart';
import 'dashboard_action_tile_elements.dart';

class DashboardCompactActionLayout extends StatelessWidget {
  final DashboardActionRecommendation item;
  final Color color;
  final Widget copy;
  final Widget metric;
  final Widget priorityPill;
  final Widget statusPill;
  final Widget urgencyChip;
  final Widget tracker;
  final Widget detailsButton;
  final Widget action;

  const DashboardCompactActionLayout({
    super.key,
    required this.item,
    required this.color,
    required this.copy,
    required this.metric,
    required this.priorityPill,
    required this.statusPill,
    required this.urgencyChip,
    required this.tracker,
    required this.detailsButton,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardActionLeadingIcon(icon: item.icon, color: color),
            const SizedBox(width: 12),
            Expanded(child: copy),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            priorityPill,
            statusPill,
            urgencyChip,
            metric,
            tracker,
            detailsButton,
            action,
          ],
        ),
      ],
    );
  }
}

class DashboardWideActionLayout extends StatelessWidget {
  final DashboardActionRecommendation item;
  final Color color;
  final Widget copy;
  final Widget metric;
  final Widget priorityPill;
  final Widget statusPill;
  final Widget urgencyChip;
  final Widget tracker;
  final Widget detailsButton;
  final Widget action;

  const DashboardWideActionLayout({
    super.key,
    required this.item,
    required this.color,
    required this.copy,
    required this.metric,
    required this.priorityPill,
    required this.statusPill,
    required this.urgencyChip,
    required this.tracker,
    required this.detailsButton,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DashboardActionLeadingIcon(icon: item.icon, color: color),
        const SizedBox(width: 12),
        Expanded(child: copy),
        const SizedBox(width: 12),
        priorityPill,
        const SizedBox(width: 10),
        statusPill,
        const SizedBox(width: 10),
        urgencyChip,
        const SizedBox(width: 10),
        metric,
        const SizedBox(width: 8),
        tracker,
        const SizedBox(width: 4),
        detailsButton,
        const SizedBox(width: 4),
        action,
      ],
    );
  }
}
