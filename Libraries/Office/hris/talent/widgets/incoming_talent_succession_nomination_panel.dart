import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_nomination_provider.dart';
import 'incoming_talent_succession_nomination_form.dart';
import 'incoming_talent_succession_nomination_tile.dart';

class IncomingTalentSuccessionNominationPanel extends ConsumerWidget {
  const IncomingTalentSuccessionNominationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nominations = ref.watch(
      filteredIncomingTalentSuccessionNominationsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionNominationSummaryProvider,
    );
    final readyCandidates = ref.watch(
      nominationReadySuccessionCandidatesProvider,
    );

    return HrisSectionPanel(
      icon: Icons.how_to_reg_outlined,
      title: 'Succession nominations',
      subtitle: summary.nextAction,
      emptyMessage: 'No succession nominations',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyCandidates.length}',
            ),
            HrisMetricStripItem(
              label: 'Panel',
              value: '${summary.panelReviewCount}',
            ),
            HrisMetricStripItem(
              label: 'Approved',
              value: '${summary.approvedCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionNominationForm(),
        if (nominations.isEmpty)
          const HrisListSurface(
            child: Text('No succession nominations submitted yet.'),
          )
        else
          for (final nomination in nominations.take(3))
            IncomingTalentSuccessionNominationTile(nomination: nomination),
      ],
    );
  }
}
