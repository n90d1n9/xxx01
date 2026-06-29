import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uuid/uuid.dart';

// lib/models/recurring_transaction.dart
class RecurringTransaction {
  final String id;
  final String title;
  final double amount;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String description;
  final TransactionType type;
  final String category;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecurringTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.description,
    required this.type,
    required this.category,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  RecurringTransaction copyWith({
    String? id,
    String? title,
    double? amount,
    RecurringFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    TransactionType? type,
    String? category,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'frequency': frequency.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
      'type': type.name,
      'category': category,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      frequency: RecurringFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => RecurringFrequency.monthly,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      description: json['description'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.sales,
      ),
      category: json['category'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum RecurringFrequency { daily, weekly, biweekly, monthly, quarterly, yearly }

enum TransactionType { sales, purchase }

// lib/services/recurring_transaction_service.dart

class RecurringTransactionService {
  final String baseUrl;
  final http.Client client;

  RecurringTransactionService({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  Future<List<RecurringTransaction>> fetchRecurringTransactions() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/recurring-transactions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RecurringTransaction.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recurring transactions');
      }
    } catch (e) {
      throw Exception('Error fetching recurring transactions: $e');
    }
  }

  Future<RecurringTransaction> createRecurringTransaction(
    RecurringTransaction transaction,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/recurring-transactions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transaction.toJson()),
      );

      if (response.statusCode == 201) {
        return RecurringTransaction.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create recurring transaction');
      }
    } catch (e) {
      throw Exception('Error creating recurring transaction: $e');
    }
  }

  Future<RecurringTransaction> updateRecurringTransaction(
    RecurringTransaction transaction,
  ) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/recurring-transactions/${transaction.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transaction.toJson()),
      );

      if (response.statusCode == 200) {
        return RecurringTransaction.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update recurring transaction');
      }
    } catch (e) {
      throw Exception('Error updating recurring transaction: $e');
    }
  }

  Future<void> deleteRecurringTransaction(String id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/recurring-transactions/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete recurring transaction');
      }
    } catch (e) {
      throw Exception('Error deleting recurring transaction: $e');
    }
  }

  Future<void> toggleRecurringTransactionStatus(
    String id,
    bool isActive,
  ) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/recurring-transactions/$id/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isActive': isActive}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to toggle recurring transaction status');
      }
    } catch (e) {
      throw Exception('Error toggling recurring transaction status: $e');
    }
  }
}

// lib/providers/recurring_transaction_providers.dart
final recurringTransactionServiceProvider =
    Provider<RecurringTransactionService>((ref) {
      return RecurringTransactionService(baseUrl: 'https://api.example.com/v1');
    });

final recurringTransactionsProvider =
    StateNotifierProvider<
      RecurringTransactionsNotifier,
      AsyncValue<List<RecurringTransaction>>
    >((ref) {
      final service = ref.watch(recurringTransactionServiceProvider);
      return RecurringTransactionsNotifier(service);
    });

final filteredRecurringTransactionsProvider =
    Provider<AsyncValue<List<RecurringTransaction>>>((ref) {
      final transactionsAsyncValue = ref.watch(recurringTransactionsProvider);
      final filter = ref.watch(transactionFilterProvider);

      return transactionsAsyncValue.when(
        data: (transactions) {
          if (filter.isEmpty) return AsyncValue.data(transactions);

          return AsyncValue.data(
            transactions.where((transaction) {
              // Apply filters
              if (filter.type != null && transaction.type != filter.type) {
                return false;
              }
              if (filter.frequency != null &&
                  transaction.frequency != filter.frequency) {
                return false;
              }
              if (filter.category != null &&
                  transaction.category != filter.category) {
                return false;
              }
              if (filter.isActive != null &&
                  transaction.isActive != filter.isActive) {
                return false;
              }
              if (filter.searchTerm != null && filter.searchTerm!.isNotEmpty) {
                return transaction.title.toLowerCase().contains(
                      filter.searchTerm!.toLowerCase(),
                    ) ||
                    transaction.description.toLowerCase().contains(
                      filter.searchTerm!.toLowerCase(),
                    );
              }
              return true;
            }).toList(),
          );
        },
        loading: () => transactionsAsyncValue,
        error: (error, stack) => transactionsAsyncValue,
      );
    });

class TransactionFilter {
  final TransactionType? type;
  final RecurringFrequency? frequency;
  final String? category;
  final bool? isActive;
  final String? searchTerm;

  const TransactionFilter({
    this.type,
    this.frequency,
    this.category,
    this.isActive,
    this.searchTerm,
  });

  bool get isEmpty =>
      type == null &&
      frequency == null &&
      category == null &&
      isActive == null &&
      (searchTerm == null || searchTerm!.isEmpty);
}

final transactionFilterProvider = StateProvider<TransactionFilter>((ref) {
  return const TransactionFilter();
});

class RecurringTransactionsNotifier
    extends StateNotifier<AsyncValue<List<RecurringTransaction>>> {
  final RecurringTransactionService _service;

  RecurringTransactionsNotifier(this._service)
    : super(const AsyncValue.loading()) {
    fetchRecurringTransactions();
  }

  Future<void> fetchRecurringTransactions() async {
    try {
      state = const AsyncValue.loading();
      final transactions = await _service.fetchRecurringTransactions();
      state = AsyncValue.data(transactions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createRecurringTransaction(
    RecurringTransaction transaction,
  ) async {
    try {
      await _service.createRecurringTransaction(transaction);
      fetchRecurringTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateRecurringTransaction(
    RecurringTransaction transaction,
  ) async {
    state.whenData((transactions) {
      final updatedTransactions = transactions.map((t) {
        return t.id == transaction.id ? transaction : t;
      }).toList();

      state = AsyncValue.data(updatedTransactions);
    });

    try {
      await _service.updateRecurringTransaction(transaction);
      fetchRecurringTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteRecurringTransaction(String id) async {
    state.whenData((transactions) {
      final updatedTransactions = transactions
          .where((t) => t.id != id)
          .toList();
      state = AsyncValue.data(updatedTransactions);
    });

    try {
      await _service.deleteRecurringTransaction(id);
    } catch (error, stackTrace) {
      fetchRecurringTransactions();
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleTransactionStatus(String id, bool isActive) async {
    state.whenData((transactions) {
      final updatedTransactions = transactions.map((t) {
        return t.id == id ? t.copyWith(isActive: isActive) : t;
      }).toList();

      state = AsyncValue.data(updatedTransactions);
    });

    try {
      await _service.toggleRecurringTransactionStatus(id, isActive);
    } catch (error, stackTrace) {
      fetchRecurringTransactions();
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// lib/screens/recurring_transactions_screen.dart

class RecurringTransactionsScreen extends ConsumerWidget {
  const RecurringTransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredRecurringTransactionsProvider);
    final filter = ref.watch(transactionFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(recurringTransactionsProvider.notifier)
                  .fetchRecurringTransactions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref, filter),
          ),
        ],
      ),
      body: transactions.when(
        data: (data) => _buildTransactionsList(context, ref, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(recurringTransactionsProvider.notifier)
                      .fetchRecurringTransactions();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    WidgetRef ref,
    List<RecurringTransaction> transactions,
  ) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'No recurring transactions found.\nTap the + button to create one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: DataTable(
                  columnSpacing: 16,
                  horizontalMargin: 24,
                  columns: const [
                    DataColumn(label: Text('Title')),
                    DataColumn(label: Text('Amount'), numeric: true),
                    DataColumn(label: Text('Amount'), numeric: true),
                    DataColumn(label: Text('Frequency')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: transactions.map((transaction) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                transaction.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                transaction.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            '\$${transaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: transaction.type == TransactionType.sales
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(Text(_formatFrequency(transaction.frequency))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: transaction.type == TransactionType.sales
                                  ? Colors.blue[50]
                                  : Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              transaction.type.name.toUpperCase(),
                              style: TextStyle(
                                color: transaction.type == TransactionType.sales
                                    ? Colors.blue[700]
                                    : Colors.orange[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Switch(
                            value: transaction.isActive,
                            onChanged: (value) {
                              ref
                                  .read(recurringTransactionsProvider.notifier)
                                  .toggleTransactionStatus(
                                    transaction.id,
                                    value,
                                  );
                            },
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showTransactionForm(
                                  context,
                                  ref,
                                  transaction,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _showDeleteConfirmation(
                                  context,
                                  ref,
                                  transaction,
                                ),
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
          ),
        ],
      ),
    );
  }

  String _formatFrequency(RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return 'Daily';
      case RecurringFrequency.weekly:
        return 'Weekly';
      case RecurringFrequency.biweekly:
        return 'Bi-weekly';
      case RecurringFrequency.monthly:
        return 'Monthly';
      case RecurringFrequency.quarterly:
        return 'Quarterly';
      case RecurringFrequency.yearly:
        return 'Yearly';
    }
  }

  Future<void> _showTransactionForm(
    BuildContext context,
    WidgetRef ref, [
    RecurringTransaction? transaction,
  ]) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          transaction == null
              ? 'Create Recurring Transaction'
              : 'Edit Recurring Transaction',
        ),
        content: RecurringTransactionForm(transaction: transaction),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    RecurringTransaction transaction,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete the recurring ${transaction.type.name} "${transaction.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref
                  .read(recurringTransactionsProvider.notifier)
                  .deleteRecurringTransaction(transaction.id);
              Navigator.of(context).pop();
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog(
    BuildContext context,
    WidgetRef ref,
    TransactionFilter currentFilter,
  ) async {
    TransactionType? type = currentFilter.type;
    RecurringFrequency? frequency = currentFilter.frequency;
    bool? isActive = currentFilter.isActive;
    String? searchTerm = currentFilter.searchTerm;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Transactions'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: TextEditingController(text: searchTerm),
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    searchTerm = value;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Transaction Type:'),
                SegmentedButton<TransactionType?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('All')),
                    ButtonSegment(
                      value: TransactionType.sales,
                      label: Text('Sales'),
                    ),
                    ButtonSegment(
                      value: TransactionType.purchase,
                      label: Text('Purchase'),
                    ),
                  ],
                  selected: {type},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      type = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Frequency:'),
                DropdownButton<RecurringFrequency?>(
                  value: frequency,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Frequencies'),
                    ),
                    ...RecurringFrequency.values.map((freq) {
                      return DropdownMenuItem(
                        value: freq,
                        child: Text(_formatFrequency(freq)),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      frequency = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Status:'),
                SegmentedButton<bool?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('All')),
                    ButtonSegment(value: true, label: Text('Active')),
                    ButtonSegment(value: false, label: Text('Inactive')),
                  ],
                  selected: {isActive},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      isActive = newSelection.first;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(transactionFilterProvider.notifier).state =
                    const TransactionFilter();
                Navigator.pop(context);
              },
              child: const Text('CLEAR'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(transactionFilterProvider.notifier)
                    .state = TransactionFilter(
                  type: type,
                  frequency: frequency,
                  isActive: isActive,
                  searchTerm: searchTerm,
                );
                Navigator.pop(context);
              },
              child: const Text('APPLY'),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/widgets/recurring_transaction_form.dart

class RecurringTransactionForm extends ConsumerStatefulWidget {
  final RecurringTransaction? transaction;

  const RecurringTransactionForm({Key? key, this.transaction})
    : super(key: key);

  @override
  ConsumerState<RecurringTransactionForm> createState() =>
      _RecurringTransactionFormState();
}

class _RecurringTransactionFormState
    extends ConsumerState<RecurringTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  late TransactionType _type;
  late RecurringFrequency _frequency;
  late DateTime _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description;
      _categoryController.text = widget.transaction!.category;
      _type = widget.transaction!.type;
      _frequency = widget.transaction!.frequency;
      _startDate = widget.transaction!.startDate;
      _endDate = widget.transaction!.endDate;
    } else {
      _type = TransactionType.sales;
      _frequency = RecurringFrequency.monthly;
      _startDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:
          MediaQuery.of(context).size.width * 0.5, // Adjust for large screens
      height: MediaQuery.of(context).size.height * 0.7,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<TransactionType>(
                      value: _type,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: TransactionType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _type = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RecurringFrequency>(
                value: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: RecurringFrequency.values.map((frequency) {
                  String label;
                  switch (frequency) {
                    case RecurringFrequency.daily:
                      label = 'Daily';
                      break;
                    case RecurringFrequency.weekly:
                      label = 'Weekly';
                      break;
                    case RecurringFrequency.biweekly:
                      label = 'Bi-weekly';
                      break;
                    case RecurringFrequency.monthly:
                      label = 'Monthly';
                      break;
                    case RecurringFrequency.quarterly:
                      label = 'Quarterly';
                      break;
                    case RecurringFrequency.yearly:
                      label = 'Yearly';
                      break;
                  }
                  return DropdownMenuItem(value: frequency, child: Text(label));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _frequency = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a category';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Start Date'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('MMM dd, yyyy').format(_startDate),
                                ),
                                const Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('End Date'),
                            const SizedBox(width: 8),
                            Switch(
                              value: _endDate != null,
                              onChanged: (value) {
                                setState(() {
                                  _endDate = value
                                      ? DateTime.now().add(
                                          const Duration(days: 365),
                                        )
                                      : null;
                                });
                              },
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _endDate != null
                              ? () => _selectDate(context, false)
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _endDate != null
                                    ? Colors.grey
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _endDate != null
                                      ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(_endDate!)
                                      : 'No End Date',
                                  style: TextStyle(
                                    color: _endDate != null
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: _endDate != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveTransaction,
                    child: Text(
                      widget.transaction == null ? 'CREATE' : 'UPDATE',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate ?? DateTime.now(),
      firstDate: isStartDate
          ? DateTime.now().subtract(const Duration(days: 365))
          : _startDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date exists and is now before start date, update it
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();

      final transaction = widget.transaction != null
          ? widget.transaction!.copyWith(
              title: _titleController.text,
              amount: double.parse(_amountController.text),
              frequency: _frequency,
              startDate: _startDate,
              endDate: _endDate,
              description: _descriptionController.text,
              type: _type,
              category: _categoryController.text,
              updatedAt: now,
            )
          : RecurringTransaction(
              id: const Uuid().v4(),
              title: _titleController.text,
              amount: double.parse(_amountController.text),
              frequency: _frequency,
              startDate: _startDate,
              endDate: _endDate,
              description: _descriptionController.text,
              type: _type,
              category: _categoryController.text,
              isActive: true,
              createdAt: now,
              updatedAt: now,
            );

      if (widget.transaction == null) {
        ref
            .read(recurringTransactionsProvider.notifier)
            .createRecurringTransaction(transaction);
      } else {
        ref
            .read(recurringTransactionsProvider.notifier)
            .updateRecurringTransaction(transaction);
      }

      Navigator.pop(context);
    }
  }
}

// lib/main.dart

void main() {
  initializeDateFormatting();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recurring Transactions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const RecurringTransactionsScreen(),
    );
  }
}

// lib/utils/date_utils.dart
class TransactionDateUtils {
  static String getNextExecutionDate(
    DateTime startDate,
    RecurringFrequency frequency,
  ) {
    final now = DateTime.now();
    DateTime nextDate = startDate;

    // Find the next execution date based on frequency
    while (nextDate.isBefore(now)) {
      switch (frequency) {
        case RecurringFrequency.daily:
          nextDate = nextDate.add(const Duration(days: 1));
          break;
        case RecurringFrequency.weekly:
          nextDate = nextDate.add(const Duration(days: 7));
          break;
        case RecurringFrequency.biweekly:
          nextDate = nextDate.add(const Duration(days: 14));
          break;
        case RecurringFrequency.monthly:
          nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
          break;
        case RecurringFrequency.quarterly:
          nextDate = DateTime(nextDate.year, nextDate.month + 3, nextDate.day);
          break;
        case RecurringFrequency.yearly:
          nextDate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
          break;
      }
    }

    return DateFormat('MMM dd, yyyy').format(nextDate);
  }

  static int getRemainingDays(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }
}
