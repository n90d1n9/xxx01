// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class BackupDataWidget extends StatefulWidget {
  const BackupDataWidget({super.key});

  @override
  State<BackupDataWidget> createState() => _BackupDataWidgetState();
}

class _BackupDataWidgetState extends State<BackupDataWidget> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController(text: 'C:\\Data Zahir\\Backup Zahir Acc 6');
  final _fileNameController = TextEditingController();
  bool _isBackgroundBackup = false;
  bool _isAutomaticBackup = false;
  int _automaticBackupInterval = 15;

  @override
  void dispose() {
    _locationController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Penyimpanan',
                  suffixIcon: Icon(Icons.folder),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _fileNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama File Arsip',
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Checkbox(
                    value: _isBackgroundBackup,
                    onChanged: (value) {
                      setState(() {
                        _isBackgroundBackup = value!;
                      });
                    },
                  ),
                  const Text('Jalan di latar belakang'),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Checkbox(
                    value: _isAutomaticBackup,
                    onChanged: (value) {
                      setState(() {
                        _isAutomaticBackup = value!;
                      });
                    },
                  ),
                  const Text('Aktifkan Backup Otomatis'),
                  const SizedBox(width: 16.0),
                  SizedBox(
                    width: 50,
                    child: TextFormField(
                      initialValue: _automaticBackupInterval.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _automaticBackupInterval = int.tryParse(value) ?? 15;
                        });
                      },
                    ),
                  ),
                  const Text('Menit'),
                ],
              ),
              const SizedBox(height: 32.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Handle backup logic
                        print('Backup data with location: ${_locationController.text}');
                        print('Backup data with file name: ${_fileNameController.text}');
                        print('Backup data with background backup: $_isBackgroundBackup');
                        print('Backup data with automatic backup: $_isAutomaticBackup');
                        print('Backup data with interval: $_automaticBackupInterval');
                      }
                    },
                    child: const Text('Lanjutkan'),
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
Jalan di Latar Belakang
Tandakan pilihan/ opsi ini jika Anda mau jendela proses backup tidak tampak setelah Anda klik Lanjutkan. Abaikan opsi ini jika Anda ingin melihat proses berjalannya backup.
4. Backup Otomatis
Ini adalah fitur baru Zahir Accounting 6 yang memungkinkan pengguna dapat menjadwalkan sendiri bilamana sistem ini membackup data keuangan secara otomatis palimg cepat frekuensi setiap semenit dan paling lambat frekuensi tidak dibatasi. Jika Anda memilih fitur ini, ada beberapa hal yang harus Anda ketahui sebagai berikut:
• Anda tidak perlu lagi menamakan tanggal dan jam di Nama File Arsip melainkan dengan nama lain misalnya nama perusahaan Anda saja.
• Setiap backup otomatis sistem akan menamakan juga secara otomatis berdasarkan tanggal dan jam dengan format yyyymmdd hhmm.
• Setiap backup otomatis tidak ada notifikasi atau tidak ada muncul jendela proses backup.
• File backup otomatis langsung disimpan di direktori yang Anda tetapkan sebelumnya.
 */

