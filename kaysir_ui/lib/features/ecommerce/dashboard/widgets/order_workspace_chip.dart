import 'package:flutter/material.dart';

import '../models/order_workspace_bridge.dart';
import '../models/product_profile.dart';
import 'chip_tone.dart';
import 'icon_label_chip.dart';
import 'tone.dart';

class OrderWorkspaceChip extends StatelessWidget {
  final ProductProfile profile;

  const OrderWorkspaceChip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final bridge = orderWorkspaceBridgeForProfile(productProfile: profile);
    final colors = tonalChipColors(
      Theme.of(context).colorScheme,
      bridge.resolvedByFallback ? VisualTone.warning : VisualTone.primary,
      backgroundAlpha: 0.22,
      borderAlpha: 0.16,
    );

    return Tooltip(
      message: _tooltipForBridge(bridge),
      child: IconLabelChip(
        key: ValueKey('order_workspace_chip_${profile.id}'),
        icon: Icons.receipt_long_outlined,
        label: bridge.compactLabel,
        colors: colors,
      ),
    );
  }
}

String _tooltipForBridge(OrderWorkspaceBridge bridge) {
  if (!bridge.resolvedByFallback) {
    return 'Preferred order workspace: ${bridge.route.title}';
  }

  return 'Preferred order workspace resolved to ${bridge.route.title}';
}
