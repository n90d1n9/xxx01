import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class GTable extends StatefulWidget {
  const GTable({super.key, this.datasource, this.rawdata, this.style});
  final GTableData? datasource;
  final Map? rawdata;
  final GTableStyle? style;
  @override
  State<GTable> createState() => _GTableState();
}

class GTableStyle {
  final double columnFilterHeight;
  final double columnHeight;
  final GTextAlign columnTitleAlign;

  GTableStyle(
      {this.columnFilterHeight = 10,
      this.columnHeight = 30,
      this.columnTitleAlign = GTextAlign.center});
}

enum GTextAlign { left, center, right }

class _GTableState extends State<GTable> {
  late GTableData tabledata;
  @override
  void initState() {
    super.initState();
    tabledata = widget.datasource ?? raw2Datasource(widget.rawdata!);
  }

  /// columnGroups that can group columns can be omitted.
  final List<PlutoColumnGroup> columnGroups = [
    /* PlutoColumnGroup(
        title: 'Id',
        fields: ['id'],
        backgroundColor: Colors.blue,
        expandedColumn: true,
        titleTextAlign: PlutoColumnTextAlign.center), */
    /*  PlutoColumnGroup(
        title: 'User information',
        fields: ['name', 'price'],
        titleTextAlign: PlutoColumnTextAlign.center), */
  ];

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late final PlutoGridStateManager stateManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: PlutoGrid(
          columns: gcol(tabledata),
          rows: grow(tabledata),
          columnGroups: columnGroups,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
          },
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          configuration: const PlutoGridConfiguration(
              style: PlutoGridStyleConfig(
                  //columnAscendingIcon: Icon(Icons.access_alarm),
                  columnFilterHeight: 10,
                  columnHeight: 30,
                  columnTextStyle: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      // fontStyle: FontStyle.italic,
                      fontSize: 14),
                  rowHeight: 30,
                  oddRowColor: Colors.cyan)),
          createFooter: (stateManager) {
            stateManager.setPageSize(10, notify: false); // default 40
            return PlutoPagination(
              stateManager,
              pageSizeToMove: 4,
            );
          },
        ),
      ),
    );
  }

  List<PlutoRow> grow(GTableData tabledata) {
    List<PlutoRow> rowpluto = [];
    List<GRow> rl = tabledata.rows;
    for (var i = 0; i < rl.length; i++) {
      var pcell = {for (var v in rl[i].cells) v.id: PlutoCell(value: v.value)};

      rowpluto.add(PlutoRow(
        cells: pcell,
      ));
    }
    return rowpluto;
  }

  List<PlutoColumn> gcol(GTableData data) {
    List<PlutoColumn> cols = [];
    for (var el in data.columns) {
      cols.add(PlutoColumn(
        titleTextAlign: PlutoColumnTextAlign.center,
        readOnly: false,
        backgroundColor: Colors.amber,
        textAlign: PlutoColumnTextAlign.center,
        title: el.value,
        field: el.id,
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          return Text(
              '${rendererContext.cell.value}'); //Image.asset('assets/images/cat.jpg');
        },
      ));
    }
    return cols;
  }
}

GTableData raw2Datasource(Map raw) {
  List<GCol> cols = [];
  List<GRow> rows = [];

  try {
    List cs = raw['columns'];
    List rs = raw['rows'];
    for (int c = 0; c < cs.length; c++) {
      String id = '${cs[c]['id']}';
      cols.add(GCol(id: id, value: cs[c]['value']));
    }

    for (int r = 0; r < rs.length; r++) {
      rows.add(GRow(id: '$r', cells: cells(cols, r, rs[r])));
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
  return GTableData(columns: cols, rows: rows);
}

List<GCell> cells(List<GCol> cols, int rowindex, List rowvalue) {
  List<GCell> celllist = [];
  for (var i = 0; i < cols.length; i++) {
    celllist.add(GCell(id: cols[i].id, value: rowvalue[i]));
  }

  return celllist;
}

class GTableData {
  GTableData({required this.rows, required this.columns});

  final List<GCol> columns;
  final List<GRow> rows;
}

class GCol {
  final String id;
  final Widget? child;
  final String value;
  final EdgeInsetsGeometry padding;

  GCol(
      {this.child,
      required this.id,
      required this.value,
      this.padding = const EdgeInsets.all(16.0)});
}

class GCell {
  final String id;
  final Widget? child;
  final dynamic value;
  final EdgeInsetsGeometry padding;

  GCell(
      {this.child,
      required this.id,
      this.value,
      this.padding = const EdgeInsets.all(16.0)});
}

class GRow {
  final String? id;

  final List<GCell> cells;

  GRow({this.id, required this.cells});
}
