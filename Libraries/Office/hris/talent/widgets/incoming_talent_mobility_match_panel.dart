import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_mobility_match_provider.dart';
import 'incoming_talent_mobility_form.dart';
import 'incoming_talent_mobility_match_tile.dart';

class IncomingTalentMobilityMatchPanel extends ConsumerWidget {
  const IncomingTalentMobilityMatchPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyDecisions = ref.watch(
      mobilityReadySuccessionPanelDecisionsProvider,
    );
    final matches = ref.watch(filteredIncomingTalentMobilityMatchesProvider);
    final summary = ref.watch(incomingTalentMobilityMatchSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.compare_arrows_outlined,
      title: 'Talent mobility marketplace',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent mobility matches',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyDecisions.length}',
            ),
            HrisMetricStripItem(
              label: 'Review',
              value: '${summary.sponsorReviewCount}',
            ),
            HrisMetricStripItem(
              label: 'Accepted',
              value: '${summary.acceptedCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
          ],
        ),
        IncomingTalentMobilityForm(decisions: readyDecisions),
        if (matches.isEmpty)
          const HrisListSurface(child: Text('No mobility matches yet.'))
        else
          for (final match in matches.take(3))
            IncomingTalentMobilityMatchTile(
              match: match,
              onSponsorReview:
                  () => _setStatus(
                    ref,
                    match,
                    IncomingTalentMobilityMatchStatus.sponsorReview,
                  ),
              onAccept:
                  () => _setStatus(
                    ref,
                    match,
                    IncomingTalentMobilityMatchStatus.accepted,
                  ),
              onBlock:
                  () => _setStatus(
                    ref,
                    match,
                    IncomingTalentMobilityMatchStatus.blocked,
                  ),
              onActivate:
                  () => _setStatus(
                    ref,
                    match,
                    IncomingTalentMobilityMatchStatus.activated,
                  ),
            ),
      ],
    );
  }

  void _setStatus(
    WidgetRef ref,
    IncomingTalentMobilityMatch match,
    IncomingTalentMobilityMatchStatus status,
  ) {
    final notifier = ref.read(incomingTalentMobilityMatchesProvider.notifier);
    switch (status) {
      case IncomingTalentMobilityMatchStatus.sponsorReview:
        notifier.sponsorReview(match.id);
      case IncomingTalentMobilityMatchStatus.accepted:
        notifier.accept(match.id);
      case IncomingTalentMobilityMatchStatus.blocked:
        notifier.block(match.id);
      case IncomingTalentMobilityMatchStatus.activated:
        notifier.activate(match.id);
      case IncomingTalentMobilityMatchStatus.proposed:
        break;
    }
  }
}
