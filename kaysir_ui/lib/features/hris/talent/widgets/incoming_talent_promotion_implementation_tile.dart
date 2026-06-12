import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_decision_models.dart';
import '../models/incoming_talent_promotion_implementation_models.dart';
import '../models/incoming_talent_promotion_readiness_models.dart';
import 'talent_meta_label.dart';

/// Promotion implementation tile with routing status and evidence.
class IncomingTalentPromotionImplementationTile extends StatelessWidget {
  final IncomingTalentPromotionImplementation implementation;

  const IncomingTalentPromotionImplementationTile({
    super.key,
    required this.implementation,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentPromotionImplementationStatusColor(
      implementation.status,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_actionIcon(implementation.action), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      implementation.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${implementation.currentRole} -> ${implementation.frameworkLevelCode} ${implementation.newRole}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: implementation.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: implementation.progressRatio,
            color: color,
            label: implementation.action.label,
          ),
          const SizedBox(height: 10),
          Text(
            implementation.implementationStep,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            implementation.evidenceNote,
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
                label: implementation.department,
              ),
              TalentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: implementation.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.storage_outlined,
                label: implementation.systemOfRecord,
              ),
              TalentMetaLabel(
                icon: Icons.how_to_reg_outlined,
                label: implementation.sourceOutcome.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(implementation.dueDate),
              ),
              if (implementation.completedDate != null)
                TalentMetaLabel(
                  icon: Icons.task_alt_outlined,
                  label: DateFormat(
                    'MMM d',
                  ).format(implementation.completedDate!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentPromotionImplementationStatusColor(
  IncomingTalentPromotionImplementationStatus status,
) {
  return switch (status) {
    IncomingTalentPromotionImplementationStatus.planned => const Color(
      0xFF2563EB,
    ),
    IncomingTalentPromotionImplementationStatus.inProgress => const Color(
      0xFFD97706,
    ),
    IncomingTalentPromotionImplementationStatus.blocked => const Color(
      0xFFDC2626,
    ),
    IncomingTalentPromotionImplementationStatus.completed => const Color(
      0xFF059669,
    ),
    IncomingTalentPromotionImplementationStatus.cancelled => const Color(
      0xFF64748B,
    ),
  };
}

IconData _actionIcon(IncomingTalentPromotionImplementationAction action) {
  return switch (action) {
    IncomingTalentPromotionImplementationAction.titleUpdate =>
      Icons.badge_outlined,
    IncomingTalentPromotionImplementationAction.compensationRoute =>
      Icons.payments_outlined,
    IncomingTalentPromotionImplementationAction.trialAssignment =>
      Icons.assignment_ind_outlined,
    IncomingTalentPromotionImplementationAction.managerCommunication =>
      Icons.campaign_outlined,
    IncomingTalentPromotionImplementationAction.followUpCheck =>
      Icons.fact_check_outlined,
  };
}

@Preview(name: 'Talent promotion implementation tile')
Widget incomingTalentPromotionImplementationTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionImplementationTile(
          implementation: _previewImplementation,
        ),
      ),
    ),
  );
}

final _previewImplementation = IncomingTalentPromotionImplementation(
  id: 'promotion-implementation-preview',
  decisionId: 'promotion-decision-preview',
  readinessId: 'promotion-readiness-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  newRole: 'Lead Backend Engineer',
  frameworkLevelCode: 'L5',
  ownerName: 'Engineering HRBP',
  approverName: 'Engineering people panel',
  action: IncomingTalentPromotionImplementationAction.titleUpdate,
  status: IncomingTalentPromotionImplementationStatus.inProgress,
  systemOfRecord: 'HRIS employee profile',
  implementationStep: 'Prepare promotion letter and HRIS title update.',
  evidenceNote: 'Capture signed letter and HRIS update confirmation.',
  blockerNote: 'Confirm manager transition and backfill risk.',
  dueDate: DateTime(2026, 7, 9),
  completedDate: null,
  sourceOutcome: IncomingTalentPromotionDecisionOutcome.promoteNow,
  sourceDecisionStatus: IncomingTalentPromotionDecisionStatus.approved,
  sourceReadinessRating: IncomingTalentPromotionReadinessRating.readyNow,
  createdAt: DateTime(2026, 6, 9),
);
