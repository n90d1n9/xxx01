import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../accounting_core/services/ledger_posting_service.dart';
import '../models/invoice.dart';
import '../states/accounting_core_provider.dart';
import '../states/customer_provider.dart';
import '../states/financial_period_posting_guard_provider.dart';
import '../states/invoice_provider.dart';
import 'closed_period_posting_notice.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  final String? customerId;

  const CreateInvoiceScreen({super.key, this.customerId});

  @override
  ConsumerState<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCustomerId;
  double? amount;
  DateTime issueDate = DateTime.now();
  DateTime dueDate = DateTime.now().add(Duration(days: 30));
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    selectedCustomerId = widget.customerId;
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider3);
    final closeRecord = ref
        .watch(financialPeriodPostingGuardProvider)
        .closedRecordForDate(issueDate);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text('Create Invoice')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
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
                      'Invoice Details',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    customersAsync.when(
                      loading: () => CircularProgressIndicator(),
                      error: (err, stack) => Text('Error: $err'),
                      data: (customers) {
                        final selectedValue =
                            customers.any(
                                  (customer) =>
                                      customer.id == selectedCustomerId,
                                )
                                ? selectedCustomerId
                                : null;

                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Customer',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: selectedValue,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a customer';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedCustomerId = value;
                            });
                          },
                          items:
                              customers.map((customer) {
                                return DropdownMenuItem(
                                  value: customer.id,
                                  child: Text(customer.name),
                                );
                              }).toList(),
                        );
                      },
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            icon: Icon(Icons.calendar_today),
                            label: Text(
                              'Issue Date: ${DateFormat('MMM d, yyyy').format(issueDate)}',
                            ),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: issueDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null && picked != issueDate) {
                                setState(() {
                                  issueDate = picked;
                                  // Update due date if it's before the issue date
                                  if (dueDate.isBefore(issueDate)) {
                                    dueDate = issueDate.add(Duration(days: 30));
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            icon: Icon(Icons.calendar_today),
                            label: Text(
                              'Due Date: ${DateFormat('MMM d, yyyy').format(dueDate)}',
                            ),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: dueDate,
                                firstDate: issueDate,
                                lastDate: DateTime(2030),
                              );
                              if (picked != null && picked != dueDate) {
                                setState(() {
                                  dueDate = picked;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    ClosedPeriodPostingNotice(
                      closeRecord: closeRecord,
                      actionLabel: 'post this customer invoice',
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.0),

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
                          'Invoice Items',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text('Add Item'),
                          onPressed: _showAddItemDialog,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    items.isEmpty
                        ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              'No items added yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                        : ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item['description']),
                              subtitle: Text(
                                '${item['quantity']} x ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(item['unitPrice'])}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'en_US',
                                      symbol: '\$',
                                    ).format(
                                      item['quantity'] * item['unitPrice'],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        items.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    if (items.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Total: ',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'en_US',
                                symbol: '\$',
                              ).format(
                                items.fold(
                                  0.0,
                                  (sum, item) =>
                                      sum +
                                      (item['quantity'] * item['unitPrice']),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed:
              closeRecord != null
                  ? null
                  : () {
                    if (_formKey.currentState!.validate() && items.isNotEmpty) {
                      try {
                        _createInvoice();
                      } on LedgerPostingException catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.issues.join(' | '))),
                        );
                        return;
                      } on StateError catch (error) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(error.message)));
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invoice created and posted to ledger'),
                        ),
                      );
                      Navigator.pop(context);
                    } else if (items.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please add at least one item')),
                      );
                    }
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Create and Post Invoice',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _createInvoice() {
    final now = DateTime.now();
    final id = 'INV-${now.microsecondsSinceEpoch}';
    final total = _invoiceTotal();
    final description = items
        .map((item) => item['description'] as String)
        .where((description) => description.trim().isNotEmpty)
        .join(', ');

    final invoice = Invoice(
      id: id,
      customerId: selectedCustomerId,
      issueDate: issueDate,
      dueDate: dueDate,
      amount: total,
      reference: id,
      invoiceNumber: id,
      description: description,
      status: InvoiceStatus.pending,
      payments: const [],
    );
    final receivableDraft = ref
        .read(receivableJournalFactoryProvider)
        .invoiceIssued(
          invoiceId: invoice.id,
          issueDate: invoice.issueDate ?? DateTime.now(),
          amount: invoice.amount,
          description: invoice.description,
          accounts: ref.read(receivablePostingAccountsProvider),
        );
    ref
        .read(financialPeriodPostingGuardProvider)
        .ensureDateIsOpen(issueDate, actionLabel: 'post customer invoice');
    final posting = ref
        .read(ledgerPostingServiceProvider)
        .post(receivableDraft, ref.read(accountingChartProvider));

    ref.read(invoicesProvider.notifier).addInvoice(invoice);
    ref.read(postedLedgerProvider.notifier).addPosting(posting);
  }

  double _invoiceTotal() {
    return items.fold(
      0.0,
      (sum, item) => sum + (item['quantity'] * item['unitPrice']),
    );
  }

  void _showAddItemDialog() {
    final formKey = GlobalKey<FormState>();
    String description = '';
    int quantity = 1;
    double unitPrice = 0.0;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add Item'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      description = value!;
                    },
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    initialValue: '1',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quantity';
                      }
                      final qty = int.tryParse(value);
                      if (qty == null || qty <= 0) {
                        return 'Quantity must be a positive number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      quantity = int.parse(value!);
                    },
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Unit Price',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a unit price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Price must be a positive number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      unitPrice = double.parse(value!);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Add'),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    setState(() {
                      items.add({
                        'description': description,
                        'quantity': quantity,
                        'unitPrice': unitPrice,
                      });
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
    );
  }
}
