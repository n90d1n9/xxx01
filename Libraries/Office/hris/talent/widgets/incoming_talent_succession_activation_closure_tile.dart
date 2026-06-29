import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionActivationClosureTile extends StatelessWidget {
  final IncomingTalentSuccessionActivationClosure closure;
  final VoidCallback onActivate;
  final VoidCallback onComplete;
  final VoidCallback onDefer;

  const IncomingTalentSuccessionActivationClosureTile({
    super.key,
    required this.closure,
    required this.onActivate,
    required this.onComplete,
    required this.onDefer,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(closure.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      closure.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${closure.closureType.label} - ${closure.targetRole}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: closure.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            closure.communicationPlan,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            closure.accessReadiness,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: closure.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: closure.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.support_agent_outlined,
                label: closure.hrPartnerName,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(closure.effectiveDate),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed:
                      closure.status ==
                              IncomingTalentSuccessionActivationClosureStatus
                                  .active
                          ? null
                          : onActivate,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Activate'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      closure.status ==
                              IncomingTalentSuccessionActivationClosureStatus
                                  .deferred
                          ? null
                          : onDefer,
                  icon: const Icon(Icons.pause_circle_outline),
                  label: const Text('Defer'),
                ),
                FilledButton.icon(
                  onPressed:
                      closure.status ==
                              IncomingTalentSuccessionActivationClosureStatus
                                  .completed
                          ? null
                          : onComplete,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Complete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(IncomingTalentSuccessionActivationClosureStatus status) {
  return switch (status) {
    IncomingTalentSuccessionActivationClosureStatus.scheduled => const Color(
      0xFF2563EB,
    ),
    IncomingTalentSuccessionActivationClosureStatus.active => const Color(
      0xFF059669,
    ),
    IncomingTalentSuccessionActivationClosureStatus.completed => const Color(
      0xFF15803D,
    ),
    IncomingTalentSuccessionActivationClosureStatus.deferred => const Color(
      0xFFDC2626,
    ),
  };
}
