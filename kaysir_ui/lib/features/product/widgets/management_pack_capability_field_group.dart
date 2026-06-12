import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack.dart';
import '../models/management_pack_field_group.dart';
import '../models/management_pack_field_group_progress.dart';
import 'management_pack_capability_visuals.dart';

typedef ProductManagementPackFieldBuilder =
    Widget Function(ProductManagementPackField field);

/// Capability card that keeps management pack fields scannable by behavior.
class ProductManagementPackCapabilityFieldGroup extends StatelessWidget {
  const ProductManagementPackCapabilityFieldGroup({
    super.key,
    required this.group,
    required this.fieldBuilder,
    required this.isExpanded,
    this.progress,
    this.onExpansionChanged,
    this.onSelectField,
  });

  final ProductManagementPackFieldGroup group;
  final ProductManagementPackFieldBuilder fieldBuilder;
  final bool isExpanded;
  final ProductManagementPackFieldGroupProgress? progress;
  final ValueChanged<bool>? onExpansionChanged;
  final ValueChanged<ProductManagementPackField>? onSelectField;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = ProductManagementPackCapabilityVisuals.capabilityColor(
      group.capability,
      colorScheme,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accentColor.withValues(alpha: 0.05),
          colorScheme.surface,
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProductManagementPackCapabilityGroupHeader(
              group: group,
              accentColor: accentColor,
              progress: progress,
              isExpanded: isExpanded,
              onExpansionChanged: onExpansionChanged,
              onSelectField: onSelectField,
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columnCount = constraints.maxWidth >= 760 ? 2 : 1;
                  const gap = 14.0;
                  final itemWidth =
                      (constraints.maxWidth - (gap * (columnCount - 1))) /
                      columnCount;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final field in group.fields)
                        SizedBox(width: itemWidth, child: fieldBuilder(field)),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Header for one capability-driven product management field group.
class _ProductManagementPackCapabilityGroupHeader extends StatelessWidget {
  const _ProductManagementPackCapabilityGroupHeader({
    required this.group,
    required this.accentColor,
    required this.isExpanded,
    this.progress,
    this.onExpansionChanged,
    this.onSelectField,
  });

  final ProductManagementPackFieldGroup group;
  final Color accentColor;
  final bool isExpanded;
  final ProductManagementPackFieldGroupProgress? progress;
  final ValueChanged<bool>? onExpansionChanged;
  final ValueChanged<ProductManagementPackField>? onSelectField;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          ProductManagementPackCapabilityVisuals.capabilityIcon(
            group.capability,
          ),
          color: accentColor,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                group.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                group.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    final statusPills = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        AppStatusPill(
          label: group.fieldCountLabel,
          color: accentColor,
          icon: Icons.tune_rounded,
          maxWidth: 100,
        ),
        if (group.requiredFieldCount > 0)
          AppStatusPill(
            label: group.requiredFieldCountLabel,
            color: colorScheme.error,
            icon: Icons.task_alt_rounded,
            maxWidth: 150,
          ),
        if (progress != null)
          AppStatusPill(
            label: progress!.readinessLabel,
            color: ProductManagementPackCapabilityVisuals.progressColor(
              progress!,
              colorScheme,
            ),
            icon: ProductManagementPackCapabilityVisuals.progressIcon(
              progress!,
            ),
            maxWidth: 170,
          ),
        if (progress != null)
          AppStatusPill(
            label:
                progress!.hasRequiredFields
                    ? progress!.requiredProgressLabel
                    : progress!.filledProgressLabel,
            color: colorScheme.secondary,
            icon: Icons.speed_rounded,
            maxWidth: 150,
          ),
        if (progress?.nextReviewField != null && onSelectField != null)
          OutlinedButton.icon(
            onPressed: () => onSelectField!(progress!.nextReviewField!.field),
            icon: const Icon(Icons.center_focus_strong_rounded),
            label: Text(progress!.reviewNextLabel),
          ),
        if (onExpansionChanged != null)
          Tooltip(
            message: '${isExpanded ? 'Hide' : 'Show'} ${group.title} fields',
            child: OutlinedButton.icon(
              onPressed: () => onExpansionChanged!(!isExpanded),
              icon: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
              label: Text(isExpanded ? 'Hide fields' : 'Show fields'),
            ),
          ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1040) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleBlock, const SizedBox(height: 10), statusPills],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 10),
            statusPills,
          ],
        );
      },
    );
  }
}

@Preview(name: 'Management pack capability field group')
Widget productManagementPackCapabilityFieldGroupPreview() {
  final pack = groceryFreshGoodsProductManagementPack;
  final groups = buildProductManagementPackFieldGroups(pack);
  final group = groups.firstWhere(
    (group) => group.capability == ProductManagementCapability.freshnessQueue,
  );
  final progress = buildProductManagementPackFieldGroupProgressOverview(
    groups: groups,
    values: const {'shelf_life_days': '5'},
  ).progressFor(group.capability);

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 860,
          child: ProductManagementPackCapabilityFieldGroup(
            group: group,
            progress: progress,
            isExpanded: true,
            onExpansionChanged: (_) {},
            fieldBuilder:
                (field) => TextFormField(
                  initialValue:
                      field.options.isEmpty ? '' : field.options.first,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: field.label,
                    helperText: field.description,
                    suffixText: field.unitLabel,
                  ),
                ),
          ),
        ),
      ),
    ),
  );
}
