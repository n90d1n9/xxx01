import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack.dart';
import '../models/product_form_required_action_view_state.dart';
import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';
import 'product_form_missing_attribute_chip.dart';

/// Compact action panel that guides operators through missing required fields.
class ProductFormRequiredActionPanel extends StatefulWidget {
  const ProductFormRequiredActionPanel({
    super.key,
    required this.progress,
    this.onSelectAttribute,
    this.maxVisibleAttributes = 4,
  });

  final ProductFormSectionProgressOverview progress;
  final ValueChanged<ProductFormMissingRequiredAttribute>? onSelectAttribute;
  final int maxVisibleAttributes;

  @override
  State<ProductFormRequiredActionPanel> createState() =>
      _ProductFormRequiredActionPanelState();
}

class _ProductFormRequiredActionPanelState
    extends State<ProductFormRequiredActionPanel> {
  var _showAllMissingAttributes = false;

  @override
  Widget build(BuildContext context) {
    final viewState = ProductFormRequiredActionViewState.fromProgress(
      progress: widget.progress,
      maxVisibleAttributes: widget.maxVisibleAttributes,
      expanded: _showAllMissingAttributes,
    );
    if (!viewState.hasMissingAttributes) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final nextAttribute = viewState.nextAttribute!;

    return AppContentPanel(
      title: 'Required field guide',
      subtitle: widget.progress.requiredProgressLabel,
      leadingIcon: Icons.rule_rounded,
      trailing: AppStatusPill(
        label: widget.progress.readinessLabel,
        color: colorScheme.error,
        icon: Icons.error_outline_rounded,
        maxWidth: 176,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NextRequiredFieldCard(
            attribute: nextAttribute,
            onSelect:
                widget.onSelectAttribute == null
                    ? null
                    : () => widget.onSelectAttribute!(nextAttribute),
          ),
          if (viewState.visibleAdditionalAttributes.isNotEmpty ||
              viewState.canToggleAdditionalAttributes) ...[
            const SizedBox(height: 12),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final attribute in viewState.visibleAdditionalAttributes)
                    ProductFormMissingAttributeChip(
                      attribute: attribute,
                      color: colorScheme.error,
                      onSelected:
                          widget.onSelectAttribute == null
                              ? null
                              : () => widget.onSelectAttribute!(attribute),
                    ),
                  if (viewState.canToggleAdditionalAttributes)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showAllMissingAttributes =
                              !_showAllMissingAttributes;
                        });
                      },
                      icon: Icon(
                        _showAllMissingAttributes
                            ? Icons.expand_less_rounded
                            : Icons.more_horiz_rounded,
                      ),
                      label: Text(viewState.additionalToggleLabel),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Product form required action panel')
Widget productFormRequiredActionPanelPreview() {
  final overview = buildProductFormSectionOverview(
    pack: groceryFreshGoodsProductManagementPack,
    isEditing: false,
  );
  final progress = buildProductFormSectionProgressOverview(
    overview: overview,
    values: const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'description': 'Leafy greens',
    },
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductFormRequiredActionPanel(
          progress: progress,
          onSelectAttribute: (_) {},
        ),
      ),
    ),
  );
}

/// Highlighted card for the next required product form field.
class _NextRequiredFieldCard extends StatelessWidget {
  const _NextRequiredFieldCard({required this.attribute, this.onSelect});

  final ProductFormMissingRequiredAttribute attribute;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colorScheme.error.withValues(alpha: 0.05),
          colorScheme.surface,
        ),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 560;
            final titleBlock = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.priority_high_rounded,
                  color: colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Next required field',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        attribute.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        attribute.helperLabel,
                        maxLines: 1,
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
            final actionButton = TextButton.icon(
              onPressed: onSelect,
              icon: const Icon(Icons.center_focus_strong_rounded),
              label: const Text('Focus field'),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  titleBlock,
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerLeft, child: actionButton),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: titleBlock),
                const SizedBox(width: 12),
                actionButton,
              ],
            );
          },
        ),
      ),
    );
  }
}
