import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/project.dart';
import '../states/project_provider.dart';
import '../utils/format_helper.dart';

class AddProjectDialog extends StatefulWidget {
  final WidgetRef ref;

  const AddProjectDialog({super.key, required this.ref});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _klienController = TextEditingController();
  final _budgetController = TextEditingController();
  final _deskripsiController = TextEditingController();
  DateTime _tanggalMulai = DateTime.now();
  DateTime _tanggalSelesai = DateTime.now().add(const Duration(days: 90));
  ProjectStatus _status = ProjectStatus.perencanaan;

  @override
  void initState() {
    _tanggalMulai = DateTime.now();
    super.initState();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _klienController.dispose();
    _budgetController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Tambah Proyek Baru'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Proyek*',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _klienController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Klien*',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lokasiController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi Proyek*',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _budgetController,
                      decoration: const InputDecoration(
                        labelText: 'Total Budget (Rp)*',
                        border: OutlineInputBorder(),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Wajib diisi';
                        if (double.tryParse(v!) == null) return 'Harus angka';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ProjectStatus>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status Proyek',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          ProjectStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(FormatHelper.getStatusText(status)),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Tanggal Mulai'),
                      subtitle: Text(
                        FormatHelper.dateFormat.format(_tanggalMulai),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _tanggalMulai,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) setState(() => _tanggalMulai = date);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Tanggal Selesai'),
                      subtitle: Text(
                        FormatHelper.dateFormat.format(_tanggalSelesai),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _tanggalSelesai,
                          firstDate: _tanggalMulai,
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _tanggalSelesai = date);
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deskripsiController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final project = Project(
        id: const Uuid().v4(),
        nama: _namaController.text,
        lokasi: _lokasiController.text,
        klien: _klienController.text,
        tanggalMulai: _tanggalMulai,
        tanggalSelesai: _tanggalSelesai,
        status: _status,
        totalBudget: double.parse(_budgetController.text),
        deskripsi:
            _deskripsiController.text.isEmpty
                ? null
                : _deskripsiController.text,
      );

      widget.ref.read(projectsProvider.notifier).addProject(project);
      Navigator.pop(context);
    }
  }
}
