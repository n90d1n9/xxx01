import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_calibration_provider.dart';
import 'incoming_talent_calibration_form.dart';
import 'incoming_talent_calibration_packet_tile.dart';
import 'incoming_talent_calibration_review_tile.dart';

class IncomingTalentCalibrationPanel extends ConsumerWidget {
  const IncomingTalentCalibrationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packets = ref.watch(filteredIncomingTalentCalibrationPacketsProvider);
    final reviews = ref.watch(filteredIncomingTalentCalibrationReviewsProvider);
    final packetSummary = ref.watch(
      incomingTalentCalibrationPacketSummaryProvider,
    );
    final reviewSummary = ref.watch(
      incomingTalentCalibrationReviewSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.rule_outlined,
      title: 'Talent calibration',
      subtitle: packetSummary.nextAction,
      emptyMessage: 'No calibration data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Accelerate',
              value: '${packetSummary.accelerateCount}',
            ),
            HrisMetricStripItem(
              label: 'Coach',
              value: '${packetSummary.coachCount}',
            ),
            HrisMetricStripItem(
              label: 'Escalate',
              value: '${packetSummary.escalateCount}',
            ),
          ],
        ),
        const IncomingTalentCalibrationForm(),
        if (packets.isEmpty)
          const HrisListSurface(
            child: Text('No calibration packets generated yet.'),
          )
        else ...[
          for (final packet in packets.take(3))
            IncomingTalentCalibrationPacketTile(packet: packet),
        ],
        HrisListSurface(
          child: Text(
            '${reviewSummary.totalCount} submitted reviews - ${reviewSummary.nextAction}',
          ),
        ),
        for (final review in reviews.take(3))
          IncomingTalentCalibrationReviewTile(review: review),
      ],
    );
  }
}
