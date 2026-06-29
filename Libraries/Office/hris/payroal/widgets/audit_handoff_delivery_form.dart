import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

/// Captures routing details for audit handoff package delivery.
class AuditHandoffDeliveryForm extends StatefulWidget {
  final AuditHandoffDeliveryDraft draft;
  final bool enabled;
  final ValueChanged<String> onRoutedByChanged;
  final ValueChanged<AuditHandoffDeliveryChannel> onChannelChanged;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onSubmit;

  const AuditHandoffDeliveryForm({
    super.key,
    required this.draft,
    required this.enabled,
    required this.onRoutedByChanged,
    required this.onChannelChanged,
    required this.onNoteChanged,
    required this.onSubmit,
  });

  @override
  State<AuditHandoffDeliveryForm> createState() =>
      _AuditHandoffDeliveryFormState();
}

class _AuditHandoffDeliveryFormState extends State<AuditHandoffDeliveryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _routedByController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _routedByController = TextEditingController(text: widget.draft.routedBy);
    _noteController = TextEditingController(text: widget.draft.note);
  }

  @override
  void didUpdateWidget(covariant AuditHandoffDeliveryForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_routedByController, widget.draft.routedBy);
    _sync(_noteController, widget.draft.note);
  }

  @override
  void dispose() {
    _routedByController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reviewer routing',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final fields = [
                  TextFormField(
                    enabled: widget.enabled,
                    controller: _routedByController,
                    decoration: const InputDecoration(
                      labelText: 'Routed by',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.how_to_reg_outlined),
                    ),
                    onChanged: widget.onRoutedByChanged,
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter a routing owner'
                                : null,
                  ),
                  DropdownButtonFormField<AuditHandoffDeliveryChannel>(
                    initialValue: widget.draft.channel,
                    decoration: const InputDecoration(
                      labelText: 'Channel',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.route_outlined),
                    ),
                    items: [
                      for (final channel in AuditHandoffDeliveryChannel.values)
                        DropdownMenuItem(
                          value: channel,
                          child: Text(channel.label),
                        ),
                    ],
                    onChanged:
                        widget.enabled
                            ? (value) {
                              if (value == null) return;
                              widget.onChannelChanged(value);
                            }
                            : null,
                  ),
                ];

                if (constraints.maxWidth < 720) {
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
            const SizedBox(height: 12),
            TextFormField(
              enabled: widget.enabled,
              controller: _noteController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Routing note',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              onChanged: widget.onNoteChanged,
              validator:
                  (value) =>
                      value == null || value.trim().length < 16
                          ? 'Enter routing notes'
                          : null,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed:
                    widget.enabled && widget.draft.isReadyToSubmit
                        ? _submit
                        : null,
                icon: const Icon(Icons.send_time_extension_outlined),
                label: const Text('Route package'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onSubmit();
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}
