import 'package:flutter/material.dart';

import 'billing_product_release_channel_launch_dispatch_plan.dart';
import 'billing_product_release_channel_launch_dispatch_status.dart';

class BillingProductReleaseChannelLaunchDispatchPresentation {
  final String title;
  final String detail;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isActionable;

  const BillingProductReleaseChannelLaunchDispatchPresentation({
    required this.title,
    required this.detail,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.isActionable,
  });

  factory BillingProductReleaseChannelLaunchDispatchPresentation.fromEntry(
    BillingProductReleaseChannelLaunchDispatchEntry entry,
  ) {
    final visuals = _visualsForStatus(entry.status);

    return BillingProductReleaseChannelLaunchDispatchPresentation(
      title: '${entry.destinationLabel} - ${entry.statusLabel}',
      detail: entry.disabledReason ?? entry.operatorStepLabel,
      icon: visuals.icon,
      backgroundColor: visuals.backgroundColor,
      foregroundColor: visuals.foregroundColor,
      isActionable: entry.isActionable,
    );
  }
}

class _BillingProductReleaseChannelLaunchDispatchVisuals {
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const _BillingProductReleaseChannelLaunchDispatchVisuals({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });
}

_BillingProductReleaseChannelLaunchDispatchVisuals _visualsForStatus(
  BillingProductReleaseChannelLaunchDispatchStatus status,
) {
  return switch (status) {
    BillingProductReleaseChannelLaunchDispatchStatus.route =>
      const _BillingProductReleaseChannelLaunchDispatchVisuals(
        icon: Icons.open_in_new_outlined,
        backgroundColor: Color(0xFFECFDF5),
        foregroundColor: Color(0xFF059669),
      ),
    BillingProductReleaseChannelLaunchDispatchStatus.local =>
      const _BillingProductReleaseChannelLaunchDispatchVisuals(
        icon: Icons.bolt_outlined,
        backgroundColor: Color(0xFFEFF6FF),
        foregroundColor: Color(0xFF2563EB),
      ),
    BillingProductReleaseChannelLaunchDispatchStatus.blockedByRelease =>
      const _BillingProductReleaseChannelLaunchDispatchVisuals(
        icon: Icons.lock_outline_rounded,
        backgroundColor: Color(0xFFFEF2F2),
        foregroundColor: Color(0xFFDC2626),
      ),
    BillingProductReleaseChannelLaunchDispatchStatus.notExposed =>
      const _BillingProductReleaseChannelLaunchDispatchVisuals(
        icon: Icons.visibility_off_outlined,
        backgroundColor: Color(0xFFF1F5F9),
        foregroundColor: Color(0xFF64748B),
      ),
    BillingProductReleaseChannelLaunchDispatchStatus.unavailable =>
      const _BillingProductReleaseChannelLaunchDispatchVisuals(
        icon: Icons.block,
        backgroundColor: Color(0xFFFFF7ED),
        foregroundColor: Color(0xFFD97706),
      ),
    BillingProductReleaseChannelLaunchDispatchStatus.ignored =>
      const _BillingProductReleaseChannelLaunchDispatchVisuals(
        icon: Icons.report_problem_outlined,
        backgroundColor: Color(0xFFFFFBEB),
        foregroundColor: Color(0xFFD97706),
      ),
  };
}
