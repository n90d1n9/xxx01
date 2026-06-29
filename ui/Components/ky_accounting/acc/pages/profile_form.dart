import 'package:flutter/material.dart';

class DataNamaDanAlamat extends StatefulWidget {
  const DataNamaDanAlamat({super.key});

  @override
  State<DataNamaDanAlamat> createState() => _DataNamaDanAlamatState();
}

class _DataNamaDanAlamatState extends State<DataNamaDanAlamat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Nama dan Alamat'),
      ),
      body: 
      Expanded(child: 
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: 
        SingleChildScrollView(
            child: 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Umum'),
                ),
                const SizedBox(width: 16.0),
                const Text('Alamat & Catatan'),
              ],
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'ID',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Perusahaan',
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tipe',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Customer',
                  child: Text('Customer'),
                ),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Klasifikasi',
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.grid_view),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Kontak Person',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Jabatan',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Telpon 1',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Telpon 2',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Fax',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Hp',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Website',
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Mata Uang',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'IDR',
                        child: Text('IDR'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Baru'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Jenis',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Company',
                        child: Text('Company'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Golongan',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'General',
                        child: Text('General'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 16.0),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.grid_view),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'NPWP',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Row(
                    children: [
                      Text('Rp'),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text('Term of Payment'),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Hari Discount',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Hari Jatuh Tempo',
              ),
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Discount Awal',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Text('%'),
              ],
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Denda Keterlambatan',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Text('%'),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Batal'),
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
      )),
    ));
  }
}



/* 
Pilihlah lebih awal tipe nama alamat. Tipe yang tersedia yaitu Customer, Vendor, Employee, dan Others. Nama yang memiliki setiap tipe tersebut akan tampil di daftar nama alamat setiap transaksi terkait. Contoh: PT XYZ bertipe Customer hanya akan tampil di modul Penjualan dan Kas & Bank.
2. ID
Merupakan kode unik tiap nama alamat. Anda harus mengisi field ini dengan angka, huruf, tanda baca, atau kombinasi ketiganya.
3. Mata Uang
Tetapkan mata uang standar untuk subyek ini agar sistem dapat mengotomatiskan mata uang ini setiap adanya kegiatan transaksi. Anda tidak dapat mengubah mata uang yang telah ditetapkan di awal jika subyek ini telah digunakan dalam transaksi. Jika pilihan mata uang yang Anda inginkan tidak ada, Anda harus membuat terlebih dahulu mata uang baru di modul Data-data > Data Mata Uang (klik selengkapnya di sini).
4. Perusahaan/ Nama
Isikan nama perusahaan/ nama untuk mengidentifikasikan subyek sesuai dengan tipe yang telah Anda pilih sebelumnya yaitu Customer, Vendor, Employee, atau Others. Perusahaan/ Nama ini akan tampil di daftar nama alamat setiap transaksi sesuai dengan tipenya.
5. Jenis
Field ini akan tampil jika Anda memilih tipe Customer, Vendor, atau Others.
6. Klasifikasi
Klik tombol ini untuk memilih atau membuat baru klasifikasi. Klasifikasi digunakan untuk memudahkan Anda mengelompokkan data subyek sesuai dengan keperluan berdasarkan tebaran geografis, jenis kelamin, strata sosial, dll. Klasifikasi ini dapat juga menyeragamkan Term of Payment bagi tipe Customer dan Vendor yang digunakan dalam transaksi penjualan atau pembelian secara kredit.
7. Golongan
Klik tombol ini untuk memillih atau membuat golongan baru. Field ini hanya tampil jika Anda memilih tipe Customer atau Employee. Anda dimungkinkan menggunakan fasilitas ini sebagai tambahan fasilitas klasifikasi secara spesifik untuk:
• Membedakan Customer berdasarkan jenis usaha atau level usaha seperti level grosir atau eceran. Di sini Anda dapat menentukan diskon baku. Dengan golongan ini Anda dapat juga menentukan harga jual bertingkat tertentu secara otomatis jika Anda memiliki fasilitas multiprice.
• Membedakan Employee berdasarkan level kerja. Di sini Anda dapat menentukan persentase komisi pegawai berdasarkan golongan yang dibuat.
8. Kontak Person
Isi dengan nama penanggung jawab terkait dengan Vendor, Customer, atau Others yang bisa Anda hubungi. Nama yang diisi ini nantikan akan tampil di faktur/ invoice.
9. NPWP
Isi dengan Nomor Pokok Wajib Pajak Vendor, Customer, Employee, atau Others. NPWP ini akan tampil di setiap pencetakan Faktur Pajak yang bisa dicetak dan diserahkan kepada Customer setelah menginput penjualan.
10. Jabatan
Isi dengan jabatan yang dijabat oleh Kontak Person. Jabatan ini akan tampil di faktur/ invoice misalnya Faktur Penjualan.

11. Batas Kredit
Isi dengan batas terbesar nominal penjualan/ pembelian kredit yang diperkenankan bagi Customer atau kepada Vendor. Dengan demikian, sistem akan menolak posting transaksi terkait jika terjadi penginputan nominal transaksi penjualan/ pembelian kredit melebihi batas kreditnya. Atur lebih lanjut penolakan posting atau sekadar pengingat oleh sistem dari menu Setting > Setup Program > Setelan Transaksi > Transaksi Penjualan > Beri centang di opsi "Penjualan yang melebihi batas kredit tidak bisa diposting sama sekali" agar sistem betul-betul menolak posting atau hilangkan centang di opsi tersebut agar sistem hanya menampilkan peringatan untuk melanjutkan posting atau membatalkan posting.
12. Telepon 1, Telepon 2, Fax, HP, Email, Website
Isikan sesuai dengan fieldnya masing-masing yang terkait dengan nomor telepon, faksimili, nomor ponsel, alamat email, dan website perusahaan. Field yang diisi ini akan tampil di faktur/ invoice.
13. Term of Payment
Field ini hanya tampil jika Anda memilih tipe Customer atau Vendor sebagai aturan pembayaran piutang usaha atau utang usaha. Isi termin pembayaran ini tergantung dari ada atau tiadanya ketetapan ketika transaksi penjualan atau pembelian terjadi.
Hari Discount: Mengidentifikasi rentang jumlah hari yang termasuk masa diskon dalam bentuk persentase.
Hari Jatuh Tempo: Mengidentifikasi rentang jumlah hari pembayaran secara normal.
Discount Awal: Persentase diskon yang diperoleh jika membayar selama hari diskon.
Denda Keterlambatan: Persentase denda yang dikenakan jika pembayaran dilakukan setelah hari jatuh tempo.
Jika Term of Payment ini diisi, sistem akan mengacu secara baku pada termin ini untuk Customer atau Vendor yang dipilih. Meskipun demikian, Anda tetap bisa menetapkan termin yang berbeda dari termin baku ini secara sementara langsung di field Term of Payment di formulir penginputan transaksi Penjualan atau Pembelian.
Anda diperkenankan juga mengubah Term of Payment ini di data Customer atau Vendor terkait meskipun data itu sudah digunakan di transaksi Penjualan atau Pembelian yang sudah diposting. Termin pembayaran di transaksi yang sudah diposting ataupun belum tidak akan berubah.
14. Komisi Penjualan dari Tabel
Opsi ini hanya tampil jika Anda memilih tipe Employee. Jika Anda menandakan opsi ini, berarti persentase komisi akan mengacu pada fasilitas Multikomisi Penjualan berupa Tabel Komisi Penjualan yang terdapat di modul Data-data. Jika Anda tidak menandakan opsi tersebut, sistem akan menampikan field baru Komisi Penjualan yang dapat Anda isi hanya dalam bentuk persentase atau isi persentase komisi penjualan dari data golongan.


 */