import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

// Models
class PurchaseOrder {
  final String id;
  final String vendorName;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final List<PurchaseOrderItem> items;
  final DateTime? expectedDeliveryDate;

  PurchaseOrder({
    required this.id,
    required this.vendorName,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.items,
    this.expectedDeliveryDate,
  });
}

class PurchaseOrderItem {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final String sku;

  PurchaseOrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.sku,
  });

  double get total => quantity * unitPrice;
}

// Providers
final purchaseOrdersProvider =
    StateNotifierProvider<PurchaseOrdersNotifier, List<PurchaseOrder>>((ref) {
      return PurchaseOrdersNotifier();
    });

final filteredPurchaseOrdersProvider = Provider<List<PurchaseOrder>>((ref) {
  final filter = ref.watch(purchaseOrderFilterProvider);
  final orders = ref.watch(purchaseOrdersProvider);

  if (filter.isEmpty) return orders;

  return orders.where((order) {
    return order.vendorName.toLowerCase().contains(filter.toLowerCase()) ||
        order.id.toLowerCase().contains(filter.toLowerCase()) ||
        order.status.toLowerCase().contains(filter.toLowerCase());
  }).toList();
});

final purchaseOrderFilterProvider = StateProvider<String>((ref) => '');

final selectedOrderProvider = StateProvider<PurchaseOrder?>((ref) => null);

// Notifier
class PurchaseOrdersNotifier extends StateNotifier<List<PurchaseOrder>> {
  PurchaseOrdersNotifier()
    : super([
        // Sample data
        PurchaseOrder(
          id: 'PO-2025-001',
          vendorName: 'Tech Supplies Inc.',
          orderDate: DateTime.now().subtract(const Duration(days: 5)),
          totalAmount: 12750.00,
          status: 'Pending',
          expectedDeliveryDate: DateTime.now().add(const Duration(days: 10)),
          items: [
            PurchaseOrderItem(
              id: 'ITEM-001',
              name: 'Laptop Pro X1',
              quantity: 5,
              unitPrice: 1200.00,
              sku: 'LP-X1-2025',
            ),
            PurchaseOrderItem(
              id: 'ITEM-002',
              name: 'Monitor 32" 4K',
              quantity: 10,
              unitPrice: 375.00,
              sku: 'MON-4K-32',
            ),
          ],
        ),
        PurchaseOrder(
          id: 'PO-2025-002',
          vendorName: 'Office Essentials Co.',
          orderDate: DateTime.now().subtract(const Duration(days: 15)),
          totalAmount: 5480.75,
          status: 'Delivered',
          expectedDeliveryDate: DateTime.now().subtract(
            const Duration(days: 2),
          ),
          items: [
            PurchaseOrderItem(
              id: 'ITEM-003',
              name: 'Ergonomic Chair',
              quantity: 15,
              unitPrice: 249.99,
              sku: 'CH-ERG-PRO',
            ),
            PurchaseOrderItem(
              id: 'ITEM-004',
              name: 'Standing Desk',
              quantity: 5,
              unitPrice: 349.99,
              sku: 'DSK-STD-01',
            ),
          ],
        ),
        PurchaseOrder(
          id: 'PO-2025-003',
          vendorName: 'Network Solutions Ltd.',
          orderDate: DateTime.now().subtract(const Duration(days: 3)),
          totalAmount: 8945.25,
          status: 'Processing',
          expectedDeliveryDate: DateTime.now().add(const Duration(days: 7)),
          items: [
            PurchaseOrderItem(
              id: 'ITEM-005',
              name: 'Enterprise Router',
              quantity: 3,
              unitPrice: 1299.99,
              sku: 'NET-RTR-ENT',
            ),
            PurchaseOrderItem(
              id: 'ITEM-006',
              name: 'Network Switch 24-Port',
              quantity: 5,
              unitPrice: 789.45,
              sku: 'NET-SW-24P',
            ),
          ],
        ),
      ]);

  void addPurchaseOrder(PurchaseOrder order) {
    state = [...state, order];
  }

  void updatePurchaseOrder(PurchaseOrder updatedOrder) {
    state = state
        .map((order) => order.id == updatedOrder.id ? updatedOrder : order)
        .toList();
  }

  void deletePurchaseOrder(String id) {
    state = state.where((order) => order.id != id).toList();
  }
}

// UI Components
class PurchaseOrdersScreen extends ConsumerWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(filteredPurchaseOrdersProvider);
    final selectedOrder = ref.watch(selectedOrderProvider);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 260,
            color: const Color(0xFF1A1F38),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            "PO",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "ProcureHub",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _SidebarMenuItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  isActive: false,
                ),
                _SidebarMenuItem(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Purchase Orders',
                  isActive: true,
                ),
                _SidebarMenuItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventory',
                  isActive: false,
                ),
                _SidebarMenuItem(
                  icon: Icons.business_outlined,
                  title: 'Vendors',
                  isActive: false,
                ),
                _SidebarMenuItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Invoices',
                  isActive: false,
                ),
                _SidebarMenuItem(
                  icon: Icons.analytics_outlined,
                  title: 'Reports',
                  isActive: false,
                ),
                const Spacer(),
                _SidebarMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  isActive: false,
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFF2D3250), height: 1),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=11',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alex Morgan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Procurement Manager',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFFF5F7FA),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 5,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Purchase Orders',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 280,
                          child: TextField(
                            onChanged: (value) =>
                                ref
                                        .read(
                                          purchaseOrderFilterProvider.notifier,
                                        )
                                        .state =
                                    value,
                            decoration: InputDecoration(
                              hintText: 'Search orders...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF3F4F6),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {},
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: () {},
                          color: Colors.grey[700],
                        ),
                      ],
                    ),
                  ),
                  // Content Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Orders List
                          Expanded(
                            flex: 5,
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'All Purchase Orders (${orders.length})',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Spacer(),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.add, size: 16),
                                          label: const Text('New Order'),
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.blueAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: orders.length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final order = orders[index];
                                        final isSelected =
                                            selectedOrder?.id == order.id;

                                        return ListTile(
                                          selected: isSelected,
                                          selectedTileColor: Colors.blue
                                              .withValues(alpha: 0.08),
                                          onTap: () =>
                                              ref
                                                      .read(
                                                        selectedOrderProvider
                                                            .notifier,
                                                      )
                                                      .state =
                                                  order,
                                          title: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  order.id,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(order.vendorName),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  DateFormat(
                                                    'MMM d, yyyy',
                                                  ).format(order.orderDate),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  '\$${order.totalAmount.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: _StatusBadge(
                                                  status: order.status,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Order Details
                          Expanded(
                            flex: 4,
                            child: selectedOrder != null
                                ? _PurchaseOrderDetails(order: selectedOrder!)
                                : const Center(
                                    child: Text(
                                      'Select an order to view details',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;

  const _SidebarMenuItem({
    required this.icon,
    required this.title,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.blueAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.white : Colors.grey[400]),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[400],
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        onTap: () {},
        dense: true,
        visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.amber;
        break;
      case 'processing':
        backgroundColor = Colors.blue;
        break;
      case 'delivered':
        backgroundColor = Colors.green;
        break;
      case 'cancelled':
        backgroundColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: backgroundColor),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: backgroundColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _PurchaseOrderDetails extends StatelessWidget {
  final PurchaseOrder order;

  const _PurchaseOrderDetails({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Text(
                  'Order ${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit Order'),
                    ),
                    const PopupMenuItem(
                      value: 'print',
                      child: Text('Print Order'),
                    ),
                    const PopupMenuItem(
                      value: 'export',
                      child: Text('Export as PDF'),
                    ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Text('Cancel Order'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Section
                  _SectionHeader(title: 'Order Summary'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.business_outlined,
                          title: 'Vendor',
                          value: order.vendorName,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.calendar_today_outlined,
                          title: 'Order Date',
                          value: DateFormat(
                            'MMM d, yyyy',
                          ).format(order.orderDate),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.local_shipping_outlined,
                          title: 'Expected Delivery',
                          value: order.expectedDeliveryDate != null
                              ? DateFormat(
                                  'MMM d, yyyy',
                                ).format(order.expectedDeliveryDate!)
                              : 'Not specified',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.payments_outlined,
                          title: 'Total Amount',
                          value: '\$${order.totalAmount.toStringAsFixed(2)}',
                          valueColor: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  // Order Items Section
                  _SectionHeader(title: 'Order Items'),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  'Item',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'SKU',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Qty',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Unit Price',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Total',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Table Items
                        ...order.items
                            .map(
                              (item) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(flex: 4, child: Text(item.name)),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        item.sku,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        item.quantity.toString(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '\$${item.unitPrice.toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '\$${item.total.toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        // Table Footer
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade200),
                            ),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Spacer(),
                              const Text(
                                'Total:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '\$${order.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Actions Section
                  _SectionHeader(title: 'Actions'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Order'),
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.receipt_outlined),
                        label: const Text('Generate Invoice'),
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.print_outlined),
                        label: const Text('Print Order'),
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Mark as Delivered'),
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Cancel Order',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Entry point
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProcureHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const PurchaseOrdersScreen(),
    );
  }
}

// Create Purchase Order Dialog
class CreatePurchaseOrderDialog extends ConsumerStatefulWidget {
  const CreatePurchaseOrderDialog({super.key});

  @override
  ConsumerState<CreatePurchaseOrderDialog> createState() =>
      _CreatePurchaseOrderDialogState();
}

class _CreatePurchaseOrderDialogState
    extends ConsumerState<CreatePurchaseOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _vendorController = TextEditingController();
  final _totalAmountController = TextEditingController();
  DateTime _orderDate = DateTime.now();
  DateTime? _expectedDeliveryDate;
  final List<PurchaseOrderItem> _items = [];

  @override
  void initState() {
    super.initState();
    // Generate a new PO ID
    _idController.text = 'PO-${DateTime.now().year}-${_generateRandomId()}';
  }

  String _generateRandomId() {
    return (100 + Random().nextInt(900)).toString();
  }

  @override
  void dispose() {
    _idController.dispose();
    _vendorController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(
        PurchaseOrderItem(
          id: 'ITEM-${_generateRandomId()}',
          name: '',
          quantity: 1,
          unitPrice: 0,
          sku: '',
        ),
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _updateTotalAmount();
  }

  void _updateTotalAmount() {
    double total = 0;
    for (var item in _items) {
      total += item.total;
    }
    _totalAmountController.text = total.toStringAsFixed(2);
  }

  void _saveOrder() {
    if (_formKey.currentState!.validate()) {
      final newOrder = PurchaseOrder(
        id: _idController.text,
        vendorName: _vendorController.text,
        orderDate: _orderDate,
        totalAmount: double.parse(_totalAmountController.text),
        status: 'Pending',
        items: _items,
        expectedDeliveryDate: _expectedDeliveryDate,
      );

      ref.read(purchaseOrdersProvider.notifier).addPurchaseOrder(newOrder);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create New Purchase Order',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Basic info section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          labelText: 'Purchase Order ID',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an ID';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _vendorController,
                        decoration: const InputDecoration(
                          labelText: 'Vendor Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a vendor name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dates section
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _orderDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _orderDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Order Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            DateFormat('MMM d, yyyy').format(_orderDate),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                _expectedDeliveryDate ??
                                DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _expectedDeliveryDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Expected Delivery Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _expectedDeliveryDate != null
                                ? DateFormat(
                                    'MMM d, yyyy',
                                  ).format(_expectedDeliveryDate!)
                                : 'Select a date',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Items section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                      onPressed: _addItem,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Items list
                if (_items.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'No items added. Click "Add Item" to add a new item.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      initialValue: _items[index].name,
                                      decoration: const InputDecoration(
                                        labelText: 'Item Name',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _items[index] = PurchaseOrderItem(
                                            id: _items[index].id,
                                            name: value,
                                            quantity: _items[index].quantity,
                                            unitPrice: _items[index].unitPrice,
                                            sku: _items[index].sku,
                                          );
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter an item name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      initialValue: _items[index].sku,
                                      decoration: const InputDecoration(
                                        labelText: 'SKU',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _items[index] = PurchaseOrderItem(
                                            id: _items[index].id,
                                            name: _items[index].name,
                                            quantity: _items[index].quantity,
                                            unitPrice: _items[index].unitPrice,
                                            sku: value,
                                          );
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: _items[index].quantity
                                          .toString(),
                                      decoration: const InputDecoration(
                                        labelText: 'Quantity',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _items[index] = PurchaseOrderItem(
                                            id: _items[index].id,
                                            name: _items[index].name,
                                            quantity: int.tryParse(value) ?? 0,
                                            unitPrice: _items[index].unitPrice,
                                            sku: _items[index].sku,
                                          );
                                        });
                                        _updateTotalAmount();
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        if (int.tryParse(value) == null ||
                                            int.parse(value) <= 0) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: _items[index].unitPrice
                                          .toString(),
                                      decoration: InputDecoration(
                                        labelText:
                                            'Unit Price (${_items[index].unitPrice})',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _items[index] = PurchaseOrderItem(
                                            id: _items[index].id,
                                            name: _items[index].name,
                                            quantity: _items[index].quantity,
                                            unitPrice:
                                                double.tryParse(value) ?? 0,
                                            sku: _items[index].sku,
                                          );
                                        });
                                        _updateTotalAmount();
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        if (double.tryParse(value) == null ||
                                            double.parse(value) <= 0) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Total',
                                        border: OutlineInputBorder(),
                                      ),
                                      child: Text(
                                        '\$${_items[index].total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeItem(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),

                // Total amount
                Row(
                  children: [
                    const Spacer(),
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        controller: _totalAmountController,
                        decoration: InputDecoration(
                          labelText:
                              'Total Amount (${_totalAmountController.value})',
                          border: OutlineInputBorder(),
                        ),
                        enabled: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _saveOrder,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text('Create Order'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dashboard Analytics widget
class PurchaseOrdersAnalytics extends StatelessWidget {
  final List<PurchaseOrder> orders;

  const PurchaseOrdersAnalytics({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final totalOrders = orders.length;
    final pendingOrders = orders
        .where((order) => order.status == 'Pending')
        .length;
    final processingOrders = orders
        .where((order) => order.status == 'Processing')
        .length;
    final deliveredOrders = orders
        .where((order) => order.status == 'Delivered')
        .length;
    final totalSpent = orders.fold(
      0.0,
      (sum, order) => sum + order.totalAmount,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Purchase Orders Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _AnalyticsCard(
                  title: 'Total Orders',
                  value: totalOrders.toString(),
                  icon: Icons.shopping_cart_outlined,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _AnalyticsCard(
                  title: 'Pending Orders',
                  value: pendingOrders.toString(),
                  icon: Icons.hourglass_empty,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _AnalyticsCard(
                  title: 'Processing Orders',
                  value: processingOrders.toString(),
                  icon: Icons.sync,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _AnalyticsCard(
                  title: 'Delivered Orders',
                  value: deliveredOrders.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Purchase Orders by Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 300,
                          child: _PurchaseOrderStatusChart(
                            pendingOrders: pendingOrders,
                            processingOrders: processingOrders,
                            deliveredOrders: deliveredOrders,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Spending Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: Colors.blue,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Spending',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${totalSpent.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Recent Vendors',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...orders
                            .take(3)
                            .map(
                              (order) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey.shade200,
                                      child: Text(
                                        order.vendorName.substring(0, 1),
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.vendorName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            DateFormat(
                                              'MMM d, yyyy',
                                            ).format(order.orderDate),
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '\$${order.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          child: const Text('View All Vendors'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade600)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.5),
                    color.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseOrderStatusChart extends StatelessWidget {
  final int pendingOrders;
  final int processingOrders;
  final int deliveredOrders;

  const _PurchaseOrderStatusChart({
    required this.pendingOrders,
    required this.processingOrders,
    required this.deliveredOrders,
  });

  @override
  Widget build(BuildContext context) {
    // Create a simple chart with colored boxes
    final total = pendingOrders + processingOrders + deliveredOrders;

    return total > 0
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 5),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            '$total',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        CustomPaint(
                          size: const Size(200, 200),
                          painter: DonutChartPainter(
                            segments: [
                              ChartSegment(pendingOrders / total, Colors.amber),
                              ChartSegment(
                                processingOrders / total,
                                Colors.purple,
                              ),
                              ChartSegment(
                                deliveredOrders / total,
                                Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatusLegendItem(
                    color: Colors.amber,
                    label: 'Pending',
                    value: pendingOrders,
                  ),
                  const SizedBox(width: 24),
                  _StatusLegendItem(
                    color: Colors.purple,
                    label: 'Processing',
                    value: processingOrders,
                  ),
                  const SizedBox(width: 24),
                  _StatusLegendItem(
                    color: Colors.green,
                    label: 'Delivered',
                    value: deliveredOrders,
                  ),
                ],
              ),
            ],
          )
        : const Center(child: Text('No orders available'));
  }
}

class ChartSegment {
  final double percentage;
  final Color color;

  ChartSegment(this.percentage, this.color);
}

class DonutChartPainter extends CustomPainter {
  final List<ChartSegment> segments;

  DonutChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2; // Start from top

    for (var segment in segments) {
      final sweepAngle = 2 * pi * segment.percentage;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20.0;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _StatusLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _StatusLegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($value)',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
