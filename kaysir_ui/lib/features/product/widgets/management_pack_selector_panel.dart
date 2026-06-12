import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack.dart';

/// Selector for switching the active product management pack.
class ProductManagementPackSelectorPanel extends StatelessWidget {
  const ProductManagementPackSelectorPanel({
    super.key,
    required this.packs,
    required this.selectedPack,
    required this.onChanged,
  });

  final List<ProductManagementPack> packs;
  final ProductManagementPack selectedPack;
  final ValueChanged<ProductManagementPackId> onChanged;

  @override
  Widget build(BuildContext context) {
    if (packs.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return AppContentPanel(
      title: 'Product pack mode',
      subtitle: selectedPack.operatorFocusLabel,
      leadingIcon: Icons.view_module_rounded,
      trailing: AppStatusPill(
        label: '${packs.length} packs',
        color: colorScheme.primary,
        icon: Icons.extension_rounded,
        maxWidth: 112,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<ProductManagementPackId>(
              showSelectedIcon: false,
              segments: [
                for (final pack in packs)
                  ButtonSegment(
                    value: pack.id,
                    icon: Icon(_packIcon(pack)),
                    label: Text(pack.title),
                  ),
              ],
              selected: {selectedPack.id},
              onSelectionChanged: (selection) {
                if (selection.isEmpty) return;
                onChanged(selection.first);
              },
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columnCount = constraints.maxWidth >= 900 ? 2 : 1;
              const gap = 12.0;
              final width =
                  (constraints.maxWidth - (gap * (columnCount - 1))) /
                  columnCount;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final pack in packs)
                    SizedBox(
                      width: width,
                      child: _PackOptionCard(
                        pack: pack,
                        isSelected: pack.id == selectedPack.id,
                        onSelected: () => onChanged(pack.id),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Management pack selector')
Widget productManagementPackSelectorPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackSelectorPanel(
          packs: defaultProductManagementPacks,
          selectedPack: coreProductManagementPack,
          onChanged: (_) {},
        ),
      ),
    ),
  );
}

/// Selectable card describing one available management pack.
class _PackOptionCard extends StatelessWidget {
  const _PackOptionCard({
    required this.pack,
    required this.isSelected,
    required this.onSelected,
  });

  final ProductManagementPack pack;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = isSelected ? colorScheme.primary : colorScheme.outline;

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            isSelected ? accent.withValues(alpha: 0.06) : colorScheme.surface,
        border: Border.all(
          color:
              isSelected
                  ? accent.withValues(alpha: 0.28)
                  : colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isSelected ? null : onSelected,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_packIcon(pack), size: 22, color: accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pack.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pack.businessModelLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  AppStatusPill(
                    label: isSelected ? 'Active' : 'Available',
                    color: accent,
                    maxWidth: 96,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                pack.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppStatusPill(
                    label: '${pack.fields.length} fields',
                    color: Colors.indigo.shade700,
                    showDot: true,
                    maxWidth: 104,
                  ),
                  AppStatusPill(
                    label: '${pack.requiredFields.length} required',
                    color: Colors.teal.shade700,
                    showDot: true,
                    maxWidth: 116,
                  ),
                  AppStatusPill(
                    label: '${pack.profilePacks.length} channel packs',
                    color: Colors.deepOrange.shade700,
                    showDot: true,
                    maxWidth: 148,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _packIcon(ProductManagementPack pack) {
  if (pack.id == ProductManagementPackId.groceryFreshGoods) {
    return Icons.local_grocery_store_rounded;
  }

  return Icons.inventory_2_rounded;
}
