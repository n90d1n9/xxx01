import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/talent_models.dart';
import 'talent_meta_label.dart';
import 'talent_status_styles.dart';

class CertificationPanel extends StatelessWidget {
  final List<CertificationRecord> certifications;

  const CertificationPanel({super.key, required this.certifications});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Certifications',
      icon: Icons.workspace_premium_outlined,
      subtitle: '${certifications.length} records',
      emptyMessage: 'No certifications match filters',
      children:
          certifications
              .map((item) => _CertificationTile(certification: item))
              .toList(),
    );
  }
}

class _CertificationTile extends StatelessWidget {
  final CertificationRecord certification;

  const _CertificationTile({required this.certification});

  @override
  Widget build(BuildContext context) {
    final color = certificationStatusColor(certification.status);

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
            child: Icon(
              certificationStatusIcon(certification.status),
              color: color,
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
                        certification.certification,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(
                      label: certificationStatusLabel(certification.status),
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    TalentMetaLabel(
                      icon: Icons.person_outline,
                      label: certification.employeeName,
                    ),
                    TalentMetaLabel(
                      icon: Icons.apartment_outlined,
                      label: certification.department,
                    ),
                    TalentMetaLabel(
                      icon: Icons.event_outlined,
                      label:
                          'Expires ${DateFormat('MMM d').format(certification.expiryDate)}',
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
