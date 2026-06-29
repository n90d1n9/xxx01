import 'package:flutter/material.dart';

class CurrencyDataWidget extends StatefulWidget {
  const CurrencyDataWidget({super.key});

  @override
  State<CurrencyDataWidget> createState() => _CurrencyDataWidgetState();
}

class _CurrencyDataWidgetState extends State<CurrencyDataWidget> {
  final _formKey = GlobalKey<FormState>();
  final _currencyCodeController = TextEditingController(text: 'USD');
  final _currencyNameController = TextEditingController(text: 'Dollar');
  final _currencySymbolController = TextEditingController(text: '\$');
  final _exchangeRateController = TextEditingController(text: '11.000');
  final _dateController = TextEditingController(text: '1/31/2014');

  @override
  void dispose() {
    _currencyCodeController.dispose();
    _currencyNameController.dispose();
    _currencySymbolController.dispose();
    _exchangeRateController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Mata Uang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Mata Uang'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Akun Penting'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _currencyCodeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Mata Uang',
                  prefixIcon: Icon(Icons.currency_exchange),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter currency code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _currencyNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Mata Uang',
                  prefixIcon: Icon(Icons.text_format),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter currency name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _currencySymbolController,
                decoration: const InputDecoration(
                  labelText: 'Simbol',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter currency symbol';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _exchangeRateController,
                decoration: const InputDecoration(
                  labelText: 'Kurs Tukar',
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter exchange rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Per Tanggal',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process data
                  }
                },
                child: const Text('Set Nilai Kurs'),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Baru'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/* 
1. Kode Mata Uang
Klik tombol ini untuk membuka daftar mata uang. Pilih mata uang dasar/ asing lalu pilih OK. Jika mata uang yang Anda cari tidak ada, klik Batal kemudian ketik secara manual 3 huruf kode internasional mata uang di field Kode Mata Uang.
2. Nama Mata Uang
Jika Anda telah memilih kode mata uang, field ini akan terisi secara otomatis namun Anda tetap bisa mengubah nama ini.
3. Simbol
Jika Anda telah memilih kode mata uang, field ini akan terisi secara otomatis namun Anda tetap bisa mengubah simbol ini.
4. Kurs Tukar
Field ini harus diisi dengan nominal dan tidak boleh bernilai 0. Isilah dengan nilai tukar (kurs) yang berlaku.
5. Per Tanggal
Ini mengidentifikasi tanggal kurs yang berlaku.
6. Set Nilai Kurs
Selain Anda dapat mengisi nilai tukar di field Kurs Tukar, Anda dapat juga mengisinya dengan mengeklik tombol ini.
Selanjutnya klik tab Akun Penting untuk mengisi akun-akun penting.
Perhatikan! Kurs Tukar, Per Tanggal, dan Set Nilai Kurs tidak akan tampil ketika Anda mengedit data mata uang dasar.

 */