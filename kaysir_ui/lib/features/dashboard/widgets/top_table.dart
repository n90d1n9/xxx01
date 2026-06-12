import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_data.dart';

class TopProductsTable extends StatelessWidget {
  final List<Product> products;

  const TopProductsTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('PRODUCT')),
          DataColumn(label: Text('DATE')),
          DataColumn(label: Text('PRICE')),
          DataColumn(label: Text('QUANTITY')),
          DataColumn(label: Text('CODE')),
        ],
        rows: products.map((product) {
          return DataRow(cells: [
            DataCell(Row(
              children: [
                Image.asset(
                  'assets/icons/logo-mi.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                Text(product.name),
              ],
            )),
            DataCell(Text(DateFormat('dd MMM').format(product.date))),
            DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
            DataCell(Text(product.quantity.toString())),
            DataCell(Text(product.code)),
          ]);
        }).toList(),
      ),
    );
  }
}
