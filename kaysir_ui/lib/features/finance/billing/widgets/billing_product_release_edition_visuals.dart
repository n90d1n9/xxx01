import 'package:flutter/material.dart';

import '../utils/billing_product_release_edition.dart';

class BillingProductReleaseEditionStateBadge extends StatelessWidget {
  final BillingProductReleaseEditionPlan plan;

  const BillingProductReleaseEditionStateBadge({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final colors = billingProductReleaseEditionStateColors(plan.state);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          plan.stateLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.foreground,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class BillingProductReleaseEditionStateIcon extends StatelessWidget {
  final BillingProductReleaseEditionState state;

  const BillingProductReleaseEditionStateIcon({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = billingProductReleaseEditionStateColors(state);
    final icon = switch (state) {
      BillingProductReleaseEditionState.publishNow =>
        Icons.rocket_launch_outlined,
      BillingProductReleaseEditionState.review => Icons.rule_folder_outlined,
      BillingProductReleaseEditionState.blocked => Icons.report_outlined,
      BillingProductReleaseEditionState.incomplete =>
        Icons.playlist_add_check_outlined,
    };

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: colors.foreground, size: 21),
    );
  }
}

class BillingProductReleaseEditionStateColors {
  final Color foreground;
  final Color background;
  final Color border;

  const BillingProductReleaseEditionStateColors({
    required this.foreground,
    required this.background,
    required this.border,
  });
}

BillingProductReleaseEditionStateColors billingProductReleaseEditionStateColors(
  BillingProductReleaseEditionState state,
) {
  return switch (state) {
    BillingProductReleaseEditionState.publishNow =>
      const BillingProductReleaseEditionStateColors(
        foreground: Color(0xFF047857),
        background: Color(0xFFD1FAE5),
        border: Color(0xFFA7F3D0),
      ),
    BillingProductReleaseEditionState.review =>
      const BillingProductReleaseEditionStateColors(
        foreground: Color(0xFFB45309),
        background: Color(0xFFFEF3C7),
        border: Color(0xFFFDE68A),
      ),
    BillingProductReleaseEditionState.blocked =>
      const BillingProductReleaseEditionStateColors(
        foreground: Color(0xFFB91C1C),
        background: Color(0xFFFEE2E2),
        border: Color(0xFFFECACA),
      ),
    BillingProductReleaseEditionState.incomplete =>
      const BillingProductReleaseEditionStateColors(
        foreground: Color(0xFF334155),
        background: Color(0xFFE2E8F0),
        border: Color(0xFFCBD5E1),
      ),
  };
}
