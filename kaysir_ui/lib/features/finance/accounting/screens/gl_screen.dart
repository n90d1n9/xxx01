import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/finance/accounting/widgets/trx/trx_table.dart';

import '../models/ledger_filter.dart';
import '../models/ledger_trx.dart';
import '../states/gl/filter_provider.dart';
import '../states/gl/ledger_provider.dart';
import '../widgets/bank_reconciliation_card.dart';

enum _LedgerPeriodPreset { all, dataMonth, dataQuarter, dataYear }

class GLScreen extends ConsumerStatefulWidget {
  const GLScreen({super.key});

  @override
  ConsumerState<GLScreen> createState() => _GLScreenState();
}

class _GLScreenState extends ConsumerState<GLScreen> {
  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(ledgerFilterProvider);
    final allTransactions = ref.watch(combinedLedgerProvider);
    final transactions = ref.watch(filteredLedgerProvider(filter));
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
          _buildLedgerOverview(context, transactions, isDarkMode),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: BankReconciliationCard(),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildQuickFilters(context, ref, filter, allTransactions),
          ),
          const SizedBox(height: 8),

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
                    : TrxTable(transactions: transactions),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerOverview(
    BuildContext context,
    List<LedgerTransaction> transactions,
    bool isDarkMode,
  ) {
    final theme = Theme.of(context);
    final totalDebit = _sumByType(transactions, TransactionType.debit);
    final totalCredit = _sumByType(transactions, TransactionType.credit);
    final netBalance = totalDebit - totalCredit;
    final largestEntry = transactions.fold(
      0.0,
      (largest, transaction) =>
          transaction.amount > largest ? transaction.amount : largest,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ledger Summary',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth =
                  constraints.maxWidth >= 1000
                      ? (constraints.maxWidth - 36) / 4
                      : constraints.maxWidth >= 620
                      ? (constraints.maxWidth - 12) / 2
                      : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _buildSummaryCard(
                      context,
                      'Filtered Debits',
                      totalDebit,
                      Icons.arrow_upward_rounded,
                      Colors.green.shade700,
                      isDarkMode ? Colors.green.shade900 : Colors.green.shade50,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildSummaryCard(
                      context,
                      'Filtered Credits',
                      totalCredit,
                      Icons.arrow_downward_rounded,
                      Colors.red.shade700,
                      isDarkMode ? Colors.red.shade900 : Colors.red.shade50,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildSummaryCard(
                      context,
                      'Filtered Net',
                      netBalance,
                      netBalance >= 0
                          ? Icons.account_balance_wallet_rounded
                          : Icons.warning_rounded,
                      netBalance >= 0
                          ? Colors.blue.shade700
                          : Colors.orange.shade700,
                      isDarkMode
                          ? (netBalance >= 0
                              ? Colors.blue.shade900
                              : Colors.orange.shade900)
                          : (netBalance >= 0
                              ? Colors.blue.shade50
                              : Colors.orange.shade50),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildSummaryCard(
                      context,
                      'Largest Entry',
                      largestEntry,
                      Icons.price_check_rounded,
                      Colors.indigo.shade700,
                      isDarkMode
                          ? Colors.indigo.shade900
                          : Colors.indigo.shade50,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters(
    BuildContext context,
    WidgetRef ref,
    LedgerFilter filter,
    List<LedgerTransaction> transactions,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Quick filters',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          ..._LedgerPeriodPreset.values.map(
            (preset) => ChoiceChip(
              label: Text(_periodLabel(preset)),
              selected: _isPeriodSelected(filter, preset, transactions),
              onSelected:
                  (_) => _applyPeriodFilter(ref, filter, preset, transactions),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            avatar: const Icon(Icons.arrow_upward_rounded, size: 18),
            label: const Text('Debit'),
            selected: filter.type == TransactionType.debit,
            onSelected: (selected) {
              ref.read(ledgerFilterProvider.notifier).state = filter.copyWith(
                type: selected ? TransactionType.debit : null,
              );
            },
          ),
          FilterChip(
            avatar: const Icon(Icons.arrow_downward_rounded, size: 18),
            label: const Text('Credit'),
            selected: filter.type == TransactionType.credit,
            onSelected: (selected) {
              ref.read(ledgerFilterProvider.notifier).state = filter.copyWith(
                type: selected ? TransactionType.credit : null,
              );
            },
          ),
          if (filter.hasActiveFilters)
            TextButton.icon(
              icon: const Icon(Icons.clear_all_rounded, size: 18),
              label: const Text('Clear'),
              onPressed:
                  () =>
                      ref.read(ledgerFilterProvider.notifier).state =
                          const LedgerFilter(),
            ),
        ],
      ),
    );
  }

  double _sumByType(
    List<LedgerTransaction> transactions,
    TransactionType type,
  ) {
    return transactions
        .where((transaction) => transaction.type == type)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  String _periodLabel(_LedgerPeriodPreset preset) {
    switch (preset) {
      case _LedgerPeriodPreset.all:
        return 'All';
      case _LedgerPeriodPreset.dataMonth:
        return 'Data Month';
      case _LedgerPeriodPreset.dataQuarter:
        return 'Quarter';
      case _LedgerPeriodPreset.dataYear:
        return 'Year';
    }
  }

  void _applyPeriodFilter(
    WidgetRef ref,
    LedgerFilter filter,
    _LedgerPeriodPreset preset,
    List<LedgerTransaction> transactions,
  ) {
    final range = _periodRange(preset, transactions);
    ref.read(ledgerFilterProvider.notifier).state = filter.copyWith(
      startDate: range?.start,
      endDate: range?.end,
    );
  }

  bool _isPeriodSelected(
    LedgerFilter filter,
    _LedgerPeriodPreset preset,
    List<LedgerTransaction> transactions,
  ) {
    final range = _periodRange(preset, transactions);
    if (range == null) {
      return filter.startDate == null && filter.endDate == null;
    }

    return _isSameDay(filter.startDate, range.start) &&
        _isSameDay(filter.endDate, range.end);
  }

  DateTimeRange? _periodRange(
    _LedgerPeriodPreset preset,
    List<LedgerTransaction> transactions,
  ) {
    if (preset == _LedgerPeriodPreset.all) {
      return null;
    }

    final anchor =
        transactions.isEmpty
            ? DateTime.now()
            : transactions
                .map((transaction) => transaction.date)
                .reduce((a, b) => a.isAfter(b) ? a : b);

    switch (preset) {
      case _LedgerPeriodPreset.all:
        return null;
      case _LedgerPeriodPreset.dataMonth:
        return DateTimeRange(
          start: DateTime(anchor.year, anchor.month),
          end: DateTime(anchor.year, anchor.month + 1, 0),
        );
      case _LedgerPeriodPreset.dataQuarter:
        final firstMonth = ((anchor.month - 1) ~/ 3) * 3 + 1;
        return DateTimeRange(
          start: DateTime(anchor.year, firstMonth),
          end: DateTime(anchor.year, firstMonth + 3, 0),
        );
      case _LedgerPeriodPreset.dataYear:
        return DateTimeRange(
          start: DateTime(anchor.year),
          end: DateTime(anchor.year, 12, 31),
        );
    }
  }

  bool _isSameDay(DateTime? first, DateTime? second) {
    if (first == null || second == null) {
      return first == null && second == null;
    }

    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
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
        if (filter.type != null)
          Chip(
            label: Text('Type: ${filter.type!.name}'),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () {
              filterNotifier.state = filter.copyWith(type: null);
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
    TransactionType? type = currentFilter.type;

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
                      DropdownButtonFormField<TransactionType?>(
                        initialValue: type,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          prefixIcon: Icon(Icons.swap_vert_rounded),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem<TransactionType?>(
                            value: null,
                            child: Text('All Types'),
                          ),
                          DropdownMenuItem<TransactionType?>(
                            value: TransactionType.debit,
                            child: Text('Debit'),
                          ),
                          DropdownMenuItem<TransactionType?>(
                            value: TransactionType.credit,
                            child: Text('Credit'),
                          ),
                        ],
                        onChanged: (value) => setState(() => type = value),
                      ),
                      const SizedBox(height: 16),
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
                      type = null;
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
                      type: type,
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
    final transactions = ref.read(combinedLedgerProvider);
    final accounts = _uniqueAccounts(transactions);
    final categories = _uniqueCategories(transactions);

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
                          initialValue: type,
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

  List<String> _uniqueAccounts(List<LedgerTransaction> transactions) {
    return {
        for (final transaction in transactions) transaction.account,
      }.toList()
      ..sort();
  }

  List<String> _uniqueCategories(List<LedgerTransaction> transactions) {
    return {
        for (final transaction in transactions) transaction.category,
      }.toList()
      ..sort();
  }
}
