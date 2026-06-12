import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_workspace_snapshot.dart';
import '../models/order_workspace_view.dart';
import 'order_card.dart';
import 'order_workspace_callbacks.dart';

class OrderTransactionsPane extends StatelessWidget {
  final OrderWorkspaceSnapshot snapshot;
  final OrderStatusChanged onOrderStatusChanged;

  const OrderTransactionsPane({
    super.key,
    required this.snapshot,
    required this.onOrderStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final list = _OrderTransactionList(
          snapshot: snapshot,
          boundedHeight: constraints.hasBoundedHeight,
          onOrderStatusChanged: onOrderStatusChanged,
        );

        return Column(
          key: const ValueKey('order_transactions_pane'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TransactionsHeader(
              visibleCount: snapshot.visibleOrderCount,
              totalCount: snapshot.totalOrderCount,
            ),
            const SizedBox(height: POSUiTokens.gapLarge),
            constraints.hasBoundedHeight ? Expanded(child: list) : list,
          ],
        );
      },
    );
  }
}

class _TransactionsHeader extends StatelessWidget {
  final int visibleCount;
  final int totalCount;

  const _TransactionsHeader({
    required this.visibleCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      key: const ValueKey('order_transactions_header'),
      children: [
        Text(
          'Transactions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: POSUiTokens.gap),
        Text(
          '$visibleCount/$totalCount',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _OrderTransactionList extends StatelessWidget {
  final OrderWorkspaceSnapshot snapshot;
  final bool boundedHeight;
  final OrderStatusChanged onOrderStatusChanged;

  const _OrderTransactionList({
    required this.snapshot,
    required this.boundedHeight,
    required this.onOrderStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!snapshot.hasVisibleOrders) {
      return POSEmptyState(
        icon:
            snapshot.workspaceContext.filter.hasActiveFilters
                ? Icons.manage_search_outlined
                : Icons.receipt_long_outlined,
        title: ecommerceOrderWorkspaceEmptyTitle(
          snapshot.workspaceContext,
          hasAnyOrders: snapshot.hasOrders,
        ),
        message: ecommerceOrderWorkspaceEmptyMessage(
          snapshot.workspaceContext,
          hasAnyOrders: snapshot.hasOrders,
        ),
      );
    }

    if (!boundedHeight) {
      return Column(
        children: snapshot.visibleOrders
            .map(
              (order) => OrderCard(
                order: order,
                onStatusChanged:
                    (status) => onOrderStatusChanged(order, status),
              ),
            )
            .toList(growable: false),
      );
    }

    return ListView.builder(
      key: const ValueKey('order_transaction_list'),
      itemCount: snapshot.visibleOrderCount,
      itemBuilder: (context, index) {
        final order = snapshot.visibleOrders[index];
        return OrderCard(
          order: order,
          onStatusChanged: (status) => onOrderStatusChanged(order, status),
        );
      },
    );
  }
}
