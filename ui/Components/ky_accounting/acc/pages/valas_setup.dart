import 'package:flutter/material.dart';

class ForeignCurrencySetup extends StatefulWidget {
  const ForeignCurrencySetup({super.key});

  @override
  State<ForeignCurrencySetup> createState() => _ForeignCurrencySetupState();
}

class _ForeignCurrencySetupState extends State<ForeignCurrencySetup> {
  final _formKey = GlobalKey<FormState>();
  final _currencyCodeController = TextEditingController(text: 'USD');
  final _currencyNameController = TextEditingController(text: 'Dollar');
  final _currencySymbolController = TextEditingController(text: '\$');
  final _exchangeRateController = TextEditingController(text: '10.000,00');

  @override
  void dispose() {
    _currencyCodeController.dispose();
    _currencyNameController.dispose();
    _currencySymbolController.dispose();
    _exchangeRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mata Uang Asing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tentukan Mata Uang Asing yang paling sering digunakan oleh perusahaan Anda.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currencyCodeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Mata Uang',
                  suffixIcon: Icon(Icons.grid_view),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kode Mata Uang tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currencyNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Mata Uang',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Mata Uang tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currencySymbolController,
                decoration: const InputDecoration(
                  labelText: 'Simbol',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Simbol tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Kurs Tukar:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _exchangeRateController,
                      decoration: const InputDecoration(
                        labelText: 'USD =',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kurs Tukar tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('IDR'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Mata Uang Asing tidak wajib ditentukan saat ini. Anda masih dapat menambah Mata Uang Asing dilain waktu.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Petunjuk button
                    },
                    child: const Text('Petunjuk'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Kembali button
                    },
                    child: const Text('< Kembali'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Implement Lanjutkan button
                      }
                    },
                    child: const Text('Lanjutkan >'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Batal button
                    },
                    child: const Text('Batal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/* 
Kode Mata Uang
Pilihlah kode mata uang yang menjadi mata uang asing pembukuan Anda dengan cara menguraikan (drop down). Jika mata uang yang Anda pilih tidak tersedia, Anda dapat mengetik manual kode mata uang yang berlaku.
Nama Mata Uang
Setelah Anda memilih kode mata uang, sistem akan otomatis memunculkan nama mata uang terkait. Jika kode mata uang Anda ketik manual, Anda harus mengetik manual juga nama mata uang yang terkait dengan kodenya.
Simbol
Simbol yang mengidentifikasikan kode mata uang yang dipilih akan tampil otomatis. Jika Anda mengetik manual kode mata uang, Anda harus mengetik manual juga simbol mata uang yang terkait dengan kode dan namanya.
Kurs Tukar
Isilah nilai tukar yang berlaku saat Anda membuat data baru ini. Nilai kurs ini akan menjadi acuan bagi nilai saldo awal akun yang bermata uang asing. Anda dapat menyesuaikan nilai tukar ini untuk selanjutnya di modul Data-data > Data Mata Uang setelah proses pembuatan data baru ini selesai.
 */