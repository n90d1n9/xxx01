import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../omni_channel/activity/widgets/omni_channel_activity_insight_status_banner.dart';
import '../../../product/models/product.dart';
import '../../order/models/order.dart';
import '../../order/states/current_order_provider.dart';
import '../../order/states/order_save_outbox_auto_sync_provider.dart';
import '../../order/states/order_save_outbox_provider.dart';
import '../../order/states/order_save_outbox_sync_provider.dart';
import '../../order/utils/order_save_outbox_freshness.dart';
import '../../order/widgets/order_save_outbox_details_dialog.dart';
import '../../payment/widgets/payment_dialog.dart';
import '../../promotion/widgets/promotion_dialog.dart';
import '../experiences/pos_commerce_channel_provider.dart';
import '../experiences/pos_experience_action_policy.dart';
import '../experiences/pos_experience_provider.dart';
import '../models/terminal.dart';
import '../services/pos_product_matcher.dart';
import '../states/held_order_provider.dart';
import '../states/pos_command_action_provider.dart';
import '../states/pos_catalog_filter_provider.dart';
import '../states/pos_layout_provider.dart';
import '../states/pos_shell_shortcut_provider.dart';
import '../states/terminal_provider.dart';
import '../utils/pos_formatters.dart';
import '../utils/pos_shell_shortcuts.dart';
import '../widgets/customer_selection_dialog.dart';
import '../widgets/held_orders_dialog.dart';
import '../widgets/pos_command_bar.dart';
import '../widgets/pos_commerce_channel_switch_result_notice.dart';
import '../widgets/pos_layout_strategy_host.dart';
import '../widgets/pos_layout_strategy_pack_provider.dart';
import '../widgets/pos_shell_app_bar.dart';
import '../widgets/pos_shell_scaffold.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(posOrderSaveOutboxHydrationProvider.future));
      _selectTerminal();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectTerminal() async {
    try {
      final List<Terminal> terminals =
          await ref.read(terminalsProvider.future) ?? const <Terminal>[];
      if (!mounted || terminals.isEmpty) return;

      var selectedTerminal = terminals.first;
      for (final terminal in terminals) {
        if (terminal.isActive) {
          selectedTerminal = terminal;
          break;
        }
      }

      ref.read(currentTerminalProvider.notifier).state ??= selectedTerminal;

      final currentTerminal = ref.read(currentTerminalProvider);
      if (currentTerminal != null && ref.read(currentOrderProvider) == null) {
        ref.read(currentOrderProvider.notifier).createNewOrder(currentTerminal);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load cashier terminals')),
      );
    }
  }

  void _updateSearch(String query) {
    final filter = ref.read(posCatalogFilterProvider);
    ref.read(posCatalogFilterProvider.notifier).state = filter.copyWith(
      query: query,
    );
  }

  void _addProduct(Product product) {
    final notifier = ref.read(currentOrderProvider.notifier);
    final cartBehavior = ref.read(posCartBehaviorProvider);
    if (ref.read(currentOrderProvider) == null) {
      final currentTerminal = ref.read(currentTerminalProvider);
      if (currentTerminal != null) {
        notifier.createNewOrder(currentTerminal);
      }
    }

    if (ref.read(currentOrderProvider) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an active terminal first')),
      );
      return;
    }

    notifier.addItem(product, 1, cartBehavior: cartBehavior);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.name} added to order'),
          duration: const Duration(milliseconds: 1200),
          action: SnackBarAction(
            label: 'Checkout',
            onPressed: () => _setLayout(POSLayoutPreference.checkout),
          ),
        ),
      );
  }

  Future<void> _scanOrEnterCode() async {
    if (!_guardExperienceAction(POSExperienceAction.barcodeScanning)) return;

    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Scan or Enter Code'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Barcode, SKU, or product name',
                prefixIcon: Icon(Icons.qr_code_scanner),
              ),
              onSubmitted: (value) => Navigator.of(context).pop(value),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(controller.text),
                child: const Text('Add'),
              ),
            ],
          ),
    );
    controller.dispose();

    final enteredCode = code?.trim();
    if (enteredCode == null || enteredCode.isEmpty) return;

    final products = await ref.read(posCatalogProductsProvider.future);
    if (!mounted) return;

    final match = ref
        .read(posProductMatcherProvider)
        .matchScannedProduct(products, enteredCode);
    if (!mounted) return;

    if (match != null) {
      _addProduct(match);
      return;
    }

    _updateSearch(enteredCode);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No exact match. Showing matches instead.')),
    );
  }

  Future<void> _addSubmittedProduct(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final products = await ref.read(posVisibleProductsProvider.future);
      if (!mounted) return;

      final match = ref
          .read(posProductMatcherProvider)
          .matchSubmittedProduct(products, query);
      if (match == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No matching product to add')),
        );
        return;
      }

      _addProduct(match);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to add product from search')),
      );
    }
  }

  Future<void> _startNewOrder() async {
    if (!_guardExperienceAction(POSExperienceAction.newOrders)) return;

    final currentTerminal = ref.read(currentTerminalProvider);
    if (currentTerminal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an active terminal first')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('New Order'),
            content: const Text('Clear the current order and start a new one?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Start'),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    ref.read(currentOrderProvider.notifier)
      ..cancelOrder()
      ..createNewOrder(currentTerminal);
  }

  void _openPromotions() {
    if (!_guardExperienceAction(POSExperienceAction.promotions)) return;

    showDialog(context: context, builder: (context) => const PromotionDialog());
  }

  void _openPayment() {
    if (!_guardExperienceAction(POSExperienceAction.payments)) return;

    final currentOrder = ref.read(currentOrderProvider);
    if (currentOrder == null || currentOrder.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items before taking payment')),
      );
      return;
    }

    showDialog(context: context, builder: (context) => const PaymentDialog());
  }

  Future<void> _syncQueuedOrders() async {
    final summary = ref.read(posOrderSaveOutboxSummaryProvider);
    if (!summary.canSync) return;

    try {
      await ref.read(posOrderSaveOutboxSyncStateProvider.notifier).drain();
      if (!mounted) return;

      final message =
          ref.read(posOrderSaveOutboxSyncStateProvider).operatorMessage;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      final message =
          ref.read(posOrderSaveOutboxSyncStateProvider).operatorMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _openOrderSyncQueue() {
    showDialog(
      context: context,
      builder:
          (context) => Consumer(
            builder: (context, dialogRef, _) {
              final outbox = dialogRef.watch(posOrderSaveOutboxProvider);
              final summary = dialogRef.watch(
                posOrderSaveOutboxSummaryProvider,
              );
              final syncState = dialogRef.watch(
                posOrderSaveOutboxSyncStateProvider,
              );
              final autoSyncState = dialogRef.watch(
                posOrderSaveOutboxAutoSyncStateProvider,
              );
              final syncBehavior = dialogRef.watch(
                posOrderSaveOutboxSyncBehaviorProvider,
              );

              return OrderSaveOutboxDetailsDialog(
                outbox: outbox,
                summary: summary,
                syncState: syncState,
                autoSyncState: autoSyncState,
                syncBehavior: syncBehavior,
                onSync:
                    syncState.isRunning
                        ? null
                        : () => unawaited(_syncQueuedOrders()),
                onClearSent:
                    () =>
                        dialogRef
                            .read(posOrderSaveOutboxProvider.notifier)
                            .clearSent(),
                onRetry:
                    (entry) => dialogRef
                        .read(posOrderSaveOutboxProvider.notifier)
                        .retryFailed(entry.idempotencyKey),
                onRetryEntries: (entries) {
                  dialogRef
                      .read(posOrderSaveOutboxProvider.notifier)
                      .retryFailedEntries(
                        entries.map((entry) => entry.idempotencyKey),
                      );
                  unawaited(_syncQueuedOrders());
                },
              );
            },
          ),
    );
  }

  void _focusSearch() {
    _searchFocusNode.requestFocus();
  }

  void _setLayout(POSLayoutPreference preference) {
    if (!_guardExperienceAction(POSExperienceAction.layoutSwitching)) return;

    ref.read(posLayoutPreferenceProvider.notifier).state = preference;
  }

  Future<void> _holdCurrentOrder() async {
    if (!_guardExperienceAction(POSExperienceAction.heldOrders)) return;

    final currentOrder = ref.read(currentOrderProvider);
    if (currentOrder == null || currentOrder.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items before holding the order')),
      );
      return;
    }

    final note = await _showHoldNoteDialog(currentOrder);
    if (note == null || !mounted) return;

    final heldOrder = ref
        .read(heldOrdersProvider.notifier)
        .hold(currentOrder, note: note);
    ref.read(currentOrderProvider.notifier)
      ..cancelOrder()
      ..createNewOrder(currentOrder.terminal);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Order #${heldOrder.shortOrderId} held'),
          action: SnackBarAction(
            label: 'Resume',
            onPressed: () {
              _resumeHeldOrder(heldOrder);
            },
          ),
        ),
      );
  }

  Future<String?> _showHoldNoteDialog(Order order) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hold Order'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.items.length} lines | ${formatPOSCurrency(order.total)}',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    prefixIcon: Icon(Icons.sticky_note_2_outlined),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.pause_circle_outline),
                label: const Text('Hold'),
                onPressed: () => Navigator.of(context).pop(controller.text),
              ),
            ],
          ),
    );
    controller.dispose();
    return note;
  }

  void _openHeldOrders() {
    if (!_guardExperienceAction(POSExperienceAction.heldOrders)) return;

    showDialog(
      context: context,
      builder: (context) => HeldOrdersDialog(onResume: _resumeHeldOrder),
    );
  }

  void _openCustomerSelection() {
    if (!_guardExperienceAction(POSExperienceAction.customerSelection)) return;

    showDialog(
      context: context,
      builder: (context) => const CustomerSelectionDialog(),
    );
  }

  void _showUnsupportedExperienceAction(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _guardExperienceAction(POSExperienceAction action) {
    final policy = ref.read(posExperienceActionPolicyProvider);
    if (policy.allows(action)) return true;

    _showUnsupportedExperienceAction(policy.unsupportedMessage(action));
    return false;
  }

  Future<bool> _resumeHeldOrder(HeldOrder heldOrder) async {
    final currentOrder = ref.read(currentOrderProvider);
    if (currentOrder != null && currentOrder.items.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Resume Held Order'),
              content: const Text(
                'Hold the current order first, then resume this one?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Resume'),
                ),
              ],
            ),
      );

      if (confirmed != true || !mounted) return false;

      ref
          .read(heldOrdersProvider.notifier)
          .hold(
            currentOrder,
            note: 'Held before resuming #${heldOrder.shortOrderId}',
          );
    }

    final resumedOrder = ref
        .read(heldOrdersProvider.notifier)
        .take(heldOrder.id);
    if (resumedOrder == null || !mounted) return false;

    ref.read(currentOrderProvider.notifier).restoreOrder(resumedOrder.order);
    ref.read(posLayoutPreferenceProvider.notifier).state =
        POSLayoutPreference.checkout;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Order #${resumedOrder.shortOrderId} resumed')),
      );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final layoutPreference = ref.watch(posLayoutPreferenceProvider);
    final commerceChannel = ref.watch(posCommerceChannelProvider);
    final experience = ref.watch(posExperienceProvider);
    final actionPolicy = ref.watch(posExperienceActionPolicyProvider);
    final currentOrder = ref.watch(currentOrderProvider);
    final outbox = ref.watch(posOrderSaveOutboxProvider);
    final outboxSummary = ref.watch(posOrderSaveOutboxSummaryProvider);
    final outboxSyncState = ref.watch(posOrderSaveOutboxSyncStateProvider);
    final outboxAutoSyncState = ref.watch(
      posOrderSaveOutboxAutoSyncStateProvider,
    );
    final outboxSyncBehavior = ref.watch(
      posOrderSaveOutboxSyncBehaviorProvider,
    );
    final outboxFreshnessState = POSOrderSaveOutboxFreshnessState.resolve(
      outbox: outbox,
      syncBehavior: outboxSyncBehavior,
      now: DateTime.now(),
    );
    final heldOrderCount = ref.watch(heldOrderCountProvider);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final layoutPack = ref.watch(posLayoutStrategyPackProvider);
    final commandActionRegistry = ref.watch(posCommandActionRegistryProvider);
    final shortcutRegistry = ref.watch(posShellShortcutRegistryProvider);
    final diagnosticsStrategy =
        layoutPack
            .resolve(preference: layoutPreference, width: viewportWidth)
            .strategy;
    final itemCount =
        currentOrder?.items.fold<int>(0, (sum, item) => sum + item.quantity) ??
        0;
    final total = currentOrder?.total ?? 0;

    return POSShellScaffold(
      shortcuts: shortcutRegistry.resolve(
        policy: actionPolicy,
        handlers: POSShellShortcutHandlers(
          onFocusSearch: _focusSearch,
          onScan: () => unawaited(_scanOrEnterCode()),
          onHoldOrder: () => unawaited(_holdCurrentOrder()),
          onOpenHeldOrders: _openHeldOrders,
          onOpenPayment: _openPayment,
          onStartNewOrder: () => unawaited(_startNewOrder()),
          onLayoutChanged: _setLayout,
        ),
      ),
      appBar: POSShellAppBar(
        experience: experience,
        commerceChannel: commerceChannel,
        actionPolicy: actionPolicy,
        viewportWidth: viewportWidth,
        layoutPreference: layoutPreference,
        resolvedStrategy: diagnosticsStrategy,
        layoutPack: layoutPack,
        outboxSummary: outboxSummary,
        outboxSyncState: outboxSyncState,
        outboxAutoSyncState: outboxAutoSyncState,
        outboxFreshnessState: outboxFreshnessState,
        outboxSyncBehavior: outboxSyncBehavior,
        onOpenOrderSyncQueue: _openOrderSyncQueue,
        onDashboard: () => context.go('/dashboard'),
        onCustomerSelection: _openCustomerSelection,
        onLayoutChanged: _setLayout,
      ),
      contentBuilder: (context, constraints) {
        final strategy =
            layoutPack
                .resolve(
                  preference: layoutPreference,
                  width: constraints.maxWidth,
                )
                .strategy;

        return POSShellContent(
          commandBar: POSCommandBar(
            experience: experience,
            actionPolicy: actionPolicy,
            layoutPreference: layoutPreference,
            resolvedStrategy: strategy,
            itemCount: itemCount,
            total: total,
            outboxSummary: outboxSummary,
            outboxSyncState: outboxSyncState,
            outboxAutoSyncState: outboxAutoSyncState,
            outboxFreshnessState: outboxFreshnessState,
            outboxSyncBehavior: outboxSyncBehavior,
            searchFocusNode: _searchFocusNode,
            onSearch: _updateSearch,
            onSearchSubmitted: _addSubmittedProduct,
            onScan: _scanOrEnterCode,
            onNewOrder: _startNewOrder,
            onPromotions: _openPromotions,
            onPayment: _openPayment,
            onHold: _holdCurrentOrder,
            onHeldOrders: _openHeldOrders,
            onSyncOutbox:
                outboxSyncState.isRunning
                    ? null
                    : () => unawaited(_syncQueuedOrders()),
            heldOrderCount: heldOrderCount,
            onLayoutChanged: _setLayout,
            layoutStrategyRegistry: layoutPack.strategyRegistry,
            commandActionRegistry: commandActionRegistry,
          ),
          statusBanner: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const POSCommerceChannelSwitchResultBanner(),
              OmniChannelActivityInsightStatusBanner(
                onOpenActivityCenter: (location) => context.go(location),
              ),
            ],
          ),
          body: POSLayoutStrategyHost(
            key: ValueKey(strategy),
            strategy: strategy,
            itemCount: itemCount,
            onProductSelected: _addProduct,
            pack: layoutPack,
          ),
        );
      },
    );
  }
}
