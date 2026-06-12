import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/service_center_models.dart';
import 'service_center_meta_label.dart';
import 'service_center_status_styles.dart';

class DocumentRequestPanel extends StatelessWidget {
  final List<DocumentRequest> documents;

  const DocumentRequestPanel({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Document Requests',
      icon: Icons.description_outlined,
      subtitle: '${documents.length} requests',
      emptyMessage: 'No document requests match filters',
      children:
          documents
              .map((document) => _DocumentTile(document: document))
              .toList(),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final DocumentRequest document;

  const _DocumentTile({required this.document});

  @override
  Widget build(BuildContext context) {
    final color = documentStatusColor(document.status);

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
            child: Icon(Icons.insert_drive_file_outlined, color: color),
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
                        document.documentType,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(
                      label: documentStatusLabel(document.status),
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${document.employeeName} - ${document.purpose}',
                  maxLines: 1,
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
                      icon: Icons.person_outline,
                      label: document.owner,
                    ),
                    ServiceCenterMetaLabel(
                      icon: Icons.calendar_today_outlined,
                      label: DateFormat('MMM d').format(document.neededBy),
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
