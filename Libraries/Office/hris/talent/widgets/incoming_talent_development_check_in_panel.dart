import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_development_check_in_provider.dart';
import 'incoming_talent_development_check_in_form.dart';
import 'incoming_talent_development_check_in_tile.dart';

class IncomingTalentDevelopmentCheckInPanel extends ConsumerWidget {
  const IncomingTalentDevelopmentCheckInPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkIns = ref.watch(
      filteredIncomingTalentDevelopmentCheckInsProvider,
    );
    final summary = ref.watch(incomingTalentDevelopmentCheckInSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Development check-ins',
      subtitle: summary.nextAction,
      emptyMessage: 'No development check-in data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Steady',
              value: '${summary.steadyCount}',
            ),
            HrisMetricStripItem(label: 'Watch', value: '${summary.watchCount}'),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
          ],
        ),
        const IncomingTalentDevelopmentCheckInForm(),
        if (checkIns.isEmpty)
          const HrisListSurface(
            child: Text('No development check-ins submitted yet.'),
          )
        else
          for (final checkIn in checkIns)
            IncomingTalentDevelopmentCheckInTile(checkIn: checkIn),
      ],
    );
  }
}
