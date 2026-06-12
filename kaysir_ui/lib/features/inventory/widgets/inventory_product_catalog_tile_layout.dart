import 'package:flutter/material.dart';

import 'inventory_tile_surface.dart';

class InventoryProductCatalogTileLayout extends StatelessWidget {
  const InventoryProductCatalogTileLayout({
    super.key,
    required this.backgroundColor,
    required this.summary,
    required this.metrics,
    required this.status,
    required this.actions,
    this.selector,
    this.footer,
  });

  static const compactBreakpoint = 900.0;

  final Color backgroundColor;
  final Widget? selector;
  final Widget summary;
  final Widget metrics;
  final Widget status;
  final Widget actions;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content =
            constraints.maxWidth < compactBreakpoint
                ? _compactContent
                : _wideContent;
        final tileContent =
            footer == null
                ? content
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [content, const SizedBox(height: 10), footer!],
                );

        return InventoryTileSurface(
          backgroundColor: backgroundColor,
          child: tileContent,
        );
      },
    );
  }

  Widget get _compactContent {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (selector == null)
          summary
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              selector!,
              const SizedBox(width: 8),
              Expanded(child: summary),
            ],
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [status, actions],
        ),
        const SizedBox(height: 12),
        metrics,
      ],
    );
  }

  Widget get _wideContent {
    return Row(
      children: [
        if (selector != null) ...[selector!, const SizedBox(width: 8)],
        Expanded(child: summary),
        const SizedBox(width: 14),
        Flexible(flex: 2, child: metrics),
        const SizedBox(width: 12),
        status,
        const SizedBox(width: 6),
        actions,
      ],
    );
  }
}
