import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import 'create_sales_order_screen.dart';
import 'sales_order.dart';

class SalesOrderDetailScreen extends StatefulWidget {
  final String salesOrderId;

  const SalesOrderDetailScreen({super.key, required this.salesOrderId});

  @override
  _SalesOrderDetailScreenState createState() => _SalesOrderDetailScreenState();
}

class _SalesOrderDetailScreenState extends State<SalesOrderDetailScreen>
    with SingleTickerProviderStateMixin {
  final SalesOrderService _salesOrderService = SalesOrderService();
  SalesOrder? _salesOrder;
  bool _isLoading = true;
  final DateFormat _dateFormat = DateFormat('MMMM dd, yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSalesOrder();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSalesOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final salesOrder = await _salesOrderService.getSalesOrderById(
        widget.salesOrderId,
      );
      setState(() {
        _salesOrder = salesOrder;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load sales order details');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_salesOrder?.orderNumber ?? 'Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen
            },
            tooltip: 'Edit Order',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // Implement print functionality
            },
            tooltip: 'Print Invoice',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'email', child: Text('Email Invoice')),
              const PopupMenuItem(value: 'cancel', child: Text('Cancel Order')),
              const PopupMenuItem(
                value: 'duplicate',
                child: Text('Duplicate Order'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Items'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _salesOrder == null
          ? const Center(child: Text('Order not found'))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildItemsTab(),
                _buildHistoryTab(),
              ],
            ),
      bottomNavigationBar: _isLoading || _salesOrder == null
          ? null
          : BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${_currencyFormat.format(_salesOrder!.totalAmount)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Implement next status action
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(_getNextActionText()),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getNextActionText() {
    if (_salesOrder == null) return 'Process';

    switch (_salesOrder!.status.toLowerCase()) {
      case 'pending':
        return 'Process Order';
      case 'processing':
        return 'Mark as Completed';
      case 'completed':
        return 'Archive Order';
      default:
        return 'Process Order';
    }
  }

  Widget _buildOverviewTab() {
    final order = _salesOrder!;
    final customer = order.customer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              order.status,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(order.status),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildInfoRow('Order Number', order.orderNumber),
                    _buildInfoRow('Date', _dateFormat.format(order.orderDate)),
                    _buildInfoRow('Payment Method', order.paymentMethod),
                    _buildInfoRow('Shipping Method', order.shippingMethod),
                    if (order.notes.isNotEmpty)
                      _buildInfoRow('Notes', order.notes),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Subtotal',
                            _currencyFormat.format(order.subtotal),
                            Colors.blue.shade50,
                            Icons.shopping_cart_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            'Tax',
                            _currencyFormat.format(order.taxAmount),
                            Colors.amber.shade50,
                            Icons.receipt_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            'Shipping',
                            _currencyFormat.format(order.shippingAmount),
                            Colors.green.shade50,
                            Icons.local_shipping_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            'Total',
                            _currencyFormat.format(order.totalAmount),
                            Colors.purple.shade50,
                            Icons.attach_money,
                            isHighlighted: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTimeline(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              radius: 24,
                              child: Text(
                                customer.name.isNotEmpty
                                    ? customer.name[0]
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Customer ID: ${customer.id}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Contact Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildContactRow(Icons.email_outlined, customer.email!),
                        if (customer.phone!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildContactRow(
                            Icons.phone_outlined,
                            customer.phone!,
                          ),
                        ],
                        const SizedBox(height: 32),
                        const Text(
                          'Billing Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAddressBlock(customer.billingAddress!),
                        const SizedBox(height: 32),
                        const Text(
                          'Shipping Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAddressBlock(customer.shippingAddress!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActionButton(
                          'Print Invoice',
                          Icons.print,
                          Colors.blue,
                          () {
                            // Implement print functionality
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildActionButton(
                          'Email Invoice',
                          Icons.email_outlined,
                          Colors.green,
                          () {
                            // Implement email functionality
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildActionButton(
                          'Duplicate Order',
                          Icons.copy,
                          Colors.amber,
                          () {
                            // Implement duplicate functionality
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildActionButton(
                          'Cancel Order',
                          Icons.cancel_outlined,
                          Colors.red,
                          () {
                            // Implement cancel functionality
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    Color color,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 20 : 18,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildAddressBlock(String address) {
    return Text(address, style: const TextStyle(fontSize: 14));
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    // Sample timeline events
    final events = [
      {'status': 'Order Placed', 'date': 'Mar 15, 2025', 'time': '10:45 AM'},
      {
        'status': 'Payment Processed',
        'date': 'Mar 15, 2025',
        'time': '10:48 AM',
      },
      {'status': 'Processing', 'date': 'Mar 16, 2025', 'time': '9:30 AM'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isLast = index == events.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 40, color: Colors.blue.shade200),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['status']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event['date']} at ${event['time']}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  if (!isLast) const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemsTab() {
    final order = _salesOrder!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Items',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: order.items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No items in this order',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(5), // Product
                            1: FlexColumnWidth(1), // Quantity
                            2: FlexColumnWidth(2), // Unit Price
                            3: FlexColumnWidth(2), // Discount
                            4: FlexColumnWidth(2), // Total
                          },
                          border: TableBorder(
                            horizontalInside: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                              ),
                              children: [
                                _buildTableHeader('Product'),
                                _buildTableHeader('Qty'),
                                _buildTableHeader('Unit Price'),
                                _buildTableHeader('Discount'),
                                _buildTableHeader('Total'),
                              ],
                            ),
                            ...order.items
                                .map((item) => _buildItemRow(item))
                                .toList(),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildTotalRow(
                        'Subtotal',
                        _currencyFormat.format(order.subtotal),
                      ),
                      _buildTotalRow(
                        'Tax',
                        _currencyFormat.format(order.taxAmount),
                      ),
                      _buildTotalRow(
                        'Shipping',
                        _currencyFormat.format(order.shippingAmount),
                      ),
                      if (order.discountAmount > 0)
                        _buildTotalRow(
                          'Discount',
                          '- ${_currencyFormat.format(order.discountAmount)}',
                        ),
                      const SizedBox(height: 8),
                      _buildTotalRow(
                        'Total',
                        _currencyFormat.format(order.totalAmount),
                        isTotal: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  TableRow _buildItemRow(SalesOrderItem item) {
    return TableRow(
      children: [
        _buildTableCell(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item.product.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.product.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.grey.shade500,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${item.product.sku}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.notes,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildTableCell(
          Text(item.quantity.toString(), textAlign: TextAlign.center),
        ),
        _buildTableCell(
          Text(
            _currencyFormat.format(item.unitPrice),
            textAlign: TextAlign.right,
          ),
        ),
        _buildTableCell(
          Text(
            item.discountPercent > 0
                ? '${item.discountPercent.toStringAsFixed(1)}%'
                : '-',
            textAlign: TextAlign.right,
          ),
        ),
        _buildTableCell(
          Text(
            _currencyFormat.format(item.totalPrice),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: child,
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 18 : 16,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildHistoryTimeline(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTimeline() {
    // Sample history events
    final events = [
      {
        'date': 'Mar 15, 2025',
        'time': '10:45 AM',
        'title': 'Order Created',
        'description': 'Order #SO-12345 was created',
        'user': 'John Doe',
      },
      {
        'date': 'Mar 15, 2025',
        'time': '10:48 AM',
        'title': 'Payment Received',
        'description': 'Payment of \$1,234.56 was received via Credit Card',
        'user': 'System',
      },
      {
        'date': 'Mar 16, 2025',
        'time': '9:30 AM',
        'title': 'Status Updated',
        'description': 'Order status changed from Pending to Processing',
        'user': 'Jane Smith',
      },
      {
        'date': 'Mar 16, 2025',
        'time': '10:15 AM',
        'title': 'Note Added',
        'description': 'Customer requested expedited shipping',
        'user': 'Jane Smith',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isLast = index == events.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 60, color: Colors.blue.shade200),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${event['date']} at ${event['time']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event['description']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By: ${event['user']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (!isLast) const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

void main(List<String> args) {
  runApp(
    const ProviderScope(
      child: MaterialApp(home: SalesOrderDetailScreen(salesOrderId: '1')),
    ),
  );
}
