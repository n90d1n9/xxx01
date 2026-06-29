import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ky_dummy.dart';
import 'ky_table/model/ky_data.dart';
import 'ky_table/tabel_controller.dart';
import 'ky_table/utils/helper.dart';
import 'ky_table/widgets/ky_data_tabel.dart';
import 'ky_table/widgets/rating.dart';

void main() {
  runApp(const ProviderScope(child: KyTableApp()));
}

class KyTableApp extends StatefulWidget {
  const KyTableApp({super.key});

  @override
  State<KyTableApp> createState() => _KyTableAppState();
}

class _KyTableAppState extends State<KyTableApp> {
  final tableController = TableController(false);
  late int selectedItem = 0;
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
    setState(() {
      selectedItem = tableController.selectedItem!.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    /* 
    class TableController extends ValueNotifier<Object?> {
  TableController(this.isMultiSelectable) : super(null);
     */
    /* return ValueListenableBuilder(
      valueListenable: tableController,
      builder: (context, _, __) {
        final filteredData = tableController.getFilteredAndSortedData();
        final paginatedData = tableController.getPaginatedData(filteredData);

       
      },
    ); */

    final coldummy = [
      KyColumn(label: 'ID', name: 'id'),
      KyColumn(label: 'Kategori', name: 'category'),
      KyColumn(label: 'Nama', name: 'name'),
      KyColumn(label: 'Value', name: 'value'),
      KyColumn(label: 'Date', name: 'date'),
      KyColumn(label: 'Status', name: 'status'),
      KyColumn(label: 'Priority', name: 'priority'),
      KyColumn(
        name: 'active',
        label: const Text('Aktif'),
        onSort: null,
        isSorted: false,
      ),
      KyColumn(
        name: 'action',
        label: Text('Actions  ${selectedItem}'),
        onSort: null,
        isSorted: false,
      ),
    ];

    final rowsdummy = List.generate(100, (index) {
      final categoryIndex = random.nextInt(categories.length);
      final _active = random.nextBool();
      final _status = statuses[random.nextInt(statuses.length)];
      final _random = random.nextInt(5) + 1;
      return KyRow(
        id: index,
        cells: [
          KyCell(value: 'ID-${1000 + index}'),
          KyCell(value: categories[categoryIndex]),
          KyCell(value: 'Item ${index + 1}'),
          KyCell(
            value: double.parse(
              (random.nextDouble() * 1000).toStringAsFixed(2),
            ),
            onTap: (value) {
              debugPrint('<<<<<< $value');
            },
          ),
          KyCell(
            value: DateTime.now().subtract(Duration(days: random.nextInt(365))),
          ),

          KyCell(value: _status, widget: status(_status)),
          KyCell(
            value: _random,
            widget: Rating(rate: _random),
          ),

          KyCell(value: _active, widget: edit(_active)),

          KyCell(value: '', widget: Text('action')),
        ],
      );
    });

    return KyDataTable(
      controller: tableController,
      columns: coldummy,
      rows: rowsdummy,
    );
  }

  Widget edit(bool item) => Row(
    children: [
      /* IconButton(
        icon: const Icon(Icons.edit, size: 20),
        onPressed: () => _editItem(item, context),
      ),
      IconButton(
        icon: const Icon(Icons.delete, size: 20),
        onPressed: () => _deleteItem(item, context),
      ), */
    ],
  );
  /* 
  void _editItem(bool item, BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ItemFormDialog(
            item: item,
            onSave: (updatedItem) {
              controller.updateItem(updatedItem);

              // Update selected item if it's the one being edited
              final currentSelected = controller.selectedItem;
              if (currentSelected?.id == updatedItem.id) {
                controller.setSelectedItem(updatedItem);
              }
            },
          ),
    );
  }

  void _deleteItem(KyRow item, BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete ${item.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.deleteItem(item.id);

                  // Clear selected item if it's the one being deleted
                  final currentSelected = controller.selectedItem;
                  if (currentSelected?.id == item.id) {
                    controller.setSelectedItem(null);
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  } */
}
