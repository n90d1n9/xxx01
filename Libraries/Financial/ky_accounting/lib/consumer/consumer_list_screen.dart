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
          data: (customers) => ListView.builder(
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
                        builder: (context) =>
                            CustomerDetailScreen(customerId: customer.id),
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
                                  final customerInvoices = invoices
                                      .where(
                                        (inv) => inv.customerId == customer.id,
                                      )
                                      .toList();
                                  final totalReceivable = customerInvoices.fold(
                                    0.0,
                                    (sum, inv) => sum + inv.remainingAmount,
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
                                          margin: EdgeInsets.only(left: 8.0),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.0,
                                            vertical: 2.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red[100],
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
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
              builder: (context) =>
                  CreateInvoiceScreen(), //customerId: customer.id),
            ),
          );
        },
      ),
    );
  }
}
