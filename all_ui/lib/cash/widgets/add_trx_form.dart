// File: lib/widgets/add_transaction_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../states/transaction_provider.dart';

class AddTransactionForm extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const AddTransactionForm({super.key, this.transaction});

  @override
  AddTransactionFormState createState() => AddTransactionFormState();
}

class AddTransactionFormState extends ConsumerState<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TransactionType _type;
  late TransactionCategory _category;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _type = widget.transaction?.type ?? TransactionType.income;
    _category =
        widget.transaction?.category ??
        ((_type == TransactionType.income)
            ? TransactionCategory.sales
            : TransactionCategory.utilities);
    _date = widget.transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.transaction == null
                  ? 'Add Transaction'
                  : 'Edit Transaction',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            _buildDatePicker(context),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  widget.transaction == null
                      ? 'ADD TRANSACTION'
                      : 'SAVE CHANGES',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _type = TransactionType.income;
                // Reset category based on type
                _category = TransactionCategory.sales;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color:
                    _type == TransactionType.income
                        ? Colors.green[100]
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      _type == TransactionType.income
                          ? Colors.green
                          : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_downward,
                    color:
                        _type == TransactionType.income
                            ? Colors.green
                            : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Income',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          _type == TransactionType.income
                              ? Colors.green
                              : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _type = TransactionType.expense;
                // Reset category based on type
                _category = TransactionCategory.utilities;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color:
                    _type == TransactionType.expense
                        ? Colors.red[100]
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      _type == TransactionType.expense
                          ? Colors.red
                          : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_upward,
                    color:
                        _type == TransactionType.expense
                            ? Colors.red
                            : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Expense',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          _type == TransactionType.expense
                              ? Colors.red
                              : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    List<TransactionCategory> categories =
        _type == TransactionType.income
            ? [
              TransactionCategory.sales,
              TransactionCategory.services,
              TransactionCategory.investments,
              TransactionCategory.otherIncome,
            ]
            : [
              TransactionCategory.costOfGoodsSold,
              TransactionCategory.wages,
              TransactionCategory.rent,
              TransactionCategory.utilities,
              TransactionCategory.marketing,
              TransactionCategory.supplies,
              TransactionCategory.maintenance,
              TransactionCategory.insurance,
              TransactionCategory.taxes,
              TransactionCategory.otherExpense,
            ];

    return DropdownButtonFormField<TransactionCategory>(
      value: categories.contains(_category) ? _category : categories.first,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items:
          categories.map((category) {
            return DropdownMenuItem<TransactionCategory>(
              value: category,
              child: Text(_getCategoryName(category)),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _category = value!;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          setState(() {
            _date = pickedDate;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM d, yyyy').format(_date)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.sales:
        return 'Sales';
      case TransactionCategory.services:
        return 'Services';
      case TransactionCategory.investments:
        return 'Investments';
      case TransactionCategory.otherIncome:
        return 'Other Income';
      case TransactionCategory.costOfGoodsSold:
        return 'Cost of Goods Sold';
      case TransactionCategory.wages:
        return 'Wages & Salaries';
      case TransactionCategory.rent:
        return 'Rent';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.marketing:
        return 'Marketing';
      case TransactionCategory.supplies:
        return 'Supplies';
      case TransactionCategory.maintenance:
        return 'Maintenance';
      case TransactionCategory.insurance:
        return 'Insurance';
      case TransactionCategory.taxes:
        return 'Taxes';
      case TransactionCategory.otherExpense:
        return 'Other Expenses';
      default:
        return 'Unknown';
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final description = _descriptionController.text.trim();
      final amount = double.parse(_amountController.text);

      if (widget.transaction == null) {
        // Add new transaction
        final newTransaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          description: description,
          amount: amount,
          date: _date,
          type: _type,
          category: _category,
        );
        ref.read(transactionProvider.notifier).addTransaction(newTransaction);
      } else {
        // Update existing transaction
        final updatedTransaction = Transaction(
          id: widget.transaction!.id,
          description: description,
          amount: amount,
          date: _date,
          type: _type,
          category: _category,
        );
        ref
            .read(transactionProvider.notifier)
            .updateTransaction(widget.transaction!.id, updatedTransaction);
      }

      Navigator.pop(context);
    }
  }
}
