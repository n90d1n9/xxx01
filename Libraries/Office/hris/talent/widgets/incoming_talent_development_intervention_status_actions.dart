import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_development_intervention_models.dart';
import '../states/incoming_talent_development_intervention_provider.dart';

class IncomingTalentDevelopmentInterventionStatusActions
    extends ConsumerWidget {
  final IncomingTalentDevelopmentInterventionAction action;

  const IncomingTalentDevelopmentInterventionStatusActions({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closed = _isClosed(action);

    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed:
                closed ||
                        action.status ==
                            IncomingTalentDevelopmentInterventionStatus
                                .inProgress
                    ? null
                    : () => _start(context, ref),
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text('Start'),
          ),
          OutlinedButton.icon(
            onPressed: closed ? null : () => _cancel(context, ref),
            icon: const Icon(Icons.block_outlined),
            label: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: closed ? null : () => _resolve(context, ref),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  void _start(BuildContext context, WidgetRef ref) {
    try {
      ref
          .read(incomingTalentDevelopmentInterventionsProvider.notifier)
          .start(action.id);
      _showMessage(context, '${action.id} started');
    } on StateError catch (error) {
      _showMessage(context, error.message);
    }
  }

  Future<void> _resolve(BuildContext context, WidgetRef ref) async {
    final note = await _promptForNote(
      context,
      title: 'Resolve intervention',
      label: 'Resolution note',
      icon: Icons.verified_outlined,
      initialValue: action.resolutionNote,
    );
    if (note == null) return;

    try {
      ref
          .read(incomingTalentDevelopmentInterventionsProvider.notifier)
          .resolve(action.id, resolutionNote: note);
      if (context.mounted) _showMessage(context, '${action.id} resolved');
    } on StateError catch (error) {
      if (context.mounted) _showMessage(context, error.message);
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final note = await _promptForNote(
      context,
      title: 'Cancel intervention',
      label: 'Cancellation note',
      icon: Icons.block_outlined,
      initialValue: action.resolutionNote,
    );
    if (note == null) return;

    try {
      ref
          .read(incomingTalentDevelopmentInterventionsProvider.notifier)
          .cancel(action.id, resolutionNote: note);
      if (context.mounted) _showMessage(context, '${action.id} cancelled');
    } on StateError catch (error) {
      if (context.mounted) _showMessage(context, error.message);
    }
  }
}

Future<String?> _promptForNote(
  BuildContext context, {
  required String title,
  required String label,
  required IconData icon,
  String initialValue = '',
}) async {
  final controller = TextEditingController(text: initialValue);
  String? errorText;

  try {
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
                minLines: 3,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(icon),
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    final note = controller.text.trim();
                    if (note.length < 12) {
                      setState(() {
                        errorText = '$label must be at least 12 characters';
                      });
                      return;
                    }
                    Navigator.of(context).pop(note);
                  },
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  } finally {
    controller.dispose();
  }
}

bool _isClosed(IncomingTalentDevelopmentInterventionAction action) {
  return action.status ==
          IncomingTalentDevelopmentInterventionStatus.resolved ||
      action.status == IncomingTalentDevelopmentInterventionStatus.cancelled;
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
