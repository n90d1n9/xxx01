import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../../inventory/models/inventory_product_catalog.dart';
import '../models/product_availability_rule_authoring.dart';

class ProductAvailabilityRuleAuthoringPanel extends StatefulWidget {
  const ProductAvailabilityRuleAuthoringPanel({
    super.key,
    required this.records,
    required this.onApply,
    this.templates = defaultProductAvailabilityRuleTemplates,
    this.templateEntries,
    this.selectedSourceId,
    this.selectedTemplateId,
    this.selectedTarget,
    this.initialTemplateId = ProductAvailabilityRuleTemplateId.counterService,
    this.initialTarget = ProductAvailabilityRuleAuthoringTarget.unconfigured,
    this.onSourceChanged,
    this.onTemplateChanged,
    this.onTargetChanged,
  });

  final List<InventoryProductCatalogRecord> records;
  final List<ProductAvailabilityRuleTemplate> templates;
  final List<ProductAvailabilityRuleTemplateEntry>? templateEntries;
  final String? selectedSourceId;
  final ProductAvailabilityRuleTemplateId? selectedTemplateId;
  final ProductAvailabilityRuleAuthoringTarget? selectedTarget;
  final ValueChanged<ProductAvailabilityRuleAuthoringPlan> onApply;
  final ProductAvailabilityRuleTemplateId initialTemplateId;
  final ProductAvailabilityRuleAuthoringTarget initialTarget;
  final ValueChanged<String>? onSourceChanged;
  final ValueChanged<ProductAvailabilityRuleTemplateId>? onTemplateChanged;
  final ValueChanged<ProductAvailabilityRuleAuthoringTarget>? onTargetChanged;

  @override
  State<ProductAvailabilityRuleAuthoringPanel> createState() =>
      _ProductAvailabilityRuleAuthoringPanelState();
}

class _ProductAvailabilityRuleAuthoringPanelState
    extends State<ProductAvailabilityRuleAuthoringPanel> {
  late ProductAvailabilityRuleTemplateId _templateId;
  var _sourceId = productAvailabilityRuleTemplateAllSourceId;
  late ProductAvailabilityRuleAuthoringTarget _target;

  @override
  void initState() {
    super.initState();
    _templateId = widget.initialTemplateId;
    _target = widget.initialTarget;
  }

  @override
  void didUpdateWidget(ProductAvailabilityRuleAuthoringPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final entries = _templateEntries;
    final sourceId = _resolvedSourceIdFor(entries);
    final sourceEntries = _entriesForSource(entries, sourceId);
    final effectiveEntries = sourceEntries.isEmpty ? entries : sourceEntries;
    final requestedTemplateId = _requestedTemplateId;
    if (!effectiveEntries.any(
          (entry) => entry.template.id == requestedTemplateId,
        ) &&
        effectiveEntries.isNotEmpty) {
      _templateId = effectiveEntries.first.template.id;
    }
    if (widget.selectedSourceId == null &&
        _entriesForSource(entries, _sourceId).isEmpty) {
      _sourceId = productAvailabilityRuleTemplateAllSourceId;
    }
    if (widget.selectedTarget != null) {
      _target = widget.selectedTarget!;
    }
  }

  List<ProductAvailabilityRuleTemplateEntry> get _templateEntries {
    return widget.templateEntries ??
        productAvailabilityRuleTemplateEntriesFor(widget.templates);
  }

  List<ProductAvailabilityRuleTemplateEntry> _entriesForSource(
    List<ProductAvailabilityRuleTemplateEntry> entries,
    String sourceId,
  ) {
    if (sourceId == productAvailabilityRuleTemplateAllSourceId) return entries;

    return List.unmodifiable(
      entries.where((entry) => entry.normalizedSourceId == sourceId),
    );
  }

  String _resolvedSourceIdFor(
    List<ProductAvailabilityRuleTemplateEntry> entries,
  ) {
    final requestedSourceId = widget.selectedSourceId ?? _sourceId;
    if (requestedSourceId == productAvailabilityRuleTemplateAllSourceId) {
      return requestedSourceId;
    }
    if (_entriesForSource(entries, requestedSourceId).isNotEmpty) {
      return requestedSourceId;
    }

    return productAvailabilityRuleTemplateAllSourceId;
  }

  ProductAvailabilityRuleTemplateId get _requestedTemplateId {
    return widget.selectedTemplateId ?? _templateId;
  }

  ProductAvailabilityRuleAuthoringTarget get _effectiveTarget {
    return widget.selectedTarget ?? _target;
  }

  ProductAvailabilityRuleTemplateId _resolvedTemplateIdFor(
    List<ProductAvailabilityRuleTemplateEntry> entries,
  ) {
    final requestedTemplateId = _requestedTemplateId;
    if (entries.any((entry) => entry.template.id == requestedTemplateId)) {
      return requestedTemplateId;
    }
    if (entries.isNotEmpty) return entries.first.template.id;

    return requestedTemplateId;
  }

  void _handleTemplateChanged(ProductAvailabilityRuleTemplateId templateId) {
    setState(() => _templateId = templateId);
    widget.onTemplateChanged?.call(templateId);
  }

  void _handleSourceChanged(
    String sourceId,
    List<ProductAvailabilityRuleTemplateEntry> entries,
  ) {
    final nextEntries = _entriesForSource(entries, sourceId);
    final requestedTemplateId = _requestedTemplateId;
    final nextTemplateId =
        nextEntries.isNotEmpty &&
                !nextEntries.any(
                  (entry) => entry.template.id == requestedTemplateId,
                )
            ? nextEntries.first.template.id
            : null;
    setState(() {
      _sourceId = sourceId;
      if (nextTemplateId != null) {
        _templateId = nextTemplateId;
      }
    });
    widget.onSourceChanged?.call(sourceId);
    if (nextTemplateId != null) widget.onTemplateChanged?.call(nextTemplateId);
  }

  void _handleTargetChanged(ProductAvailabilityRuleAuthoringTarget target) {
    setState(() => _target = target);
    widget.onTargetChanged?.call(target);
  }

  @override
  Widget build(BuildContext context) {
    final entries = _templateEntries;
    if (entries.isEmpty) {
      return const AppContentPanel(
        title: 'Rule authoring',
        leadingIcon: Icons.edit_calendar_rounded,
        child: Text('No availability templates configured.'),
      );
    }

    final sourceId = _resolvedSourceIdFor(entries);
    final visibleEntries = _entriesForSource(entries, sourceId);
    final effectiveEntries = visibleEntries.isEmpty ? entries : visibleEntries;
    final templateId = _resolvedTemplateIdFor(effectiveEntries);
    final templateEntry = productAvailabilityRuleTemplateEntryFor(
      templateId,
      entries: effectiveEntries,
    );
    final template = templateEntry.template;
    final target = _effectiveTarget;
    final plan = buildProductAvailabilityRuleAuthoringPlan(
      records: widget.records,
      template: template,
      target: target,
    );

    return AppContentPanel(
      title: 'Rule authoring',
      subtitle:
          'Template: ${template.title} | Source: ${templateEntry.sourceLabel} '
          '| Target: ${plan.targetCountLabel}',
      leadingIcon: Icons.edit_calendar_rounded,
      trailing: AppStatusPill(
        label: plan.changeCountLabel,
        color: plan.canApply ? Colors.green.shade700 : Colors.blueGrey,
        icon:
            plan.canApply
                ? Icons.playlist_add_check_rounded
                : Icons.check_rounded,
        maxWidth: 140,
      ),
      child:
          widget.records.isEmpty
              ? const Text('No products available for rule authoring.')
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AuthoringControls(
                    entries: effectiveEntries,
                    sourceSummaries:
                        summarizeProductAvailabilityRuleTemplateSources(
                          entries,
                        ),
                    sourceId:
                        visibleEntries.isEmpty
                            ? productAvailabilityRuleTemplateAllSourceId
                            : sourceId,
                    templateId: template.id,
                    target: target,
                    onTemplateChanged: _handleTemplateChanged,
                    onSourceChanged:
                        (value) => _handleSourceChanged(value, entries),
                    onTargetChanged: _handleTargetChanged,
                  ),
                  const SizedBox(height: 14),
                  _TemplatePreview(plan: plan, templateEntry: templateEntry),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppActionButton(
                      label: 'Apply template',
                      icon: Icons.playlist_add_check_rounded,
                      onPressed:
                          plan.canApply ? () => widget.onApply(plan) : null,
                    ),
                  ),
                ],
              ),
    );
  }
}

class _AuthoringControls extends StatelessWidget {
  const _AuthoringControls({
    required this.entries,
    required this.sourceSummaries,
    required this.sourceId,
    required this.templateId,
    required this.target,
    required this.onTemplateChanged,
    required this.onSourceChanged,
    required this.onTargetChanged,
  });

  final List<ProductAvailabilityRuleTemplateEntry> entries;
  final List<ProductAvailabilityRuleTemplateSourceSummary> sourceSummaries;
  final String sourceId;
  final ProductAvailabilityRuleTemplateId templateId;
  final ProductAvailabilityRuleAuthoringTarget target;
  final ValueChanged<ProductAvailabilityRuleTemplateId> onTemplateChanged;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<ProductAvailabilityRuleAuthoringTarget> onTargetChanged;

  @override
  Widget build(BuildContext context) {
    final templateField =
        DropdownButtonFormField<ProductAvailabilityRuleTemplateId>(
          key: ValueKey(_templateFieldKey(entries, templateId)),
          initialValue: templateId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Template',
            prefixIcon: Icon(Icons.rule_rounded),
            border: OutlineInputBorder(),
          ),
          items: [
            for (final entry in entries)
              DropdownMenuItem(
                value: entry.template.id,
                child: Text(
                  entry.template.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) {
            if (value != null) onTemplateChanged(value);
          },
        );
    final targetField =
        DropdownButtonFormField<ProductAvailabilityRuleAuthoringTarget>(
          key: ValueKey('availability-target-${target.name}'),
          initialValue: target,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Target',
            prefixIcon: Icon(Icons.filter_alt_rounded),
            border: OutlineInputBorder(),
          ),
          items: [
            for (final value in ProductAvailabilityRuleAuthoringTarget.values)
              DropdownMenuItem(
                value: value,
                child: Text(
                  productAvailabilityRuleAuthoringTargetTitle(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) {
            if (value != null) onTargetChanged(value);
          },
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final sourceFilter =
            sourceSummaries.length <= 1
                ? const SizedBox.shrink()
                : _TemplateSourceFilter(
                  summaries: sourceSummaries,
                  selectedSourceId: sourceId,
                  onChanged: onSourceChanged,
                );
        final fields =
            constraints.maxWidth < 680
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    templateField,
                    const SizedBox(height: 12),
                    targetField,
                  ],
                )
                : Row(
                  children: [
                    Expanded(child: templateField),
                    const SizedBox(width: 12),
                    Expanded(child: targetField),
                  ],
                );

        if (sourceSummaries.length > 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [sourceFilter, const SizedBox(height: 12), fields],
          );
        }

        return fields;
      },
    );
  }
}

class _TemplateSourceFilter extends StatelessWidget {
  const _TemplateSourceFilter({
    required this.summaries,
    required this.selectedSourceId,
    required this.onChanged,
  });

  final List<ProductAvailabilityRuleTemplateSourceSummary> summaries;
  final String selectedSourceId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final totalCount = summaries.fold<int>(
      0,
      (total, summary) => total + summary.templateCount,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: Text('All templates ($totalCount)'),
          selected:
              selectedSourceId == productAvailabilityRuleTemplateAllSourceId,
          onSelected:
              (_) => onChanged(productAvailabilityRuleTemplateAllSourceId),
        ),
        for (final summary in summaries)
          ChoiceChip(
            label: Text('${summary.title} (${summary.templateCount})'),
            selected: selectedSourceId == summary.id,
            onSelected: (_) => onChanged(summary.id),
          ),
      ],
    );
  }
}

class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview({required this.plan, required this.templateEntry});

  final ProductAvailabilityRuleAuthoringPlan plan;
  final ProductAvailabilityRuleTemplateEntry templateEntry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _templateIcon(plan.template.id),
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.template.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        plan.template.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppStatusPill(
                  label: plan.targetCountLabel,
                  color: Colors.blue.shade700,
                  icon: Icons.filter_alt_rounded,
                  maxWidth: 132,
                ),
                AppStatusPill(
                  label: plan.changeCountLabel,
                  color:
                      plan.canApply ? Colors.green.shade700 : Colors.blueGrey,
                  icon: Icons.edit_rounded,
                  maxWidth: 132,
                ),
                AppStatusPill(
                  label: plan.unchangedCountLabel,
                  color: Colors.blueGrey.shade700,
                  icon: Icons.check_rounded,
                  maxWidth: 172,
                ),
                AppStatusPill(
                  label: templateEntry.sourceLabel,
                  color: colorScheme.primary,
                  icon: Icons.extension_rounded,
                  maxWidth: 230,
                ),
                AppStatusPill(
                  label: plan.template.attributeCountLabel,
                  color: Colors.deepOrange.shade700,
                  icon: Icons.rule_rounded,
                  maxWidth: 144,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _RuleFieldWrap(attributes: plan.template.attributes),
            const SizedBox(height: 12),
            Text(
              plan.previewProductLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleFieldWrap extends StatelessWidget {
  const _RuleFieldWrap({required this.attributes});

  final Map<String, String> attributes;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in attributes.entries)
          AppStatusPill(
            label: '${_attributeLabel(entry.key)}: ${entry.value}',
            color: Colors.deepOrange.shade700,
            showDot: true,
            maxWidth: 220,
          ),
      ],
    );
  }
}

IconData _templateIcon(ProductAvailabilityRuleTemplateId id) {
  switch (id.value) {
    case 'counter_service':
      return Icons.point_of_sale_rounded;
    case 'online_store':
      return Icons.storefront_rounded;
    case 'marketplace':
      return Icons.public_rounded;
    case 'kiosk':
      return Icons.tablet_mac_rounded;
    case 'wholesale':
      return Icons.warehouse_rounded;
    case 'temporarily_paused':
    case 'freshness_hold':
      return Icons.pause_circle_rounded;
    case 'fresh_shelf':
      return Icons.eco_rounded;
    default:
      return Icons.rule_rounded;
  }
}

String _attributeLabel(String key) {
  return key
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

String _templateFieldKey(
  List<ProductAvailabilityRuleTemplateEntry> entries,
  ProductAvailabilityRuleTemplateId templateId,
) {
  final entryIds = entries.map((entry) => entry.template.id.value).join('|');
  return 'availability-template-${templateId.value}-$entryIds';
}
