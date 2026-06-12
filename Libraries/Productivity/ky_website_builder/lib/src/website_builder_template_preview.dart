import 'package:flutter/material.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_component_preview.dart';
import 'website_builder_component_properties.dart';
import 'website_builder_templates.dart';

class WebsiteBuilderTemplatePreview extends StatelessWidget {
  final WebsiteBuilderTemplate template;
  final BuilderComponentCatalog catalog;

  const WebsiteBuilderTemplatePreview({
    super.key,
    required this.template,
    this.catalog = websiteBuilderCatalog,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = template.canvasConfig;
    final canvasWidth = config.canvasWidth <= 0 ? 1.0 : config.canvasWidth;
    final canvasHeight = config.canvasHeight <= 0 ? 1.0 : config.canvasHeight;
    final components = [...template.components]
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return KyBuilderPanel(
      color: theme.colorScheme.surface,
      clipContent: true,
      child: AspectRatio(
        aspectRatio: canvasWidth / canvasHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              key: ValueKey('website-builder-template-preview-${template.id}'),
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TemplatePreviewGridPainter(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.44,
                      ),
                    ),
                  ),
                ),
                for (final component in components)
                  _TemplatePreviewComponent(
                    component: component,
                    canvasWidth: canvasWidth,
                    canvasHeight: canvasHeight,
                    previewWidth: constraints.maxWidth,
                    previewHeight: constraints.maxHeight,
                    catalog: catalog,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TemplatePreviewComponent extends StatelessWidget {
  final BuilderComponentGeometry component;
  final double canvasWidth;
  final double canvasHeight;
  final double previewWidth;
  final double previewHeight;
  final BuilderComponentCatalog catalog;

  const _TemplatePreviewComponent({
    required this.component,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.previewWidth,
    required this.previewHeight,
    required this.catalog,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kind = catalog.byKey(component.kindKey);
    final accent = websiteBuilderAccentForKind(
      kind?.key ?? component.kindKey,
      theme.colorScheme,
    );
    final label =
        websiteBuilderPrimaryPropertyValue(component) ??
        kind?.label ??
        component.kindKey;

    return Positioned(
      left: _scaled(component.position.dx, canvasWidth, previewWidth),
      top: _scaled(component.position.dy, canvasHeight, previewHeight),
      width: _scaled(component.size.width, canvasWidth, previewWidth),
      height: _scaled(component.size.height, canvasHeight, previewHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.16),
          border: Border.all(color: accent.withValues(alpha: 0.74)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showLabel =
                constraints.maxWidth >= 48 && constraints.maxHeight >= 20;
            if (!showLabel) return const SizedBox.expand();
            return Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TemplatePreviewGridPainter extends CustomPainter {
  final Color color;

  const _TemplatePreviewGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1;
    const divisions = 6;
    final stepX = size.width / divisions;
    final stepY = size.height / divisions;

    for (var index = 1; index < divisions; index += 1) {
      final x = stepX * index;
      final y = stepY * index;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_TemplatePreviewGridPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}

double _scaled(double value, double source, double target) {
  return (value / source).clamp(0.0, 1.0) * target;
}
