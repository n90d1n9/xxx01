import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/compliance_models.dart';
import 'compliance_status_styles.dart';

class ComplianceDocumentPanel extends StatelessWidget {
  final List<ComplianceDocument> documents;

  const ComplianceDocumentPanel({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.badge_outlined,
      title: 'Document Expiry',
      subtitle: '${documents.length} documents',
      emptyMessage: 'No matching expiring documents',
      children:
          documents
              .map((document) => _DocumentTile(document: document))
              .toList(),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final ComplianceDocument document;

  const _DocumentTile({required this.document});

  @override
  Widget build(BuildContext context) {
    final color = documentRiskColor(document.risk);
    final formatter = DateFormat('MMM d');
    final daysLeft = document.expiresAt.difference(DateTime.now()).inDays;

    return HrisListSurface(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.badge_outlined, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.employeeName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${document.documentType} - ${document.department}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 6),
                Text(
                  'Expires ${formatter.format(document.expiresAt)} - ${daysLeft < 0 ? 0 : daysLeft} days left',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          HrisStatusPill(label: documentRiskLabel(document.risk), color: color),
        ],
      ),
    );
  }
}
