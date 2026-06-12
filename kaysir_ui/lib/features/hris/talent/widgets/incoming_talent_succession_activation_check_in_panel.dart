import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_succession_activation_check_in_provider.dart';
import 'incoming_talent_succession_activation_check_in_form.dart';
import 'incoming_talent_succession_activation_check_in_tile.dart';

class IncomingTalentSuccessionActivationCheckInPanel extends ConsumerWidget {
  const IncomingTalentSuccessionActivationCheckInPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkIns = ref.watch(
      filteredIncomingTalentSuccessionActivationCheckInsProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionActivationCheckInSummaryProvider,
    );
    final readyPlans = ref.watch(checkInReadySuccessionActivationPlansProvider);

    return HrisSectionPanel(
      icon: Icons.rate_review_outlined,
      title: 'Activation check-ins',
      subtitle: summary.nextAction,
      emptyMessage: 'No activation check-ins',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Ready', value: '${readyPlans.length}'),
            HrisMetricStripItem(
              label: 'On track',
              value: '${summary.onTrackCount + summary.acceleratingCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value: '${summary.watchCount + summary.blockedCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionActivationCheckInForm(),
        if (checkIns.isEmpty)
          const HrisListSurface(
            child: Text('No activation check-ins submitted yet.'),
          )
        else
          for (final checkIn in checkIns.take(3))
            IncomingTalentSuccessionActivationCheckInTile(checkIn: checkIn),
      ],
    );
  }
}
