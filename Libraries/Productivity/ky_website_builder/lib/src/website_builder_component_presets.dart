import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_component_properties.dart';

class WebsiteBuilderComponentPreset {
  final String id;
  final String kindKey;
  final String label;
  final String description;
  final Map<String, String> properties;
  final bool isCustom;

  const WebsiteBuilderComponentPreset({
    required this.id,
    required this.kindKey,
    required this.label,
    required this.description,
    required this.properties,
    this.isCustom = false,
  });

  WebsiteBuilderComponentPreset copyWith({
    String? id,
    String? kindKey,
    String? label,
    String? description,
    Map<String, String>? properties,
    bool? isCustom,
  }) {
    return WebsiteBuilderComponentPreset(
      id: id ?? this.id,
      kindKey: kindKey ?? this.kindKey,
      label: label ?? this.label,
      description: description ?? this.description,
      properties: properties ?? this.properties,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kindKey': kindKey,
      'label': label,
      'description': description,
      'properties': properties,
      'isCustom': isCustom,
    };
  }

  factory WebsiteBuilderComponentPreset.fromJson(Map<String, dynamic> json) {
    return WebsiteBuilderComponentPreset(
      id: json['id'] as String? ?? '',
      kindKey: json['kindKey'] as String? ?? '',
      label: json['label'] as String? ?? 'Custom preset',
      description: json['description'] as String? ?? '',
      properties: {
        for (final entry
            in Map<String, dynamic>.from(
              json['properties'] as Map? ?? const {},
            ).entries)
          entry.key: '${entry.value}',
      },
      isCustom: json['isCustom'] as bool? ?? true,
    );
  }
}

const _presetsByKind = <String, List<WebsiteBuilderComponentPreset>>{
  'hero': [
    WebsiteBuilderComponentPreset(
      id: 'hero_product_launch',
      kindKey: 'hero',
      label: 'Product launch',
      description: 'Campaign copy for a launch or featured release.',
      properties: {
        'headline': 'Launch your next product',
        'subheadline':
            'Turn early demand into a polished campaign page that is ready to share.',
        'ctaLabel': 'Explore the launch',
      },
    ),
    WebsiteBuilderComponentPreset(
      id: 'hero_service_booking',
      kindKey: 'hero',
      label: 'Service booking',
      description: 'Lead visitors from first question to appointment.',
      properties: {
        'headline': 'Book expert help today',
        'subheadline':
            'Guide visitors from first question to confirmed appointment with one focused page.',
        'ctaLabel': 'Book a call',
      },
    ),
  ],
  'section': [
    WebsiteBuilderComponentPreset(
      id: 'section_benefits',
      kindKey: 'section',
      label: 'Benefits',
      description: 'A short value section for outcomes and proof.',
      properties: {
        'title': 'Why customers choose us',
        'body':
            'Combine a practical workflow, clear pricing, and responsive support in one simple experience.',
      },
    ),
    WebsiteBuilderComponentPreset(
      id: 'section_process',
      kindKey: 'section',
      label: 'Process',
      description: 'A concise explanation for how the offer works.',
      properties: {
        'title': 'How it works',
        'body':
            'Share the request, confirm the details, and get a page-ready result without extra coordination.',
      },
    ),
  ],
  'two_column': [
    WebsiteBuilderComponentPreset(
      id: 'two_column_problem_solution',
      kindKey: 'two_column',
      label: 'Problem and solution',
      description: 'Contrast the customer pain with your response.',
      properties: {
        'leftTitle': 'The challenge',
        'leftBody':
            'Teams need a clearer way to turn scattered content into a focused page.',
        'rightTitle': 'The solution',
        'rightBody':
            'Reusable blocks keep the message consistent while every section stays editable.',
      },
    ),
    WebsiteBuilderComponentPreset(
      id: 'two_column_plan_publish',
      kindKey: 'two_column',
      label: 'Plan and publish',
      description: 'A workflow pair for production-oriented pages.',
      properties: {
        'leftTitle': 'Plan',
        'leftBody':
            'Collect the offer, target audience, and conversion goal before arranging the page.',
        'rightTitle': 'Publish',
        'rightBody':
            'Review content health, export the page, and keep the layout ready for reuse.',
      },
    ),
  ],
  'text_block': [
    WebsiteBuilderComponentPreset(
      id: 'text_block_story',
      kindKey: 'text_block',
      label: 'Story',
      description: 'A narrative block for context and positioning.',
      properties: {
        'title': 'Built around the way you sell',
        'body':
            'Use this space to explain the journey, the result, and why the page matters to the customer.',
      },
    ),
    WebsiteBuilderComponentPreset(
      id: 'text_block_testimonial',
      kindKey: 'text_block',
      label: 'Testimonial',
      description: 'A compact proof block for customer feedback.',
      properties: {
        'title': 'What customers are saying',
        'body':
            'The page made our offer easier to understand and gave the team a cleaner way to launch.',
      },
    ),
  ],
  'image': [
    WebsiteBuilderComponentPreset(
      id: 'image_product',
      kindKey: 'image',
      label: 'Product image',
      description: 'Safe placeholder copy for product-focused media.',
      properties: {
        'imageUrl': 'https://example.com/product.jpg',
        'altText': 'Product displayed in a clean storefront layout',
      },
    ),
    WebsiteBuilderComponentPreset(
      id: 'image_team',
      kindKey: 'image',
      label: 'Team image',
      description: 'Safe placeholder copy for people and service pages.',
      properties: {
        'imageUrl': 'https://example.com/team.jpg',
        'altText': 'Team preparing a customer project',
      },
    ),
  ],
  'gallery': [
    WebsiteBuilderComponentPreset(
      id: 'gallery_showcase',
      kindKey: 'gallery',
      label: 'Showcase',
      description: 'A gallery title for product or portfolio examples.',
      properties: {
        'title': 'Recent showcase',
        'caption':
            'A curated look at launches, products, and customer-ready page sections.',
      },
    ),
    WebsiteBuilderComponentPreset(
      id: 'gallery_collection',
      kindKey: 'gallery',
      label: 'Collection',
      description: 'A gallery title for grouped items or catalog pages.',
      properties: {
        'title': 'Featured collection',
        'caption':
            'Highlight the most useful items with visual proof and quick context.',
      },
    ),
  ],
  'button': [
    WebsiteBuilderComponentPreset(
      id: 'button_demo',
      kindKey: 'button',
      label: 'Book a demo',
      description: 'A sales action that links to the demo route.',
      properties: {'label': 'Book a demo', 'href': '/demo'},
    ),
    WebsiteBuilderComponentPreset(
      id: 'button_checkout',
      kindKey: 'button',
      label: 'Start checkout',
      description: 'A commerce action that links to checkout.',
      properties: {'label': 'Start checkout', 'href': '/checkout'},
    ),
  ],
  'form': [
    WebsiteBuilderComponentPreset(
      id: 'form_support',
      kindKey: 'form',
      label: 'Support request',
      description: 'A support-oriented form title and submit action.',
      properties: {'title': 'Request support', 'submitLabel': 'Send request'},
    ),
    WebsiteBuilderComponentPreset(
      id: 'form_lead',
      kindKey: 'form',
      label: 'Lead capture',
      description: 'A general contact form for lead generation.',
      properties: {'title': 'Get in touch', 'submitLabel': 'Contact me'},
    ),
  ],
  'pricing': [
    WebsiteBuilderComponentPreset(
      id: 'pricing_starter',
      kindKey: 'pricing',
      label: 'Starter plan',
      description: 'Entry pricing for a self-serve plan.',
      properties: {
        'title': 'Starter',
        'price': r'$19',
        'ctaLabel': 'Start plan',
      },
    ),
    WebsiteBuilderComponentPreset(
      id: 'pricing_enterprise',
      kindKey: 'pricing',
      label: 'Enterprise plan',
      description: 'Custom pricing for a sales-assisted plan.',
      properties: {
        'title': 'Enterprise',
        'price': 'Custom',
        'ctaLabel': 'Talk to sales',
      },
    ),
  ],
  'product_card': [
    WebsiteBuilderComponentPreset(
      id: 'product_signature',
      kindKey: 'product_card',
      label: 'Signature bundle',
      description: 'A bundled product with a direct cart action.',
      properties: {
        'productName': 'Signature Bundle',
        'price': r'$79',
        'ctaLabel': 'Add bundle',
      },
    ),
    WebsiteBuilderComponentPreset(
      id: 'product_featured',
      kindKey: 'product_card',
      label: 'Featured service',
      description: 'A service offer with a reservation action.',
      properties: {
        'productName': 'Featured Service',
        'price': 'From \$149',
        'ctaLabel': 'Reserve now',
      },
    ),
  ],
};

List<WebsiteBuilderComponentPreset> websiteBuilderPresetsFor(String kindKey) {
  return _presetsByKind[kindKey] ?? const [];
}

List<WebsiteBuilderComponentPreset> websiteBuilderPresetsMatching(
  String kindKey,
  String query,
) {
  final presets = websiteBuilderPresetsFor(kindKey);
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return presets;
  return [
    for (final preset in presets)
      if (websiteBuilderPresetMatchesQuery(preset, normalizedQuery)) preset,
  ];
}

bool websiteBuilderKindHasPresetMatch(String kindKey, String query) {
  return websiteBuilderPresetsMatching(kindKey, query).isNotEmpty;
}

WebsiteBuilderComponentPreset? websiteBuilderPresetById(
  String kindKey,
  String id,
) {
  for (final preset in websiteBuilderPresetsFor(kindKey)) {
    if (preset.id == id) return preset;
  }
  return null;
}

bool websiteBuilderPresetMatchesQuery(
  WebsiteBuilderComponentPreset preset,
  String query,
) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return true;
  return _matchesPresetText(preset.id, normalizedQuery) ||
      _matchesPresetText(preset.label, normalizedQuery) ||
      _matchesPresetText(preset.kindKey, normalizedQuery) ||
      _matchesPresetText(preset.description, normalizedQuery) ||
      preset.properties.entries.any(
        (entry) =>
            _matchesPresetText(entry.key, normalizedQuery) ||
            _matchesPresetText(entry.value, normalizedQuery),
      );
}

BuilderComponentGeometry websiteBuilderComponentWithPreset(
  BuilderComponentGeometry component,
  WebsiteBuilderComponentPreset preset,
) {
  if (component.kindKey != preset.kindKey) return component;

  final editableKeys = {
    for (final spec in websiteBuilderPropertySpecsFor(component.kindKey))
      spec.key,
  };
  if (editableKeys.isEmpty) return component;

  final nextProperties = {...component.properties};
  var changed = false;

  for (final entry in preset.properties.entries) {
    if (!editableKeys.contains(entry.key)) continue;
    if (nextProperties[entry.key] == entry.value) continue;
    nextProperties[entry.key] = entry.value;
    changed = true;
  }

  if (!changed) return component;
  return component.copyWith(properties: nextProperties);
}

bool _matchesPresetText(String value, String normalizedQuery) {
  return value.toLowerCase().contains(normalizedQuery);
}
