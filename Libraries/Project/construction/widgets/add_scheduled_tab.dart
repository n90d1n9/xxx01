import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../models/schedule.dart';
import '../states/scheduled_provider.dart';
import '../utils/format_helper.dart';

class AddScheduleDialog extends StatefulWidget {
  final WidgetRef ref;
  final String projectId;
  final Schedule? editSchedule;

  const AddScheduleDialog({
    Key? key,
    required this.ref,
    required this.projectId,
    this.editSchedule,
  }) : super(key: key);

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _aktivitasController = TextEditingController();
  final _picController = TextEditingController();
  late DateTime _mulai;
  late DateTime _selesai;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    if (widget.editSchedule != null) {
      _aktivitasController.text = widget.editSchedule!.aktivitas;
      _picController.text = widget.editSchedule!.pic ?? '';
      _mulai = widget.editSchedule!.mulai;
      _selesai = widget.editSchedule!.selesai;
      _progress = widget.editSchedule!.progress;
    } else {
      _mulai = DateTime.now();
      _selesai = DateTime.now().add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _aktivitasController.dispose();
    _picController.dispose();
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
                widget.editSchedule == null ? 'Tambah Jadwal' : 'Edit Jadwal',
              ),
              automaticallyImplyLeading: false,
              actions: [
                if (widget.editSchedule != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      widget.ref
                          .read(scheduleProvider.notifier)
                          .deleteSchedule(widget.editSchedule!.id);
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
                    TextFormField(
                      controller: _aktivitasController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Aktivitas*',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _picController,
                      decoration: const InputDecoration(
                        labelText: 'PIC (Person In Charge)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Tanggal Mulai'),
                      subtitle: Text(FormatHelper.dateFormat.format(_mulai)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _mulai,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) setState(() => _mulai = date);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Tanggal Selesai'),
                      subtitle: Text(FormatHelper.dateFormat.format(_selesai)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selesai,
                          firstDate: _mulai,
                          lastDate: DateTime(2030),
                        );
                        if (date != null) setState(() => _selesai = date);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Progress: $_progress%',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: _progress.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '$_progress%',
                      onChanged: (value) {
                        setState(() => _progress = value.toInt());
                      },
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
      final schedule = Schedule(
        id: widget.editSchedule?.id ?? const Uuid().v4(),
        projectId: widget.projectId,
        aktivitas: _aktivitasController.text,
        mulai: _mulai,
        selesai: _selesai,
        progress: _progress,
        pic: _picController.text.isEmpty ? null : _picController.text,
      );

      if (widget.editSchedule == null) {
        widget.ref.read(scheduleProvider.notifier).addSchedule(schedule);
      } else {
        widget.ref.read(scheduleProvider.notifier).updateSchedule(schedule);
      }

      Navigator.pop(context);
    }
  }
}
