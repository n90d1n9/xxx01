import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/builder_canvas_config.dart';
import '../models/builder_component_catalog.dart';
import '../models/builder_component_geometry.dart';
import '../models/builder_component_kind.dart';
import 'builder_grid_painter.dart';

/// Builds the widget used to render one component inside a builder canvas.
typedef KyBuilderComponentWidgetBuilder =
    Widget Function(
      BuildContext context,
      BuilderComponentGeometry component,
      BuilderComponentKind? kind,
      bool isSelected,
    );

/// Renders a scrollable, framed builder canvas with selectable components.
class KyBuilderCanvasFrame extends StatelessWidget {
  final BuilderCanvasConfig config;
  final BuilderComponentCatalog catalog;
  final List<BuilderComponentGeometry> components;
  final String? selectedComponentId;
  final ValueChanged<String>? onComponentSelected;
  final KyBuilderComponentWidgetBuilder? componentBuilder;
  final Widget? overlay;

  const KyBuilderCanvasFrame({
    super.key,
    required this.config,
    required this.catalog,
    required this.components,
    this.selectedComponentId,
    this.onComponentSelected,
    this.componentBuilder,
    this.overlay,
  });

  @Preview(name: 'Builder canvas frame')
  const KyBuilderCanvasFrame.preview({super.key})
    : config = const BuilderCanvasConfig(canvasWidth: 520, canvasHeight: 340),
      catalog = const BuilderComponentCatalog(
        kinds: [
          BuilderComponentKind(
            key: 'hero',
            label: 'Hero',
            category: 'Content',
            defaultSize: Size(260, 130),
            description: 'Primary page introduction.',
          ),
          BuilderComponentKind(
            key: 'button',
            label: 'Button',
            category: 'Controls',
            defaultSize: Size(120, 48),
            description: 'Call-to-action button.',
          ),
        ],
      ),
      components = const [
        BuilderComponentGeometry(
          id: 'hero-1',
          kindKey: 'hero',
          position: Offset(32, 36),
          size: Size(260, 130),
          zIndex: 0,
        ),
        BuilderComponentGeometry(
          id: 'button-1',
          kindKey: 'button',
          position: Offset(72, 210),
          size: Size(120, 48),
          zIndex: 1,
        ),
      ],
      selectedComponentId = 'hero-1',
      onComponentSelected = null,
      componentBuilder = null,
      overlay = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sortedComponents = [
      ...components.where((component) => component.isVisible),
    ]..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.32),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.all(color: colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: config.canvasWidth,
                  height: config.canvasHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (config.showGrid)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: KyBuilderGridPainter(
                              gridSize: config.gridSize,
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.62,
                              ),
                            ),
                          ),
                        ),
                      for (final component in sortedComponents)
                        _PositionedBuilderComponent(
                          component: component,
                          kind: catalog.byKey(component.kindKey),
                          isSelected: selectedComponentId == component.id,
                          onSelected: onComponentSelected,
                          componentBuilder: componentBuilder,
                        ),
                      if (overlay != null) Positioned.fill(child: overlay!),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Positions and handles selection for a single canvas component.
class _PositionedBuilderComponent extends StatelessWidget {
  final BuilderComponentGeometry component;
  final BuilderComponentKind? kind;
  final bool isSelected;
  final ValueChanged<String>? onSelected;
  final KyBuilderComponentWidgetBuilder? componentBuilder;

  const _PositionedBuilderComponent({
    required this.component,
    required this.kind,
    required this.isSelected,
    required this.onSelected,
    required this.componentBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: component.position.dx,
      top: component.position.dy,
      width: component.size.width,
      height: component.size.height,
      child: GestureDetector(
        onTap: () => onSelected?.call(component.id),
        child:
            componentBuilder?.call(context, component, kind, isSelected) ??
            _DefaultBuilderComponent(
              component: component,
              kind: kind,
              isSelected: isSelected,
            ),
      ),
    );
  }
}

/// Fallback visual for canvas components when no custom builder is supplied.
class _DefaultBuilderComponent extends StatelessWidget {
  final BuilderComponentGeometry component;
  final BuilderComponentKind? kind;
  final bool isSelected;

  const _DefaultBuilderComponent({
    required this.component,
    required this.kind,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kind?.label ?? component.kindKey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${component.size.width.round()} x ${component.size.height.round()}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '#${component.zIndex}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
