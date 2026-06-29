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
                        orElse: () => Customer(
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
                          color: invoice.isOverdue
                              ? Colors.red
                              : Colors.grey[600],
                          fontSize: 12.0,
                        ),
                      ),
                      Text(
                        invoice.isOverdue
                            ? '${invoice.daysOverdue} days overdue'
                            : _getStatusText(invoice.status),
                        style: TextStyle(
                          color: invoice.isOverdue
                              ? Colors.red
                              : Colors.grey[600],
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
