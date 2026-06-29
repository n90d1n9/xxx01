import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import '../states/incoming_talent_operating_inbox_provider.dart';
import 'incoming_talent_operating_inbox_owner_digest_tile.dart';

/// Owner workload digest for cross-HRIS talent operating inbox ownership.
class IncomingTalentOperatingInboxOwnerDigestPanel extends ConsumerWidget {
  const IncomingTalentOperatingInboxOwnerDigestPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final digests = ref.watch(incomingTalentOperatingInboxOwnerDigestsProvider);
    final summary = ref.watch(
      incomingTalentOperatingInboxOwnerDigestSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.supervisor_account_outlined,
      title: 'Talent owner workload',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent owner workload',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Owners',
              value: '${summary.ownerCount}',
            ),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalOwnerCount}',
            ),
            HrisMetricStripItem(
              label: 'Stretched',
              value: '${summary.stretchedOwnerCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${summary.overdueItemCount}',
            ),
          ],
        ),
        if (digests.isEmpty)
          const HrisListSurface(
            child: Text('No owner-owned talent operating work needs review.'),
          )
        else
          for (final digest in digests.take(5))
            IncomingTalentOperatingInboxOwnerDigestTile(digest: digest),
      ],
    );
  }
}

@Preview(name: 'Talent owner workload panel')
Widget incomingTalentOperatingInboxOwnerDigestPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentOperatingInboxOwnerDigestsProvider.overrideWithValue([
        _previewCriticalDigest,
        _previewStretchedDigest,
      ]),
      incomingTalentOperatingInboxOwnerDigestSummaryProvider.overrideWithValue(
        IncomingTalentOperatingInboxOwnerDigestSummary.fromDigests([
          _previewCriticalDigest,
          _previewStretchedDigest,
        ]),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentOperatingInboxOwnerDigestPanel(),
        ),
      ),
    ),
  );
}

final _previewCriticalDigest = IncomingTalentOperatingInboxOwnerDigest(
  ownerName: 'People Operations Talent Partner',
  load: IncomingTalentOperatingInboxOwnerLoad.critical,
  totalCount: 3,
  criticalCount: 2,
  watchCount: 1,
  routineCount: 0,
  overdueCount: 1,
  dueSoonCount: 1,
  riskCouncilCount: 2,
  developmentCount: 0,
  successionCount: 0,
  promotionCount: 1,
  earliestDueDate: DateTime(2026, 6, 10),
  nextAction:
      'Recover 1 overdue talent inbox item with People Operations Talent Partner.',
  itemIds: const ['risk-follow-up:preview', 'promotion-action:preview'],
);

final _previewStretchedDigest = IncomingTalentOperatingInboxOwnerDigest(
  ownerName: 'Engineering HRBP',
  load: IncomingTalentOperatingInboxOwnerLoad.stretched,
  totalCount: 2,
  criticalCount: 0,
  watchCount: 2,
  routineCount: 0,
  overdueCount: 0,
  dueSoonCount: 2,
  riskCouncilCount: 0,
  developmentCount: 2,
  successionCount: 0,
  promotionCount: 0,
  earliestDueDate: DateTime(2026, 6, 13),
  nextAction: 'Close 2 talent inbox items due soon with Engineering HRBP.',
  itemIds: const ['training-session:preview', 'career-review:preview'],
);
