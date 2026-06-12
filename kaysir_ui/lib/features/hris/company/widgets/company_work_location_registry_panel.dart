import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_work_location.dart';
import 'company_status_styles.dart';

class CompanyWorkLocationRegistryPanel extends StatelessWidget {
  final List<CompanyWorkLocation> locations;
  final ValueChanged<String> onMarkReady;

  const CompanyWorkLocationRegistryPanel({
    super.key,
    required this.locations,
    required this.onMarkReady,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.location_on_outlined,
      title: 'Work Location Registry',
      subtitle: '${locations.length} locations',
      emptyMessage: 'No matching work locations',
      children:
          locations
              .map(
                (location) => _LocationTile(
                  location: location,
                  onMarkReady: () => onMarkReady(location.id),
                ),
              )
              .toList(),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final CompanyWorkLocation location;
  final VoidCallback onMarkReady;

  const _LocationTile({required this.location, required this.onMarkReady});

  @override
  Widget build(BuildContext context) {
    final statusColor = companyWorkLocationStatusColor(location.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  location.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: location.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${location.type.label} - ${location.entityName}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Owner',
                value: location.coverageOwner,
              ),
              HrisMetricStripItem(
                label: 'Assigned',
                value: '${location.assignedHeadcount}',
              ),
              HrisMetricStripItem(
                label: 'Capacity',
                value: '${location.capacity}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: location.occupancyRatio,
            color: statusColor,
            label:
                '${(location.occupancyRatio * 100).clamp(0, 150).round()}% occupancy',
          ),
          if (location.issues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  location.issues
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
                onPressed: onMarkReady,
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Mark ready'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
