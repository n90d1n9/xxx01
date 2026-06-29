import 'package:flutter/material.dart';

class AccountForm extends StatefulWidget {
  const AccountForm({super.key});

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _classificationController = TextEditingController();
  final _codeController = TextEditingController(text: '1500-00-010');
  final _nameController = TextEditingController(text: 'Pajak Dibayar di Muka');
  final _aliasController = TextEditingController();
  bool _isCashBank = false;
  bool _isActive = false;
  String _selectedCurrency = 'IDR';

  @override
  void dispose() {
    _classificationController.dispose();
    _codeController.dispose();
    _nameController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tambah Akun Baru',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _classificationController,
            decoration: const InputDecoration(
              labelText: 'Klasifikasi',
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Kode',
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _aliasController,
                  decoration: const InputDecoration(
                    labelText: 'Alias',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Simpan'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: _isCashBank,
                onChanged: (value) {
                  setState(() {
                    _isCashBank = value!;
                  });
                },
              ),
              const Text('Kas / Bank'),
              const SizedBox(width: 20),
              Checkbox(
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value!;
                  });
                },
              ),
              const Text('Tidak Aktif'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  items: const [
                    DropdownMenuItem(
                      value: 'IDR',
                      child: Text('IDR'),
                    ),
                    DropdownMenuItem(
                      value: 'USD',
                      child: Text('USD'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Departemen',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


/* 

Klasifikasi
Field ini telah berisi subklasifikasi akun standar yang harus Anda pilih. Jika Anda memerlukan penambahan subklasifikasi, silakan buat baru dari menu Setting > Klasifikasi Akun.
2. Alias
Tombol ini memungkinkan Anda untuk menampilkan nama alias akun dalam bahasa lain yaitu bahasa Inggris jika Anda memiliki fasilitas Akun Alias Name. Akun yang dimaksud yakni akun standar Zahir. Jika Anda telah membuat akun baru misalnya dalam bahasa Indonesia dan ingin menampilkan nama aliasnya, Anda harus menambah nama alias untuk akun yang dimaksud di daftar rekening > klik tombol alias > akun yang baru Anda buat akan menampilkan nama akun pertama (belum berubah) > kemudian klik edit akun terkait > ubah nama pertama menjadi nama alias yang diinginkan > klik rekam.
3. Kode
Field ini akan terisi otomatis selepas Anda memilih klasifikasi namun Anda tetap dapat mengubah kode ini berdasarkan urutan akun yang diinginkan. Di field ini Anda hanya diperkenankan mengubah digit akun yang mengidentifikasi urutan akun. Adapun fungsi kode ini dibagi ke dalam 3 bagian sebagai berikut:
Contoh: 1100-00-001 Kas
Keterangan:
• 1 (angka/ digit pertama dari kiri) adalah digit permanen level 1 yang mengidentifikasi
klasifikasi akun Harta. Anda tidak dapat mengubah kode ini.
• 1100 adalah jumlah digit level 3. Jangan mengubah kode ini di field kode karena ini kode
baku yang mengidentifikasi klasifikasi dan subklasifikasi akun. Anda dapat mengubah digit level 3 sesuai dengan klasifikasi dan subklasifikasi yang benar dari menu Setting >
 © 2014 PT Zahir Internasional 48
Klasifikasi Akun > Lanjutkan > Lanjutkan > pilih Level 1 lalu ubah kode di Level 3 tanpa
mengubah angka pertama.
• 00 adalah jumlah digit departemen
• 001 adalah jumlah digit urutan akun. Di field kode, Anda dapat menghubah digit ini sesuai
dengan urutan akun yang diinginkan
4. Nama
Isi dengan nama akun. Pembuatan nama baru akun adalah nama utama atau nama standar akun Anda. Jika Anda memiliki fasilitas Akun Alias Name, Anda dapat membuat nama alias akun yang dimaksud seperti alur yang dijelaskan pada butir ke-2 di atas.
5. Kas/ Bank
Beri centang opsi ini jika akun berklasifikasi Kas/ Bank (Akun dengan kode kepala 1). Jika Anda mencentang opsi ini, Anda akan menemukan icon centang merah pada daftar rekening yang menandakan bahwa
• Akun yang dicentang ini akan muncul di daftar akun pada transaksi modul Kas & Bank yaitu Transfer Kas, Kas Masuk, Kas Keluar, dan Rekonsiliasi Bank.
• Akun yang dicentang ini digunakan sebagai akun utama yang terlibat dalam Laporan Arus Kas.
6. Tidak Aktif
Jika opsi ini dicentang karena akun tidak akan digunakan lagi, akun yang dimaksud akan disembunyikan oleh sistem dari daftar rekening. Anda tetap dapat memunculkan dan menggunakan lagi akun itu dengan cara mengedit akun yang terdekat dengannya lalu gunakan tombol navigasi yang terdapat di sudut kiri bawah untuk mencari akun yang disembunyikan. Jika sudah ditemukan, hilangkan centang di opsi ini lalu rekam.
7. Mata Uang
Anda harus menentukan mata uang yang digunakan untuk akun ini agar setiap transaksi, buku besar, dan laporan mengacu pada mata uang yang dimaksud. Jika Anda tidak memiliki fasilitas Multicurrency, pilihan field Mata Uang tidak tampil.
8. Departemen
Klik tombol ini untuk memilih kode departemen yang telah dibuat di data departemen agar sistem dapat menggolongkan akun berdasarkan departemennya saat Anda memilih kode departemen di laporan keuangan. Field ini akan tampil jika Anda memiliki fasilitas Departemen.

 */


