
import 'package:flutter/material.dart';

class ProyekData extends StatefulWidget {
  const ProyekData({super.key});

  @override
  ProyekDataState createState() => ProyekDataState();
}

class ProyekDataState extends State<ProyekData> {
  late EmployeeDataSource _employeeDataSource;

  @override
  void initState() {
    _employeeDataSource = EmployeeDataSource(employeeData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syncfusion Flutter DataGrid'),
      ),
      body: SfDataGrid(
        source: _employeeDataSource,
        columns: <GridColumn>[
          GridColumn(
              columnName: 'No. Proyek',
              label: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: const Text(
                  'No. Proyek',
                  overflow: TextOverflow.ellipsis,
                ),
              )),
          GridColumn(
              columnName: 'Fase Pekerjaan',
              label: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: const Text(
                  'Fase Pekerjaan',
                  overflow: TextOverflow.ellipsis,
                ),
              )),
          GridColumn(
              columnName: 'Kode Biaya',
              label: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: const Text(
                  'Kode Biaya',
                  overflow: TextOverflow.ellipsis,
                ),
              )),
          GridColumn(
              columnName: 'Anggaran Belanja',
              label: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: const Text(
                  'Anggaran Belanja',
                  overflow: TextOverflow.ellipsis,
                ),
              )),
          GridColumn(
              columnName: 'Realisasi',
              label: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: const Text(
                  'Realisasi',
                  overflow: TextOverflow.ellipsis,
                ),
              )),
        ],
      ),
    );
  }
}


class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource(this.employeeData) {
    _buildData();
  }

  List<Employee> employeeData;
  List<DataGridRow> employeeRows = [];

  void _buildData() {
    employeeRows = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'No. Proyek', value: e.noProyek),
              DataGridCell<String>(
                  columnName: 'Fase Pekerjaan', value: e.fasePekerjaan),
              DataGridCell<String>(
                  columnName: 'Kode Biaya', value: e.kodeBiaya),
              DataGridCell<double>(
                  columnName: 'Anggaran Belanja', value: e.anggaranBelanja),
              DataGridCell<double>(
                  columnName: 'Realisasi', value: e.realisasi),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => employeeRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(dataGridCell.value.toString()),
      );
    }).toList());
  }
}
