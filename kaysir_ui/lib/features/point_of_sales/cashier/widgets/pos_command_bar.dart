import 'package:flutter/material.dart';

import '../../order/utils/order_save_outbox_auto_sync_state.dart';
import '../../order/utils/order_save_outbox_freshness.dart';
import '../../order/utils/order_save_outbox_summary.dart';
import '../../order/utils/order_save_outbox_sync_behavior.dart';
import '../../order/utils/order_save_outbox_sync_state.dart';
import '../../order/widgets/order_save_outbox_status_chip.dart';
import '../experiences/default_pos_experience.dart';
import '../experiences/pos_experience.dart';
import '../experiences/pos_experience_action_policy.dart';
import '../states/pos_layout_provider.dart';
import '../utils/pos_command_actions.dart';
import '../utils/pos_command_bar_layout.dart';
import '../utils/pos_formatters.dart';
import 'pos_ui.dart';
import 'search_bar.dart';

class POSCommandBar extends StatelessWidget {
  final POSExperience experience;
  final POSExperienceActionPolicy? actionPolicy;
  final POSLayoutPreference layoutPreference;
  final POSLayoutStrategy resolvedStrategy;
  final int itemCount;
  final double total;
  final POSOrderSaveOutboxSummary outboxSummary;
  final POSOrderSaveOutboxSyncState outboxSyncState;
  final POSOrderSaveOutboxAutoSyncState outboxAutoSyncState;
  final POSOrderSaveOutboxFreshnessState outboxFreshnessState;
  final POSOrderSaveOutboxSyncBehavior outboxSyncBehavior;
  final FocusNode searchFocusNode;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onScan;
  final VoidCallback onNewOrder;
  final VoidCallback onPromotions;
  final VoidCallback onPayment;
  final VoidCallback onHold;
  final VoidCallback onHeldOrders;
  final VoidCallback? onSyncOutbox;
  final int heldOrderCount;
  final ValueChanged<POSLayoutPreference> onLayoutChanged;
  final POSLayoutStrategyRegistry layoutStrategyRegistry;
  final POSCommandActionRegistry commandActionRegistry;

  const POSCommandBar({
    super.key,
    this.experience = defaultPOSExperience,
    this.actionPolicy,
    required this.layoutPreference,
    required this.resolvedStrategy,
    required this.itemCount,
    required this.total,
    this.outboxSummary = const POSOrderSaveOutboxSummary.empty(),
    this.outboxSyncState = const POSOrderSaveOutboxSyncState.idle(),
    this.outboxAutoSyncState = const POSOrderSaveOutboxAutoSyncState.idle(),
    this.outboxFreshnessState = const POSOrderSaveOutboxFreshnessState.fresh(),
    this.outboxSyncBehavior = POSOrderSaveOutboxSyncBehavior.standard,
    required this.searchFocusNode,
    required this.onSearch,
    required this.onSearchSubmitted,
    required this.onScan,
    required this.onNewOrder,
    required this.onPromotions,
    required this.onPayment,
    required this.onHold,
    required this.onHeldOrders,
    this.onSyncOutbox,
    required this.heldOrderCount,
    required this.onLayoutChanged,
    this.layoutStrategyRegistry = defaultPOSLayoutStrategyRegistry,
    this.commandActionRegistry = defaultPOSCommandActionRegistry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return POSSurface(
      borderRadius: BorderRadius.zero,
      border: Border(bottom: BorderSide(color: theme.dividerColor)),
      elevated: true,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = POSCommandBarLayout.resolve(constraints.maxWidth);
          final actions = _buildActions(layout.usesCompactControls);

          if (layout.stacksActions) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                POSSearchBar(
                  focusNode: searchFocusNode,
                  onSearch: onSearch,
                  onSubmitted: onSearchSubmitted,
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: _withSpacing(actions, right: 8)),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: POSSearchBar(
                  focusNode: searchFocusNode,
                  onSearch: onSearch,
                  onSubmitted: onSearchSubmitted,
                ),
              ),
              const SizedBox(width: POSUiTokens.gapLarge),
              ..._withSpacing(actions, left: POSUiTokens.gap),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildActions(bool compactLayoutLabels) {
    final policy =
        actionPolicy ?? POSExperienceActionPolicy(experience: experience);

    return [
      POSMetricPill(
        icon: const Icon(Icons.shopping_bag_outlined),
        label: '$itemCount items',
        value: formatPOSCurrency(total),
      ),
      if (outboxSummary.shouldSurface)
        OrderSaveOutboxStatusChip(
          summary: outboxSummary,
          syncState: outboxSyncState,
          autoSyncState: outboxAutoSyncState,
          freshnessState: outboxFreshnessState,
          syncBehavior: outboxSyncBehavior,
          compact: compactLayoutLabels,
          onPressed: onSyncOutbox,
        ),
      if (policy.allows(POSExperienceAction.layoutSwitching))
        POSLayoutSwitcher(
          value: layoutPreference,
          resolvedStrategy: resolvedStrategy,
          compact: compactLayoutLabels,
          registry: layoutStrategyRegistry,
          onChanged: onLayoutChanged,
        ),
      ..._buildCommandActionButtons(policy),
    ];
  }

  List<Widget> _buildCommandActionButtons(POSExperienceActionPolicy policy) {
    final actions = commandActionRegistry.resolve(
      policy: policy,
      itemCount: itemCount,
      heldOrderCount: heldOrderCount,
      handlers: POSCommandActionHandlers(
        onScan: onScan,
        onStartNewOrder: onNewOrder,
        onHoldOrder: onHold,
        onOpenHeldOrders: onHeldOrders,
        onPromotions: onPromotions,
        onPayment: onPayment,
      ),
    );

    return actions.map(_buildCommandActionButton).toList();
  }

  Widget _buildCommandActionButton(POSResolvedCommandAction action) {
    final spec = action.spec;
    final icon =
        spec.showsHeldOrderCount
            ? Badge.count(
              count: action.heldOrderCount,
              isLabelVisible: action.heldOrderCount > 0,
              child: Icon(spec.icon),
            )
            : Icon(spec.icon);

    return POSActionButton(
      icon: icon,
      label: spec.label,
      onPressed: action.onPressed,
      variant: spec.variant,
      tooltip: action.tooltipLabel,
    );
  }

  List<Widget> _withSpacing(
    List<Widget> children, {
    double left = 0,
    double right = 0,
  }) {
    return children
        .map(
          (child) => Padding(
            padding: EdgeInsets.only(left: left, right: right),
            child: child,
          ),
        )
        .toList();
  }
}

class POSLayoutSwitcher extends StatelessWidget {
  final POSLayoutPreference value;
  final POSLayoutStrategy resolvedStrategy;
  final bool compact;
  final POSLayoutStrategyRegistry registry;
  final ValueChanged<POSLayoutPreference> onChanged;

  const POSLayoutSwitcher({
    super.key,
    required this.value,
    required this.resolvedStrategy,
    required this.compact,
    this.registry = defaultPOSLayoutStrategyRegistry,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activeStrategy = registry.specForStrategy(resolvedStrategy);

    return Tooltip(
      message:
          'Active layout: ${activeStrategy.label} - ${activeStrategy.description}',
      child: SegmentedButton<POSLayoutPreference>(
        showSelectedIcon: false,
        selected: {value},
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onSelectionChanged: (selected) => onChanged(selected.first),
        segments:
            registry.preferenceOptions.map((preference) {
              return ButtonSegment<POSLayoutPreference>(
                value: preference,
                icon: Icon(_layoutIcon(preference)),
                label: compact ? null : Text(preference.label),
              );
            }).toList(),
      ),
    );
  }

  IconData _layoutIcon(POSLayoutPreference preference) {
    switch (preference) {
      case POSLayoutPreference.auto:
        return Icons.auto_mode;
      case POSLayoutPreference.counter:
        return Icons.view_sidebar_outlined;
      case POSLayoutPreference.compact:
        return Icons.view_agenda_outlined;
      case POSLayoutPreference.checkout:
        return Icons.receipt_long_outlined;
    }
  }
}
