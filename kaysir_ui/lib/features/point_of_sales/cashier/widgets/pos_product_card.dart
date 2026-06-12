import 'package:flutter/material.dart';

import '../../../product/models/product.dart';
import '../experiences/pos_catalog_behavior.dart';
import 'pos_ui.dart';

class POSProductCard extends StatelessWidget {
  final Product product;
  final POSCatalogBehavior catalogBehavior;
  final ValueChanged<Product> onSelected;
  final String Function(double amount) priceFormatter;
  final bool dense;

  const POSProductCard({
    super.key,
    required this.product,
    required this.catalogBehavior,
    required this.onSelected,
    required this.priceFormatter,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionState = catalogBehavior.resolveProductAction(product);
    final foreground = theme.colorScheme.onSurface;
    final supporting = theme.colorScheme.onSurfaceVariant;

    return Opacity(
      opacity: actionState.canAdd ? 1 : 0.68,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: actionState.canAdd ? () => onSelected(product) : null,
            child: POSSurface(
              border: Border.all(
                color:
                    actionState.canAdd
                        ? theme.dividerColor
                        : theme.colorScheme.error.withValues(alpha: 0.22),
              ),
              elevated: !dense,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProductArt(dense: dense),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(dense ? 10 : 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _supportingLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: supporting,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            priceFormatter(product.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (actionState.canAdd)
                            FilledButton.tonalIcon(
                              icon: const Icon(Icons.add_shopping_cart),
                              label: Text(actionState.actionLabel),
                              onPressed: () => onSelected(product),
                              style: _buttonStyle(),
                            )
                          else
                            _UnavailableReason(
                              reason: actionState.disabledReason,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _supportingLine {
    final category = product.category?.trim();
    if (category != null && category.isNotEmpty) {
      return category;
    }

    final sku = product.sku?.trim();
    if (sku != null && sku.isNotEmpty) {
      return 'SKU $sku';
    }

    return 'Uncategorized';
  }

  ButtonStyle _buttonStyle() {
    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        const Size.fromHeight(POSUiTokens.controlHeight),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
        ),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ProductArt extends StatelessWidget {
  final bool dense;

  const _ProductArt({required this.dense});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: dense ? 1.9 : 1.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.54),
        ),
        child: Center(
          child: POSIconBadge(
            icon: Icons.inventory_2_outlined,
            size: dense ? 34 : 40,
            iconSize: dense ? 19 : 22,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _UnavailableReason extends StatelessWidget {
  final String? reason;

  const _UnavailableReason({required this.reason});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: POSUiTokens.controlHeight),
      alignment: Alignment.centerLeft,
      padding: POSUiTokens.controlPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: Text(
        reason ?? 'Unavailable',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onErrorContainer,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
