import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_models.dart';

class HolidayFormPanel extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController dateController;
  final TextEditingController observedDateController;
  final TextEditingController scopeController;
  final TextEditingController descriptionController;
  final HolidayType selectedType;
  final bool isPaid;
  final bool isRecurring;
  final bool requiresCoveragePlan;
  final bool isEditing;
  final ValueChanged<HolidayType?> onTypeChanged;
  final ValueChanged<bool> onPaidChanged;
  final ValueChanged<bool> onRecurringChanged;
  final ValueChanged<bool> onCoverageChanged;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const HolidayFormPanel({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.dateController,
    required this.observedDateController,
    required this.scopeController,
    required this.descriptionController,
    required this.selectedType,
    required this.isPaid,
    required this.isRecurring,
    required this.requiresCoveragePlan,
    required this.isEditing,
    required this.onTypeChanged,
    required this.onPaidChanged,
    required this.onRecurringChanged,
    required this.onCoverageChanged,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: hrisPanelDecoration(),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: HrisColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event_note_outlined,
                    color: HrisColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEditing ? 'Edit holiday' : 'Add holiday',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 720;
                final fieldWidth =
                    isNarrow
                        ? double.infinity
                        : (constraints.maxWidth - 12) / 2;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        key: const Key('holiday-name-field'),
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Holiday name',
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Enter holiday name'
                                    : null,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: DropdownButtonFormField<HolidayType>(
                        key: const Key('holiday-type-field'),
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          prefixIcon: Icon(Icons.category_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items:
                            HolidayType.values
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type.label),
                                  ),
                                )
                                .toList(),
                        onChanged: onTypeChanged,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        key: const Key('holiday-date-field'),
                        controller: dateController,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          hintText: 'YYYY-MM-DD',
                          prefixIcon: Icon(Icons.today_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateRequiredDate,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        key: const Key('holiday-observed-date-field'),
                        controller: observedDateController,
                        decoration: const InputDecoration(
                          labelText: 'Observed date',
                          hintText: 'YYYY-MM-DD',
                          prefixIcon: Icon(Icons.event_repeat_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateOptionalDate,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        key: const Key('holiday-scope-field'),
                        controller: scopeController,
                        decoration: const InputDecoration(
                          labelText: 'Scope',
                          prefixIcon: Icon(Icons.groups_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Enter scope'
                                    : null,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: TextFormField(
                        key: const Key('holiday-description-field'),
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.notes_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HolidaySwitchChip(
                  label: 'Paid',
                  selected: isPaid,
                  icon: Icons.payments_outlined,
                  onChanged: onPaidChanged,
                ),
                _HolidaySwitchChip(
                  label: 'Recurring',
                  selected: isRecurring,
                  icon: Icons.repeat_rounded,
                  onChanged: onRecurringChanged,
                ),
                _HolidaySwitchChip(
                  label: 'Coverage plan',
                  selected: requiresCoveragePlan,
                  icon: Icons.assignment_turned_in_outlined,
                  onChanged: onCoverageChanged,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onCancel, child: const Text('Cancel')),
                const SizedBox(width: 8),
                FilledButton.icon(
                  key: const Key('holiday-save-button'),
                  onPressed: onSubmit,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: Text(isEditing ? 'Save holiday' : 'Add holiday'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HolidaySwitchChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const _HolidaySwitchChip({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: selected,
      onSelected: onChanged,
    );
  }
}

String? _validateRequiredDate(String? value) {
  if (value == null || value.trim().isEmpty) return 'Enter date';

  return _validateDate(value);
}

String? _validateOptionalDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;

  return _validateDate(value);
}

String? _validateDate(String value) {
  return DateTime.tryParse(value.trim()) == null ? 'Use YYYY-MM-DD' : null;
}
