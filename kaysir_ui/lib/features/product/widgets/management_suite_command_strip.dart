import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';

import '../../../widgets/ui/app_surface.dart';

/// Quick actions shared by product management suite screens.
class ProductManagementSuiteCommandStrip extends StatelessWidget {
  const ProductManagementSuiteCommandStrip({
    super.key,
    required this.onOpenWorkspace,
    required this.onOpenCatalog,
    required this.onAddProduct,
  });

  final VoidCallback onOpenWorkspace;
  final VoidCallback onOpenCatalog;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      key: const ValueKey('product-management-suite-command-strip'),
      padding: const EdgeInsets.all(12),
      backgroundColor: colorScheme.surfaceContainerLowest,
      borderColor: colorScheme.outlineVariant.withValues(alpha: 0.72),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final actions = [
            AppActionButton(
              label: 'Workspace',
              icon: Icons.dashboard_rounded,
              variant: AppActionButtonVariant.secondary,
              compact: true,
              onPressed: onOpenWorkspace,
            ),
            AppActionButton(
              label: 'Catalog',
              icon: Icons.inventory_2_rounded,
              variant: AppActionButtonVariant.secondary,
              compact: true,
              onPressed: onOpenCatalog,
            ),
            AppActionButton(
              label: 'Add product',
              icon: Icons.add_box_rounded,
              compact: true,
              onPressed: onAddProduct,
            ),
          ];

          if (constraints.maxWidth < 620) {
            return Wrap(spacing: 8, runSpacing: 8, children: actions);
          }

          return Row(
            children: [
              for (var index = 0; index < actions.length; index++) ...[
                if (index > 0) const SizedBox(width: 8),
                actions[index],
              ],
            ],
          );
        },
      ),
    );
  }
}

@Preview(name: 'Product management suite commands')
Widget productManagementSuiteCommandStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementSuiteCommandStrip(
          onOpenWorkspace: () {},
          onOpenCatalog: () {},
          onAddProduct: () {},
        ),
      ),
    ),
  );
}
