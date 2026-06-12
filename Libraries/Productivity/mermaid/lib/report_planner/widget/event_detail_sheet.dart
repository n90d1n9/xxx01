// Event Details Sheet (simplified)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/agenda_item.dart';
import '../state/agenda_items_provider.dart';
import '../state/analytics_provider.dart';
import 'add_event_sheet.dart';

class EventDetailsSheet extends ConsumerWidget {
  final AgendaItem item;

  const EventDetailsSheet({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (item.recurrence != null &&
                  item.recurrence!.type != RecurrenceType.none)
                _buildDetailRow(
                  context,
                  Icons.repeat,
                  'Recurring',
                  _getRecurrenceText(item.recurrence!),
                ),
              if (item.reminders.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  Icons.notifications_active,
                  'Reminders',
                  item.reminders
                      .map((r) => '${r.minutesBefore} min before')
                      .join(', '),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => AddEventSheet(editItem: item),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(agendaItemsProvider.notifier)
                            .deleteItem(item.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getRecurrenceText(RecurrencePattern pattern) {
    switch (pattern.type) {
      case RecurrenceType.daily:
        return 'Every day';
      case RecurrenceType.weekly:
        return 'Every week';
      case RecurrenceType.monthly:
        return 'Every month';
      case RecurrenceType.yearly:
        return 'Every year';
      default:
        return 'Custom';
    }
  }
}
