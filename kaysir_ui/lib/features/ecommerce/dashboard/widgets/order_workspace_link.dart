import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../../order/models/order_workspace_launch_context.dart';
import '../models/order_workspace_bridge.dart';
import '../models/product_profile.dart';
import 'action_button.dart';
import 'detail_row.dart';
import 'tone.dart';

class OrderWorkspaceLink extends StatelessWidget {
  final ProductProfile profile;
  final ValueChanged<String>? onOpenOrderWorkspace;

  const OrderWorkspaceLink({
    super.key,
    required this.profile,
    this.onOpenOrderWorkspace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = toneColors(
      theme.colorScheme,
      VisualTone.primary,
      backgroundAlpha: 0.42,
    );
    final bridge = orderWorkspaceBridgeForProfile(productProfile: profile);
    final route = bridge.route;
    final onOpenOrderWorkspace = this.onOpenOrderWorkspace;

    return DetailRow(
      key: ValueKey('order_workspace_link_${profile.id}'),
      icon: Icons.receipt_long_outlined,
      title: route.title,
      description: route.description,
      titleScale: DetailRowTitleScale.standard,
      titleMaxLines: 2,
      descriptionMaxLines: 3,
      iconColors: colors,
      iconBackgroundSource: ToneBackgroundSource.container,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _OrderWorkspaceLine(label: 'Focus', value: route.subtitle),
          _OrderWorkspaceLine(label: 'Route', value: route.path),
          _OrderWorkspaceLine(
            label: 'Order profile',
            value: bridge.displayProfileId,
          ),
          if (bridge.resolvedByFallback &&
              bridge.displayProfileId != bridge.resolvedProfileId)
            _OrderWorkspaceLine(
              label: 'Resolved profile',
              value: bridge.resolvedProfileId,
            ),
          _OrderWorkspaceLine(
            label: 'Presets',
            value: bridge.workspaceViewCountLabel,
          ),
          if (bridge.channelSummary.isNotEmpty)
            _OrderWorkspaceLine(
              label: 'Channels',
              value: bridge.channelSummary,
            ),
          if (onOpenOrderWorkspace != null) ...[
            const SizedBox(height: POSUiTokens.gap),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ActionButton(
                key: ValueKey('order_workspace_open_${profile.id}'),
                label: 'Open order workspace',
                icon: Icons.open_in_new_outlined,
                variant: ActionButtonVariant.outlined,
                onPressed:
                    () => onOpenOrderWorkspace(
                      bridge.launchLocation(
                        reason: OrderWorkspaceLaunchReason.profileDetails,
                      ),
                    ),
                tooltip: 'Open ${route.title}',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderWorkspaceLine extends StatelessWidget {
  final String label;
  final String value;

  const _OrderWorkspaceLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        '$label: $value',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
