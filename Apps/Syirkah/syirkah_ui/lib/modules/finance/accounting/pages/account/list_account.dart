/*
import 'package:flutter/material.dart';
//import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class RekeningDataGrid extends StatefulWidget {
  const RekeningDataGrid({super.key});

  @override
  State<RekeningDataGrid> createState() => _RekeningDataGridState();
}


List<Rekening> rekeningData = [
  Rekening(
    klasifikasi: 'Harta',
    kodeRekening: '1100-00-010',
    namaRekening: 'Kas Kecil',
    namaAliasRekening: 'Petty Cash',
  ),
  Rekening(
    klasifikasi: 'Harta',
    kodeRekening: '1100-00-020',
    namaRekening: 'Kas',
    namaAliasRekening: 'Cash in Hand',
  ),
  Rekening(
    klasifikasi: 'Harta',
    kodeRekening: '1100-00-030',
    namaRekening: 'Kas (USD)',
    namaAliasRekening: 'Cash in Hand',
  ),
  Rekening(
    klasifikasi: 'Harta',
    kodeRekening: '1200-00-010',
    namaRekening: 'Bank',
    namaAliasRekening: 'Checking Account',
  ),
];
class _RekeningDataGridState extends State<RekeningDataGrid> {
  late RekeningDataSource _rekeningDataSource;

  @override
  void initState() {
    super.initState();
    _rekeningDataSource = RekeningDataSource([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Rekening'),
      ),
      body: SfDataGrid(
        source: _rekeningDataSource,
        columns: <GridColumn>[
          GridColumn(
            columnName: 'Klasifikasi',
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Klasifikasi'),
            ),
          ),
          GridColumn(
            columnName: 'Kode Rekening',
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Kode Rekening'),
            ),
          ),
          GridColumn(
            columnName: 'Nama Rekening',
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Nama Rekening'),
            ),
          ),
          GridColumn(
            columnName: 'Nama Alias Rekening',
            label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Nama Alias Rekening'),
            ),
          ),
        ],
      ),
    );
  }
}

class Rekening {
  final String klasifikasi;
  final String kodeRekening;
  final String namaRekening;
  final String namaAliasRekening;

  Rekening({
    required this.klasifikasi,
    required this.kodeRekening,
    required this.namaRekening,
    required this.namaAliasRekening,
  });
}


class RekeningDataSource extends DataGridSource {
  RekeningDataSource(this._rekeningData) {
    _rekeningData = rekeningData
        .map((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'Klasifikasi', value: e.klasifikasi),
              DataGridCell<String>(columnName: 'Kode Rekening', value: e.kodeRekening),
              DataGridCell<String>(columnName: 'Nama Rekening', value: e.namaRekening),
              DataGridCell<String>(columnName: 'Nama Alias Rekening', value: e.namaAliasRekening),
            ]))
        .toList();
  }

  List<DataGridRow> _rekeningData = [];

  @override
  List<DataGridRow> get rows => _rekeningData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(e.value.toString()),
        );
      }).toList(),
    );
  }
}
*/
