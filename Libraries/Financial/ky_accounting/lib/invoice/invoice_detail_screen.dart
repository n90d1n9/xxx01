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
            itemBuilder: (context) => [
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
                    Text('Delete Invoice', style: TextStyle(color: Colors.red)),
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
                            orElse: () => Customer(
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
      builder: (context) => AlertDialog(
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
      builder: (context) => AlertDialog(
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Payment reminder sent')));
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
      builder: (context) => AlertDialog(
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
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
