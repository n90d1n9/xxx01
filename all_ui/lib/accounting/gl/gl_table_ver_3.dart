import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'models/ledger_filter.dart';
import 'models/ledger_trx.dart';
import 'states/filter_provider.dart';
import 'states/ledger_provider.dart';

class GeneralLedgerScreen extends ConsumerWidget {
  const GeneralLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(ledgerFilterProvider);
    final transactions = ref.watch(filteredLedgerProvider(filter));
    final ledgerNotifier = ref.read(ledgerProvider.notifier);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('General Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded),
            tooltip: 'Filter Transactions',
            onPressed: () => _showFilterDialog(context, ref, filter),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export Data',
            onPressed: () => _showExportDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        child: const Icon(Icons.add),
        onPressed: () => _showAddTransactionDialog(context, ref),
      ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Summary',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        'Total Debits',
                        ledgerNotifier.getTotalDebit(),
                        Icons.arrow_upward_rounded,
                        Colors.green.shade700,
                        isDarkMode
                            ? Colors.green.shade900
                            : Colors.green.shade50,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        'Total Credits',
                        ledgerNotifier.getTotalCredit(),
                        Icons.arrow_downward_rounded,
                        Colors.red.shade700,
                        isDarkMode ? Colors.red.shade900 : Colors.red.shade50,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        'Net Balance',
                        ledgerNotifier.getNetBalance(),
                        ledgerNotifier.getNetBalance() >= 0
                            ? Icons.account_balance_wallet_rounded
                            : Icons.warning_rounded,
                        ledgerNotifier.getNetBalance() >= 0
                            ? Colors.blue.shade700
                            : Colors.orange.shade700,
                        isDarkMode
                            ? (ledgerNotifier.getNetBalance() >= 0
                                ? Colors.blue.shade900
                                : Colors.orange.shade900)
                            : (ledgerNotifier.getNetBalance() >= 0
                                ? Colors.blue.shade50
                                : Colors.orange.shade50),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Chips (if any active)
          if (filter.hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildActiveFilters(context, ref, filter),
            ),

          // Transactions Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${transactions.length} entries',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Ledger Table
          Expanded(
            child:
                transactions.isEmpty
                    ? _buildEmptyState(context)
                    : _buildTransactionsTable(context, ref, transactions),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double amount,
    IconData icon,
    Color iconColor,
    Color backgroundColor,
  ) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(symbol: '\$');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formatter.format(amount),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilters(
    BuildContext context,
    WidgetRef ref,
    LedgerFilter filter,
  ) {
    final filterNotifier = ref.read(ledgerFilterProvider.notifier);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (filter.startDate != null)
          Chip(
            label: Text(
              'From: ${DateFormat('MMM d, y').format(filter.startDate!)}',
            ),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              filterNotifier.state = filter.copyWith(startDate: null);
            },
          ),
        if (filter.endDate != null)
          Chip(
            label: Text(
              'To: ${DateFormat('MMM d, y').format(filter.endDate!)}',
            ),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              filterNotifier.state = filter.copyWith(endDate: null);
            },
          ),
        if (filter.account != null && filter.account!.isNotEmpty)
          Chip(
            label: Text('Account: ${filter.account}'),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              filterNotifier.state = filter.copyWith(account: null);
            },
          ),
        if (filter.category != null && filter.category!.isNotEmpty)
          Chip(
            label: Text('Category: ${filter.category}'),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              filterNotifier.state = filter.copyWith(category: null);
            },
          ),
        if (filter.searchTerm != null && filter.searchTerm!.isNotEmpty)
          Chip(
            label: Text('Search: ${filter.searchTerm}'),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              filterNotifier.state = filter.copyWith(searchTerm: null);
            },
          ),
        TextButton.icon(
          icon: const Icon(Icons.clear_all, size: 16),
          label: const Text('Clear All'),
          onPressed: () {
            filterNotifier.state = LedgerFilter();
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or add a new transaction',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTable(
    BuildContext context,
    WidgetRef ref,
    List<LedgerTransaction> transactions,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            horizontalMargin: 16,
            headingRowHeight: 50,
            dataRowMinHeight: 60,
            dataRowMaxHeight: 60,
            headingRowColor: MaterialStateProperty.all(
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            dividerThickness: 1,
            showCheckboxColumn: false,
            columns: [
              DataColumn(
                label: _buildColumnHeader(context, 'Date'),
                tooltip: 'Transaction Date',
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Account'),
                tooltip: 'Account Name',
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Description'),
                tooltip: 'Transaction Description',
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Type'),
                tooltip: 'Transaction Type',
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Amount'),
                tooltip: 'Transaction Amount',
                numeric: true,
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Reference'),
                tooltip: 'Reference Number',
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Category'),
                tooltip: 'Transaction Category',
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Actions'),
                tooltip: 'Actions',
              ),
            ],
            rows:
                transactions.map((transaction) {
                  return DataRow(
                    onSelectChanged:
                        (_) =>
                            _showTransactionDetails(context, ref, transaction),
                    cells: [
                      DataCell(
                        Text(
                          DateFormat('MMM d, y').format(transaction.date),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      DataCell(
                        Text(
                          transaction.account,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            transaction.description,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      DataCell(
                        Chip(
                          label: Text(
                            transaction.type.name,
                            style: TextStyle(
                              color:
                                  transaction.type == TransactionType.debit
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor:
                              transaction.type == TransactionType.debit
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      DataCell(
                        Text(
                          transaction.formattedAmount,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                transaction.type == TransactionType.debit
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          transaction.reference,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              transaction.category,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            transaction.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getCategoryColor(transaction.category),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_rounded,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              tooltip: 'Edit Transaction',
                              onPressed:
                                  () => _showEditTransactionDialog(
                                    context,
                                    ref,
                                    transaction,
                                  ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_rounded,
                                size: 20,
                                color: theme.colorScheme.error,
                              ),
                              tooltip: 'Delete Transaction',
                              onPressed:
                                  () =>
                                      _confirmDelete(context, ref, transaction),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildColumnHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Color _getCategoryColor(String category) {
    // Create a deterministic color based on the category name
    final int hash = category.hashCode;

    final List<Color> categoryColors = [
      Colors.blue.shade700,
      Colors.purple.shade700,
      Colors.indigo.shade700,
      Colors.teal.shade700,
      Colors.amber.shade700,
      Colors.deepOrange.shade700,
      Colors.pink.shade700,
      Colors.cyan.shade700,
    ];

    return categoryColors[hash.abs() % categoryColors.length];
  }

  void _showTransactionDetails(
    BuildContext context,
    WidgetRef ref,
    LedgerTransaction transaction,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction Details',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                'Date',
                DateFormat('MMMM d, y').format(transaction.date),
                Icons.calendar_today_rounded,
              ),
              _buildDetailRow(
                context,
                'Account',
                transaction.account,
                Icons.account_balance_rounded,
              ),
              _buildDetailRow(
                context,
                'Description',
                transaction.description,
                Icons.description_rounded,
              ),
              _buildDetailRow(
                context,
                'Type',
                transaction.type.name,
                transaction.type == TransactionType.debit
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                valueColor:
                    transaction.type == TransactionType.debit
                        ? Colors.green.shade700
                        : Colors.red.shade700,
              ),
              _buildDetailRow(
                context,
                'Amount',
                transaction.formattedAmount,
                Icons.attach_money_rounded,
                valueColor:
                    transaction.type == TransactionType.debit
                        ? Colors.green.shade700
                        : Colors.red.shade700,
              ),
              _buildDetailRow(
                context,
                'Reference',
                transaction.reference,
                Icons.numbers_rounded,
              ),
              _buildDetailRow(
                context,
                'Category',
                transaction.category,
                Icons.category_rounded,
                valueColor: _getCategoryColor(transaction.category),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditTransactionDialog(
                        context,
                        ref,
                        // Provider.containerOf(context).read(Provider),
                        transaction,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Duplicate'),
                    onPressed: () {
                      Navigator.pop(context);
                      _duplicateTransaction(
                        context,
                        ref,
                        //Provider.containerOf(context).read(Provider),
                        transaction,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    WidgetRef ref,
    LedgerFilter currentFilter,
  ) {
    final theme = Theme.of(context);
    DateTime? startDate = currentFilter.startDate;
    DateTime? endDate = currentFilter.endDate;
    String? account = currentFilter.account;
    String? category = currentFilter.category;
    String? searchTerm = currentFilter.searchTerm;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.filter_alt_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text('Filter Transactions'),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date Range',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateFilterField(
                              context,
                              'Start Date',
                              startDate,
                              (date) => setState(() => startDate = date),
                              clearDate: () => setState(() => startDate = null),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateFilterField(
                              context,
                              'End Date',
                              endDate,
                              (date) => setState(() => endDate = date),
                              clearDate: () => setState(() => endDate = null),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Transaction Filters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Account',
                          hintText: 'Filter by account name',
                          prefixIcon: const Icon(Icons.account_balance_rounded),
                          suffixIcon:
                              account != null && account!.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed:
                                        () => setState(() => account = null),
                                  )
                                  : null,
                          border: const OutlineInputBorder(),
                        ),
                        controller: TextEditingController(text: account),
                        onChanged:
                            (value) => account = value.isEmpty ? null : value,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          hintText: 'Filter by category',
                          prefixIcon: const Icon(Icons.category_rounded),
                          suffixIcon:
                              category != null && category!.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed:
                                        () => setState(() => category = null),
                                  )
                                  : null,
                          border: const OutlineInputBorder(),
                        ),
                        controller: TextEditingController(text: category),
                        onChanged:
                            (value) => category = value.isEmpty ? null : value,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Search',
                          hintText: 'Search in description or reference',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon:
                              searchTerm != null && searchTerm!.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed:
                                        () => setState(() => searchTerm = null),
                                  )
                                  : null,
                          border: const OutlineInputBorder(),
                        ),
                        controller: TextEditingController(text: searchTerm),
                        onChanged:
                            (value) =>
                                searchTerm = value.isEmpty ? null : value,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reset'),
                  onPressed: () {
                    setState(() {
                      startDate = null;
                      endDate = null;
                      account = null;
                      category = null;
                      searchTerm = null;
                    });
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Apply'),
                  onPressed: () {
                    ref
                        .read(ledgerFilterProvider.notifier)
                        .state = LedgerFilter(
                      startDate: startDate,
                      endDate: endDate,
                      account: account,
                      category: category,
                      searchTerm: searchTerm,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateFilterField(
    BuildContext context,
    String label,
    DateTime? date,
    Function(DateTime?) onDateChanged, {
    required Function() clearDate,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(colorScheme: theme.colorScheme),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? DateFormat('MMM d, y').format(date) : label,
                style: TextStyle(
                  color:
                      date != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            if (date != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: clearDate,
              ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.download_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Export Ledger Data'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose a format to export your ledger data:',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              _buildExportOption(
                context,
                'Excel Spreadsheet (.xlsx)',
                Icons.table_chart_rounded,
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildExportOption(
                context,
                'CSV File (.csv)',
                Icons.insert_drive_file_rounded,
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildExportOption(
                context,
                'PDF Document (.pdf)',
                Icons.picture_as_pdf_rounded,
                Colors.red,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExportOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exporting ledger data as $title'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final accountController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final referenceController = TextEditingController();
    final categoryController = TextEditingController();
    TransactionType type = TransactionType.debit;

    // Get available accounts and categories for suggestions
    final ledgerNotifier = ref.read(ledgerProvider.notifier);
    final accounts = ledgerNotifier.getUniqueAccounts();
    final categories = ledgerNotifier.getUniqueCategories();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.add_circle_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text('Add New Transaction'),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction Details',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Date field
                        TextFormField(
                          controller: dateController,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(
                              Icons.calendar_today_rounded,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit_calendar_rounded),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  dateController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(date);
                                }
                              },
                            ),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a date';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Account field with autocomplete
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return accounts;
                            }
                            return accounts.where(
                              (account) => account.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                            );
                          },
                          onSelected: (String selection) {
                            accountController.text = selection;
                          },
                          fieldViewBuilder: (
                            context,
                            controller,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            accountController.text = controller.text;
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Account',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.account_balance_rounded),
                              ),
                              onChanged: (value) {
                                accountController.text = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an account';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Description field
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Type dropdown
                        DropdownButtonFormField<TransactionType>(
                          value: type,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.swap_vert_rounded),
                          ),
                          items:
                              TransactionType.values.map((
                                TransactionType type,
                              ) {
                                return DropdownMenuItem<TransactionType>(
                                  value: type,
                                  child: Row(
                                    children: [
                                      Icon(
                                        type == TransactionType.debit
                                            ? Icons.arrow_upward_rounded
                                            : Icons.arrow_downward_rounded,
                                        color:
                                            type == TransactionType.debit
                                                ? Colors.green
                                                : Colors.red,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(type.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (TransactionType? newValue) {
                            if (newValue != null) {
                              setState(() {
                                type = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Amount field
                        TextFormField(
                          controller: amountController,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.attach_money_rounded),
                            prefixText: '\$ ',
                            suffixIcon: Icon(
                              type == TransactionType.debit
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color:
                                  type == TransactionType.debit
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Reference field
                        TextFormField(
                          controller: referenceController,
                          decoration: const InputDecoration(
                            labelText: 'Reference',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a reference';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Category field with autocomplete
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return categories;
                            }
                            return categories.where(
                              (category) => category.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                            );
                          },
                          onSelected: (String selection) {
                            categoryController.text = selection;
                          },
                          fieldViewBuilder: (
                            context,
                            controller,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            categoryController.text = controller.text;
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category_rounded),
                              ),
                              onChanged: (value) {
                                categoryController.text = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a category';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newTransaction = LedgerTransaction(
                        date: DateFormat(
                          'yyyy-MM-dd',
                        ).parse(dateController.text),
                        account: accountController.text,
                        description: descriptionController.text,
                        type: type,
                        amount: double.parse(amountController.text),
                        reference: referenceController.text,
                        category: categoryController.text,
                      );

                      ref
                          .read(ledgerProvider.notifier)
                          .addTransaction(newTransaction);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction added successfully'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTransactionDialog(
    BuildContext context,
    WidgetRef ref,
    LedgerTransaction transaction,
  ) {
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(transaction.date),
    );
    final accountController = TextEditingController(text: transaction.account);
    final descriptionController = TextEditingController(
      text: transaction.description,
    );
    final amountController = TextEditingController(
      text: transaction.amount.toString(),
    );
    final referenceController = TextEditingController(
      text: transaction.reference,
    );
    final categoryController = TextEditingController(
      text: transaction.category,
    );
    var type = transaction.type;

    // Get available accounts and categories for suggestions
    final ledgerNotifier = ref.read(ledgerProvider.notifier);
    final accounts = ledgerNotifier.getUniqueAccounts();
    final categories = ledgerNotifier.getUniqueCategories();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text('Edit Transaction'),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction Details',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Date field
                        TextFormField(
                          controller: dateController,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(
                              Icons.calendar_today_rounded,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit_calendar_rounded),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: transaction.date,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  dateController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(date);
                                }
                              },
                            ),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a date';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Account field with autocomplete
                        Autocomplete<String>(
                          initialValue: TextEditingValue(
                            text: transaction.account,
                          ),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return accounts;
                            }
                            return accounts.where(
                              (account) => account.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                            );
                          },
                          onSelected: (String selection) {
                            accountController.text = selection;
                          },
                          fieldViewBuilder: (
                            context,
                            controller,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            // Set initial value if controller is empty
                            if (controller.text.isEmpty) {
                              controller.text = transaction.account;
                            }
                            accountController.text = controller.text;

                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Account',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.account_balance_rounded),
                              ),
                              onChanged: (value) {
                                accountController.text = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an account';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Description field
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Type dropdown
                        DropdownButtonFormField<TransactionType>(
                          value: type,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.swap_vert_rounded),
                          ),
                          items:
                              TransactionType.values.map((
                                TransactionType value,
                              ) {
                                return DropdownMenuItem<TransactionType>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      Icon(
                                        value == TransactionType.debit
                                            ? Icons.arrow_upward_rounded
                                            : Icons.arrow_downward_rounded,
                                        color:
                                            value == TransactionType.debit
                                                ? Colors.green
                                                : Colors.red,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(value.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (TransactionType? newValue) {
                            if (newValue != null) {
                              setState(() {
                                type = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Amount field
                        TextFormField(
                          controller: amountController,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.attach_money_rounded),
                            prefixText: '\$ ',
                            suffixIcon: Icon(
                              type == TransactionType.debit
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color:
                                  type == TransactionType.debit
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Reference field
                        TextFormField(
                          controller: referenceController,
                          decoration: const InputDecoration(
                            labelText: 'Reference',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a reference';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Category field with autocomplete
                        Autocomplete<String>(
                          initialValue: TextEditingValue(
                            text: transaction.category,
                          ),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return categories;
                            }
                            return categories.where(
                              (category) => category.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ),
                            );
                          },
                          onSelected: (String selection) {
                            categoryController.text = selection;
                          },
                          fieldViewBuilder: (
                            context,
                            controller,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            // Set initial value if controller is empty
                            if (controller.text.isEmpty) {
                              controller.text = transaction.category;
                            }
                            categoryController.text = controller.text;

                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category_rounded),
                              ),
                              onChanged: (value) {
                                categoryController.text = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a category';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Update'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final updatedTransaction = transaction.copyWith(
                        date: DateFormat(
                          'yyyy-MM-dd',
                        ).parse(dateController.text),
                        account: accountController.text,
                        description: descriptionController.text,
                        type: type,
                        amount: double.parse(amountController.text),
                        reference: referenceController.text,
                        category: categoryController.text,
                      );

                      ref
                          .read(ledgerProvider.notifier)
                          .updateTransaction(updatedTransaction);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction updated successfully'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LedgerTransaction transaction,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.delete_forever_rounded,
                color: theme.colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Confirm Deletion'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this transaction?',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: .5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMM d, y').format(transaction.date),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Chip(
                            label: Text(
                              transaction.type.name,
                              style: TextStyle(
                                color:
                                    transaction.type == TransactionType.debit
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor:
                                transaction.type == TransactionType.debit
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                      const Divider(),
                      Text(
                        transaction.description,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Account: ${transaction.account}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Amount: ${transaction.formattedAmount}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              transaction.type == TransactionType.debit
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This action cannot be undone.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              icon: const Icon(Icons.delete_rounded, size: 18),
              label: const Text('Delete'),
              onPressed: () {
                ref
                    .read(ledgerProvider.notifier)
                    .deleteTransaction(transaction.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Transaction deleted'),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        ref
                            .read(ledgerProvider.notifier)
                            .addTransaction(transaction);
                      },
                    ),
                  ),
                );

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _duplicateTransaction(
    BuildContext context,
    WidgetRef ref,
    LedgerTransaction transaction,
  ) {
    // Create a copy with today's date
    final duplicatedTransaction = transaction.copyWith(
      date: DateTime.now(),
      reference: '${transaction.reference} (Copy)',
    );

    ref.read(ledgerProvider.notifier).addTransaction(duplicatedTransaction);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction duplicated successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'General Ledger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GeneralLedgerScreen(),
    );
  }
}
