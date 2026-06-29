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
            itemBuilder: (context) => [
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
                    final customerInvoices = invoices
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
                    final customerInvoices = invoices
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
                                        builder: (context) =>
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
                                    builder: (context) =>
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
                            separatorBuilder: (context, index) =>
                                Divider(height: 1),
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
                    final customerInvoices = invoices
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
                            separatorBuilder: (context, index) =>
                                Divider(height: 1),
                            itemBuilder: (context, index) {
                              final payment = allPayments[index];
                              final relatedInvoice = customerInvoices
                                  .firstWhere(
                                    (inv) => inv.payments.contains(payment),
                                    orElse: () =>
                                        throw Exception('Invoice not found'),
                                  );

                              return PaymentListItem(
                                payment: payment,
                                invoiceNumber: relatedInvoice.invoiceNumber!,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InvoiceDetailScreen(
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
              builder: (context) =>
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
      builder: (context) => AlertDialog(
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
