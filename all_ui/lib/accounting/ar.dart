import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });
}

class Invoice {
  final String id;
  final String customerId;
  final double amount;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<Payment> payments;
  final String status;

  final String? invoiceNumber; // 'paid', 'partial', 'overdue', 'pending'

  Invoice({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.issueDate,
    required this.dueDate,
    required this.payments,
    required this.status,
    this.invoiceNumber,
  });

  double get paidAmount =>
      payments.fold(0, (sum, payment) => sum + payment.amount);
  double get remainingAmount => amount - paidAmount;
  bool get isOverdue => dueDate.isBefore(DateTime.now()) && remainingAmount > 0;
  int get daysOverdue =>
      isOverdue ? DateTime.now().difference(dueDate).inDays : 0;
}

class Payment {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime date;
  final String method; // 'credit_card', 'bank_transfer', 'cash', etc.

  Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.date,
    required this.method,
  });
}

// Providers
final customersProvider = FutureProvider<List<Customer>>((ref) async {
  // Simulate API call
  await Future.delayed(Duration(seconds: 1));
  return [
    Customer(
      id: '1',
      name: 'Acme Corp',
      email: 'accounts@acme.com',
      phone: '555-123-4567',
    ),
    Customer(
      id: '2',
      name: 'Wayne Enterprises',
      email: 'finance@wayne.com',
      phone: '555-987-6543',
    ),
    Customer(
      id: '3',
      name: 'Stark Industries',
      email: 'ar@stark.com',
      phone: '555-789-0123',
    ),
    Customer(
      id: '4',
      name: 'Umbrella Corp',
      email: 'billing@umbrella.com',
      phone: '555-456-7890',
    ),
  ];
});

final invoicesProvider = FutureProvider<List<Invoice>>((ref) async {
  // Simulate API call
  await Future.delayed(Duration(seconds: 1));
  final now = DateTime.now();
  return [
    Invoice(
      id: 'INV-001',
      customerId: '1',
      amount: 5000.00,
      issueDate: now.subtract(Duration(days: 30)),
      dueDate: now.subtract(Duration(days: 15)),
      payments: [
        Payment(
          id: 'PAY-001',
          invoiceId: 'INV-001',
          amount: 2500.00,
          date: now.subtract(Duration(days: 20)),
          method: 'bank_transfer',
        ),
      ],
      status: 'partial',
    ),
    Invoice(
      id: 'INV-002',
      customerId: '2',
      amount: 7500.00,
      issueDate: now.subtract(Duration(days: 20)),
      dueDate: now.add(Duration(days: 10)),
      payments: [],
      status: 'pending',
    ),
    Invoice(
      id: 'INV-003',
      customerId: '3',
      amount: 12000.00,
      issueDate: now.subtract(Duration(days: 45)),
      dueDate: now.subtract(Duration(days: 15)),
      payments: [
        Payment(
          id: 'PAY-002',
          invoiceId: 'INV-003',
          amount: 12000.00,
          date: now.subtract(Duration(days: 10)),
          method: 'credit_card',
        ),
      ],
      status: 'paid',
    ),
    Invoice(
      id: 'INV-004',
      customerId: '1',
      amount: 3000.00,
      issueDate: now.subtract(Duration(days: 60)),
      dueDate: now.subtract(Duration(days: 30)),
      payments: [],
      status: 'overdue',
    ),
    Invoice(
      id: 'INV-005',
      customerId: '4',
      amount: 8500.00,
      issueDate: now.subtract(Duration(days: 15)),
      dueDate: now.add(Duration(days: 15)),
      payments: [
        Payment(
          id: 'PAY-003',
          invoiceId: 'INV-005',
          amount: 4250.00,
          date: now.subtract(Duration(days: 5)),
          method: 'bank_transfer',
        ),
      ],
      status: 'partial',
    ),
  ];
});

final selectedFilterProvider = StateProvider<String>((ref) => 'all');

final filteredInvoicesProvider = Provider<AsyncValue<List<Invoice>>>((ref) {
  final invoicesAsync = ref.watch(invoicesProvider);
  final filter = ref.watch(selectedFilterProvider);

  return invoicesAsync.whenData((invoices) {
    switch (filter) {
      case 'paid':
        return invoices.where((invoice) => invoice.status == 'paid').toList();
      case 'partial':
        return invoices
            .where((invoice) => invoice.status == 'partial')
            .toList();
      case 'pending':
        return invoices
            .where((invoice) => invoice.status == 'pending')
            .toList();
      case 'overdue':
        return invoices
            .where((invoice) => invoice.status == 'overdue')
            .toList();
      default:
        return invoices;
    }
  });
});

final arSummaryProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final invoicesAsync = ref.watch(invoicesProvider);

  return invoicesAsync.whenData((invoices) {
    double totalReceivable = 0;
    double totalOverdue = 0;
    double totalPaid = 0;

    for (final invoice in invoices) {
      totalPaid += invoice.paidAmount;
      totalReceivable += invoice.remainingAmount;

      if (invoice.isOverdue) {
        totalOverdue += invoice.remainingAmount;
      }
    }

    return {
      'totalReceivable': totalReceivable,
      'totalOverdue': totalOverdue,
      'totalPaid': totalPaid,
    };
  });
});

// Aging buckets provider
final agingBucketsProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final invoicesAsync = ref.watch(invoicesProvider);

  return invoicesAsync.whenData((invoices) {
    final Map<String, double> agingBuckets = {
      'current': 0,
      '1-30': 0,
      '31-60': 0,
      '61-90': 0,
      '90+': 0,
    };

    for (final invoice in invoices) {
      if (invoice.remainingAmount <= 0) continue;

      if (!invoice.isOverdue) {
        agingBuckets['current'] =
            agingBuckets['current']! + invoice.remainingAmount;
      } else if (invoice.daysOverdue <= 30) {
        agingBuckets['1-30'] = agingBuckets['1-30']! + invoice.remainingAmount;
      } else if (invoice.daysOverdue <= 60) {
        agingBuckets['31-60'] =
            agingBuckets['31-60']! + invoice.remainingAmount;
      } else if (invoice.daysOverdue <= 90) {
        agingBuckets['61-90'] =
            agingBuckets['61-90']! + invoice.remainingAmount;
      } else {
        agingBuckets['90+'] = agingBuckets['90+']! + invoice.remainingAmount;
      }
    }

    return agingBuckets;
  });
});

// Main Screen
class AccountsReceivableScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredInvoices = ref.watch(filteredInvoicesProvider);
    final arSummary = ref.watch(arSummaryProvider);
    final agingBuckets = ref.watch(agingBucketsProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);

    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Accounts Receivable'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement advanced filtering
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(invoicesProvider);
          ref.refresh(customersProvider);
        },
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            // Summary Cards
            arSummary.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data:
                  (summary) => Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: [
                      _buildSummaryCard(
                        context,
                        'Total Receivable',
                        formatter.format(summary['totalReceivable']),
                        Colors.indigo,
                        Icons.account_balance_wallet,
                      ),
                      _buildSummaryCard(
                        context,
                        'Overdue',
                        formatter.format(summary['totalOverdue']),
                        Colors.red,
                        Icons.warning_rounded,
                      ),
                      _buildSummaryCard(
                        context,
                        'Paid (Last 30 days)',
                        formatter.format(summary['totalPaid']),
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ],
                  ),
            ),

            SizedBox(height: 24.0),

            // Aging Chart
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aging Analysis',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    agingBuckets.when(
                      loading: () => Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
                      data:
                          (buckets) => Container(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY:
                                    buckets.values.reduce(
                                      (a, b) => a > b ? a : b,
                                    ) *
                                    1.2,
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    //tooltipBgColor: Colors.blueGrey,
                                    getTooltipItem: (
                                      group,
                                      groupIndex,
                                      rod,
                                      rodIndex,
                                    ) {
                                      String bucketName = buckets.keys
                                          .elementAt(groupIndex);
                                      return BarTooltipItem(
                                        '$bucketName\n${formatter.format(rod.toY)}',
                                        TextStyle(color: Colors.white),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  /* bottomTitles: SideTitles(
                                showTitles: true,
                                getTextStyles: (context, value) => TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                margin: 10,
                                getTitles: (double value) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return 'Current';
                                    case 1:
                                      return '1-30';
                                    case 2:
                                      return '31-60';
                                    case 3:
                                      return '61-90';
                                    case 4:
                                      return '90+';
                                    default:
                                      return '';
                                  }
                                },
                              ),
                              leftTitles: SideTitles(
                                showTitles: true,
                                getTextStyles: (context, value) => TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                ),
                                margin: 10,
                              ), */
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(
                                  buckets.length,
                                  (index) => BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: buckets.values.elementAt(index),
                                        /* colors: [
                                      index == 0 ? Colors.green : 
                                      index == 1 ? Colors.orange[300]! : 
                                      index == 2 ? Colors.orange[600]! :
                                      index == 3 ? Colors.deepOrange : 
                                      Colors.red,
                                    ], */
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.0),

            // Invoice Filter
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invoices',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedFilter,

                          // Completion of the dropdown filter
                          onChanged: (value) {
                            ref.read(selectedFilterProvider.notifier).state =
                                value!;
                          },
                          items: [
                            DropdownMenuItem(value: 'all', child: Text('All')),
                            DropdownMenuItem(
                              value: 'paid',
                              child: Text('Paid'),
                            ),
                            DropdownMenuItem(
                              value: 'partial',
                              child: Text('Partial'),
                            ),
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'overdue',
                              child: Text('Overdue'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),

                    // Invoice List
                    filteredInvoices.when(
                      loading: () => Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
                      data:
                          (invoices) =>
                              invoices.isEmpty
                                  ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20.0,
                                      ),
                                      child: Text(
                                        'No invoices found',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  )
                                  : ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: invoices.length,
                                    separatorBuilder:
                                        (context, index) => Divider(),
                                    itemBuilder: (context, index) {
                                      final invoice = invoices[index];
                                      return InvoiceListItem(invoice: invoice);
                                    },
                                  ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // TODO: Navigate to create invoice screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateInvoiceScreen()),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      width:
          MediaQuery.of(context).size.width > 600
              ? (MediaQuery.of(context).size.width - 48) / 3
              : MediaQuery.of(context).size.width - 32,
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                  ),
                  Icon(icon, color: color),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Invoice List Item
class InvoiceListItem extends ConsumerWidget {
  final Invoice invoice;

  const InvoiceListItem({Key? key, required this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceDetailScreen(invoiceId: invoice.id),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusIndicator(invoice.status),
            SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        invoice.id,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatter.format(invoice.amount),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  customersAsync.when(
                    loading: () => Text('Loading...'),
                    error: (err, stack) => Text('Error loading customer'),
                    data: (customers) {
                      final customer = customers.firstWhere(
                        (c) => c.id == invoice.customerId,
                        orElse:
                            () => Customer(
                              id: '',
                              name: 'Unknown Customer',
                              email: '',
                              phone: '',
                            ),
                      );
                      return Text(customer.name);
                    },
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Due: ${DateFormat('MMM d, yyyy').format(invoice.dueDate)}',
                        style: TextStyle(
                          color:
                              invoice.isOverdue ? Colors.red : Colors.grey[600],
                          fontSize: 12.0,
                        ),
                      ),
                      Text(
                        invoice.isOverdue
                            ? '${invoice.daysOverdue} days overdue'
                            : _getStatusText(invoice.status),
                        style: TextStyle(
                          color:
                              invoice.isOverdue ? Colors.red : Colors.grey[600],
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  if (invoice.paidAmount > 0 && invoice.remainingAmount > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: LinearProgressIndicator(
                        value: invoice.paidAmount / invoice.amount,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status) {
      case 'paid':
        color = Colors.green;
        break;
      case 'partial':
        color = Colors.blue;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'overdue':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 12.0,
      height: 12.0,
      margin: EdgeInsets.only(top: 4.0),
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'partial':
        return 'Partially Paid';
      case 'pending':
        return 'Pending Payment';
      case 'overdue':
        return 'Overdue';
      default:
        return status.toUpperCase();
    }
  }
}

// Invoice Detail Screen
class InvoiceDetailScreen extends ConsumerWidget {
  final String invoiceId;

  const InvoiceDetailScreen({Key? key, required this.invoiceId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider);
    final customersAsync = ref.watch(customersProvider);
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Invoice Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  // TODO: Navigate to edit invoice screen
                  break;
                case 'delete':
                  _showDeleteConfirmation(context);
                  break;
                case 'send':
                  _showSendConfirmation(context);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit Invoice'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'send',
                    child: Row(
                      children: [
                        Icon(Icons.send, size: 18),
                        SizedBox(width: 8),
                        Text('Send Reminder'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Delete Invoice',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: invoicesAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (invoices) {
          final invoice = invoices.firstWhere(
            (inv) => inv.id == invoiceId,
            orElse: () => throw Exception('Invoice not found'),
          );

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              // Invoice Header Card
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            invoice.id,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildStatusChip(invoice.status),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      customersAsync.when(
                        loading: () => Text('Loading...'),
                        error: (err, stack) => Text('Error loading customer'),
                        data: (customers) {
                          final customer = customers.firstWhere(
                            (c) => c.id == invoice.customerId,
                            orElse:
                                () => Customer(
                                  id: '',
                                  name: 'Unknown Customer',
                                  email: '',
                                  phone: '',
                                ),
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                customer.name,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                customer.email,
                                style: TextStyle(fontSize: 14.0),
                              ),
                              SizedBox(height: 2.0),
                              Text(
                                customer.phone,
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.0),

              // Invoice Details Card
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice Details',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      _buildDetailRow(
                        'Total Amount',
                        formatter.format(invoice.amount),
                      ),
                      _buildDetailRow(
                        'Issued Date',
                        DateFormat('MMMM d, yyyy').format(invoice.issueDate),
                      ),
                      _buildDetailRow(
                        'Due Date',
                        DateFormat('MMMM d, yyyy').format(invoice.dueDate),
                      ),
                      _buildDetailRow(
                        'Status',
                        _getFullStatusText(invoice.status),
                      ),
                      if (invoice.isOverdue)
                        _buildDetailRow(
                          'Days Overdue',
                          '${invoice.daysOverdue}',
                          isAlert: true,
                        ),
                      _buildDetailRow(
                        'Amount Paid',
                        formatter.format(invoice.paidAmount),
                      ),
                      _buildDetailRow(
                        'Amount Due',
                        formatter.format(invoice.remainingAmount),
                      ),

                      if (invoice.paidAmount > 0 && invoice.remainingAmount > 0)
                        Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Progress',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8.0),
                              LinearProgressIndicator(
                                value: invoice.paidAmount / invoice.amount,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                                minHeight: 10.0,
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                '${(invoice.paidAmount / invoice.amount * 100).toStringAsFixed(1)}% paid',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.0),

              // Payments Card
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment History',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (invoice.remainingAmount > 0)
                            ElevatedButton(
                              child: Text('Record Payment'),
                              onPressed: () {
                                // TODO: Show payment recording dialog
                                _showRecordPaymentDialog(context, invoice);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      invoice.payments.isEmpty
                          ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'No payments recorded',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          )
                          : ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: invoice.payments.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (context, index) {
                              final payment = invoice.payments[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(formatter.format(payment.amount)),
                                subtitle: Text(
                                  _capitalizeMethod(payment.method),
                                ),
                                trailing: Text(
                                  DateFormat(
                                    'MMM d, yyyy',
                                  ).format(payment.date),
                                ),
                                leading: Icon(
                                  _getPaymentIcon(payment.method),
                                  color: Colors.green,
                                ),
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'paid':
        color = Colors.green;
        label = 'Paid';
        break;
      case 'partial':
        color = Colors.blue;
        label = 'Partial';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'overdue':
        color = Colors.red;
        label = 'Overdue';
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 4.0),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAlert = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14.0),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isAlert ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getFullStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'partial':
        return 'Partially Paid';
      case 'pending':
        return 'Pending Payment';
      case 'overdue':
        return 'Overdue';
      default:
        return status.toUpperCase();
    }
  }

  String _capitalizeMethod(String method) {
    return method
        .split('_')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'credit_card':
        return Icons.credit_card;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Invoice'),
            content: Text(
              'Are you sure you want to delete this invoice? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  // TODO: Implement delete functionality
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Return to invoices list
                },
              ),
            ],
          ),
    );
  }

  void _showSendConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Send Payment Reminder'),
            content: Text('Send a payment reminder to the customer?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Send'),
                onPressed: () {
                  // TODO: Implement send functionality
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment reminder sent')),
                  );
                },
              ),
            ],
          ),
    );
  }

  void _showRecordPaymentDialog(BuildContext context, Invoice invoice) {
    final formKey = GlobalKey<FormState>();
    double? amount;
    String method = 'bank_transfer';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Record Payment'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final paymentAmount = double.tryParse(value);
                      if (paymentAmount == null) {
                        return 'Please enter a valid amount';
                      }
                      if (paymentAmount <= 0) {
                        return 'Amount must be greater than zero';
                      }
                      if (paymentAmount > invoice.remainingAmount) {
                        return 'Amount cannot exceed ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(invoice.remainingAmount)}';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      amount = double.parse(value!);
                    },
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Payment Method'),
                    value: method,
                    onChanged: (value) {
                      method = value!;
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'bank_transfer',
                        child: Text('Bank Transfer'),
                      ),
                      DropdownMenuItem(
                        value: 'credit_card',
                        child: Text('Credit Card'),
                      ),
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Save'),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    // TODO: Implement payment recording functionality
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Payment recorded')));
                  }
                },
              ),
            ],
          ),
    );
  }
}

// Create Invoice Screen
class CreateInvoiceScreen extends ConsumerStatefulWidget {
  @override
  _CreateInvoiceScreenState createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCustomerId;
  double? amount;
  DateTime issueDate = DateTime.now();
  DateTime dueDate = DateTime.now().add(Duration(days: 30));
  List<Map<String, dynamic>> items = [];

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text('Create Invoice')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice Details',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    customersAsync.when(
                      loading: () => CircularProgressIndicator(),
                      error: (err, stack) => Text('Error: $err'),
                      data:
                          (customers) => DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Customer',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedCustomerId,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a customer';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                selectedCustomerId = value;
                              });
                            },
                            items:
                                customers.map((customer) {
                                  return DropdownMenuItem(
                                    value: customer.id,
                                    child: Text(customer.name),
                                  );
                                }).toList(),
                          ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            icon: Icon(Icons.calendar_today),
                            label: Text(
                              'Issue Date: ${DateFormat('MMM d, yyyy').format(issueDate)}',
                            ),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: issueDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null && picked != issueDate) {
                                setState(() {
                                  issueDate = picked;
                                  // Update due date if it's before the issue date
                                  if (dueDate.isBefore(issueDate)) {
                                    dueDate = issueDate.add(Duration(days: 30));
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            icon: Icon(Icons.calendar_today),
                            label: Text(
                              'Due Date: ${DateFormat('MMM d, yyyy').format(dueDate)}',
                            ),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: dueDate,
                                firstDate: issueDate,
                                lastDate: DateTime(2030),
                              );
                              if (picked != null && picked != dueDate) {
                                setState(() {
                                  dueDate = picked;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.0),

            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invoice Items',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text('Add Item'),
                          onPressed: _showAddItemDialog,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    items.isEmpty
                        ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              'No items added yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                        : ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item['description']),
                              subtitle: Text(
                                '${item['quantity']} x ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(item['unitPrice'])}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'en_US',
                                      symbol: '\$',
                                    ).format(
                                      item['quantity'] * item['unitPrice'],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        items.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    if (items.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Total: ',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'en_US',
                                symbol: '\$',
                              ).format(
                                items.fold(
                                  0.0,
                                  (sum, item) =>
                                      sum +
                                      (item['quantity'] * item['unitPrice']),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Create Invoice',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate() && items.isNotEmpty) {
              // TODO: Create invoice and navigate back
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invoice created successfully')),
              );
              Navigator.pop(context);
            } else if (items.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please add at least one item')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    final formKey = GlobalKey<FormState>();
    String description = '';
    int quantity = 1;
    double unitPrice = 0.0;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add Item'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      description = value!;
                    },
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    initialValue: '1',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quantity';
                      }
                      final qty = int.tryParse(value);
                      if (qty == null || qty <= 0) {
                        return 'Quantity must be a positive number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      quantity = int.parse(value!);
                    },
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Unit Price',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a unit price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Price must be a positive number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      unitPrice = double.parse(value!);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Add'),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    setState(() {
                      items.add({
                        'description': description,
                        'quantity': quantity,
                        'unitPrice': unitPrice,
                      });
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
    );
  }
}

// Dashboard Widget
class ARDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arSummary = ref.watch(arSummaryProvider);
    final agingBuckets = ref.watch(agingBucketsProvider);

    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text('AR Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(invoicesProvider);
          ref.refresh(customersProvider);
        },
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            // Summary Cards
            arSummary.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data:
                  (summary) => Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: [
                      _buildSummaryCard(
                        context,
                        'Total Receivable',
                        formatter.format(summary['totalReceivable']),
                        Colors.indigo,
                        Icons.account_balance_wallet,
                      ),
                      _buildSummaryCard(
                        context,
                        'Overdue',
                        formatter.format(summary['totalOverdue']),
                        Colors.red,
                        Icons.warning_rounded,
                      ),
                      _buildSummaryCard(
                        context,
                        'Paid (Last 30 days)',
                        formatter.format(summary['totalPaid']),
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ],
                  ),
            ),

            SizedBox(height: 24.0),

            // Aging Chart
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aging Analysis',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    agingBuckets.when(
                      loading: () => Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
                      data:
                          (buckets) => Container(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY:
                                    buckets.values.reduce(
                                      (a, b) => a > b ? a : b,
                                    ) *
                                    1.2,
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    //tooltipBgColor: Colors.blueGrey,
                                    getTooltipItem: (
                                      group,
                                      groupIndex,
                                      rod,
                                      rodIndex,
                                    ) {
                                      String bucketName = buckets.keys
                                          .elementAt(groupIndex);
                                      return BarTooltipItem(
                                        '$bucketName\n${formatter.format(rod.toY)}',
                                        TextStyle(color: Colors.white),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  /* bottomTitles: SideTitles(
                                showTitles: true,
                                getTextStyles: (context, value) => TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                margin: 10,
                                getTitles: (double value) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return 'Current';
                                    case 1:
                                      return '1-30';
                                    case 2:
                                      return '31-60';
                                    case 3:
                                      return '61-90';
                                    case 4:
                                      return '90+';
                                    default:
                                      return '';
                                  }
                                },
                              ), */
                                  /* leftTitles: SideTitles(
                                showTitles: true,
                                getTextStyles: (context, value) => TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                ),
                                margin: 10,
                              ), */
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(
                                  buckets.length,
                                  (index) => BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: buckets.values.elementAt(index),
                                        color: Colors.orange[300],
                                        /* [
                                      index == 0 ? Colors.green : 
                                      index == 1 ? Colors.orange[300]! : 
                                      index == 2 ? Colors.orange[600]! :
                                      index == 3 ? Colors.deepOrange : 
                                      Colors.red,
                                    ] */
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.0),

            // Recent Activity
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ref
                        .watch(invoicesProvider)
                        .when(
                          loading:
                              () => Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text('Error: $err'),
                          data: (invoices) {
                            final recentInvoices =
                                invoices
                                    .where(
                                      (inv) => inv.issueDate.isAfter(
                                        DateTime.now().subtract(
                                          Duration(days: 30),
                                        ),
                                      ),
                                    )
                                    .toList()
                                  ..sort(
                                    (a, b) =>
                                        b.issueDate.compareTo(a.issueDate),
                                  );

                            final recentPayments =
                                invoices
                                    .expand((inv) => inv.payments)
                                    .where(
                                      (payment) => payment.date.isAfter(
                                        DateTime.now().subtract(
                                          Duration(days: 30),
                                        ),
                                      ),
                                    )
                                    .toList()
                                  ..sort((a, b) => b.date.compareTo(a.date));

                            return Column(
                              children: [
                                _buildActivityList(
                                  context,
                                  recentInvoices
                                      .take(5)
                                      .map(
                                        (inv) => {
                                          'date': inv.issueDate,
                                          'type': 'invoice',
                                          'amount': inv.amount,
                                          'id': inv.id,
                                          'customerId': inv.customerId,
                                        },
                                      )
                                      .toList(),
                                  recentPayments
                                      .take(5)
                                      .map(
                                        (payment) => {
                                          'date': payment.date,
                                          'type': 'payment',
                                          'amount': payment.amount,
                                          'id': payment.id,
                                          'invoiceId': payment.invoiceId,
                                        },
                                      )
                                      .toList(),
                                  ref,
                                ),
                              ],
                            );
                          },
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      width:
          MediaQuery.of(context).size.width > 600
              ? (MediaQuery.of(context).size.width - 48) / 3
              : MediaQuery.of(context).size.width - 32,
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                  ),
                  Icon(icon, color: color),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(
    BuildContext context,
    List<Map<String, dynamic>> recentInvoices,
    List<Map<String, dynamic>> recentPayments,
    WidgetRef ref,
  ) {
    final allActivities = [...recentInvoices, ...recentPayments];
    allActivities.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    final customersAsync = ref.watch(customersProvider);
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return allActivities.isEmpty
        ? Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'No recent activity',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        )
        : ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: allActivities.length > 10 ? 10 : allActivities.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            final activity = allActivities[index];
            final isInvoice = activity['type'] == 'invoice';

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor:
                    isInvoice ? Colors.blue[100] : Colors.green[100],
                child: Icon(
                  isInvoice ? Icons.description : Icons.payment,
                  color: isInvoice ? Colors.blue : Colors.green,
                ),
              ),
              title: Text(
                isInvoice
                    ? 'Invoice ${activity['id']} issued'
                    : 'Payment received for ${activity['invoiceId']}',
              ),
              subtitle: Row(
                children: [
                  Text(DateFormat('MMM d, yyyy').format(activity['date'])),
                  SizedBox(width: 8.0),
                  if (isInvoice && activity['customerId'] != null)
                    customersAsync.when(
                      loading: () => Text('Loading...'),
                      error: (err, stack) => Text('Error'),
                      data: (customers) {
                        final customer = customers.firstWhere(
                          (c) => c.id == activity['customerId'],
                          orElse:
                              () => Customer(
                                id: '',
                                name: 'Unknown',
                                email: '',
                                phone: '',
                              ),
                        );
                        return Text('• ${customer.name}');
                      },
                    ),
                ],
              ),
              trailing: Text(
                formatter.format(activity['amount']),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isInvoice ? Colors.blue[700] : Colors.green[700],
                ),
              ),
              onTap: () {
                if (isInvoice) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              InvoiceDetailScreen(invoiceId: activity['id']),
                    ),
                  );
                }
              },
            );
          },
        );
  }
}

// Customer List Screen
class CustomerListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);
    final invoicesAsync = ref.watch(invoicesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Customers'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(customersProvider);
          ref.refresh(invoicesProvider);
        },
        child: customersAsync.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data:
              (customers) => ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];

                  return Card(
                    elevation: 2.0,
                    margin: EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CustomerDetailScreen(
                                  customerId: customer.id,
                                ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12.0),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                customer.name.isNotEmpty
                                    ? customer.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    customer.email,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  invoicesAsync.when(
                                    loading: () => Text('Loading...'),
                                    error: (err, stack) => Text('Error'),
                                    data: (invoices) {
                                      final customerInvoices =
                                          invoices
                                              .where(
                                                (inv) =>
                                                    inv.customerId ==
                                                    customer.id,
                                              )
                                              .toList();
                                      final totalReceivable = customerInvoices
                                          .fold(
                                            0.0,
                                            (sum, inv) =>
                                                sum + inv.remainingAmount,
                                          );
                                      final hasOverdue = customerInvoices.any(
                                        (inv) => inv.isOverdue,
                                      );

                                      return Row(
                                        children: [
                                          Text(
                                            'Invoices: ${customerInvoices.length}',
                                            style: TextStyle(fontSize: 12.0),
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            'Balance: ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(totalReceivable)}',
                                            style: TextStyle(fontSize: 12.0),
                                          ),
                                          if (hasOverdue)
                                            Container(
                                              margin: EdgeInsets.only(
                                                left: 8.0,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6.0,
                                                vertical: 2.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.red[100],
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Text(
                                                'Overdue',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // TODO: Navigate to create customer screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      CreateInvoiceScreen(), //customerId: customer.id),
            ),
          );
        },
      ),
    );
  }
}

// Customer Detail Screen
class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({Key? key, required this.customerId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);
    final invoicesAsync = ref.watch(invoicesProvider);
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Customer Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to Edit Customer screen
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation(context);
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Delete Customer',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(customersProvider);
          ref.refresh(invoicesProvider);
        },
        child: customersAsync.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (customers) {
            final customer = customers.firstWhere(
              (c) => c.id == customerId,
              orElse: () => throw Exception('Customer not found'),
            );

            return ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                // Customer Profile Card
                Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                customer.name.isEmpty
                                    ? '?'
                                    : customer.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.email,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4.0),
                                      Text(
                                        customer.email,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.0),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4.0),
                                      Text(
                                        customer.phone,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: Icons.email,
                              label: 'Email',
                              onPressed: () {
                                // TODO: Open email client
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.phone,
                              label: 'Call',
                              onPressed: () {
                                // TODO: Open phone app
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.message,
                              label: 'Message',
                              onPressed: () {
                                // TODO: Open messaging app
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.0),

                // Account Summary Card
                invoicesAsync.when(
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (invoices) {
                    final customerInvoices =
                        invoices
                            .where((inv) => inv.customerId == customer.id)
                            .toList();
                    final totalAmount = customerInvoices.fold(
                      0.0,
                      (sum, inv) => sum + inv.amount,
                    );
                    final totalPaid = customerInvoices.fold(
                      0.0,
                      (sum, inv) => sum + inv.paidAmount,
                    );
                    final totalDue = customerInvoices.fold(
                      0.0,
                      (sum, inv) => sum + inv.remainingAmount,
                    );
                    final overdueAmount = customerInvoices
                        .where((inv) => inv.isOverdue)
                        .fold(0.0, (sum, inv) => sum + inv.remainingAmount);

                    return Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Summary',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoColumn(
                                  'Total Invoiced',
                                  formatter.format(totalAmount),
                                ),
                                _buildInfoColumn(
                                  'Total Paid',
                                  formatter.format(totalPaid),
                                ),
                                _buildInfoColumn(
                                  'Total Due',
                                  formatter.format(totalDue),
                                  isHighlighted: totalDue > 0,
                                ),
                              ],
                            ),
                            if (overdueAmount > 0) ...[
                              SizedBox(height: 16.0),
                              Container(
                                padding: EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning, color: Colors.red),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Overdue Amount: ${formatter.format(overdueAmount)}',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 16.0),

                // Invoices List
                invoicesAsync.when(
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (invoices) {
                    final customerInvoices =
                        invoices
                            .where((inv) => inv.customerId == customer.id)
                            .toList();

                    if (customerInvoices.isEmpty) {
                      return Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16.0),
                                Text(
                                  'No invoices yet',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.add),
                                  label: Text('Create Invoice'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                CreateInvoiceScreen(), //customerId: customer.id),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Invoices',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: Icon(Icons.add, size: 18),
                              label: Text('New Invoice'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            CreateInvoiceScreen(), //customerId: customer.id),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Card(
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: customerInvoices.length,
                            separatorBuilder:
                                (context, index) => Divider(height: 1),
                            itemBuilder: (context, index) {
                              final invoice = customerInvoices[index];
                              return InvoiceListItem(
                                invoice: invoice,
                                /* onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InvoiceDetailScreen(invoiceId: invoice.id),
                                    ),
                                  );
                                }, */
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 16.0),

                // Payment History
                invoicesAsync.when(
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (invoices) {
                    final customerInvoices =
                        invoices
                            .where((inv) => inv.customerId == customer.id)
                            .toList();

                    // Get all payments from all invoices
                    final allPayments =
                        customerInvoices.expand((inv) => inv.payments).toList()
                          ..sort(
                            (a, b) => b.date.compareTo(a.date),
                          ); // Sort by date, newest first

                    if (allPayments.isEmpty) {
                      return SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment History',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Card(
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: allPayments.length,
                            separatorBuilder:
                                (context, index) => Divider(height: 1),
                            itemBuilder: (context, index) {
                              final payment = allPayments[index];
                              final relatedInvoice = customerInvoices
                                  .firstWhere(
                                    (inv) => inv.payments.contains(payment),
                                    orElse:
                                        () =>
                                            throw Exception(
                                              'Invoice not found',
                                            ),
                                  );

                              return PaymentListItem(
                                payment: payment,
                                invoiceNumber: relatedInvoice.invoiceNumber!,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => InvoiceDetailScreen(
                                            invoiceId: relatedInvoice.id,
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_chart),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      CreateInvoiceScreen(), //customerId: customer.id),
            ),
          );
        },
        tooltip: 'Create Invoice',
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue),
            SizedBox(height: 4.0),
            Text(label, style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
        SizedBox(height: 4.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Customer'),
            content: Text(
              'Are you sure you want to delete this customer? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  // TODO: Implement delete functionality
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to customers list
                },
              ),
            ],
          ),
    );
  }
}

// Invoice List Item Widget
/* class InvoiceListItem extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;

  const InvoiceListItem({Key? key, required this.invoice, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      title: Text(
        'Invoice #${invoice.invoiceNumber}',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.0),
          Text(
            'Due: ${DateFormat('MMM d, yyyy').format(invoice.dueDate)}',
            style: TextStyle(
              color: invoice.isOverdue ? Colors.red : Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.0),
          Row(
            children: [
              _buildStatusBadge(invoice.status),
              SizedBox(width: 8.0),
              Text(
                invoice.description,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatter.format(invoice.amount),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          SizedBox(height: 4.0),
          if (invoice.remainingAmount > 0)
            Text(
              'Due: ${formatter.format(invoice.remainingAmount)}',
              style: TextStyle(
                color: invoice.isOverdue ? Colors.red : Colors.grey[600],
                fontWeight:
                    invoice.isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            )
          else
            Text(
              'Paid',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(InvoiceStatus status) {
    Color color;
    String text;

    switch (status) {
      case InvoiceStatus.draft:
        color = Colors.grey;
        text = 'Draft';
        break;
      case InvoiceStatus.sent:
        color = Colors.blue;
        text = 'Sent';
        break;
      case InvoiceStatus.partiallyPaid:
        color = Colors.orange;
        text = 'Partial';
        break;
      case InvoiceStatus.paid:
        color = Colors.green;
        text = 'Paid';
        break;
      case InvoiceStatus.overdue:
        color = Colors.red;
        text = 'Overdue';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: Colors.yellow),
      ),
      child: Text(
        'text',
        style: TextStyle(
          color: Colors.amberAccent,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} */

// Payment List Item Widget
class PaymentListItem extends StatelessWidget {
  final Payment payment;
  final String invoiceNumber;
  final VoidCallback onTap;

  const PaymentListItem({
    Key? key,
    required this.payment,
    required this.invoiceNumber,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: CircleAvatar(
        backgroundColor: Colors.green[100],
        child: Icon(Icons.attach_money, color: Colors.green),
      ),
      title: Text(
        'Payment received',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.0),
          Text(
            'Invoice #${invoiceNumber}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 4.0),
          Text(
            'Date: ${DateFormat('MMM d, yyyy').format(payment.date)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 4.0),
          Text(
            'Method: ${payment.method}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
      trailing: Text(
        formatter.format(payment.amount),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
          color: Colors.green,
        ),
      ),
    );
  }
}

void main() {
  runApp(ProviderScope(child: MaterialApp(home: ARDashboardScreen())));
}
