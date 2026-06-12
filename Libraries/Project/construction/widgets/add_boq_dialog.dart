import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../models/boq_category.dart';
import '../models/boq_item.dart';
import '../states/boq_provider.dart';
import '../utils/format_helper.dart';

class AddBoQDialog extends StatefulWidget {
  final WidgetRef ref;
  final String projectId;
  final BoQItem? editItem;

  const AddBoQDialog({
    super.key,
    required this.ref,
    required this.projectId,
    this.editItem,
  });

  @override
  State<AddBoQDialog> createState() => _AddBoQDialogState();
}

class _AddBoQDialogState extends State<AddBoQDialog> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _satuanController = TextEditingController();
  final _volumeController = TextEditingController();
  final _hargaSatuanController = TextEditingController();
  final _keteranganController = TextEditingController();
  BoQCategory _kategori = BoQCategory.pekerjaanPersiapan;

  @override
  void initState() {
    super.initState();
    if (widget.editItem != null) {
      _itemController.text = widget.editItem!.item;
      _satuanController.text = widget.editItem!.satuan;
      _volumeController.text = widget.editItem!.volume.toString();
      _hargaSatuanController.text = widget.editItem!.hargaSatuan.toString();
      _keteranganController.text = widget.editItem!.keterangan ?? '';
      _kategori = widget.editItem!.kategori;
    }
  }

  @override
  void dispose() {
    _itemController.dispose();
    _satuanController.dispose();
    _volumeController.dispose();
    _hargaSatuanController.dispose();
    _keteranganController.dispose();
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
              title: Text(
                widget.editItem == null ? 'Tambah Item BoQ' : 'Edit Item BoQ',
              ),
              automaticallyImplyLeading: false,
              actions: [
                if (widget.editItem != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      widget.ref
                          .read(boqProvider.notifier)
                          .deleteItem(widget.editItem!.id);
                      Navigator.pop(context);
                    },
                  ),
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
                    DropdownButtonFormField<BoQCategory>(
                      value: _kategori,
                      decoration: const InputDecoration(
                        labelText: 'Kategori Pekerjaan*',
                        border: OutlineInputBorder(),
                      ),
                      items: BoQCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(FormatHelper.getCategoryText(cat)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _kategori = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _itemController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Item Pekerjaan*',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _volumeController,
                            decoration: const InputDecoration(
                              labelText: 'Volume*',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v?.isEmpty ?? true) return 'Wajib diisi';
                              if (double.tryParse(v!) == null)
                                return 'Harus angka';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _satuanController,
                            decoration: const InputDecoration(
                              labelText: 'Satuan*',
                              hintText: 'm3, m2, ls, unit',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v?.isEmpty ?? true ? 'Wajib diisi' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hargaSatuanController,
                      decoration: const InputDecoration(
                        labelText: 'Harga Satuan (Rp)*',
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
                    TextFormField(
                      controller: _keteranganController,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
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
      final item = BoQItem(
        id: widget.editItem?.id ?? const Uuid().v4(),
        projectId: widget.projectId,
        kategori: _kategori,
        item: _itemController.text,
        satuan: _satuanController.text,
        volume: double.parse(_volumeController.text),
        hargaSatuan: double.parse(_hargaSatuanController.text),
        keterangan: _keteranganController.text.isEmpty
            ? null
            : _keteranganController.text,
      );

      if (widget.editItem == null) {
        widget.ref.read(boqProvider.notifier).addItem(item);
      } else {
        widget.ref.read(boqProvider.notifier).updateItem(item);
      }

      Navigator.pop(context);
    }
  }
}
