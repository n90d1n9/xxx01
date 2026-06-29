/*

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProyekData extends StatefulWidget {
  const ProyekData({super.key});

  @override
  _ProyekDataState createState() => _ProyekDataState();
}

class _ProyekDataState extends State<ProyekData> {
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

class Employee {
  Employee({
    required this.noProyek,
    required this.fasePekerjaan,
    required this.kodeBiaya,
    required this.anggaranBelanja,
    required this.realisasi,
  });

  final String noProyek;
  final String fasePekerjaan;
  final String kodeBiaya;
  final double anggaranBelanja;
  final double realisasi;
}

List<Employee> employeeData = [
  Employee(
    noProyek: 'Pemrosesan Kegiatan 1',
    fasePekerjaan: 'No Phase',
    kodeBiaya: 'No Cost Code',
    anggaranBelanja: 0.00,
    realisasi: 0.00,
  ),
  Employee(
    noProyek: 'Pemrosesan Kegiatan 1',
    fasePekerjaan: '03-Preparation',
    kodeBiaya: '01-Labor',
    anggaranBelanja: 3500000.00,
    realisasi: 4480000.00,
  ),
];

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
*/
