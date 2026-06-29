//import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//import 'package:syncfusion_flutter_charts/charts.dart';

/*class CurrencyData extends StatefulWidget {
  const CurrencyData({super.key});

  @override
  State<CurrencyData> createState() => _CurrencyDataState();
}*/
/*
class _CurrencyDataState extends State<CurrencyData> {
  final List<Currency> _currencies = [
    Currency('USD', 'Dollar', '\$', 11000, '1/31/2014'),
    // Add more currencies here
  ];

  late CurrencyDataSource _currencyDataSource;

  @override
  void initState() {
    super.initState();
    _currencyDataSource = CurrencyDataSource(_currencies);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Mata Uang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Mata Uang'),
                ),
                const SizedBox(width: 16.0),
                const Text('Akun Penting'),
              ],
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Kode Mata Uang',
                hintText: 'USD',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nama Mata Uang',
                hintText: 'Dollar',
              ),
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Text('Simbol:'),
                SizedBox(width: 16.0),
                TextField(
                  decoration: InputDecoration(
                    hintText: '\$',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Text('Kurs Tukar:'),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '11.000',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Text('Per Tanggal:'),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '1/31/2014',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Set Nilai Kurs'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Baru'),
            ),
            const SizedBox(height: 16.0),
            *//*Expanded(
              child: SfDataGrid(
                source: _currencyDataSource,
                columns:  [
                  GridColumn(
                    columnName: 'Kode',
                    label: const Text('Kode Mata Uang'),
                  ),
                  GridColumn(
                    columnName: 'Nama',
                    label: const Text('Nama Mata Uang'),
                  ),
                  GridColumn(
                    columnName: 'Simbol',
                    label: const Text('Simbol'),
                  ),
                  GridColumn(
                    columnName: 'Kurs',
                    label: const Text('Kurs Tukar'),
                  ),
                  GridColumn(
                    columnName: 'Tanggal',
                    label: const Text('Per Tanggal'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SfCartesianChart(
                series: [
                  LineSeries<Currency, String>(
                    dataSource: _currencies,
                    xValueMapper: (Currency currency, _) => currency.kode,
                    yValueMapper: (Currency currency, _) => currency.kurs,
                  ),
                ],
              ),
            ),*//*
          ],
        ),
      ),
    );
  }
}*/
/*

class Currency {
  final String kode;
  final String nama;
  final String simbol;
  final int kurs;
  final String tanggal;

  Currency(this.kode, this.nama, this.simbol, this.kurs, this.tanggal);
}

class CurrencyDataSource extends DataGridSource {
  CurrencyDataSource(this.currencies);

  final List<Currency> currencies;

  @override
  List<DataGridRow> get rows => currencies.map((currency) {
    return DataGridRow(cells: [
      DataGridCell<String>(columnName: 'Kode', value: currency.kode),
      DataGridCell<String>(columnName: 'Nama', value: currency.nama),
      DataGridCell<String>(columnName: 'Simbol', value: currency.simbol),
      DataGridCell<int>(columnName: 'Kurs', value: currency.kurs),
      DataGridCell<String>(columnName: 'Tanggal', value: currency.tanggal),
    ]);
  }).toList();

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Text(dataGridCell.value.toString()),
        );
      }).toList(),
    );
  }
}
*/
