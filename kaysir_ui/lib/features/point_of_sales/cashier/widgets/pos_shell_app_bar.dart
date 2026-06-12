import 'package:flutter/material.dart';

import '../../order/utils/order_save_outbox_auto_sync_state.dart';
import '../../order/utils/order_save_outbox_freshness.dart';
import '../../order/utils/order_save_outbox_summary.dart';
import '../../order/utils/order_save_outbox_sync_behavior.dart';
import '../../order/utils/order_save_outbox_sync_state.dart';
import '../../order/widgets/order_save_outbox_status_action.dart';
import '../experiences/pos_commerce_channel.dart';
import '../experiences/pos_experience.dart';
import '../experiences/pos_experience_action_policy.dart';
import '../states/pos_layout_provider.dart';
import '../utils/pos_shell_action_layout.dart';
import 'pos_commerce_channel_menu.dart';
import 'pos_experience_diagnostics.dart';
import 'pos_experience_menu.dart';
import 'pos_layout_strategy_pack.dart';
import 'pos_runtime_pack_menu.dart';
import 'terminal_selector.dart';

class POSShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double defaultToolbarHeight = 64;

  final String title;
  final String? subtitle;
  final POSExperience experience;
  final POSCommerceChannel commerceChannel;
  final POSExperienceActionPolicy actionPolicy;
  final double viewportWidth;
  final POSLayoutPreference layoutPreference;
  final POSLayoutStrategy resolvedStrategy;
  final POSLayoutStrategyPack layoutPack;
  final POSOrderSaveOutboxSummary outboxSummary;
  final POSOrderSaveOutboxSyncState outboxSyncState;
  final POSOrderSaveOutboxAutoSyncState outboxAutoSyncState;
  final POSOrderSaveOutboxFreshnessState outboxFreshnessState;
  final POSOrderSaveOutboxSyncBehavior outboxSyncBehavior;
  final VoidCallback onOpenOrderSyncQueue;
  final VoidCallback onDashboard;
  final VoidCallback? onCustomerSelection;
  final ValueChanged<POSLayoutPreference>? onLayoutChanged;
  final bool showTerminalSelector;
  final bool showCommerceChannelMenu;
  final bool showExperienceMenu;
  final bool showRuntimePackMenu;
  final bool showDiagnostics;
  final double toolbarHeight;

  const POSShellAppBar({
    super.key,
    this.title = 'Kaysir POS',
    this.subtitle,
    required this.experience,
    required this.commerceChannel,
    required this.actionPolicy,
    required this.viewportWidth,
    required this.layoutPreference,
    required this.resolvedStrategy,
    required this.layoutPack,
    this.outboxSummary = const POSOrderSaveOutboxSummary.empty(),
    this.outboxSyncState = const POSOrderSaveOutboxSyncState.idle(),
    this.outboxAutoSyncState = const POSOrderSaveOutboxAutoSyncState.idle(),
    this.outboxFreshnessState = const POSOrderSaveOutboxFreshnessState.fresh(),
    this.outboxSyncBehavior = POSOrderSaveOutboxSyncBehavior.standard,
    required this.onOpenOrderSyncQueue,
    required this.onDashboard,
    this.onCustomerSelection,
    this.onLayoutChanged,
    this.showTerminalSelector = true,
    this.showCommerceChannelMenu = true,
    this.showExperienceMenu = true,
    this.showRuntimePackMenu = true,
    this.showDiagnostics = true,
    this.toolbarHeight = defaultToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionLayout = POSShellActionLayout.resolve(viewportWidth);
    final canSelectCustomer =
        actionPolicy.allows(POSExperienceAction.customerSelection) &&
        onCustomerSelection != null;
    final canSwitchLayout =
        actionPolicy.allows(POSExperienceAction.layoutSwitching) &&
        onLayoutChanged != null;
    final shouldShowOverflow = !actionLayout.showSecondaryActionsInline;

    return AppBar(
      toolbarHeight: toolbarHeight,
      titleSpacing: 16,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: _POSShellTitle(
        title: title,
        subtitle: subtitle ?? '${experience.label} | ${commerceChannel.label}',
      ),
      actions: [
        if (showTerminalSelector && actionLayout.showTerminalInline)
          const TerminalSelector(),
        if (showRuntimePackMenu) const POSRuntimePackMenu(),
        if (showCommerceChannelMenu) const POSCommerceChannelMenu(),
        if (showExperienceMenu) POSExperienceMenu(viewportWidth: viewportWidth),
        if (showDiagnostics)
          POSExperienceDiagnosticsButton(
            viewportWidth: viewportWidth,
            layoutPreference: layoutPreference,
            resolvedStrategy: resolvedStrategy,
            layoutPack: layoutPack,
          ),
        OrderSaveOutboxStatusAction(
          summary: outboxSummary,
          syncState: outboxSyncState,
          autoSyncState: outboxAutoSyncState,
          freshnessState: outboxFreshnessState,
          syncBehavior: outboxSyncBehavior,
          onPressed: onOpenOrderSyncQueue,
        ),
        if (actionLayout.showSecondaryActionsInline) ...[
          IconButton(
            tooltip: 'Dashboard',
            icon: const Icon(Icons.home_outlined),
            onPressed: onDashboard,
          ),
          if (canSelectCustomer)
            IconButton(
              tooltip: 'Customer',
              icon: const Icon(Icons.person_outline),
              onPressed: onCustomerSelection,
            ),
          if (canSwitchLayout)
            IconButton(
              tooltip: 'Auto layout',
              icon: const Icon(Icons.tune),
              onPressed: () => onLayoutChanged!(POSLayoutPreference.auto),
            ),
        ] else if (shouldShowOverflow)
          _POSShellOverflowMenu(
            showCustomer: canSelectCustomer,
            showAutoLayout: canSwitchLayout,
            onDashboard: onDashboard,
            onCustomerSelection: onCustomerSelection,
            onLayoutChanged: onLayoutChanged,
          ),
      ],
    );
  }
}

enum _POSShellOverflowAction { dashboard, customer, autoLayout }

class _POSShellOverflowMenu extends StatelessWidget {
  final bool showCustomer;
  final bool showAutoLayout;
  final VoidCallback onDashboard;
  final VoidCallback? onCustomerSelection;
  final ValueChanged<POSLayoutPreference>? onLayoutChanged;

  const _POSShellOverflowMenu({
    required this.showCustomer,
    required this.showAutoLayout,
    required this.onDashboard,
    this.onCustomerSelection,
    this.onLayoutChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_POSShellOverflowAction>(
      tooltip: 'More POS actions',
      icon: const Icon(Icons.more_horiz),
      onSelected: (action) {
        switch (action) {
          case _POSShellOverflowAction.dashboard:
            onDashboard();
          case _POSShellOverflowAction.customer:
            onCustomerSelection?.call();
          case _POSShellOverflowAction.autoLayout:
            onLayoutChanged?.call(POSLayoutPreference.auto);
        }
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem<_POSShellOverflowAction>(
              value: _POSShellOverflowAction.dashboard,
              child: _POSShellOverflowTile(
                icon: Icons.home_outlined,
                label: 'Dashboard',
              ),
            ),
            if (showCustomer)
              const PopupMenuItem<_POSShellOverflowAction>(
                value: _POSShellOverflowAction.customer,
                child: _POSShellOverflowTile(
                  icon: Icons.person_outline,
                  label: 'Customer',
                ),
              ),
            if (showAutoLayout)
              const PopupMenuItem<_POSShellOverflowAction>(
                value: _POSShellOverflowAction.autoLayout,
                child: _POSShellOverflowTile(
                  icon: Icons.tune,
                  label: 'Auto layout',
                ),
              ),
          ],
    );
  }
}

class _POSShellOverflowTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _POSShellOverflowTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 19, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _POSShellTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _POSShellTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
