import 'package:flutter/material.dart';

import '../utils/billing_product_release_channel.dart';

class BillingProductReleaseChannelCellBadge extends StatelessWidget {
  final BillingProductReleaseChannelCell cell;

  const BillingProductReleaseChannelCellBadge({super.key, required this.cell});

  @override
  Widget build(BuildContext context) {
    final colors = billingProductReleaseChannelCellColors(cell.state);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          cell.stateLabel,
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

class BillingProductReleaseChannelCellColors {
  final Color foreground;
  final Color background;
  final Color border;

  const BillingProductReleaseChannelCellColors({
    required this.foreground,
    required this.background,
    required this.border,
  });
}

BillingProductReleaseChannelCellColors billingProductReleaseChannelCellColors(
  BillingProductReleaseChannelCellState state,
) {
  return switch (state) {
    BillingProductReleaseChannelCellState.publishNow =>
      const BillingProductReleaseChannelCellColors(
        foreground: Color(0xFF047857),
        background: Color(0xFFD1FAE5),
        border: Color(0xFFA7F3D0),
      ),
    BillingProductReleaseChannelCellState.review =>
      const BillingProductReleaseChannelCellColors(
        foreground: Color(0xFFB45309),
        background: Color(0xFFFEF3C7),
        border: Color(0xFFFDE68A),
      ),
    BillingProductReleaseChannelCellState.blocked =>
      const BillingProductReleaseChannelCellColors(
        foreground: Color(0xFFB91C1C),
        background: Color(0xFFFEE2E2),
        border: Color(0xFFFECACA),
      ),
    BillingProductReleaseChannelCellState.notTargeted =>
      const BillingProductReleaseChannelCellColors(
        foreground: Color(0xFF475569),
        background: Color(0xFFE2E8F0),
        border: Color(0xFFCBD5E1),
      ),
  };
}
