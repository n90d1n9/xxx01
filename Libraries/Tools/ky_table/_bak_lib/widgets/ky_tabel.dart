import 'package:flutter/material.dart';

import 'ky_data_tabel.dart';
import 'detail_panel.dart';
import 'filter_panel.dart';
import 'item_form_dialog.dart';
import '../tabel_controller.dart';
import 'tabel_pagination.dart';

class KyTable extends StatefulWidget {
  final TableController controller;
  const KyTable({super.key, required this.controller});

  @override
  State<KyTable> createState() => _KyTableState();
}

class _KyTableState extends State<KyTable> {
  @override
  Widget build(BuildContext context) {
    final selectedItem = widget.controller.selectedItem;

    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Master-Detail Table')),
      body: Row(
        children: [
          // Master view (table)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Filter panel
                TableFilterPanel(controller: widget.controller),

                // Table header and body
                Expanded(child: KyDataTable(controller: widget.controller)),

                // Pagination
                TablePagination(controller: widget.controller),
              ],
            ),
          ),

          // Detail view
          if (selectedItem != null)
            Expanded(
              flex: 1,
              child: DetailPanel(
                item: selectedItem,
                controller: widget.controller,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ItemFormDialog(
            onSave: (item) {
              widget.controller.addItem(item);
            },
          ),
    );
  }
}
