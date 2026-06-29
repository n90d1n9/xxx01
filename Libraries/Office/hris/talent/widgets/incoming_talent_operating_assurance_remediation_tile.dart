import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import 'talent_meta_label.dart';

/// Tile for one owner-assigned talent assurance remediation action.
class IncomingTalentOperatingAssuranceRemediationTile extends StatelessWidget {
  final IncomingTalentOperatingAssuranceRemediationAction action;

  const IncomingTalentOperatingAssuranceRemediationTile({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentOperatingAssuranceRemediationPriorityColor(
      action.priority,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_typeIcon(action.type), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      action.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: action.priority.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: action.normalizedPressureRatio,
            color: color,
            label:
                '${(action.normalizedPressureRatio * 100).round()}% remediation pressure',
          ),
          const SizedBox(height: 10),
          Text(
            action.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (action.evidenceRequests.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              action.evidenceRequests.first,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(action.nextDueDate),
              ),
              TalentMetaLabel(
                icon: Icons.account_tree_outlined,
                label: action.workstreamLabel,
              ),
              TalentMetaLabel(
                icon: Icons.pending_actions_outlined,
                label: '${action.gapCount} ${_plural(action.gapCount, 'gap')}',
              ),
              TalentMetaLabel(
                icon: Icons.link_outlined,
                label:
                    '${action.linkedEscalationCount} linked ${_plural(action.linkedEscalationCount, 'escalation')}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentOperatingAssuranceRemediationPriorityColor(
  IncomingTalentOperatingAssuranceRemediationPriority priority,
) {
  return switch (priority) {
    IncomingTalentOperatingAssuranceRemediationPriority.critical => const Color(
      0xFFDC2626,
    ),
    IncomingTalentOperatingAssuranceRemediationPriority.high => const Color(
      0xFFD97706,
    ),
    IncomingTalentOperatingAssuranceRemediationPriority.standard => const Color(
      0xFF2563EB,
    ),
  };
}

IconData _typeIcon(IncomingTalentOperatingAssuranceRemediationType type) {
  return switch (type) {
    IncomingTalentOperatingAssuranceRemediationType.recoverOverdueEvidence =>
      Icons.timer_outlined,
    IncomingTalentOperatingAssuranceRemediationType.clearLinkedEscalation =>
      Icons.link_outlined,
    IncomingTalentOperatingAssuranceRemediationType.closeDueToday =>
      Icons.today_outlined,
    IncomingTalentOperatingAssuranceRemediationType.prepareAuditPack =>
      Icons.inventory_2_outlined,
  };
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent assurance remediation tile')
Widget incomingTalentOperatingAssuranceRemediationTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentOperatingAssuranceRemediationTile(
          action: _previewAction,
        ),
      ),
    ),
  );
}

final _previewAction = IncomingTalentOperatingAssuranceRemediationAction(
  id: 'assurance-remediation-people-operations-talent-partner-risk-council',
  type: IncomingTalentOperatingAssuranceRemediationType.recoverOverdueEvidence,
  priority: IncomingTalentOperatingAssuranceRemediationPriority.critical,
  assuranceLevel: IncomingTalentOperatingAssuranceLevel.exposed,
  ownerName: 'People Operations Talent Partner',
  workstreamLabel: 'Risk council',
  title: 'People Operations Talent Partner - Risk council evidence',
  detail: '2 assurance gaps in risk council',
  nextAction:
      'Ask People Operations Talent Partner to recover 1 overdue risk council evidence gap.',
  gapCount: 2,
  criticalGapCount: 1,
  highGapCount: 1,
  overdueGapCount: 1,
  dueTodayGapCount: 0,
  linkedEscalationCount: 3,
  nextDueDate: DateTime(2026, 6, 10),
  pressureRatio: 0.78,
  evidenceRequests: const [
    'Attach decision notes, owner commitment, and follow-up acceptance.',
  ],
  gapIds: const ['evidence-risk-overdue', 'evidence-risk-today'],
);
