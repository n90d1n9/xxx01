import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_availability_rule_authoring.dart';

class ProductAvailabilityRuleTemplateSourcePanel extends StatelessWidget {
  const ProductAvailabilityRuleTemplateSourcePanel({
    super.key,
    required this.registry,
    this.selectedSourceId = productAvailabilityRuleTemplateAllSourceId,
    this.onSourceSelected,
  });

  final ProductAvailabilityRuleTemplateRegistry registry;
  final String selectedSourceId;
  final ValueChanged<String>? onSourceSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent =
        registry.hasContributions
            ? Colors.teal.shade700
            : Colors.blueGrey.shade700;

    return AppContentPanel(
      title: 'Template sources',
      subtitle:
          '${registry.pack.title} | ${registry.templateCountLabel} available',
      leadingIcon: Icons.extension_rounded,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppStatusPill(
            label: registry.sourceCountLabel,
            color: accent,
            icon: Icons.account_tree_rounded,
            maxWidth: 132,
          ),
          AppStatusPill(
            label: registry.contributionCountLabel,
            color: colorScheme.primary,
            icon: Icons.hub_rounded,
            maxWidth: 164,
          ),
          if (registry.hasDuplicateTemplates)
            AppStatusPill(
              label: registry.ignoredTemplateCountLabel,
              color: Colors.amber.shade800,
              icon: Icons.merge_type_rounded,
              maxWidth: 172,
            ),
        ],
      ),
      child:
          registry.sourceSummaries.isEmpty
              ? Text(
                'No templates registered',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              )
              : _TemplateSourceList(
                registry: registry,
                selectedSourceId: selectedSourceId,
                onSourceSelected: onSourceSelected,
              ),
    );
  }
}

class _TemplateSourceList extends StatelessWidget {
  const _TemplateSourceList({
    required this.registry,
    required this.selectedSourceId,
    required this.onSourceSelected,
  });

  final ProductAvailabilityRuleTemplateRegistry registry;
  final String selectedSourceId;
  final ValueChanged<String>? onSourceSelected;

  @override
  Widget build(BuildContext context) {
    final summaries = registry.sourceSummaries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TemplateSourceMetrics(registry: registry),
        const SizedBox(height: 12),
        _TemplateSourceLine(
          sourceId: productAvailabilityRuleTemplateAllSourceId,
          title: 'All templates',
          subtitle: 'Every available rule source',
          countLabel: registry.templateCountLabel,
          icon: Icons.layers_rounded,
          color: Theme.of(context).colorScheme.primary,
          selected:
              selectedSourceId == productAvailabilityRuleTemplateAllSourceId,
          showDivider: true,
          onSelected: onSourceSelected,
        ),
        for (var index = 0; index < summaries.length; index += 1)
          _TemplateSourceLine(
            sourceId: summaries[index].id,
            title: summaries[index].title,
            subtitle:
                summaries[index].id ==
                        productAvailabilityRuleTemplateCoreSourceId
                    ? 'Core rule templates'
                    : 'Module rule templates',
            countLabel: summaries[index].templateCountLabel,
            icon:
                summaries[index].id ==
                        productAvailabilityRuleTemplateCoreSourceId
                    ? Icons.rule_rounded
                    : Icons.extension_rounded,
            color:
                summaries[index].id ==
                        productAvailabilityRuleTemplateCoreSourceId
                    ? Colors.indigo.shade700
                    : Colors.teal.shade700,
            selected: selectedSourceId == summaries[index].id,
            showDivider: index != summaries.length - 1,
            onSelected: onSourceSelected,
          ),
      ],
    );
  }
}

class _TemplateSourceMetrics extends StatelessWidget {
  const _TemplateSourceMetrics({required this.registry});

  final ProductAvailabilityRuleTemplateRegistry registry;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppStatusPill(
          label: registry.coreTemplateCountLabel,
          color: Colors.indigo.shade700,
          icon: Icons.rule_rounded,
          maxWidth: 168,
        ),
        AppStatusPill(
          label: registry.contributedTemplateCountLabel,
          color: Colors.teal.shade700,
          icon: Icons.add_box_rounded,
          maxWidth: 210,
        ),
      ],
    );
  }
}

class _TemplateSourceLine extends StatelessWidget {
  const _TemplateSourceLine({
    required this.sourceId,
    required this.title,
    required this.subtitle,
    required this.countLabel,
    required this.icon,
    required this.color,
    required this.selected,
    required this.showDivider,
    this.onSelected,
  });

  final String sourceId;
  final String title;
  final String subtitle;
  final String countLabel;
  final IconData icon;
  final Color color;
  final bool selected;
  final bool showDivider;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canSelect = onSelected != null;

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.09) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final titleBlock = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final countPill = AppStatusPill(
                label: countLabel,
                color: color,
                icon: selected ? Icons.check_rounded : null,
                showDot: !selected,
                maxWidth: 126,
              );

              if (constraints.maxWidth < 620) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [titleBlock, const SizedBox(height: 10), countPill],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleBlock),
                  const SizedBox(width: 12),
                  countPill,
                ],
              );
            },
          ),
        ),
      ),
    );
    final selectableRow =
        canSelect
            ? InkWell(
              onTap: () => onSelected!(sourceId),
              borderRadius: BorderRadius.circular(8),
              child: row,
            )
            : row;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        selectableRow,
        if (showDivider) ...[
          Divider(color: colorScheme.outlineVariant, height: 1),
        ],
      ],
    );
  }
}
