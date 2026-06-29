import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'audit_handoff_delivery_form.dart';

/// Shows and captures reviewer routing for the audit handoff package.
class AuditHandoffDeliveryPanel extends StatelessWidget {
  final AuditHandoffDeliverySummary summary;
  final ValueChanged<String> onRoutedByChanged;
  final ValueChanged<AuditHandoffDeliveryChannel> onChannelChanged;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onSubmit;
  final VoidCallback onReopen;

  const AuditHandoffDeliveryPanel({
    super.key,
    required this.summary,
    required this.onRoutedByChanged,
    required this.onChannelChanged,
    required this.onNoteChanged,
    required this.onSubmit,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        summary.isDelivered
            ? const Color(0xFF15803D)
            : summary.canRoute
            ? const Color(0xFF2563EB)
            : const Color(0xFFB91C1C);

    return HrisSectionPanel(
      icon: Icons.send_time_extension_outlined,
      title: 'Audit handoff delivery',
      subtitle: summary.package.packageId,
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HrisStatusPill(label: summary.statusLabel, color: color),
                  _MetricChip(
                    icon: Icons.forward_to_inbox_outlined,
                    label: summary.package.recipientLabel,
                  ),
                  if (summary.record != null)
                    _MetricChip(
                      icon: Icons.route_outlined,
                      label: summary.record!.channel.label,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    summary.isDelivered
                        ? Icons.mark_email_read_outlined
                        : Icons.outbox_outlined,
                    color: color,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      summary.nextAction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (summary.record != null) ...[
                const SizedBox(height: 8),
                Text(
                  summary.record!.note,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (summary.isDelivered)
          HrisListSurface(
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onReopen,
                icon: const Icon(Icons.undo_outlined, size: 18),
                label: const Text('Reopen delivery'),
              ),
            ),
          )
        else
          AuditHandoffDeliveryForm(
            draft: summary.draft,
            enabled: summary.canRoute,
            onRoutedByChanged: onRoutedByChanged,
            onChannelChanged: onChannelChanged,
            onNoteChanged: onNoteChanged,
            onSubmit: onSubmit,
          ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
