
import 'package:flutter/material.dart';

class RestoreForm extends StatefulWidget {
  const RestoreForm({super.key});

  @override
  State<RestoreForm> createState() => _RestoreFormState();
}

class _RestoreFormState extends State<RestoreForm> {
  final _formKey = GlobalKey<FormState>();
  final _backupFileController = TextEditingController(
      text: 'C:\\Data Zahir\\Backup Zahir Acc 6\\ZahirBac');
  final _directoryController = TextEditingController(text: 'C:\\Data Zahir\\');
  final _backupFileNewController =
      TextEditingController(text: 'Zahir Sample 2.GDB');
  bool _isLocal = true;

  @override
  void dispose() {
    _backupFileController.dispose();
    _directoryController.dispose();
    _backupFileNewController.dispose();
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
            'File Backup yang akan di Restore :',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _backupFileController,
            decoration: const InputDecoration(
              labelText: 'Nama File Arsip :',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lokasi Data Hasil Restore :',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _directoryController,
            decoration: const InputDecoration(
              labelText: 'Lokasi Baru (Directory) :',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _backupFileNewController,
            decoration: const InputDecoration(
              labelText: 'Nama File Arsip Baru :',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _isLocal,
                onChanged: (value) {
                  setState(() {
                    _isLocal = value!;
                  });
                },
              ),
              const Text('Database Lokal'),
              const SizedBox(width: 16),
              Checkbox(
                value: !_isLocal,
                onChanged: (value) {
                  setState(() {
                    _isLocal = !value!;
                  });
                },
              ),
              const Text('Database Berada di Server'),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isLocal)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Server Name :',
              ),
            ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement cancel action
                },
                child: const Text('Batal'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement continue action
                  if (_formKey.currentState!.validate()) {
                    // Process data
                  }
                },
                child: const Text('Lanjutkan'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
