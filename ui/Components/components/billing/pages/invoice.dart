import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define providers for state management
final vendorProvider = StateProvider<String>((ref) => 'A0001');
final vendorNameProvider = StateProvider<String>((ref) => 'Vendor 1');
final totalBeforeDiscountProvider = StateProvider<double>((ref) => 12500000);
final taxProvider = StateProvider<double>((ref) => 1250000);
final totalPaymentDueProvider = StateProvider<double>((ref) => 13750000);

class InvoicePage extends ConsumerWidget {
  const InvoicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = ref.watch(vendorProvider);
    final vendorName = ref.watch(vendorNameProvider);
    final totalBeforeDiscount = ref.watch(totalBeforeDiscountProvider);
    final tax = ref.watch(taxProvider);
    final totalPaymentDue = ref.watch(totalPaymentDueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('A/P Invoice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Vendor: '),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: vendor),
                    onChanged: (value) => ref.read(vendorProvider.notifier) ,
                  ),
                ),
                const Text('Name: '),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: vendorName),
                    onChanged: (value) => ref.read(vendorNameProvider.notifier),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Items:'),
            DataTable(
              columns: const [
                DataColumn(label: Text('Item No.')),
                DataColumn(label: Text('Quantity')),
                DataColumn(label: Text('Unit Price')),
                DataColumn(label: Text('Total')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('Z0026')),
                  DataCell(Text('5')),
                  DataCell(Text('VND 500,000.00')),
                  DataCell(Text('VND 2,500,000.00')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Z0025')),
                  DataCell(Text('10')),
                  DataCell(Text('VND 1,000,000.00')),
                  DataCell(Text('VND 10,000,000.00')),
                ]),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Before Discount:'),
                Text('VND $totalBeforeDiscount'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax:'),
                Text('VND $tax'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Payment Due:'),
                Text('VND $totalPaymentDue'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement your logic here
                  },
                  child: const Text('OK'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Implement your logic here
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}