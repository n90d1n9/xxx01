// Main Screen
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_filter_bar.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_icon_action_button.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_search_field.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

import '../../states/aging_bucket_provider.dart';
import '../../states/ar_summary_provider.dart';
import '../../states/customer_provider.dart';
import '../../states/invoice_filter_provider.dart';
import '../../states/invoice_provider.dart';
import '../../widgets/invoice_create.dart';
import '../../widgets/invoice_list_item.dart';

const _receivableStatusOptions = <AppFilterChipOption<String>>[
  AppFilterChipOption(value: 'all', label: 'All', icon: Icons.all_inclusive),
  AppFilterChipOption(
    value: 'pending',
    label: 'Pending',
    icon: Icons.schedule_outlined,
  ),
  AppFilterChipOption(
    value: 'partial',
    label: 'Partial',
    icon: Icons.timelapse_outlined,
  ),
  AppFilterChipOption(value: 'paid', label: 'Paid', icon: Icons.done_rounded),
  AppFilterChipOption(
    value: 'overdue',
    label: 'Overdue',
    icon: Icons.warning_amber_rounded,
  ),
];

const _receivableSortOptions = <AppSelectOption<ReceivableSort>>[
  AppSelectOption(
    value: ReceivableSort.dueDateAsc,
    label: 'Due date: oldest first',
  ),
  AppSelectOption(
    value: ReceivableSort.dueDateDesc,
    label: 'Due date: newest first',
  ),
  AppSelectOption(
    value: ReceivableSort.amountDesc,
    label: 'Balance: high to low',
  ),
  AppSelectOption(value: ReceivableSort.customerName, label: 'Customer name'),
];

class AccountsReceivableScreen extends ConsumerStatefulWidget {
  const AccountsReceivableScreen({super.key});

  @override
  ConsumerState<AccountsReceivableScreen> createState() =>
      _AccountsReceivableScreenState();
}

class _AccountsReceivableScreenState
    extends ConsumerState<AccountsReceivableScreen> {
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(receivableSearchProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredInvoices = ref.watch(filteredInvoicesProvider);
    final arSummary = ref.watch(arSummaryProvider);
    final agingBuckets = ref.watch(agingBucketsProvider);
    final selectedFilter = ref.watch(receivableStatusFilterProvider);
    final selectedSort = ref.watch(receivableSortProvider);
    final searchTerm = ref.watch(receivableSearchProvider);

    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Accounts Receivable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search invoices',
            onPressed: () {
              _searchFocusNode.requestFocus();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter and sort',
            onPressed:
                () => _showFilterSheet(context, selectedFilter, selectedSort),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReceivables,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            arSummary.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (summary) => _buildReceivableOverview(summary, formatter),
            ),

            const SizedBox(height: 24.0),

            AppContentPanel(
              title: 'Aging Analysis',
              leadingIcon: Icons.bar_chart_rounded,
              child: agingBuckets.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error: $err'),
                data: (buckets) => _buildAgingChart(buckets, formatter),
              ),
            ),

            const SizedBox(height: 24.0),

            AppContentPanel(
              title: 'Invoices',
              leadingIcon: Icons.receipt_long_rounded,
              trailing: Text(
                '${filteredInvoices.asData?.value.length ?? 0} shown',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInvoiceControls(
                    context,
                    selectedFilter,
                    selectedSort,
                    searchTerm,
                  ),
                  const SizedBox(height: 16.0),
                  filteredInvoices.when(
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text('Error: $err'),
                    data:
                        (invoices) =>
                            invoices.isEmpty
                                ? _buildInvoiceEmptyState(searchTerm)
                                : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: invoices.length,
                                  separatorBuilder:
                                      (context, index) => const Divider(),
                                  itemBuilder: (context, index) {
                                    final invoice = invoices[index];
                                    return InvoiceListItem(invoice: invoice);
                                  },
                                ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateInvoiceScreen()),
          );
        },
      ),
    );
  }

  Widget _buildReceivableOverview(
    Map<String, double> summary,
    NumberFormat formatter,
  ) {
    return AppMetricGrid(
      maxColumns: 3,
      metrics: [
        AppMetricGridItem(
          title: 'Total Receivable',
          value: formatter.format(summary['totalReceivable']),
          icon: Icons.account_balance_wallet,
          accentColor: Colors.indigo,
        ),
        AppMetricGridItem(
          title: 'Overdue',
          value: formatter.format(summary['totalOverdue']),
          icon: Icons.warning_rounded,
          accentColor: Colors.red,
        ),
        AppMetricGridItem(
          title: 'Paid (Last 30 days)',
          value: formatter.format(summary['totalPaid']),
          icon: Icons.check_circle,
          accentColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildInvoiceEmptyState(String searchTerm) {
    return AppEmptyState(
      icon: Icons.receipt_long_outlined,
      title:
          searchTerm.isEmpty
              ? 'No invoices found'
              : 'No invoices match "$searchTerm"',
      message:
          searchTerm.isEmpty
              ? 'Create an invoice or refresh receivables to review customer balances.'
              : 'Try a broader invoice, reference, customer, or email search.',
    );
  }

  Future<void> _refreshReceivables() async {
    ref.invalidate(invoicesProvider);
    ref.invalidate(customersProvider);
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Widget _buildInvoiceControls(
    BuildContext context,
    String selectedFilter,
    ReceivableSort selectedSort,
    String searchTerm, {
    bool includeSearch = true,
  }) {
    return AppFilterBar(
      contained: false,
      search:
          includeSearch
              ? AppSearchField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: 'Search invoice, reference, customer, email',
                height: 48,
                trailing:
                    searchTerm.isEmpty
                        ? null
                        : AppIconActionButton(
                          icon: Icons.clear,
                          tooltip: 'Clear receivable search',
                          size: 32,
                          iconSize: 18,
                          onPressed: () {
                            _searchController.clear();
                            ref.read(receivableSearchProvider.notifier).state =
                                '';
                          },
                        ),
                onChanged:
                    (value) =>
                        ref.read(receivableSearchProvider.notifier).state =
                            value,
              )
              : null,
      filters: [
        AppFilterChipGroup<String>(
          value: selectedFilter,
          options: _receivableStatusOptions,
          onChanged:
              (value) =>
                  ref.read(receivableStatusFilterProvider.notifier).state =
                      value,
        ),
      ],
      trailing: [
        AppSelectField<ReceivableSort>(
          label: 'Sort by',
          icon: Icons.sort,
          value: selectedSort,
          options: _receivableSortOptions,
          onChanged:
              (value) =>
                  ref.read(receivableSortProvider.notifier).state = value,
        ),
      ],
      compactBreakpoint: includeSearch ? 760 : double.infinity,
    );
  }

  Widget _buildAgingChart(Map<String, double> buckets, NumberFormat formatter) {
    if (buckets.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No aging data available')),
      );
    }

    final maxValue = buckets.values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue == 0 ? 1 : maxValue * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final bucketName = buckets.keys.elementAt(groupIndex);
                return BarTooltipItem(
                  '$bucketName\n${formatter.format(rod.toY)}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: const FlTitlesData(show: true),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            buckets.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: buckets.values.elementAt(index),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context,
    String selectedFilter,
    ReceivableSort selectedSort,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter and Sort',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildInvoiceControls(
                  context,
                  selectedFilter,
                  selectedSort,
                  ref.read(receivableSearchProvider),
                  includeSearch: false,
                ),
              ],
            ),
          ),
    );
  }
}
