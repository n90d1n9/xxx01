import 'package:flutter/material.dart';

import 'table/table_data_model.dart';
import 'table/table_view.dart';

class PosOrder extends StatelessWidget {
  final List<List<GCell>>? data;
  final double? width;
  final double? height;
  final Map<int, TableColumnWidth>? columnWidths;
  final Map<int, dynamic>? config;
  const PosOrder(
      {super.key,
      this.data,
      this.width,
      this.height,
      this.columnWidths,
      this.config});

  @override
  Widget build(BuildContext context) {
    List<String> header = [
      'No',
      'Item',
      'Qty',
      'Unit',
      'Unit Price',
      'Discount',
      'Amount',
      'Stock'
    ];

    return Expanded(
        flex: 1,
        child: SingleChildScrollView(
            child: Container(
                constraints: const BoxConstraints(minWidth: 960),
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                color: Colors.black12,
                width: width,
                height: height,
                child: GTableView(
                  header: header,
                  columnWidths: columnWidths,
                  border: const TableBorder(
                      horizontalInside: BorderSide(width: 0.2)),
                  headerStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  headerDecoration: BoxDecoration(
                      color: Colors.black38,
                      border: Border.all(width: 1.0, color: Colors.white)),
                  width: double.infinity,
                  height: double.infinity,
                  config: config,
                  data: data,
                ))));
  }
}
