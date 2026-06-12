import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityLaunchGateChecklist extends StatelessWidget {
  final IncomingTalentMobilityLaunchChecklistDraft draft;
  final ValueChanged<bool> onSponsorSignedOff;
  final ValueChanged<bool> onHostManagerReady;
  final ValueChanged<bool> onAccessReady;
  final ValueChanged<bool> onCommunicationReady;
  final ValueChanged<bool> onBackfillReady;
  final ValueChanged<bool> onFirstReviewScheduled;

  const IncomingTalentMobilityLaunchGateChecklist({
    super.key,
    required this.draft,
    required this.onSponsorSignedOff,
    required this.onHostManagerReady,
    required this.onAccessReady,
    required this.onCommunicationReady,
    required this.onBackfillReady,
    required this.onFirstReviewScheduled,
  });

  @override
  Widget build(BuildContext context) {
    final ready = draft.allGatesReady;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HrisProgressBar(
            value: draft.completedGateCount / draft.totalGateCount,
            color: ready ? const Color(0xFF15803D) : HrisColors.primary,
            label:
                '${draft.completedGateCount}/${draft.totalGateCount} launch gates',
          ),
          const SizedBox(height: 8),
          _GateTile(
            label: 'Sponsor signoff',
            value: draft.sponsorSignedOff,
            onChanged: onSponsorSignedOff,
          ),
          _GateTile(
            label: 'Host manager ready',
            value: draft.hostManagerReady,
            onChanged: onHostManagerReady,
          ),
          _GateTile(
            label: 'Access ready',
            value: draft.accessReady,
            onChanged: onAccessReady,
          ),
          _GateTile(
            label: 'Communication ready',
            value: draft.communicationReady,
            onChanged: onCommunicationReady,
          ),
          _GateTile(
            label: 'Backfill ready',
            value: draft.backfillReady,
            onChanged: onBackfillReady,
          ),
          _GateTile(
            label: 'First review scheduled',
            value: draft.firstReviewScheduled,
            onChanged: onFirstReviewScheduled,
          ),
        ],
      ),
    );
  }
}

class _GateTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _GateTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(label),
      onChanged: (value) => onChanged(value ?? false),
    );
  }
}
