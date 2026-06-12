import 'package:flutter/material.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_component_properties.dart';

class WebsiteBuilderComponentPreview extends StatelessWidget {
  final BuilderComponentGeometry component;
  final BuilderComponentKind? kind;
  final bool isSelected;

  const WebsiteBuilderComponentPreview({
    super.key,
    required this.component,
    required this.kind,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = websiteBuilderAccentForKind(
      kind?.key ?? component.kindKey,
      colorScheme,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            isSelected ? accent.withValues(alpha: 0.16) : colorScheme.surface,
        border: Border.all(
          color: isSelected ? accent : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.12 : 0.05),
            blurRadius: isSelected ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < 220 || constraints.maxHeight < 120;
            return Padding(
              padding: EdgeInsets.all(compact ? 8 : 12),
              child:
                  compact
                      ? _CompactComponentPreview(
                        component: component,
                        kind: kind,
                        accent: accent,
                      )
                      : _ExpandedComponentPreview(
                        component: component,
                        kind: kind,
                        accent: accent,
                      ),
            );
          },
        ),
      ),
    );
  }
}

class _ExpandedComponentPreview extends StatelessWidget {
  final BuilderComponentGeometry component;
  final BuilderComponentKind? kind;
  final Color accent;

  const _ExpandedComponentPreview({
    required this.component,
    required this.kind,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return switch (component.kindKey) {
      'hero' => _HeroPreview(component: component, accent: accent),
      'section' => _SectionPreview(component: component, accent: accent),
      'two_column' => _TwoColumnPreview(component: component, accent: accent),
      'text_block' => _TextBlockPreview(component: component, accent: accent),
      'image' => _ImagePreview(component: component, accent: accent),
      'gallery' => _GalleryPreview(component: component, accent: accent),
      'button' => _ButtonPreview(component: component, accent: accent),
      'form' => _FormPreview(component: component, accent: accent),
      'pricing' => _PricingPreview(component: component, accent: accent),
      'product_card' => _ProductCardPreview(
        component: component,
        accent: accent,
      ),
      _ => _GenericPreview(component: component, kind: kind, accent: accent),
    };
  }
}

class _CompactComponentPreview extends StatelessWidget {
  final BuilderComponentGeometry component;
  final BuilderComponentKind? kind;
  final Color accent;

  const _CompactComponentPreview({
    required this.component,
    required this.kind,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary =
        websiteBuilderPrimaryPropertyValue(component) ??
        kind?.label ??
        component.kindKey;
    final secondary =
        component.properties['href'] ??
        component.properties['price'] ??
        kind?.category;

    return Row(
      children: [
        Icon(websiteBuilderIconForKind(kind?.key), size: 18, color: accent),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              if (secondary != null && secondary.trim().isNotEmpty)
                Text(
                  secondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroPreview extends StatelessWidget {
  final BuilderComponentGeometry component;
  final Color accent;

  const _HeroPreview({required this.component, required this.accent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _property(component, 'headline', 'Hero headline'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _property(component, 'subheadline', 'Supporting hero copy'),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            _PreviewPill(
              label: _property(component, 'ctaLabel', 'Call to action'),
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionPreview extends StatelessWidget {
  final BuilderComponentGeometry component;
  final Color accent;

  const _SectionPreview({required this.component, required this.accent});

  @override
  Widget build(BuildContext context) {
    return _TextPanel(
      icon: Icons.view_agenda_outlined,
      title: _property(component, 'title', 'Section title'),
      body: _property(component, 'body', 'Section body'),
      accent: accent,
    );
  }
}

class _TextBlockPreview extends StatelessWidget {
  final BuilderComponentGeometry component;
  final Color accent;

  const _TextBlockPreview({required this.component, required this.accent});

  @override
  Widget build(BuildContext context) {
    return _TextPanel(
      icon: Icons.notes,
      title: _property(component, 'title', 'Text title'),
      body: _property(component, 'body', 'Text body'),
      accent: accent,
    );
  }
}

class _TwoColumnPreview extends StatelessWidget {
  final BuilderComponentGeometry component;
  final Color accent;

  const _TwoColumnPreview({required this.component, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniPanel(
            title: _property(component, 'leftTitle', 'Left'),
            body: _property(component, 'leftBody', 'Left body'),
            accent: accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniPanel(
            title: _property(component, 'rightTitle', 'Right'),
            body: _property(component, 'rightBody', 'Right body'),
            accent: accent,
          ),
        ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final BuilderComponentGeometry component;
  final Color accent;

  const _ImagePreview({required this.component, required this.accent});

  @override
  Widget build(BuildContext context) {
    return _MediaPanel(
      icon: Icons.image_outlined,
      title: _property(component, 'altText', 'Image description'),
      body: _property(component, 'imageUrl', 'Image URL'),
      accent: accent,
    );
  }
}

class _GalleryPreview extends StatelessWidget {
  final BuilderComponentGeometry component;
  final Color accent;

  const _GalleryPreview({required this.component, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var index = 0; index < 4; index += 1)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10 + (index * 0.03)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _PreviewTitle(
          text: _property(component, 'title', 'Gallery'),
          accent: accent,
        ),
        _PreviewBody(
          text: _property(component, 'caption', 'Gallery caption'),
          maxLines: 2,
        ),
      ],
    );
  }
}

class _ButtonPreview extends StatelessWidget {
  final BuilderComponentGeometry component;
  final Color accent;

  const _ButtonPreview({required this.component, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PreviewPill(
            label: _property(component, 'label', 'Button'),
            accent: accent,
          ),
          const SizedBox(height: 6),
          _PreviewBody(
            text: _property(component, 'href', '/link'),
            maxLines: 1,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FormPreview extends StatelessWidget {
  final BuilderComponentGeometry component;
  final Color accent;

  const _FormPreview({required this.component, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewTitle(
          text: _property(component, 'title', 'Form'),
          accent: accent,
        ),
        const SizedBox(height: 10),
        _FormLine(accent: accent),
        const SizedBox(height: 8),
        _FormLine(accent: accent),
        const Spacer(),
        _PreviewPill(
          label: _property(component, 'submitLabel', 'Submit'),
          accent: accent,
        ),
      ],
    );
  }
}

class _PricingPreview extends StatelessWidget {
  final BuilderComponentGeometry component;
  final Color accent;

  const _PricingPreview({required this.component, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewTitle(
          text: _property(component, 'title', 'Plan'),
          accent: accent,
        ),
        const SizedBox(height: 8),
        Text(
          _property(component, 'price', r'$0'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: accent,
          ),
        ),
        const SizedBox(height: 8),
        _FeatureLine(accent: accent, label: 'Included feature'),
        const SizedBox(height: 6),
        _FeatureLine(accent: accent, label: 'Priority support'),
        const Spacer(),
        _PreviewPill(
          label: _property(component, 'ctaLabel', 'Choose plan'),
          accent: accent,
        ),
      ],
    );
  }
}

class _ProductCardPreview extends StatelessWidget {
  final BuilderComponentGeometry component;
  final Color accent;

  const _ProductCardPreview({required this.component, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Icon(Icons.shopping_bag_outlined, color: accent),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _PreviewTitle(
          text: _property(component, 'productName', 'Product'),
          accent: accent,
        ),
        _PreviewBody(text: _property(component, 'price', r'$0'), maxLines: 1),
        const SizedBox(height: 8),
        _PreviewPill(
          label: _property(component, 'ctaLabel', 'Add'),
          accent: accent,
        ),
      ],
    );
  }
}

class _GenericPreview extends StatelessWidget {
  final BuilderComponentGeometry component;
  final BuilderComponentKind? kind;
  final Color accent;

  const _GenericPreview({
    required this.component,
    required this.kind,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return _TextPanel(
      icon: websiteBuilderIconForKind(kind?.key),
      title:
          websiteBuilderPrimaryPropertyValue(component) ??
          kind?.label ??
          component.kindKey,
      body: kind?.category ?? 'Component',
      accent: accent,
    );
  }
}

class _TextPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color accent;

  const _TextPanel({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(height: 8),
            _PreviewTitle(text: title, accent: accent),
            const SizedBox(height: 6),
            _PreviewBody(text: body, maxLines: 4),
          ],
        ),
      ),
    );
  }
}

class _MiniPanel extends StatelessWidget {
  final String title;
  final String body;
  final Color accent;

  const _MiniPanel({
    required this.title,
    required this.body,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PreviewTitle(text: title, accent: accent),
            const SizedBox(height: 6),
            _PreviewBody(text: body, maxLines: 5),
          ],
        ),
      ),
    );
  }
}

class _MediaPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color accent;

  const _MediaPanel({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: accent, size: 28),
              const SizedBox(height: 8),
              _PreviewTitle(
                text: title,
                accent: accent,
                align: TextAlign.center,
              ),
              const SizedBox(height: 4),
              _PreviewBody(text: body, maxLines: 2, align: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows compact text inside website component previews.
class _PreviewPill extends StatelessWidget {
  final String label;
  final Color accent;

  const _PreviewPill({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return KyBuilderBadge(
      label: label,
      backgroundColor: accent,
      borderColor: Colors.transparent,
      borderWidth: 0,
      foregroundColor: Colors.white,
      radius: 6,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PreviewTitle extends StatelessWidget {
  final String text;
  final Color accent;
  final TextAlign align;

  const _PreviewTitle({
    required this.text,
    required this.accent,
    this.align = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: accent,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _PreviewBody extends StatelessWidget {
  final String text;
  final int maxLines;
  final TextAlign align;

  const _PreviewBody({
    required this.text,
    required this.maxLines,
    this.align = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _FormLine extends StatelessWidget {
  final Color accent;

  const _FormLine({required this.accent});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: accent.withValues(alpha: 0.36)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const SizedBox(height: 28, width: double.infinity),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  final Color accent;
  final String label;

  const _FeatureLine({required this.accent, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle, size: 14, color: accent),
        const SizedBox(width: 6),
        Expanded(child: _PreviewBody(text: label, maxLines: 1)),
      ],
    );
  }
}

String _property(
  BuilderComponentGeometry component,
  String key,
  String fallback,
) {
  final value = component.properties[key]?.trim();
  return value == null || value.isEmpty ? fallback : value;
}

IconData websiteBuilderIconForKind(String? key) {
  return switch (key) {
    'hero' => Icons.web_asset,
    'section' => Icons.view_agenda_outlined,
    'two_column' => Icons.view_column,
    'text_block' => Icons.notes,
    'image' => Icons.image_outlined,
    'gallery' => Icons.photo_library_outlined,
    'button' => Icons.smart_button_outlined,
    'form' => Icons.dynamic_form_outlined,
    'pricing' => Icons.sell_outlined,
    'product_card' => Icons.shopping_bag_outlined,
    _ => Icons.widgets_outlined,
  };
}

Color websiteBuilderAccentForKind(String key, ColorScheme colorScheme) {
  return switch (key) {
    'hero' || 'section' || 'two_column' => colorScheme.primary,
    'image' || 'gallery' => colorScheme.tertiary,
    'pricing' || 'product_card' => const Color(0xFF047857),
    'form' || 'button' => colorScheme.secondary,
    _ => colorScheme.primary,
  };
}
