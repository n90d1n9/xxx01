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
                      data: (invoices) => invoices.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Text(
                                  'No invoices found',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: invoices.length,
                              separatorBuilder: (context, index) => Divider(),
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
}
