
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
//import 'package:syncfusion_flutter_inputs/inputs.dart';

class DataBarang extends StatefulWidget {
  const DataBarang({super.key});

  @override
  State<DataBarang> createState() => _DataBarangState();
}

class _DataBarangState extends State<DataBarang> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _kodeBarangController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _kelompokBarangController =
      TextEditingController();
  final TextEditingController _kodeAliasController = TextEditingController();
  final TextEditingController _namaAliasController = TextEditingController();
  final TextEditingController _dalamStokController = TextEditingController();
  final TextEditingController _telahDipesanKeSupplierController =
      TextEditingController();
  final TextEditingController _telahDipesanPelangganController =
      TextEditingController();
  final TextEditingController _stokMinimalController = TextEditingController();
  final TextEditingController _minimalPemesananController =
      TextEditingController();
  final TextEditingController _proyeksiPenjualanController =
      TextEditingController();
  final TextEditingController _hargaBeliSatuanController =
      TextEditingController();
  final TextEditingController _hargaJualSatuanController =
      TextEditingController();
  final TextEditingController _hargaPokokSatuanController =
      TextEditingController();
  final TextEditingController _gudangUtamaController =
      TextEditingController();
  final TextEditingController _supplierUtamaController =
      TextEditingController();
  final TextEditingController _waktuPengirimanController =
      TextEditingController();
  final TextEditingController _departemenController = TextEditingController();

  @override
  void dispose() {
    _kodeBarangController.dispose();
    _deskripsiController.dispose();
    _kelompokBarangController.dispose();
    _kodeAliasController.dispose();
    _namaAliasController.dispose();
    _dalamStokController.dispose();
    _telahDipesanKeSupplierController.dispose();
    _telahDipesanPelangganController.dispose();
    _stokMinimalController.dispose();
    _minimalPemesananController.dispose();
    _proyeksiPenjualanController.dispose();
    _hargaBeliSatuanController.dispose();
    _hargaJualSatuanController.dispose();
    _hargaPokokSatuanController.dispose();
    _gudangUtamaController.dispose();
    _supplierUtamaController.dispose();
    _waktuPengirimanController.dispose();
    _departemenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Barang'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Barang / Persediaan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _kodeBarangController,
                  decoration: const InputDecoration(
                    labelText: 'Kode Barang',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode Barang tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _deskripsiController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _kelompokBarangController,
                  decoration: const InputDecoration(
                    labelText: 'Kelompok Barang',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kelompok Barang tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _kodeAliasController,
                  decoration: const InputDecoration(
                    labelText: 'Kode Alias',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode Alias tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _namaAliasController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Alias',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama Alias tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Stok',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _dalamStokController,
                  decoration: const InputDecoration(
                    labelText: 'Dalam Stok',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Dalam Stok tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _telahDipesanKeSupplierController,
                  decoration: const InputDecoration(
                    labelText: 'Telah dipesan ke Supplier',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Telah dipesan ke Supplier tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _telahDipesanPelangganController,
                  decoration: const InputDecoration(
                    labelText: 'Telah dipesan Pelanggan',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Telah dipesan Pelanggan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _stokMinimalController,
                  decoration: const InputDecoration(
                    labelText: 'Stok Minimal',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Stok Minimal tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _minimalPemesananController,
                  decoration: const InputDecoration(
                    labelText: 'Minimal Pemesanan',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Minimal Pemesanan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _proyeksiPenjualanController,
                  decoration: const InputDecoration(
                    labelText: 'Proyeksi Penjualan',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proyeksi Penjualan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Harga',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _hargaBeliSatuanController,
                  decoration: const InputDecoration(
                    labelText: 'Harga Beli Satuan',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga Beli Satuan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _hargaJualSatuanController,
                  decoration: const InputDecoration(
                    labelText: 'Harga Jual Satuan',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga Jual Satuan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _hargaPokokSatuanController,
                  decoration: const InputDecoration(
                    labelText: 'Harga Pokok Satuan',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga Pokok Satuan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Lokasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _gudangUtamaController,
                  decoration: const InputDecoration(
                    labelText: 'Gudang Utama',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Gudang Utama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _supplierUtamaController,
                  decoration: const InputDecoration(
                    labelText: 'Supplier Utama',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Supplier Utama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _waktuPengirimanController,
                  decoration: const InputDecoration(
                    labelText: 'Waktu Pengiriman (Hari)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Waktu Pengiriman tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Lainnya',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _departemenController,
                  decoration: const InputDecoration(
                    labelText: 'Departemen',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Departemen tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Proses data
                          print('Kode Barang: ${_kodeBarangController.text}');
                          print('Deskripsi: ${_deskripsiController.text}');
                          print(
                              'Kelompok Barang: ${_kelompokBarangController.text}');
                          print('Kode Alias: ${_kodeAliasController.text}');
                          print('Nama Alias: ${_namaAliasController.text}');
                          print('Dalam Stok: ${_dalamStokController.text}');
                          print(
                              'Telah dipesan ke Supplier: ${_telahDipesanKeSupplierController.text}');
                          print(
                              'Telah dipesan Pelanggan: ${_telahDipesanPelangganController.text}');
                          print('Stok Minimal: ${_stokMinimalController.text}');
                          print(
                              'Minimal Pemesanan: ${_minimalPemesananController.text}');
                          print(
                              'Proyeksi Penjualan: ${_proyeksiPenjualanController.text}');
                          print(
                              'Harga Beli Satuan: ${_hargaBeliSatuanController.text}');
                          print(
                              'Harga Jual Satuan: ${_hargaJualSatuanController.text}');
                          print(
                              'Harga Pokok Satuan: ${_hargaPokokSatuanController.text}');
                          print(
                              'Gudang Utama: ${_gudangUtamaController.text}');
                          print(
                              'Supplier Utama: ${_supplierUtamaController.text}');
                          print(
                              'Waktu Pengiriman: ${_waktuPengirimanController.text}');
                          print(
                              'Departemen: ${_departemenController.text}');
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Atribut',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {},
                    ),
                    const Text('Pakai No Serial'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {},
                    ),
                    const Text('Pakai Lot'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {},
                    ),
                    const Text('Konsinyasi'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {},
                    ),
                    const Text('Tidak Aktif'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {},
                    ),
                    const Text('Produk Musiman'),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Satuan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text('Satuan Dasar:'),
                    SizedBox(width: 10),
                    /* Expanded(
                      child: SfDropdownButton(
                        items: const [
                          DropdownMenuItem(
                            value: 'Pcs',
                            child: Text('Pcs'),
                          ),
                          DropdownMenuItem(
                            value: 'Kg',
                            child: Text('Kg'),
                          ),
                          DropdownMenuItem(
                            value: 'Liter',
                            child: Text('Liter'),
                          ),
                        ],
                        value: 'Pcs',
                        onChanged: (value) {},
                      ),
                    ), */
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text('Satuan Laporan:'),
                    SizedBox(width: 10),
                    /* Expanded(
                      child: SfDropdownButton(
                        items: const [
                          DropdownMenuItem(
                            value: 'Pcs',
                            child: Text('Pcs'),
                          ),
                          DropdownMenuItem(
                            value: 'Kg',
                            child: Text('Kg'),
                          ),
                          DropdownMenuItem(
                            value: 'Liter',
                            child: Text('Liter'),
                          ),
                        ],
                        value: 'Pcs',
                        onChanged: (value) {},
                      ),
                    ), */
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pajak',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text('Pjk:'),
                    SizedBox(width: 10),
                    /* Expanded(
                      child: SfDropdownButton(
                        items: const [
                          DropdownMenuItem(
                            value: 'PPN',
                            child: Text('PPN'),
                          ),
                          DropdownMenuItem(
                            value: 'PPh',
                            child: Text('PPh'),
                          ),
                        ],
                        value: 'PPN',
                        onChanged: (value) {},
                      ),
                    ), */
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text('Pjk:'),
                    SizedBox(width: 10),
                    /* Expanded(
                      child: SfDropdownButton(
                        items: const [
                          DropdownMenuItem(
                            value: 'PPN',
                            child: Text('PPN'),
                          ),
                          DropdownMenuItem(
                            value: 'PPh',
                            child: Text('PPh'),
                          ),
                        ],
                        value: 'PPN',
                        onChanged: (value) {},
                      ),
                    ), */
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



/* 
Kode Barang
Isilah dengan mengetik kode unik untuk setiap jenis barang. Anda dapat juga mengisi field ini menggunakan pemindai barcode (barcode scanner) yang tercantum di setiap jenis barang sehingga sistem langsung memunculkan kode barang terkait secara otomatis.
2. Deskripsi
Isilah dengan mengetik nama barang yang dimaksud.
3. Kelompok Barang
Jika Anda memiliki fasiitas kelompok data, dengan ini Anda harus membuat terlebih dahulu kelompok barang untuk mengelompokkan satu berbagai jenis barang ke satu kelompok. Misalnya kelompok barang mentah terdiri dari tepung terigu, gula, mentega, tepung cokelat dsb, kelompok barang jadi terdiri dari roti cokelat, roti tawar, dsb. Dengan demikian, setiap Anda membuat satu jenis barang dan memilih kelompoknya, sistem langsung menyeragamkan informasi metode HPP dan akun penting terkait begitu juga memudahkan Anda membedakan barang-barang yang Anda kelompokkan. Anda dapat juga membuat kelompok barang dari modul Data-data > Data Lainnya > Kelompok Produk. Jika Anda tidak memiliki fasilitas ini dan memang tidak memerlukannya, abaikan petunjuk ini.
4. Satuan Dasar
Klik tombol ini untuk menguraikan satuan yang tersedia dan pilih salah satu satuan yang ada agar sistem dapat membuat acuan utama bagi barang masuk dan keluar selalu menggunakan satuan ini dalam transaksi, misalnya kilogram, gram, liter, dsb. Jika satuan pengukuran tidak tersedia di pilihan ini, Anda harus membuatnya terlebih dahulu dari modul Data-data > Satuan Pengukuran
  © 2014 PT Zahir Internasional 68
(lihat selengkapnya di sini).
5. Satuan Laporan
Klik tombol ini untuk menguraikan satuan yang tersedia dan pilih salah satu satuan yang ada agar sistem dapat membuat acuan lain bagi barang masuk dan keluar selalu menggunakan satuan ini untuk ditampilkan di laporan-laporan terkait (laporan barang) saja, bukan di transaksi. Jika satuan pengukuran tidak tersedia di pilihan ini, Anda harus membuatnya terlebih dahulu dari modul Data-data > Satuan Pengukuran (lihat selengkapnya di sini). Pastikan satuan laporan ini bukanlah satuan/ unit dasar di Daftar Satuan Pengukuran namun harus memiliki keterkaitan dengan satuan dasar sebagai satuan konversinya.
6. Pakai No. Serial
Tandakan opsi ini jika satu jenis barang ini menggunakan nomor serial. Dengan demikian setiap Anda hendak mencatat barang baru di saldo awal persediaan atau transaksi, sistem akan meminta Anda untuk mengisi nomor serial masuk atau keluar. Contoh konkret penggunaan nomor serial salah satunya nomor IMEI pada perangkat keras barang elektronik.
7. Pakai Lot
Tandakan opsi ini jika satu jenis barang menggunakan nomor lot. Ini berfungsi sebagai nomor batch sekaligus tanggal kedaluwarsa setiap barang. Dengan demikian, sistem akan meminta Anda untuk mengisi nomor lot atas barang masuk dan keluar. Contoh konkret penggunaan nomor lot salah satunya pada produk-produk farmasi (obat).
8. Konsinyasi
Tandakan opsi ini jika barang ini berstatus sebagai barang titipan dari consignor sehingga barang ini akan tersedia di daftar barang konsinyasi agar Anda dapat menginput transaksi penerimaan barang konsinyasi dari Modul Persediaan > Penerimaan Barang Konsinyasi atau Retur Barang Konsinyasi.
9. Tidak Aktif
Tandakan opsi ini jika barang ini sudah tidak digunakan lagi dan bersaldo nol sehingga sistem akan menyembunyikan barang ini dari daftar barang. Jika sewaktu-waktu Anda hendak memunculkannya lagi, silakan buka modul Data-data > klik menu Data Produk > klik Daftar Barang > Klik Filter > Klik Lengkap > Ubah status menjadi Tidak Aktif > Rekam. Selanjutnya akan muncul Daftar Barang yang tidak aktif. Cari barang yang akan diaktifkan lagi lalu klik edit lalu hilangkan tanda di opsi Tidak Aktif lalu Rekam. Selanjutnya barang yang dimaksud muncul lagi di Daftar Barang dan siap untuk Anda gunakan lagi.
10. Produk Musiman
Tandakan opsi ini jika Anda ingin memproyeksikan penjualan barang yang dipengaruhi atau tidak dipengaruhi musim. Pengaturan lebih lanjut Produk Musiman ini dapat dilakukan di modul Persediaan > Manajemen Persediaan > Proyeksi Penjualan.
11. Kode Alias
Isilah kode lain untuk jenis barang yang sama. Dengan demikian Anda dapat memilih barang yang dimaksud di daftar barang dengan mencari berdasarkan kode alias ketika input transaksi.
12. Nama Alias
Isilah nama barang lain untuk jenis barang yang sama. Dengan demikian Anda dapat memilih barang yang dimaksud di daftar barang dengan mencari berdasarkan nama alias ketika input transaksi. Nama alias ini digunakan biasanya untuk memberi nama yang berbeda-beda untuk barang yang sama berdasarkan regionalnya.
13. Dalam Stok
Berisi keterangan jumlah stok yang tercatat di sistem. Anda tidak dapat mengetik langsung field ini melainkan dengan adanya saldo awal atau transaksi yang terjadi.
© 2014 PT Zahir Internasional 69

14. Telah Dipesan ke Supplier
Berisi jumlah barang yang telah dipesan kepada supplier. Jumlah pesanan tersebut tidak dapat diketik manual melainkan ia mengacu pada purchase order untuk produk tersebut.
15. Telah Dipesan Pelanggan
Berisi jumlah barang yang telah dipesan oleh pelanggan. Jumlah pesanan tersebut tidak dapat diketik manual melainkan ia mengacu pada sales order untuk produk tersebut.
16. Stok Minimal
Jumlah batas minimun barang yang diperkenankan. Jika setiap input transaksi yang dapat mengurangi barang terkait mengakibatkan jumlah mendekati minimum, sistem akan memberi notifikasi di modul Laporan > Reminder, dan harus dilakukan pesanan pembelian lagi. Anda harus mengatur lebih lanjut penggunaan fasilitas Auto-Purchase Order dari modul Persediaan > Manajemen Persediaan.
17. Minimal Pemesanan
Jumlah barang minumum untuk melakukan pesanan pembelian (PO).
18. Proyeksi Penjualan
Isilah dengan jumlah barang yang diproyeksikan dijual. Anda harus mengatur proyeksi penjualan dari modul Persediaan > Manajemen Persediaan.
19. Harga Beli Satuan dan Pjk
Berisi keterangan harga beli terakhir setiap satuan barang. Ia akan muncul otomatis jika telah adanya saldo awal persediaan atau transaksi pembelian. Pjk adalah field pajak yang bisa Anda isi dengan akun beli atas barang yang dimaksud sehingga setiap Anda menginput transaksi pembelian atau pesanan pembelian, sistem secara otomatis mengenakan pajak atas barang tersebut. Jika barang yang dimaksud tidak dikenakan pajak, pilih no VAT (tanda titik) atau jangan memilih apapun di field Pjk ini.
20. Harga Jual Satuan dan PJk
Isilah field ini dengan harga jual konstan untuk setiap satuan barang ini sehingga sistem akan memunculkan harga jual yang dimaksud setiap Anda menginput transaksi penjualan atau pesanan penjualan. Anda dapat mengabaikan field ini atau dapat juga menghapus isi field ini sewaktu-waktu. Pjk adalah field pajak yang bisa Anda isi dengan akun jual atas barang yang dimaksud sehingga setiap Anda menginput transaksi penjualan atau pesanan penjualan, sistem secara otomatis mengenakan pajak atas barang tersebut. Jika barang yang dimaksud tidak dikenakan pajak, pilih no VAT (tanda titik) atau jangan memilih apapun di field Pjk ini.
21. Harga Pokok Satuan
Berisi harga pokok setiap satuan barang berdasarkan metode harga pokok yang dipilih yaitu FIFO, LIFO, atau Average. Field ini akan terisi secara otomatis setelah adanya saldo awal persediaan atau adanya transaksi yang melibatkan barang ini.
22. Gudang Utama
Klik tombol ini untuk memilih gudang utama sebagai acuan baku penyimpan barang ini, misalnya gudang Head Quarter.
23. Supplier Utama
Klik tombol ini untuk memilih pemasok utama yang dijadikan sebagai pemasok utama sehingga sistem akan menampilkan pemasok ini secara otomatis setiap Anda menginput Pembelian. Anda dimungkinkan untuk mengubah pemasok ini saat transaksi pembelian berlangsung atau mengubahnya dari data produk ini.
24. Waktu Pengiriman (Hari)
Isi dengan batas maksimum masa pengiriman barang dengan acuan dari tanggal pengiriman di penginputan transaksi.
© 2014 PT Zahir Internasional 70

25. Departemen
Klik tombol ini untuk memilih departemen yang memiliki keterkaitan dengan barang ini, misalnya departemen yang menginput pembelian barang, penjualan barang, dsb. Di sini Anda dapat memfilter departemen di laporan barang terkait sehingga jika Anda memilih departemen yang dimaksud, laporan hanya akan menampilkan barang yang terkait dengan departemen yang dipilih.

 */