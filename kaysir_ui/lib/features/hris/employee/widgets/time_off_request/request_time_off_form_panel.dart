import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/request_time_off_draft.dart';

class RequestTimeOffFormPanel extends StatelessWidget {
  final RequestTimeOffDraft draft;
  final List<TimeOffBalance> balances;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final ValueChanged<String> onReasonChanged;

  const RequestTimeOffFormPanel({
    super.key,
    required this.draft,
    required this.balances,
    required this.onTypeChanged,
    required this.onStartDateTap,
    required this.onEndDateTap,
    required this.onReasonChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.edit_calendar_outlined,
      title: 'New request',
      subtitle: 'Choose dates and explain the time away',
      children: [
        DropdownButtonFormField<String>(
          initialValue: draft.type,
          decoration: const InputDecoration(
            labelText: 'Time off type',
            prefixIcon: Icon(Icons.category_outlined),
            border: OutlineInputBorder(),
          ),
          items:
              balances
                  .map(
                    (balance) => DropdownMenuItem(
                      value: balance.type,
                      child: Text(balance.type),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value == null) return;
            onTypeChanged(value);
          },
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final fields = [
              _DateSelector(
                label: 'Start date',
                value: draft.startDate,
                onTap: onStartDateTap,
              ),
              _DateSelector(
                label: 'End date',
                value: draft.endDate,
                onTap: onEndDateTap,
              ),
            ];

            if (constraints.maxWidth < 560) {
              return Column(
                children: [
                  fields.first,
                  const SizedBox(height: 12),
                  fields.last,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: fields.first),
                const SizedBox(width: 12),
                Expanded(child: fields.last),
              ],
            );
          },
        ),
        TextFormField(
          key: ValueKey(draft.reason),
          initialValue: draft.reason,
          onChanged: onReasonChanged,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Add context for your manager',
            prefixIcon: Icon(Icons.notes_outlined),
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;

  const _DateSelector({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          DateFormat('MMM d, yyyy').format(value),
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
