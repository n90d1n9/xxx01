import 'dart:ui';

import 'builder_component_kind.dart';

class BuilderComponentCatalog {
  final List<BuilderComponentKind> kinds;

  const BuilderComponentCatalog({required this.kinds});

  List<String> get categories {
    final seen = <String>{};
    return [
      for (final kind in kinds)
        if (seen.add(kind.category)) kind.category,
    ];
  }

  BuilderComponentKind? byKey(String key) {
    for (final kind in kinds) {
      if (kind.key == key) return kind;
    }
    return null;
  }

  List<BuilderComponentKind> search({String query = '', String? category}) {
    return [
      for (final kind in kinds)
        if ((category == null ||
                category == 'All' ||
                kind.category == category) &&
            kind.matches(query))
          kind,
    ];
  }

  BuilderComponentCatalog merge(BuilderComponentCatalog other) {
    final merged = <String, BuilderComponentKind>{
      for (final kind in kinds) kind.key: kind,
      for (final kind in other.kinds) kind.key: kind,
    };
    return BuilderComponentCatalog(kinds: merged.values.toList());
  }
}

const websiteBuilderCatalog = BuilderComponentCatalog(
  kinds: [
    BuilderComponentKind(
      key: 'section',
      label: 'Section',
      category: 'Layout',
      defaultSize: Size(720, 280),
      description: 'Full-width page band for grouped content.',
      tags: ['container', 'band', 'page'],
    ),
    BuilderComponentKind(
      key: 'two_column',
      label: 'Two Columns',
      category: 'Layout',
      defaultSize: Size(680, 260),
      description: 'Balanced editorial or product columns.',
      tags: ['layout', 'columns'],
    ),
    BuilderComponentKind(
      key: 'hero',
      label: 'Hero Section',
      category: 'Content',
      defaultSize: Size(760, 360),
      description: 'Primary page introduction with title and action.',
      tags: ['headline', 'landing', 'header'],
    ),
    BuilderComponentKind(
      key: 'text_block',
      label: 'Text Block',
      category: 'Content',
      defaultSize: Size(320, 160),
      description: 'Reusable heading and paragraph block.',
      tags: ['copy', 'paragraph'],
    ),
    BuilderComponentKind(
      key: 'image',
      label: 'Image',
      category: 'Media',
      defaultSize: Size(320, 220),
      description: 'Responsive image placeholder.',
      tags: ['photo', 'media'],
    ),
    BuilderComponentKind(
      key: 'gallery',
      label: 'Gallery',
      category: 'Media',
      defaultSize: Size(520, 300),
      description: 'Grid of product, venue, or article imagery.',
      tags: ['images', 'grid'],
    ),
    BuilderComponentKind(
      key: 'button',
      label: 'Button',
      category: 'Controls',
      defaultSize: Size(160, 52),
      description: 'Call-to-action button.',
      tags: ['action', 'cta', 'link'],
    ),
    BuilderComponentKind(
      key: 'form',
      label: 'Form',
      category: 'Controls',
      defaultSize: Size(380, 280),
      description: 'Lead capture or contact form.',
      tags: ['input', 'contact'],
    ),
    BuilderComponentKind(
      key: 'pricing',
      label: 'Pricing Cards',
      category: 'Commerce',
      defaultSize: Size(680, 360),
      description: 'Plan comparison cards with actions.',
      tags: ['plans', 'subscription', 'cards'],
    ),
    BuilderComponentKind(
      key: 'product_card',
      label: 'Product Card',
      category: 'Commerce',
      defaultSize: Size(260, 340),
      description: 'Compact product display with image and price.',
      tags: ['store', 'catalog'],
    ),
  ],
);

const posLayoutBuilderCatalog = BuilderComponentCatalog(
  kinds: [
    BuilderComponentKind(
      key: 'button_grid',
      label: 'Button Grid',
      category: 'POS',
      defaultSize: Size(360, 280),
      description: 'Grid for menu or quick action buttons.',
      tags: ['layout_builder', 'buttons'],
    ),
    BuilderComponentKind(
      key: 'cart_panel',
      label: 'Cart Panel',
      category: 'POS',
      defaultSize: Size(280, 360),
      description: 'Order summary and checkout panel.',
      tags: ['cart', 'checkout'],
    ),
    BuilderComponentKind(
      key: 'numpad',
      label: 'Numpad',
      category: 'POS',
      defaultSize: Size(220, 300),
      description: 'Numeric input cluster.',
      tags: ['input', 'cashier'],
    ),
    BuilderComponentKind(
      key: 'function_panel',
      label: 'Function Panel',
      category: 'POS',
      defaultSize: Size(220, 260),
      description: 'Utility actions for cashier workflows.',
      tags: ['actions', 'cashier'],
    ),
    BuilderComponentKind(
      key: 'custom_button',
      label: 'Action Button',
      category: 'POS',
      defaultSize: Size(160, 56),
      description: 'Single configurable action button.',
      tags: ['button'],
    ),
    BuilderComponentKind(
      key: 'text_label',
      label: 'Text Label',
      category: 'POS',
      defaultSize: Size(180, 48),
      description: 'Static or data-bound label.',
      tags: ['text', 'binding'],
    ),
    BuilderComponentKind(
      key: 'image_holder',
      label: 'Image Holder',
      category: 'POS',
      defaultSize: Size(220, 160),
      description: 'Image placeholder for logos or product visuals.',
      tags: ['image'],
    ),
    BuilderComponentKind(
      key: 'separator',
      label: 'Separator',
      category: 'POS',
      defaultSize: Size(240, 24),
      description: 'Divider between regions.',
      tags: ['divider'],
    ),
  ],
);
