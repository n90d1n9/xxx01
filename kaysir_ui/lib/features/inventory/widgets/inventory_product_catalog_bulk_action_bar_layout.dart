import 'package:flutter/material.dart';

class InventoryProductCatalogBulkActionBarLayout extends StatelessWidget {
  const InventoryProductCatalogBulkActionBarLayout({
    super.key,
    required this.selector,
    required this.actions,
    this.impactStrip,
  });

  static const compactBreakpoint = 720.0;

  final Widget selector;
  final Widget actions;
  final Widget? impactStrip;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < compactBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              selector,
              const SizedBox(height: 10),
              actions,
              if (impactStrip != null) ...[
                const SizedBox(height: 10),
                impactStrip!,
              ],
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                selector,
                const SizedBox(width: 12),
                Expanded(child: actions),
              ],
            ),
            if (impactStrip != null) ...[
              const SizedBox(height: 10),
              impactStrip!,
            ],
          ],
        );
      },
    );
  }
}
