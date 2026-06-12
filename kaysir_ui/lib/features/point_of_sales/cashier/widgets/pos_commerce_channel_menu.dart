import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../order/models/order.dart';
import '../../order/states/current_order_provider.dart';
import '../experiences/pos_commerce_channel.dart';
import '../experiences/pos_commerce_channel_controller.dart';
import '../experiences/pos_commerce_channel_switch_plan.dart';
import '../experiences/pos_order_fulfillment.dart';
import '../experiences/pos_order_fulfillment_provider.dart';
import 'pos_commerce_channel_switch_action_handler.dart';
import 'pos_commerce_channel_icons.dart';
import 'pos_commerce_channel_option_tile.dart';
import 'pos_commerce_channel_switch_panel.dart';
import 'pos_switch_action_context_binding.dart';
import 'pos_switch_interaction.dart';
import 'pos_switch_popup_menu.dart';

class POSCommerceChannelMenu extends ConsumerWidget {
  final bool showLabel;
  final double? viewportWidth;

  const POSCommerceChannelMenu({
    super.key,
    this.showLabel = false,
    this.viewportWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(posCommerceChannelSwitchControllerProvider);
    final currentChannel = controller.currentChannel;
    final resolvedViewportWidth =
        viewportWidth ?? MediaQuery.sizeOf(context).width;
    final currentOrder = ref.watch(currentOrderProvider);
    final currentFulfillmentContext = ref.watch(
      posOrderFulfillmentContextProvider,
    );
    final fulfillmentDrafts = ref.watch(posOrderFulfillmentDraftsProvider);

    if (controller.isSingleOption) {
      return const SizedBox.shrink();
    }

    final icon = Icon(posCommerceChannelIcon(currentChannel.kind));
    POSCommerceChannelSwitchPlan planFor(POSCommerceChannel channel) {
      return _planFor(
        controller: controller,
        channel: channel,
        currentOrder: currentOrder,
        currentFulfillmentContext: currentFulfillmentContext,
        fulfillmentDrafts: fulfillmentDrafts,
      );
    }

    Future<void> openCompactSheet() async {
      final channel = await _showCompactSwitchSheet(
        context: context,
        controller: controller,
        planBuilder: planFor,
        currentOrder: currentOrder,
      );
      if (channel == null || !context.mounted) return;

      await handlePOSCommerceChannelSwitchAction(
        actionContext: buildPOSSwitchActionContext(context: context, ref: ref),
        switchController: controller,
        plan: planFor(channel),
      );
    }

    return POSSwitchAdaptiveMenuButton<String>(
      tooltip: 'Channel: ${currentChannel.label}',
      icon: icon,
      label: showLabel ? Text(currentChannel.label) : null,
      viewportWidth: resolvedViewportWidth,
      onCompactPressed: openCompactSheet,
      initialValue: currentChannel.id,
      onSelected: (channelId) async {
        final channel = controller.channelFor(channelId);
        await handlePOSCommerceChannelSwitchAction(
          actionContext: buildPOSSwitchActionContext(
            context: context,
            ref: ref,
          ),
          switchController: controller,
          plan: planFor(channel),
        );
      },
      itemBuilder: (context) => _buildEntries(controller, planFor),
    );
  }

  List<PopupMenuEntry<String>> _buildEntries(
    POSCommerceChannelSwitchController controller,
    _POSCommerceChannelSwitchPlanBuilder planBuilder,
  ) {
    return buildPOSSwitchPopupMenuEntries<String, List<POSCommerceChannel>>(
      title: const Text('Commerce channels'),
      sections: [controller.channels],
      itemEntriesBuilder:
          (channels) => channels.map((channel) {
            final availability = planBuilder(channel).availability;

            return CheckedPopupMenuItem<String>(
              value: channel.id,
              checked: availability.isCurrent,
              child: POSCommerceChannelOptionTile(
                channel: channel,
                statusLabel: availability.statusLabel,
                statusRequiresAttention: availability.needsConfirmation,
              ),
            );
          }),
    );
  }

  Future<POSCommerceChannel?> _showCompactSwitchSheet({
    required BuildContext context,
    required POSCommerceChannelSwitchController controller,
    required _POSCommerceChannelSwitchPlanBuilder planBuilder,
    required Order? currentOrder,
  }) {
    return showPOSSwitchCompactSheet<POSCommerceChannel>(
      context: context,
      builder: (sheetContext) {
        return POSCommerceChannelSwitchPanel(
          controller: controller,
          planBuilder: planBuilder,
          currentOrder: currentOrder,
          onChannelSelected:
              (channel) => Navigator.of(sheetContext).pop(channel),
        );
      },
    );
  }

  POSCommerceChannelSwitchPlan _planFor({
    required POSCommerceChannelSwitchController controller,
    required POSCommerceChannel channel,
    required Order? currentOrder,
    required POSOrderFulfillmentContext currentFulfillmentContext,
    required Map<String, POSOrderFulfillmentContext> fulfillmentDrafts,
  }) {
    final targetFulfillmentContext = resolvePOSOrderFulfillmentContextFor(
      order: currentOrder,
      channel: channel,
      drafts: fulfillmentDrafts,
    );

    return POSCommerceChannelSwitchPlan.resolve(
      currentChannel: controller.currentChannel,
      targetChannel: channel,
      currentLayoutPreference: controller.currentLayoutPreference,
      currentFulfillmentContext: currentFulfillmentContext,
      targetFulfillmentContext: targetFulfillmentContext,
      order: currentOrder,
    );
  }
}

typedef _POSCommerceChannelSwitchPlanBuilder =
    POSCommerceChannelSwitchPlan Function(POSCommerceChannel channel);
