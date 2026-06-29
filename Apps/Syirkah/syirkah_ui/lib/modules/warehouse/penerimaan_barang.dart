import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PenerimaanBarang extends ConsumerWidget {
  const PenerimaanBarang({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penerimaan Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama Pemasok :'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'PT. RST',
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text('Masuk ke Gudang :'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Head Quarter',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No. Pembelian :'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '00000014',
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text('Keterangan :'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Pembelian, PT. RST',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nomor PO :'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '',
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text('Tanggal Faktur :'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: '02/10/17',
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text('Mata Uang :'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'IDR',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                const Text('Inclusive Tax'),
                const SizedBox(width: 16.0),
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                const Text('DO'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                const Text('Jasa'),
                const SizedBox(width: 16.0),
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                const Text('Tunai'),
              ],
            ),
            const SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'No. Barang',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Deskripsi Barang',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Di Terima',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Di Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Satuan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Harga',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Disc (%)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Pjk',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Job',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            DataTable(
              columns: const [
                DataColumn(label: Text('PAHOO012')),
                DataColumn(label: Text('AH Other Product Type 12')),
                DataColumn(label: Text('8')),
                DataColumn(label: Text('0 Pcs')),
                DataColumn(label: Text('')),
                DataColumn(label: Text('564.000.00')),
                DataColumn(label: Text('0')),
                DataColumn(label: Text('4.512.000.00')),
                DataColumn(label: Text('')),
                DataColumn(label: Text('')),
              ],
              rows: const [
                DataRow(
                  cells: [
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                    DataCell(Text('')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Rincian'),
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tgl. Pengiriman :'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: '02/10/17',
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text('Term Pembayaran :'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: '0% 0 Net 0',
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bag. Pembelian :'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'N/A',
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text('Credit/Debit Memo :'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: '',
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Hapus Baris'),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Rekam Ulang'),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Buka Ulang'),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Stock List'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text('Baris : 1'),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Text('Biaya - Biaya Lain :'),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '',
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios),
              ],
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Text('Total Pajak :'),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '0.00',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Text('Total Setelah Pajak :'),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '4.512.000.00',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Text('Dibayar / Uang Muka :'),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '',
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios),
              ],
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Text('Saldo Terhutang :'),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '4.512.000.00',
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                const Text('Cetak'),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Rekam Draft'),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Rekam'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
