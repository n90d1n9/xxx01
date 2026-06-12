import 'package:flutter/material.dart';

import '../models/billing_invoice_sync_state.dart';

class BillingInvoiceSyncBadge extends StatelessWidget {
  final BillingInvoiceSyncState state;
  final bool showConfirmed;

  const BillingInvoiceSyncBadge({
    super.key,
    required this.state,
    this.showConfirmed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (state == BillingInvoiceSyncState.confirmed && !showConfirmed) {
      return const SizedBox.shrink();
    }

    final colors = _colorsFor(state);

    return Tooltip(
      message: state.description,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(colors.icon, color: colors.foreground, size: 14),
            const SizedBox(width: 4),
            Text(
              state.label,
              style: TextStyle(
                color: colors.foreground,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncBadgeColors {
  final Color foreground;
  final Color background;
  final Color border;
  final IconData icon;

  const _SyncBadgeColors({
    required this.foreground,
    required this.background,
    required this.border,
    required this.icon,
  });
}

_SyncBadgeColors _colorsFor(BillingInvoiceSyncState state) {
  switch (state) {
    case BillingInvoiceSyncState.confirmed:
      return const _SyncBadgeColors(
        foreground: Color(0xFF047857),
        background: Color(0xFFD1FAE5),
        border: Color(0xFFA7F3D0),
        icon: Icons.cloud_done_outlined,
      );
    case BillingInvoiceSyncState.localOnly:
      return const _SyncBadgeColors(
        foreground: Color(0xFF1D4ED8),
        background: Color(0xFFDBEAFE),
        border: Color(0xFFBFDBFE),
        icon: Icons.cloud_upload_outlined,
      );
  }
}
