import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';

import '../../states/gl/ledger_provider.dart';

class TrxEdit extends ConsumerWidget {
  final LedgerTransaction transaction;
  const TrxEdit({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formKey = GlobalKey<FormState>();

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
    final transactions = ref.read(combinedLedgerProvider);
    final accounts =
        {for (final transaction in transactions) transaction.account}.toList()
          ..sort();
    final categories =
        {for (final transaction in transactions) transaction.category}.toList()
          ..sort();

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
                        prefixIcon: const Icon(Icons.calendar_today_rounded),
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
                      initialValue: TextEditingValue(text: transaction.account),
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
                      initialValue: type,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.swap_vert_rounded),
                      ),
                      items:
                          TransactionType.values.map((TransactionType value) {
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
                    date: DateFormat('yyyy-MM-dd').parse(dateController.text),
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
  }
}
