import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/engagement_models.dart';
import 'engagement_meta_label.dart';
import 'engagement_status_styles.dart';

class RecognitionPanel extends StatelessWidget {
  final List<RecognitionMoment> recognition;

  const RecognitionPanel({super.key, required this.recognition});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Recognition',
      icon: Icons.celebration_outlined,
      subtitle: '${recognition.length} moments',
      emptyMessage: 'Recognition hidden in attention view',
      children:
          recognition
              .map((moment) => _RecognitionTile(recognition: moment))
              .toList(),
    );
  }
}

class _RecognitionTile extends StatelessWidget {
  final RecognitionMoment recognition;

  const _RecognitionTile({required this.recognition});

  @override
  Widget build(BuildContext context) {
    final color = recognitionTypeColor(recognition.type);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Text(
              _initials(recognition.employeeName),
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recognition.employeeName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    HrisStatusPill(
                      label: recognitionTypeLabel(recognition.type),
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  recognition.reason,
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
                    EngagementMetaLabel(
                      icon: Icons.person_outline,
                      label: recognition.fromName,
                    ),
                    EngagementMetaLabel(
                      icon: Icons.calendar_today_outlined,
                      label: DateFormat(
                        'MMM d',
                      ).format(recognition.recognizedAt),
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
