/*
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InvoiceList extends StatefulWidget {
  const InvoiceList({super.key});

  @override
  State<InvoiceList> createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  late InvoiceDataSource _invoiceDataSource;

  @override
  void initState() {
    super.initState();
    _invoiceDataSource = InvoiceDataSource(invoiceData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagihan Pembelian'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Tambah Tagihan Pembelian'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Import Tagihan Pembelian'),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Semua'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Unpaid'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Partial'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Paid'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SfDataGrid(
              source: _invoiceDataSource,
              columns:  [
                GridColumn(
                  columnName: 'nomor',
                  label: const Text('Nomor'),
                ),
                GridColumn(
                  columnName: 'reference',
                  label: const Text('Reference'),
                ),
                GridColumn(
                  columnName: 'vendor',
                  label: const Text('Vendor'),
                ),
                GridColumn(
                  columnName: 'tanggal',
                  label: const Text('Tanggal'),
                ),
                GridColumn(
                  columnName: 'jatuhTempo',
                  label: const Text('Tanggal Jatuh Tempo'),
                ),
                GridColumn(
                  columnName: 'status',
                  label: const Text('Status'),
                ),
                GridColumn(
                  columnName: 'sisaTagihan',
                  label: const Text('Sisa Tagihan'),
                ),
                GridColumn(
                  columnName: 'total',
                  label: const Text('Total'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Invoice {
  Invoice({
    required this.nomor,
    required this.reference,
    required this.vendor,
    required this.tanggal,
    required this.jatuhTempo,
    required this.status,
    required this.sisaTagihan,
    required this.total,
  });

  final String nomor;
  final String reference;
  final String vendor;
  final DateTime tanggal;
  final DateTime jatuhTempo;
  final String status;
  final double sisaTagihan;
  final double total;
}

class InvoiceDataSource extends DataGridSource {
  InvoiceDataSource(this.invoiceData) {
    _invoiceData = invoiceData
        .map((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'nomor', value: e.nomor),
              DataGridCell<String>(columnName: 'reference', value: e.reference),
              DataGridCell<String>(columnName: 'vendor', value: e.vendor),
              DataGridCell<DateTime>(columnName: 'tanggal', value: e.tanggal),
              DataGridCell<DateTime>(
                  columnName: 'jatuhTempo', value: e.jatuhTempo),
              DataGridCell<String>(columnName: 'status', value: e.status),
              DataGridCell<double>(
                  columnName: 'sisaTagihan', value: e.sisaTagihan),
              DataGridCell<double>(columnName: 'total', value: e.total),
            ]))
        .toList();
  }

  List<Invoice> invoiceData;
  List<DataGridRow> _invoiceData = [];

  @override
  List<DataGridRow> get rows => _invoiceData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    */
/* return DataGridRowAdapter(
      cells: row.getCells(),
    ); *//*

    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          */
/* alignment: (dataGridCell.columnName == 'id' ||
                  dataGridCell.columnName == 'salary')
              ? Alignment.centerRight
              : Alignment.centerLeft, *//*

          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
          ));
    }).toList());
  }
}

final List<Invoice> invoiceData = [
  Invoice(
    nomor: 'PV/00181',
    reference: '',
    vendor: 'Luruh Pradana Wahyuni',
    tanggal: DateTime(2020, 4, 24),
    jatuhTempo: DateTime(2020, 5, 11),
    status: 'Unpaid',
    sisaTagihan: 343000.00,
    total: 343000.00,
  ),
  Invoice(
    nomor: 'PV/00180',
    reference: '',
    vendor: 'Dalima Pratiwi Ardianto',
    tanggal: DateTime(2020, 4, 24),
    jatuhTempo: DateTime(2020, 5, 14),
    status: 'Paid',
    sisaTagihan: 0.00,
    total: 98000.00,
  ),
];
*/
