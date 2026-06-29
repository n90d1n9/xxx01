
import 'package:flutter/material.dart';

class Gl01 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Table'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Tanggal')),
            DataColumn(label: Text('Nama Akun')),
            DataColumn(label: Text('Ref')),
            DataColumn(label: Text('Debit')),
            DataColumn(label: Text('Kredit')),
            DataColumn(label: Text('Saldo')),
          ],
          rows: [
            DataRow(
              cells: [
                DataCell(Text('Januari 1')),
                DataCell(Text('Modal')),
                DataCell(Text('')),
                DataCell(Text('2,200,000,000')),
                DataCell(Text('')),
                DataCell(Text('2,200,000,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 7')),
                DataCell(Text('Kendaraan Truk')),
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('250,000,000')),
                DataCell(Text('1,950,000,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 10')),
                DataCell(Text('Uang muka Peralatan')),
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('39,970,000')),
                DataCell(Text('1,910,030,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 15')),
                DataCell(Text('Tanah & Bangunan')),
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('1,430,000,000')),
                DataCell(Text('480,030,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 17')),
                DataCell(Text('Perlengkapan Kantor')),
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('30,280,000')),
                DataCell(Text('449,750,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 18')),
                DataCell(Text('Kendaraan Excavator')),
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('275,000,000')),
                DataCell(Text('174,750,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 19')),
                DataCell(Text('Biaya Asuransi')),
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('2,959,000')),
                DataCell(Text('171,791,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 21')),
                DataCell(Text('Biaya listrik, tlp & air')),
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('1,014,300')),
                DataCell(Text('170,776,700')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 30')),
                DataCell(Text('Pendapatan Jasa')),
                DataCell(Text('')),
                DataCell(Text('950,000,000')),
                DataCell(Text('')),
                DataCell(Text('1,120,776,700')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 31')),
                DataCell(Text('Biaya Gaji')),
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('150,000,000')),
                DataCell(Text('970,776,700')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 30')),
                DataCell(Text('Pendapatan Jasa')),
                DataCell(Text('')),
                DataCell(Text('300,000,000')),
                DataCell(Text('')),
                DataCell(Text('300,000,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 17')),
                DataCell(Text('Kas')),
                DataCell(Text('')),
                DataCell(Text('30,280,000')),
                DataCell(Text('')),
                DataCell(Text('30,280,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 10')),
                DataCell(Text('Hutang Usaha')),
                DataCell(Text('')),
                DataCell(Text('10,030,000')),
                DataCell(Text('')),
                DataCell(Text('10,030,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 10')),
                DataCell(Text('Kas')),
                DataCell(Text('')),
                DataCell(Text('39,970,000')),
                DataCell(Text('')),
                DataCell(Text('39,970,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 18')),
                DataCell(Text('Kas')),
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('275,000,000')),
                DataCell(Text('314,970,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 15')),
                DataCell(Text('Kas')),
                DataCell(Text('')),
                DataCell(Text('130,000,000')),
                DataCell(Text('')),
                DataCell(Text('130,000,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 15')),
                DataCell(Text('Kas')),
                DataCell(Text('')),
                DataCell(Text('1,300,000,000')),
                DataCell(Text('')),
                DataCell(Text('1,300,000,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 7')),
                DataCell(Text('Kas')),
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('250,000,000')),
                DataCell(Text('250,000,000')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Januari 18')),
                DataCell(Text('Hutang usaha')),
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('175,000,000')),
                DataCell(Text('425,000,000')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
