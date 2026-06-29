import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class GTableLarge extends StatefulWidget {
  const GTableLarge({super.key, this.datasource, this.rawdata});
  final GTableLargeData? datasource;
  final Map? rawdata;
  @override
  State<GTableLarge> createState() => _GTableLargeState();
}

class _GTableLargeState extends State<GTableLarge> {
  late GDataSource _datasource;
  late GTableLargeData tabledata;
  @override
  void initState() {
    super.initState();
    tabledata = widget.datasource ?? raw2Datasource(widget.rawdata!);
    _datasource = GDataSource(data: tabledata);
  }

  @override
  Widget build(BuildContext context) {
    return SfDataGrid(
        allowFiltering: true,
        allowSorting: true,
        source: _datasource,
        columnWidthMode: ColumnWidthMode.fill,
        columns: <GridColumn>[
          ...gcol(tabledata),
        ],
        selectionMode: SelectionMode.multiple,
        
        );
  }

  List<GridColumn> gcol(GTableLargeData data) {
    List<GridColumn> cols = [];
    for (var el in data.columns!) {
      cols.add(GridColumn(
          columnName: el.id,
          label: Container(
              padding: el.padding,
              alignment: Alignment.center,
              child: el.child ?? Text(el.value!))));
    }
    return cols;
  }
}

GTableLargeData raw2Datasource(Map raw) {
  List<GCol> cols = [];
  List<GRow> rows = [];

  try {
    List cs = raw['columns'];
    for (int c = 0; c < cs.length; c++) {
      cols.add(GCol(id: '${cs[c]}', value: cs[c]));
    }
    List rs = raw['rows'];
    for (int r = 0; r < rs.length; r++) {
      rows.add(GRow(id: '${rs[r]}', value: rs[r]));
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }

  return GTableLargeData(columns: cols, rows: rows);
}

class GTableLargeData {
  GTableLargeData({this.rows, this.columns});

  final List<GCol>? columns;
  final List<GRow>? rows;
}

class GCol {
  final String id;
  final Widget? child;
  final String? value;
  final EdgeInsetsGeometry padding;

  GCol(
      {this.child,
      required this.id,
      this.value,
      this.padding = const EdgeInsets.all(16.0)});
}

class GRow {
  final String? id;
  final dynamic value;
  final Widget? child;

  GRow({this.id, this.child, this.value});
}

class GDataSource extends DataGridSource {
  List<DataGridRow> _data = [];

  GDataSource({required GTableLargeData data}) {
     print('----GDataSource------${data.rows!}--');
    _data = data.rows!
        .map<DataGridRow>((d) => DataGridRow(cells: [...cells(d)]))
        .toList();
  }

  List<DataGridCell> cells(GRow data) {
    List<DataGridCell> list = [];
    List row = data.value;
     print('----cell--------');
    for (int i = 0; i < row.length; i++) {
      print(row[2]);
      list.add(DataGridCell(columnName: '${row[2]}', value: row[i]));
    }
    return list;
  }

  @override
  List<DataGridRow> get rows => _data;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
