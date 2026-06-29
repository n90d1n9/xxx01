import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_legal_entity.dart';
import 'company_status_styles.dart';

class CompanyLegalEntityRegistryPanel extends StatelessWidget {
  final List<CompanyLegalEntity> entities;
  final ValueChanged<String> onMarkVerified;

  const CompanyLegalEntityRegistryPanel({
    super.key,
    required this.entities,
    required this.onMarkVerified,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.apartment_outlined,
      title: 'Legal Entity Registry',
      subtitle: '${entities.length} company entities',
      emptyMessage: 'No matching legal entities',
      children:
          entities
              .map(
                (entity) => _EntityTile(
                  entity: entity,
                  onMarkVerified: () => onMarkVerified(entity.id),
                ),
              )
              .toList(),
    );
  }
}

class _EntityTile extends StatelessWidget {
  final CompanyLegalEntity entity;
  final VoidCallback onMarkVerified;

  const _EntityTile({required this.entity, required this.onMarkVerified});

  @override
  Widget build(BuildContext context) {
    final statusColor = companyLegalEntityStatusColor(entity.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entity.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: entity.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${entity.city}, ${entity.country} - ${entity.registrationNumber}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'HR owner', value: entity.hrOwner),
              HrisMetricStripItem(label: 'Tax ID', value: entity.taxId),
              HrisMetricStripItem(
                label: 'Payroll',
                value: entity.payrollEnabled ? 'Enabled' : 'Disabled',
              ),
            ],
          ),
          if (entity.issues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  entity.issues
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
}
