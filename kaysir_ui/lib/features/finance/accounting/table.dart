import 'package:flutter/material.dart';
import 'package:ky_table/ky_table.dart';
import 'package:ky_table/tabel_controller.dart';

class MyTable extends StatefulWidget {
  const MyTable({super.key});

  @override
  State<MyTable> createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  final tableController = TableController();

  @override
  void initState() {
    super.initState();
    tableController.addListener(_handleChange);
  }

  @override
  void dispose() {
    tableController.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    /* return ValueListenableBuilder(
      valueListenable: tableController,
      builder: (context, _, __) {
        final filteredData = tableController.getFilteredAndSortedData();
        final paginatedData = tableController.getPaginatedData(filteredData);

       
      },
    ); */
    return KyTable(controller: tableController);
  }
}

void main(List<String> args) {
  runApp(MaterialApp(home: MyTable()));
}
