import 'package:flutter/material.dart';

import '../../order/models/order.dart';
import '../experiences/pos_commerce_channel.dart';
import '../experiences/pos_commerce_channel_active_order_impact.dart';
import '../experiences/pos_commerce_channel_controller.dart';
import '../experiences/pos_commerce_channel_filter.dart';
import '../experiences/pos_commerce_channel_switch_availability.dart';
import '../experiences/pos_commerce_channel_switch_preview.dart';
import '../experiences/pos_commerce_channel_switch_plan.dart';
import '../experiences/pos_commerce_channel_switch_preflight.dart';
import '../experiences/pos_order_fulfillment.dart';
import 'pos_commerce_channel_active_order_impact_summary.dart';
import 'pos_commerce_channel_behavior_impact_summary.dart';
import 'pos_commerce_channel_option_tile.dart';
import 'pos_commerce_channel_switch_plan_action_summary.dart';
import 'pos_switch_filtered_panel.dart';
import 'pos_switch_option_surface.dart';
import 'pos_switch_section_header.dart';

typedef POSCommerceChannelAvailabilityBuilder =
    POSCommerceChannelSwitchAvailability Function(POSCommerceChannel channel);
typedef POSCommerceChannelSwitchPlanBuilder =
    POSCommerceChannelSwitchPlan Function(POSCommerceChannel channel);

class POSCommerceChannelSwitchPanel extends StatelessWidget {
  final POSCommerceChannelSwitchController controller;
  final ValueChanged<POSCommerceChannel> onChannelSelected;
  final POSCommerceChannelAvailabilityBuilder? availabilityBuilder;
  final POSCommerceChannelSwitchPlanBuilder? planBuilder;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollController? scrollController;
  final bool enableSearch;
  final Order? currentOrder;

  const POSCommerceChannelSwitchPanel({
    super.key,
    required this.controller,
    required this.onChannelSelected,
    this.availabilityBuilder,
    this.planBuilder,
    this.padding = const EdgeInsets.fromLTRB(16, 6, 16, 16),
    this.shrinkWrap = false,
    this.scrollController,
    this.enableSearch = true,
    this.currentOrder,
  });

  @override
  Widget build(BuildContext context) {
    return POSSwitchFilteredPanel<
      POSCommerceChannelFilterStatus,
      POSCommerceChannelFilterSection
    >(
      title: 'Commerce channels',
      currentLabel: controller.currentChannel.label,
      initialStatus: POSCommerceChannelFilterStatus.all,
      statusValues: POSCommerceChannelFilterStatus.values,
      statusLabelBuilder: (status) => status.label,
      searchHintText: 'Search channels',
      filteredTitle: 'No matching channels',
      emptyTitle: 'No commerce channels available',
      padding: padding,
      shrinkWrap: shrinkWrap,
      scrollController: scrollController,
      enableSearch: enableSearch,
      currentOrder: currentOrder,
      dataBuilder: (context, filterState) {
        final filter = POSCommerceChannelFilter(
          query: filterState.query,
          status: filterState.status,
        );
        final result = controller.filterChannels(
          filter,
          extraSearchTermsBuilder: _switchSearchTerms,
        );
        final counts = controller.channelCounts(
          query: filterState.query,
          extraSearchTermsBuilder: _switchSearchTerms,
        );

        return POSSwitchFilteredPanelData(
          sections: result.sections,
          filterActive: filter.isActive,
          countForStatus: counts.countFor,
        );
      },
      headerBuilder:
          (context, section) => POSSwitchSectionHeader(
            title: section.title,
            countLabel:
                '${section.channelCount} channel'
                '${section.channelCount == 1 ? '' : 's'}',
          ),
      childrenBuilder:
          (context, section) => [
            for (final channel in section.channels)
              Builder(
                builder: (context) {
                  final plan = _planFor(channel);
                  final availability = plan.availability;
                  final behaviorImpact = controller.behaviorImpactFor(channel);
                  final activeOrderImpact =
                      POSCommerceChannelActiveOrderImpact.fromPlan(plan);

                  return POSSwitchOptionSurface(
                    selected: availability.isCurrent,
                    onTap: () => onChannelSelected(channel),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        POSCommerceChannelOptionTile(
                          channel: channel,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          showDescription: true,
                          statusLabel: availability.statusLabel,
                          statusRequiresAttention:
                              availability.needsConfirmation,
                          preview: POSCommerceChannelSwitchPreview.evaluate(
                            availability: availability,
                          ),
                          behaviorProfile: controller.behaviorProfileFor(
                            channel,
                          ),
                        ),
                        if (!plan.isCurrent && behaviorImpact.hasChanges) ...[
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: _actionSummaryIndent,
                            ),
                            child: POSCommerceChannelBehaviorImpactSummary(
                              impact: behaviorImpact,
                            ),
                          ),
                        ],
                        if (activeOrderImpact.isVisible) ...[
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: _actionSummaryIndent,
                            ),
                            child: POSCommerceChannelActiveOrderImpactSummary(
                              impact: activeOrderImpact,
                            ),
                          ),
                        ],
                        if (!plan.isCurrent) ...[
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: _actionSummaryIndent,
                            ),
                            child: POSCommerceChannelSwitchPlanActionSummary(
                              plan: plan,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
          ],
    );
  }

  POSCommerceChannelSwitchAvailability _availabilityFor(
    POSCommerceChannel channel,
  ) {
    final customBuilder = availabilityBuilder;
    if (customBuilder != null) return customBuilder(channel);

    return POSCommerceChannelSwitchAvailability.evaluate(
      currentChannel: controller.currentChannel,
      targetChannel: channel,
      currentLayoutPreference: controller.currentLayoutPreference,
      currentFulfillmentContext: POSOrderFulfillmentContext.forChannel(
        controller.currentChannel,
      ),
      targetFulfillmentContext: POSOrderFulfillmentContext.forChannel(channel),
      order: null,
    );
  }

  POSCommerceChannelSwitchPlan _planFor(POSCommerceChannel channel) {
    final customBuilder = planBuilder;
    if (customBuilder != null) return customBuilder(channel);

    return POSCommerceChannelSwitchPlan.fromAvailability(
      availability: _availabilityFor(channel),
    );
  }

  Iterable<String> _switchSearchTerms(POSCommerceChannel channel) sync* {
    final plan = _planFor(channel);
    final preview = POSCommerceChannelSwitchPreview.evaluate(
      availability: plan.availability,
    );

    yield* preview.searchTerms;
    yield plan.impactLabel;
    yield plan.statusLabel;
    yield* POSCommerceChannelActiveOrderImpact.fromPlan(plan).searchTerms;
    yield* POSCommerceChannelSwitchPreflight.fromPlan(plan).searchTerms;
    yield* controller.behaviorSearchTermsFor(channel);

    for (final action in plan.actions) {
      yield action.id;
      yield action.label;
      yield action.role.name;
      yield action.requiresAttention ? 'requires attention' : 'safe';
    }
  }
}

const double _actionSummaryIndent = 42;
