import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/project_custom_attribute.dart';
import '../services/project_domain_attribute_metadata_service.dart';
import 'project_domain_attribute_metadata_chip_bar.dart';
import 'project_custom_attribute_type_ui.dart';

class ProjectCustomAttributesPanel extends StatelessWidget {
  const ProjectCustomAttributesPanel({
    required this.attributes,
    this.businessDomain,
    this.maxItems,
    super.key,
  });

  final List<ProjectCustomAttribute> attributes;
  final String? businessDomain;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final visible =
        attributes.where((attribute) => attribute.hasValue).toList()
          ..sort((first, second) {
            if (first.isPinned != second.isPinned) {
              return first.isPinned ? -1 : 1;
            }
            return first.label.compareTo(second.label);
          });
    final items = maxItems == null ? visible : visible.take(maxItems!).toList();
    final metadata =
        businessDomain == null
            ? const <ProjectDomainAttributeMetadata>[]
            : const ProjectDomainAttributeMetadataService().build(
              businessDomain: businessDomain!,
              attributes: items,
            );

    if (items.isEmpty) {
      return const AppEmptyState(
        icon: Icons.extension_off_outlined,
        title: 'No custom attributes',
        message: 'Domain-specific fields will appear here after intake.',
      );
    }

    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _ProjectCustomAttributeRow(
            attribute: items[index],
            metadata: metadata.isEmpty ? null : metadata[index],
          ),
          if (index != items.length - 1) const SizedBox(height: 10),
        ],
        if (items.length < visible.length) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: AppStatusPill(
              label: '+${visible.length - items.length} more',
              icon: Icons.more_horiz_rounded,
              color: Theme.of(context).colorScheme.primary,
              maxWidth: 120,
            ),
          ),
        ],
      ],
    );
  }
}

class _ProjectCustomAttributeRow extends StatelessWidget {
  const _ProjectCustomAttributeRow({required this.attribute, this.metadata});

  final ProjectCustomAttribute attribute;
  final ProjectDomainAttributeMetadata? metadata;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return AppInfoRow(
      title: attribute.label,
      subtitle: attribute.displayValue,
      icon: attribute.type.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: color.withValues(alpha: 0.12),
      iconForegroundColor: color,
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 180),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AppStatusPill(
              label: attribute.type.label,
              icon: attribute.type.icon,
              color: color,
              maxWidth: 108,
            ),
            if (metadata != null) ...[
              const SizedBox(height: 8),
              ProjectDomainAttributeMetadataChipBar(metadata: metadata!),
            ],
          ],
        ),
      ),
    );
  }
}
