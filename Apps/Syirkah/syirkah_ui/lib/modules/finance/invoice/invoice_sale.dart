import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopUI extends ConsumerWidget {
  const DesktopUI({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penjualan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama Pelanggan:'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'PT. JKL Teknologi',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Keluar dari Gudang:'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Head Quarter',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No. Faktur:'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '00000021',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Keterangan:'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Penjualan, PT. JKL Teknologi',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nomor SO:'),
                      const TextField(
                        decoration: InputDecoration(
                          hintText: '',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Tanggal Faktur:'),
                      Row(
                        children: [
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: '02/10/17',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.calendar_today),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mata Uang:'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'IDR',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                const Text('Inclusive Tax'),
                const SizedBox(width: 16),
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
                const SizedBox(width: 16),
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                const Text('Tunai'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Expanded(child: Text('No. Barang', style: TextStyle(color: Colors.white))),
                  Expanded(child: Text('Deskripsi Barang', style: TextStyle(color: Colors.white))),
                  Expanded(child: Text('Di Kirim', style: TextStyle(color: Colors.white))),
                  Expanded(child: Text('Di Order', style: TextStyle(color: Colors.white))),
                  Expanded(child: Text('Satuan', style: TextStyle(color: Colors.white))),
                  Expanded(child: Text('Harga', style: TextStyle(color: Colors.white))),
                  Expanded(child: Text('Disc (%)', style: TextStyle(color: Colors.white))),
                  Expanded(child: Text('Total', style: TextStyle(color: Colors.white))),
                  Expanded(child: Text('Pjk', style: TextStyle(color: Colors.white))),
                  Expanded(child: Text('Job', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Expanded(child: Text('PAH00012')),
                  Expanded(child: Text('AH Other Product Type 12')),
                  Expanded(child: Text('8')),
                  Expanded(child: Text('0 Pcs')),
                  Expanded(child: Text('570.000.00')),
                  Expanded(child: Text('0')),
                  Expanded(child: Text('4.560.000.00')),
                  Expanded(child: Text('.')),
                  Expanded(child: Text('.')),
                  Expanded(child: Text('.')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Rincian'),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tgl. Pengiriman:'),
                  Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '02/10/17',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Term Pembayaran:'),
                  Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '0% 0 Net 0',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.grid_view),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Salesman:'),
                  Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'N/A',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.grid_view),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Credit/Debit Memo:'),
                  Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.grid_view),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Hapus Baris'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Rekam Ulang'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Buka Ulang'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Stock List'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Biaya - Biaya Lain:'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Pajak:'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '0.00',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Setelah Pajak:'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '4.560.000.00',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dibayar / Uang Muka:'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '4.560.000.00',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saldo Terhutang:'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '0.00',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                const Text('Cetak'),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Rekam Draft'),
                ),
                const SizedBox(width: 16),
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
