import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../shared/theme/gantt_theme.dart';

/// Sidebar widget for managing custom field definitions.
/// Embedded in the task detail panel's "Fields" tab.
class CustomFieldsEditor extends ConsumerWidget {
  final Task task;
  const CustomFieldsEditor({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defs = ref.watch(customFieldDefsProvider);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('CUSTOM FIELDS', style: GanttTheme.headerLabel),
        const Spacer(),
        TextButton.icon(
          onPressed: () => _showAddFieldDialog(context, ref),
          icon: const Icon(Icons.add, size: 12),
          label: const Text('Add'),
          style: TextButton.styleFrom(
            foregroundColor: GanttTheme.accentLight,
            textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 11),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            minimumSize: Size.zero,
          ),
        ),
      ]),
      const SizedBox(height: 8),
      if (defs.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('No custom fields defined.',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: GanttTheme.textMuted)),
        )
      else
        ...defs.map((def) => _FieldRow(def: def, task: task)),
    ]);
  }

  void _showAddFieldDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    CustomFieldType type = CustomFieldType.text;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          backgroundColor: GanttTheme.surface2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: GanttTheme.surface4)),
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 320,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add Custom Field',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: GanttTheme.textPrimary)),
                      const SizedBox(height: 16),
                      TextField(
                          controller: nameCtrl,
                          autofocus: true,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: GanttTheme.textPrimary),
                          decoration:
                              const InputDecoration(labelText: 'Field Name')),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<CustomFieldType>(
                        value: type,
                        dropdownColor: GanttTheme.surface3,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: GanttTheme.textPrimary),
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: CustomFieldType.values
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(_typeName(t)),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => type = v ?? type),
                      ),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        TextButton(
                            onPressed: () {
                              nameCtrl.dispose();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Cancel')),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (nameCtrl.text.trim().isNotEmpty) {
                              ref
                                  .read(customFieldDefsProvider.notifier)
                                  .add(CustomFieldDef(
                                    id: 'cf_${DateTime.now().millisecondsSinceEpoch}',
                                    name: nameCtrl.text.trim(),
                                    type: type,
                                  ));
                            }
                            nameCtrl.dispose();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Add Field'),
                        ),
                      ]),
                    ]),
              )),
        ),
      ),
    );
  }

  static String _typeName(CustomFieldType t) => switch (t) {
        CustomFieldType.text => 'Text',
        CustomFieldType.number => 'Number',
        CustomFieldType.boolean => 'Checkbox',
        CustomFieldType.date => 'Date',
        CustomFieldType.select => 'Select',
      };
}

class _FieldRow extends ConsumerWidget {
  final CustomFieldDef def;
  final Task task;
  const _FieldRow({required this.def, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = task.customFields[def.id];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        SizedBox(
            width: 100,
            child: Text(def.name,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: GanttTheme.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        Expanded(child: _fieldWidget(context, ref, def, value, task.id)),
        // Toggle sidebar visibility
        IconButton(
          icon: Icon(
              def.showInSidebar ? Icons.visibility : Icons.visibility_off,
              size: 12),
          color:
              def.showInSidebar ? GanttTheme.accent : GanttTheme.textDisabled,
          tooltip: def.showInSidebar ? 'Hide from sidebar' : 'Show in sidebar',
          onPressed: () =>
              ref.read(customFieldDefsProvider.notifier).toggleSidebar(def.id),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 12),
          color: GanttTheme.textDisabled,
          tooltip: 'Remove field',
          onPressed: () =>
              ref.read(customFieldDefsProvider.notifier).remove(def.id),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        ),
      ]),
    );
  }

  Widget _fieldWidget(BuildContext context, WidgetRef ref, CustomFieldDef d,
      dynamic value, String taskId) {
    switch (d.type) {
      case CustomFieldType.text:
        return _TextFieldWidget(
            value: value?.toString() ?? '',
            onChanged: (v) => ref
                .read(tasksProvider.notifier)
                .setCustomField(taskId, d.id, v));
      case CustomFieldType.number:
        return _NumberFieldWidget(
            value: (value as num?)?.toDouble() ?? 0,
            onChanged: (v) => ref
                .read(tasksProvider.notifier)
                .setCustomField(taskId, d.id, v));
      case CustomFieldType.boolean:
        return Checkbox(
          value: value as bool? ?? false,
          onChanged: (v) => ref
              .read(tasksProvider.notifier)
              .setCustomField(taskId, d.id, v ?? false),
          activeColor: GanttTheme.accent,
        );
      case CustomFieldType.date:
        final dateVal = value is String ? DateTime.tryParse(value) : null;
        return InkWell(
          onTap: () async {
            final p = await showDatePicker(
                context: context,
                initialDate: dateVal ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                builder: (ctx, child) =>
                    Theme(data: GanttTheme.dark, child: child!));
            if (p != null)
              ref
                  .read(tasksProvider.notifier)
                  .setCustomField(taskId, d.id, p.toIso8601String());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
                color: GanttTheme.surface2,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: GanttTheme.surface4)),
            child: Text(
                dateVal != null
                    ? '${dateVal.day}/${dateVal.month}/${dateVal.year}'
                    : 'Select date',
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: GanttTheme.textPrimary)),
          ),
        );
      case CustomFieldType.select:
        return DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          value: d.options.contains(value) ? value as String : null,
          hint: const Text('Select…',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: GanttTheme.textMuted)),
          dropdownColor: GanttTheme.surface3,
          style: const TextStyle(
              fontFamily: 'Inter', fontSize: 12, color: GanttTheme.textPrimary),
          isDense: true,
          items: d.options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) =>
              ref.read(tasksProvider.notifier).setCustomField(taskId, d.id, v),
        ));
    }
  }
}

class _TextFieldWidget extends StatefulWidget {
  final String value;
  final void Function(String) onChanged;
  const _TextFieldWidget({required this.value, required this.onChanged});
  @override
  State<_TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<_TextFieldWidget> {
  late final TextEditingController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _ctrl,
        style: const TextStyle(
            fontFamily: 'Inter', fontSize: 12, color: GanttTheme.textPrimary),
        decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
        onSubmitted: widget.onChanged,
        onEditingComplete: () => widget.onChanged(_ctrl.text),
      );
}

class _NumberFieldWidget extends StatefulWidget {
  final double value;
  final void Function(double) onChanged;
  const _NumberFieldWidget({required this.value, required this.onChanged});
  @override
  State<_NumberFieldWidget> createState() => _NumberFieldWidgetState();
}

class _NumberFieldWidgetState extends State<_NumberFieldWidget> {
  late final TextEditingController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.value == 0 ? '' : widget.value.toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(
            fontFamily: 'Inter', fontSize: 12, color: GanttTheme.textPrimary),
        decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
        onSubmitted: (v) {
          final n = double.tryParse(v);
          if (n != null) widget.onChanged(n);
        },
      );
}
