import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/recruitment_models.dart';
import 'recruitment_meta_label.dart';
import 'recruitment_status_styles.dart';

class OfferTrackerPanel extends StatelessWidget {
  final List<OfferTracker> offers;

  const OfferTrackerPanel({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Offer Tracker',
      icon: Icons.handshake_outlined,
      subtitle: '${offers.length} offers',
      emptyMessage: 'No offers match filters',
      children: offers.map((offer) => _OfferTile(offer: offer)).toList(),
    );
  }
}

class _OfferTile extends StatelessWidget {
  final OfferTracker offer;

  const _OfferTile({required this.offer});

  @override
  Widget build(BuildContext context) {
    final color = offerStatusColor(offer.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  offer.candidateName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HrisStatusPill(
                label: offerStatusLabel(offer.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            offer.role,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: offer.compensationScore / 100,
            color: color,
            label: 'Compensation score ${offer.compensationScore}',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              RecruitmentMetaLabel(
                icon: Icons.person_outline,
                label: offer.recruiter,
              ),
              RecruitmentMetaLabel(
                icon: Icons.event_outlined,
                label: 'Expires ${DateFormat('MMM d').format(offer.expiresAt)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
