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
              data: (summary) => Wrap(
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
                      data: (buckets) => Container(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY:
                                buckets.values.reduce((a, b) => a > b ? a : b) *
                                1.2,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                //tooltipBgColor: Colors.blueGrey,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  String bucketName = buckets.keys.elementAt(
                                    groupIndex,
                                  );
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
                          loading: () =>
                              Center(child: CircularProgressIndicator()),
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
      width: MediaQuery.of(context).size.width > 600
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
                  backgroundColor: isInvoice
                      ? Colors.blue[100]
                      : Colors.green[100],
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
                            orElse: () => Customer(
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
                        builder: (context) =>
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
