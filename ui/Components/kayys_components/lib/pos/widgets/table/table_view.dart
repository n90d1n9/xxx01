import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'table_data_model.dart';

class GTableView extends StatelessWidget {
  final List<String>? header;
  final List<List<GCell>>? data;
  final double? width;
  final double? height;
  final TextStyle headerStyle;
  final TextStyle rowStyle;
  final BoxDecoration headerDecoration;
  final BoxDecoration rowDecoration;
  final Map<int, dynamic>? config;
  final TableBorder? border;
  final Map<int, TableColumnWidth>? columnWidths;
  const GTableView(
      {super.key,
      this.header,
      this.data,
      this.width,
      this.height,
      this.headerDecoration = const BoxDecoration(color: Colors.black12),
      this.rowDecoration = const BoxDecoration(color: Colors.white),
      this.headerStyle = const TextStyle(color: Colors.black45),
      this.rowStyle = const TextStyle(
        color: Colors.black45,
      ),
      this.columnWidths,
      this.border,
      this.config});

  @override
  Widget build(BuildContext context) {
    return Table(
        border: border,
        columnWidths: columnWidths,
        children: [tableHeader(), ...tableData()]);
  }

  TableRow tableHeader() {
    List<Widget> headerNames = [];
    header!.forEachIndexed((index, el) {
      headerNames.add(Text(
        el,
        textAlign: TextAlign.center,
        style: headerStyle,
      ));
    });
    return TableRow(decoration: headerDecoration, children: headerNames);
  }

  List<TableRow> tableData() {
    List<TableRow> rows = [];
    data!.forEachIndexed((index, el) {
      List<Widget> cells = [];
      header!.forEachIndexed((i, element) {
        cells.add(_cell(el[i], i));
      });
      rows.add(rowData(cells));
    });
    return rows;
  }

  TableRow rowData(cells) {
    return TableRow(decoration: rowDecoration, children: cells);
  }

  Widget _cell(GCell data, index) {
    return Container(
        margin: data.margin,
        padding: data.padding,
        decoration: data.decoration,
        constraints: data.constraints,
        child: Text(
          '${data.value}',
          textAlign:
              config![index] != TextAlign.left ? config![index] : data.align,
          style: rowStyle,
        ));
  }
}
