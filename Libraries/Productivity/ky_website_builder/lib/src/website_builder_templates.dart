import 'dart:ui';

import 'package:ky_builder_shared/ky_builder_shared.dart';

class WebsiteBuilderTemplate {
  final String id;
  final String name;
  final String category;
  final String description;
  final BuilderCanvasConfig canvasConfig;
  final List<BuilderComponentGeometry> components;
  final String? selectedComponentId;

  const WebsiteBuilderTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.canvasConfig,
    required this.components,
    this.selectedComponentId,
  });

  int get componentCount => components.length;

  BuilderSharedSnapshot toSharedSnapshot() {
    return BuilderSharedSnapshot(
      id: id,
      name: name,
      canvasConfig: canvasConfig,
      components: components,
      selectedComponentId: selectedComponentId,
    );
  }
}

class WebsiteBuilderTemplateLibrary {
  final List<WebsiteBuilderTemplate> templates;

  const WebsiteBuilderTemplateLibrary(this.templates);

  List<String> get categories {
    final seen = <String>{};
    return [
      for (final template in templates)
        if (seen.add(template.category)) template.category,
    ];
  }

  WebsiteBuilderTemplate? byId(String id) {
    for (final template in templates) {
      if (template.id == id) return template;
    }
    return null;
  }

  List<WebsiteBuilderTemplate> search({String query = '', String? category}) {
    final normalizedQuery = query.trim().toLowerCase();
    return [
      for (final template in templates)
        if ((category == null || category == template.category) &&
            _matchesQuery(template, normalizedQuery))
          template,
    ];
  }

  bool _matchesQuery(WebsiteBuilderTemplate template, String query) {
    if (query.isEmpty) return true;
    final haystack =
        [
          template.name,
          template.category,
          template.description,
          for (final component in template.components) ...[
            component.kindKey,
            ...component.properties.values,
          ],
        ].join(' ').toLowerCase();
    return haystack.contains(query);
  }
}

const websiteBuilderTemplateLibrary = WebsiteBuilderTemplateLibrary(
  websiteBuilderTemplates,
);

const websiteBuilderTemplates = <WebsiteBuilderTemplate>[
  WebsiteBuilderTemplate(
    id: 'template_landing_page',
    name: 'Landing Page',
    category: 'Marketing',
    description:
        'Hero, value section, feature columns, pricing, and lead form.',
    canvasConfig: BuilderCanvasConfig(canvasHeight: 1400),
    selectedComponentId: 'landing_hero',
    components: [
      BuilderComponentGeometry(
        id: 'landing_hero',
        kindKey: 'hero',
        position: Offset(80, 60),
        size: Size(800, 340),
        properties: {
          'headline': 'Launch your next storefront',
          'subheadline':
              'Turn campaigns, products, and contact flows into one polished page.',
          'ctaLabel': 'Start selling',
        },
        zIndex: 0,
      ),
      BuilderComponentGeometry(
        id: 'landing_image',
        kindKey: 'image',
        position: Offset(920, 80),
        size: Size(260, 300),
        properties: {'imageUrl': '', 'altText': 'Product preview'},
        zIndex: 1,
      ),
      BuilderComponentGeometry(
        id: 'landing_section',
        kindKey: 'section',
        position: Offset(80, 440),
        size: Size(1080, 240),
        properties: {
          'title': 'Built for modern commerce teams',
          'body':
              'Use reusable sections to shape a site that can evolve with each product, offer, or event.',
        },
        zIndex: 2,
      ),
      BuilderComponentGeometry(
        id: 'landing_columns',
        kindKey: 'two_column',
        position: Offset(80, 730),
        size: Size(1080, 260),
        properties: {
          'leftTitle': 'Design faster',
          'leftBody': 'Compose page blocks from a shared builder catalog.',
          'rightTitle': 'Publish cleaner',
          'rightBody': 'Export readable HTML with safety checks built in.',
        },
        zIndex: 3,
      ),
      BuilderComponentGeometry(
        id: 'landing_pricing',
        kindKey: 'pricing',
        position: Offset(80, 1040),
        size: Size(500, 300),
        properties: {
          'title': 'Growth',
          'price': r'$29',
          'ctaLabel': 'Choose plan',
        },
        zIndex: 4,
      ),
      BuilderComponentGeometry(
        id: 'landing_form',
        kindKey: 'form',
        position: Offset(640, 1040),
        size: Size(520, 300),
        properties: {'title': 'Talk to us', 'submitLabel': 'Request demo'},
        zIndex: 5,
      ),
    ],
  ),
  WebsiteBuilderTemplate(
    id: 'template_product_page',
    name: 'Product Page',
    category: 'Commerce',
    description: 'Product hero, gallery, product card, and supporting copy.',
    canvasConfig: BuilderCanvasConfig(canvasHeight: 1220),
    selectedComponentId: 'product_hero',
    components: [
      BuilderComponentGeometry(
        id: 'product_hero',
        kindKey: 'hero',
        position: Offset(80, 60),
        size: Size(720, 320),
        properties: {
          'headline': 'Signature product drop',
          'subheadline':
              'Present a focused launch with product story, visuals, and purchase action.',
          'ctaLabel': 'Shop now',
        },
        zIndex: 0,
      ),
      BuilderComponentGeometry(
        id: 'product_card',
        kindKey: 'product_card',
        position: Offset(860, 70),
        size: Size(300, 340),
        properties: {
          'productName': 'Signature Product',
          'price': r'$49',
          'ctaLabel': 'Add to cart',
        },
        zIndex: 1,
      ),
      BuilderComponentGeometry(
        id: 'product_gallery',
        kindKey: 'gallery',
        position: Offset(80, 450),
        size: Size(560, 320),
        properties: {
          'title': 'Product details',
          'caption':
              'Use the gallery to show variants, packaging, or use cases.',
        },
        zIndex: 2,
      ),
      BuilderComponentGeometry(
        id: 'product_copy',
        kindKey: 'text_block',
        position: Offset(700, 470),
        size: Size(460, 260),
        properties: {
          'title': 'Why customers choose it',
          'body':
              'Pair product proof with a clear, scannable story that helps shoppers decide quickly.',
        },
        zIndex: 3,
      ),
      BuilderComponentGeometry(
        id: 'product_section',
        kindKey: 'section',
        position: Offset(80, 840),
        size: Size(820, 220),
        properties: {
          'title': 'Shipping, support, and guarantees',
          'body':
              'Add practical details that reduce friction and make the buying path feel trustworthy.',
        },
        zIndex: 4,
      ),
      BuilderComponentGeometry(
        id: 'product_button',
        kindKey: 'button',
        position: Offset(940, 910),
        size: Size(180, 56),
        properties: {'label': 'View catalog', 'href': '/catalog'},
        zIndex: 5,
      ),
    ],
  ),
  WebsiteBuilderTemplate(
    id: 'template_contact_page',
    name: 'Contact Page',
    category: 'Operations',
    description: 'Contact form, intro section, team note, and visual panel.',
    canvasConfig: BuilderCanvasConfig(canvasHeight: 980),
    selectedComponentId: 'contact_form',
    components: [
      BuilderComponentGeometry(
        id: 'contact_section',
        kindKey: 'section',
        position: Offset(80, 60),
        size: Size(640, 240),
        properties: {
          'title': 'Get in touch',
          'body':
              'Give visitors a direct path to ask questions, book a call, or request a custom offer.',
        },
        zIndex: 0,
      ),
      BuilderComponentGeometry(
        id: 'contact_image',
        kindKey: 'image',
        position: Offset(780, 70),
        size: Size(340, 260),
        properties: {'imageUrl': '', 'altText': 'Support team workspace'},
        zIndex: 1,
      ),
      BuilderComponentGeometry(
        id: 'contact_form',
        kindKey: 'form',
        position: Offset(80, 390),
        size: Size(500, 340),
        properties: {'title': 'Send a message', 'submitLabel': 'Send inquiry'},
        zIndex: 2,
      ),
      BuilderComponentGeometry(
        id: 'contact_note',
        kindKey: 'text_block',
        position: Offset(640, 420),
        size: Size(480, 220),
        properties: {
          'title': 'Response promise',
          'body':
              'Set expectations clearly with response time, available channels, and next steps.',
        },
        zIndex: 3,
      ),
      BuilderComponentGeometry(
        id: 'contact_button',
        kindKey: 'button',
        position: Offset(640, 700),
        size: Size(200, 56),
        properties: {'label': 'Book a call', 'href': '/contact'},
        zIndex: 4,
      ),
    ],
  ),
];
