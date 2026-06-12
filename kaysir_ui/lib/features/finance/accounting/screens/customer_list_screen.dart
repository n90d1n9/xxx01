import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_filter_bar.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_icon_action_button.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_search_field.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

import '../models/customer.dart';
import '../states/customer_account_provider.dart';
import '../states/customer_provider.dart';
import '../states/invoice_provider.dart';
import 'customer_detail_screen.dart';

const _customerRiskFilterOptions = <AppFilterChipOption<CustomerRiskFilter>>[
  AppFilterChipOption(
    value: CustomerRiskFilter.all,
    label: 'All',
    icon: Icons.all_inclusive,
  ),
  AppFilterChipOption(
    value: CustomerRiskFilter.openBalance,
    label: 'Open Balance',
    icon: Icons.account_balance_wallet_rounded,
  ),
  AppFilterChipOption(
    value: CustomerRiskFilter.overdue,
    label: 'Overdue',
    icon: Icons.warning_amber_rounded,
  ),
  AppFilterChipOption(
    value: CustomerRiskFilter.clear,
    label: 'Clear',
    icon: Icons.done_all_rounded,
  ),
];

const _customerSortOptions = <AppSelectOption<CustomerSort>>[
  AppSelectOption(value: CustomerSort.balanceDesc, label: 'Open balance'),
  AppSelectOption(value: CustomerSort.overdueDesc, label: 'Overdue balance'),
  AppSelectOption(value: CustomerSort.nameAsc, label: 'Customer name'),
  AppSelectOption(
    value: CustomerSort.invoiceCountDesc,
    label: 'Open invoice count',
  ),
];

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(customerSearchProvider),
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
    final summariesAsync = ref.watch(customerAccountSummariesProvider);
    final searchTerm = ref.watch(customerSearchProvider);
    final riskFilter = ref.watch(customerRiskFilterProvider);
    final selectedSort = ref.watch(customerSortProvider);
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search customers',
            onPressed: () => _searchFocusNode.requestFocus(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter and sort',
            onPressed:
                () => _showFilterSheet(context, riskFilter, selectedSort),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCustomers,
        child: summariesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data:
              (summaries) => AppListSurface(
                metrics: _buildCustomerOverview(summaries, currencyFormat),
                filters: _buildControls(
                  context,
                  riskFilter,
                  selectedSort,
                  searchTerm,
                ),
                emptyState: _buildEmptyState(context, searchTerm),
                children: [
                  for (final summary in summaries)
                    _buildCustomerCard(context, summary, currencyFormat),
                ],
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Customer',
        child: const Icon(Icons.person_add_alt_1_rounded),
        onPressed: () => _showAddCustomerDialog(context),
      ),
    );
  }

  Future<void> _refreshCustomers() async {
    ref.invalidate(customersProvider3);
    ref.invalidate(customersProvider);
    ref.invalidate(invoicesProvider);
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Widget _buildCustomerOverview(
    List<CustomerAccountSummary> summaries,
    NumberFormat currencyFormat,
  ) {
    final totalBalance = summaries.fold(
      0.0,
      (sum, summary) => sum + summary.totalBalance,
    );
    final overdueBalance = summaries.fold(
      0.0,
      (sum, summary) => sum + summary.overdueBalance,
    );
    final overdueCustomers = summaries.where((summary) => summary.hasOverdue);

    return AppMetricGrid(
      maxColumns: 3,
      metrics: [
        AppMetricGridItem(
          title: 'Customers',
          value: summaries.length.toString(),
          icon: Icons.people_alt_rounded,
          accentColor: Colors.indigo,
        ),
        AppMetricGridItem(
          title: 'Open Balance',
          value: currencyFormat.format(totalBalance),
          icon: Icons.account_balance_wallet_rounded,
          accentColor: Colors.blue,
        ),
        AppMetricGridItem(
          title: 'Overdue',
          value: currencyFormat.format(overdueBalance),
          icon: Icons.warning_rounded,
          accentColor: Colors.red,
          helper: '${overdueCustomers.length} customers',
        ),
      ],
    );
  }

  Widget _buildControls(
    BuildContext context,
    CustomerRiskFilter riskFilter,
    CustomerSort selectedSort,
    String searchTerm, {
    bool includeSearch = true,
  }) {
    return AppFilterBar(
      search:
          includeSearch
              ? AppSearchField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: 'Search name, email, or phone',
                height: 48,
                trailing:
                    searchTerm.isEmpty
                        ? null
                        : AppIconActionButton(
                          icon: Icons.clear,
                          tooltip: 'Clear customer search',
                          size: 32,
                          iconSize: 18,
                          onPressed: () {
                            _searchController.clear();
                            ref.read(customerSearchProvider.notifier).state =
                                '';
                          },
                        ),
                onChanged:
                    (value) =>
                        ref.read(customerSearchProvider.notifier).state = value,
              )
              : null,
      filters: [
        AppFilterChipGroup<CustomerRiskFilter>(
          value: riskFilter,
          options: _customerRiskFilterOptions,
          onChanged:
              (value) =>
                  ref.read(customerRiskFilterProvider.notifier).state = value,
        ),
      ],
      trailing: [
        AppSelectField<CustomerSort>(
          label: 'Sort by',
          icon: Icons.sort_rounded,
          value: selectedSort,
          options: _customerSortOptions,
          onChanged:
              (value) => ref.read(customerSortProvider.notifier).state = value,
        ),
      ],
      compactBreakpoint: includeSearch ? 760 : double.infinity,
    );
  }

  Widget _buildCustomerCard(
    BuildContext context,
    CustomerAccountSummary summary,
    NumberFormat currencyFormat,
  ) {
    final customer = summary.customer;

    return Card(
      elevation: 2.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CustomerDetailScreen(customerId: customer.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              customer.name,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildStatusPill(summary),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          customer.email,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          customer.phone,
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 10.0),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.receipt_long_rounded,
                    '${summary.openInvoiceCount} open invoices',
                  ),
                  _buildInfoChip(
                    Icons.account_balance_wallet_rounded,
                    currencyFormat.format(summary.totalBalance),
                  ),
                  if (summary.hasOverdue)
                    _buildInfoChip(
                      Icons.warning_rounded,
                      '${summary.overdueInvoiceCount} overdue',
                      color: Colors.red,
                    ),
                  if (summary.nextDueDate != null)
                    _buildInfoChip(
                      Icons.event_available_rounded,
                      'Next due ${DateFormat('MMM d').format(summary.nextDueDate!)}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(CustomerAccountSummary summary) {
    final label =
        summary.hasOverdue
            ? 'Overdue'
            : summary.hasOpenBalance
            ? 'Open'
            : 'Clear';
    final MaterialColor color =
        summary.hasOverdue
            ? Colors.red
            : summary.hasOpenBalance
            ? Colors.blue
            : Colors.green;

    return AppStatusPill(
      label: label,
      color: color.shade700,
      backgroundColor: color.shade100,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      textStyle: TextStyle(
        color: color.shade700,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label, {
    MaterialColor color = Colors.blue,
  }) {
    return AppStatusPill(
      label: label,
      icon: icon,
      color: color.shade700,
      backgroundColor: color.withValues(alpha: 0.08),
      borderColor: Colors.transparent,
      borderRadius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      textStyle: TextStyle(
        color: color.shade700,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String searchTerm) {
    return AppSurface(
      padding: EdgeInsets.zero,
      child: AppEmptyState(
        icon: Icons.people_alt_outlined,
        title:
            searchTerm.isEmpty
                ? 'No customers found'
                : 'No customers match "$searchTerm"',
        message:
            searchTerm.isEmpty
                ? 'Create a customer or refresh the list to bring account balances into view.'
                : 'Try a broader name, email, or phone search.',
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context,
    CustomerRiskFilter riskFilter,
    CustomerSort selectedSort,
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
                _buildControls(
                  context,
                  riskFilter,
                  selectedSort,
                  ref.read(customerSearchProvider),
                  includeSearch: false,
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _showAddCustomerDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    try {
      await showDialog<void>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Add Customer'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      validator:
                          (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter a name'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_rounded),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator:
                          (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter an email'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone_rounded),
                      ),
                      keyboardType: TextInputType.phone,
                      validator:
                          (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter a phone number'
                                  : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save'),
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final customer = Customer(
                      id: 'C-${DateTime.now().microsecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                    );

                    ref.read(customersProvider3.notifier).addCustomer(customer);
                    ref.read(customersProvider.notifier).addCustomer(customer);
                    Navigator.pop(context);
                    if (!mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('${customer.name} added'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
      );
    } finally {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
    }
  }
}
