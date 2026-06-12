import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/service_center_models.dart';
import 'service_center_meta_label.dart';
import 'service_center_status_styles.dart';

class ServiceAnnouncementPanel extends StatelessWidget {
  final List<ServiceAnnouncement> announcements;

  const ServiceAnnouncementPanel({super.key, required this.announcements});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Broadcasts',
      icon: Icons.campaign_outlined,
      subtitle: '${announcements.length} scheduled',
      emptyMessage: 'No broadcasts match filters',
      children:
          announcements
              .map(
                (announcement) => _AnnouncementTile(announcement: announcement),
              )
              .toList(),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final ServiceAnnouncement announcement;

  const _AnnouncementTile({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final color = announcementToneColor(announcement.tone);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.campaign_outlined, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  announcement.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    ServiceCenterMetaLabel(
                      icon: Icons.groups_outlined,
                      label: announcement.audience,
                    ),
                    ServiceCenterMetaLabel(
                      icon: Icons.schedule_outlined,
                      label: DateFormat(
                        'MMM d, HH:mm',
                      ).format(announcement.publishAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
