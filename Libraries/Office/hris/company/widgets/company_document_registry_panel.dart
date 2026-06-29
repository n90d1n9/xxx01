import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_document.dart';
import 'company_status_styles.dart';

class CompanyDocumentRegistryPanel extends StatelessWidget {
  final List<CompanyDocumentRecord> documents;
  final DateTime asOfDate;
  final ValueChanged<String> onMarkVerified;

  const CompanyDocumentRegistryPanel({
    super.key,
    required this.documents,
    required this.asOfDate,
    required this.onMarkVerified,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.folder_copy_outlined,
      title: 'Company Document Registry',
      subtitle: '${documents.length} statutory records',
      emptyMessage: 'No matching company documents',
      children:
          documents
              .map(
                (document) => _DocumentTile(
                  document: document,
                  asOfDate: asOfDate,
                  onMarkVerified: () => onMarkVerified(document.id),
                ),
              )
              .toList(),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final CompanyDocumentRecord document;
  final DateTime asOfDate;
  final VoidCallback onMarkVerified;

  const _DocumentTile({
    required this.document,
    required this.asOfDate,
    required this.onMarkVerified,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = companyDocumentStatusColor(document.status);
    final issues = document.issues(asOfDate);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  document.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: document.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${document.type.label} - ${document.entityName}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Owner', value: document.ownerName),
              HrisMetricStripItem(
                label: 'Module',
                value: document.linkedModule,
              ),
              HrisMetricStripItem(
                label: 'Expiry',
                value: _expiryLabel(document, asOfDate),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            document.documentNumber.trim().isEmpty
                ? 'Document number pending'
                : document.documentNumber,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  issues
                      .map(
                        (issue) => HrisStatusPill(
                          label: issue.label,
                          color: Colors.orange,
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onMarkVerified,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Mark verified'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _expiryLabel(CompanyDocumentRecord document, DateTime asOfDate) {
    final expiry = document.expiryDate;
    if (expiry == null) return 'No expiry';
    final days = document.daysUntilExpiry(asOfDate) ?? 0;
    if (days < 0) return 'Expired ${days.abs()}d';
    if (days == 0) return 'Due today';
    return '${_formatDate(expiry)} (${days}d)';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
