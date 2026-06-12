import 'package:ky_builder_shared/ky_builder_shared.dart';

class WebsiteBuilderComponentPropertySpec {
  final String key;
  final String label;
  final String defaultValue;
  final int maxLines;

  const WebsiteBuilderComponentPropertySpec({
    required this.key,
    required this.label,
    this.defaultValue = '',
    this.maxLines = 1,
  });
}

enum WebsiteBuilderComponentContentIssueSeverity { info, warning }

class WebsiteBuilderComponentContentIssue {
  final WebsiteBuilderComponentContentIssueSeverity severity;
  final String key;
  final String message;
  final String? suggestedValue;
  final String fixLabel;

  const WebsiteBuilderComponentContentIssue({
    required this.severity,
    required this.key,
    required this.message,
    this.suggestedValue,
    this.fixLabel = 'Fix',
  });

  bool get isWarning =>
      severity == WebsiteBuilderComponentContentIssueSeverity.warning;
  bool get hasFix => suggestedValue != null;
}

const _propertySpecsByKind =
    <String, List<WebsiteBuilderComponentPropertySpec>>{
      'hero': [
        WebsiteBuilderComponentPropertySpec(
          key: 'headline',
          label: 'Headline',
          defaultValue: 'Launch a better storefront',
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'subheadline',
          label: 'Subheadline',
          defaultValue:
              'Build pages, products, and campaigns from one workspace.',
          maxLines: 3,
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'ctaLabel',
          label: 'CTA label',
          defaultValue: 'Start building',
        ),
      ],
      'section': [
        WebsiteBuilderComponentPropertySpec(
          key: 'title',
          label: 'Title',
          defaultValue: 'Featured section',
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'body',
          label: 'Body',
          defaultValue: 'Use this block to introduce a focused page section.',
          maxLines: 4,
        ),
      ],
      'two_column': [
        WebsiteBuilderComponentPropertySpec(
          key: 'leftTitle',
          label: 'Left title',
          defaultValue: 'Plan',
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'leftBody',
          label: 'Left body',
          defaultValue: 'Define the message and supporting content.',
          maxLines: 3,
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'rightTitle',
          label: 'Right title',
          defaultValue: 'Publish',
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'rightBody',
          label: 'Right body',
          defaultValue: 'Ship a page that works across channels.',
          maxLines: 3,
        ),
      ],
      'text_block': [
        WebsiteBuilderComponentPropertySpec(
          key: 'title',
          label: 'Title',
          defaultValue: 'Text block',
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'body',
          label: 'Body',
          defaultValue: 'Write supporting content for this part of the page.',
          maxLines: 5,
        ),
      ],
      'image': [
        WebsiteBuilderComponentPropertySpec(
          key: 'imageUrl',
          label: 'Image URL',
          defaultValue: 'https://example.com/image.jpg',
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'altText',
          label: 'Alt text',
          defaultValue: 'Image description',
        ),
      ],
      'gallery': [
        WebsiteBuilderComponentPropertySpec(
          key: 'title',
          label: 'Title',
          defaultValue: 'Gallery',
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'caption',
          label: 'Caption',
          defaultValue: 'Showcase products, spaces, or editorial imagery.',
          maxLines: 3,
        ),
      ],
      'button': [
        WebsiteBuilderComponentPropertySpec(
          key: 'label',
          label: 'Label',
          defaultValue: 'Learn more',
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'href',
          label: 'Link',
          defaultValue: '/learn-more',
        ),
      ],
      'form': [
        WebsiteBuilderComponentPropertySpec(
          key: 'title',
          label: 'Title',
          defaultValue: 'Contact us',
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'submitLabel',
          label: 'Submit label',
          defaultValue: 'Send message',
        ),
      ],
      'pricing': [
        WebsiteBuilderComponentPropertySpec(
          key: 'title',
          label: 'Plan name',
          defaultValue: 'Growth',
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'price',
          label: 'Price',
          defaultValue: r'$29',
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'ctaLabel',
          label: 'CTA label',
          defaultValue: 'Choose plan',
        ),
      ],
      'product_card': [
        WebsiteBuilderComponentPropertySpec(
          key: 'productName',
          label: 'Product name',
          defaultValue: 'Signature Product',
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'price',
          label: 'Price',
          defaultValue: r'$49',
        ),
        WebsiteBuilderComponentPropertySpec(
          key: 'ctaLabel',
          label: 'CTA label',
          defaultValue: 'Add to cart',
        ),
      ],
    };

const _primaryContentKeys = {
  'headline',
  'title',
  'productName',
  'leftTitle',
  'rightTitle',
};

const _actionContentKeys = {'label', 'ctaLabel', 'submitLabel'};

List<WebsiteBuilderComponentPropertySpec> websiteBuilderPropertySpecsFor(
  String kindKey,
) {
  return _propertySpecsByKind[kindKey] ?? const [];
}

Map<String, String> websiteBuilderDefaultPropertiesFor(String kindKey) {
  return {
    for (final spec in websiteBuilderPropertySpecsFor(kindKey))
      if (spec.defaultValue.isNotEmpty) spec.key: spec.defaultValue,
  };
}

String? websiteBuilderDefaultPropertyValueFor(String kindKey, String key) {
  for (final spec in websiteBuilderPropertySpecsFor(kindKey)) {
    if (spec.key == key && spec.defaultValue.isNotEmpty) {
      return spec.defaultValue;
    }
  }
  return null;
}

bool websiteBuilderComponentContentMatchesDefaults(
  BuilderComponentGeometry component,
) {
  final specs = websiteBuilderPropertySpecsFor(component.kindKey);
  if (specs.isEmpty) return true;
  for (final spec in specs) {
    if ((component.properties[spec.key] ?? spec.defaultValue) !=
        spec.defaultValue) {
      return false;
    }
  }
  return true;
}

BuilderComponentGeometry websiteBuilderComponentWithDefaultProperties(
  BuilderComponentGeometry component,
) {
  final defaults = websiteBuilderDefaultPropertiesFor(component.kindKey);
  if (defaults.isEmpty) return component;
  return component.copyWith(properties: {...defaults, ...component.properties});
}

BuilderComponentGeometry websiteBuilderComponentWithResetContentProperties(
  BuilderComponentGeometry component,
) {
  final specs = websiteBuilderPropertySpecsFor(component.kindKey);
  if (specs.isEmpty) return component;
  final defaults = websiteBuilderDefaultPropertiesFor(component.kindKey);
  final nextProperties = {...component.properties};
  for (final spec in specs) {
    nextProperties.remove(spec.key);
  }
  nextProperties.addAll(defaults);
  return component.copyWith(properties: nextProperties);
}

BuilderComponentGeometry websiteBuilderComponentWithContentIssueFixes(
  BuilderComponentGeometry component, {
  List<WebsiteBuilderComponentContentIssue>? issues,
}) {
  final effectiveIssues = issues ?? websiteBuilderContentIssuesFor(component);
  final nextProperties = {...component.properties};
  var changed = false;

  for (final issue in effectiveIssues) {
    final suggestedValue = issue.suggestedValue;
    if (suggestedValue == null || issue.key.trim().isEmpty) continue;
    if (nextProperties[issue.key] == suggestedValue) continue;
    nextProperties[issue.key] = suggestedValue;
    changed = true;
  }

  if (!changed) return component;
  return component.copyWith(properties: nextProperties);
}

List<WebsiteBuilderComponentContentIssue> websiteBuilderContentIssuesFor(
  BuilderComponentGeometry component,
) {
  final issues = <WebsiteBuilderComponentContentIssue>[];
  final specs = websiteBuilderPropertySpecsFor(component.kindKey);

  for (final spec in specs) {
    final rawValue = component.properties[spec.key];
    if (rawValue == null || rawValue.trim().isNotEmpty) continue;

    if (spec.key == 'altText' && component.kindKey == 'image') {
      issues.add(
        WebsiteBuilderComponentContentIssue(
          severity: WebsiteBuilderComponentContentIssueSeverity.warning,
          key: spec.key,
          message:
              '${spec.label} is empty; exported image will use generic copy.',
          suggestedValue: spec.defaultValue,
          fixLabel: 'Restore',
        ),
      );
      continue;
    }

    if (_actionContentKeys.contains(spec.key)) {
      issues.add(
        WebsiteBuilderComponentContentIssue(
          severity: WebsiteBuilderComponentContentIssueSeverity.warning,
          key: spec.key,
          message:
              '${spec.label} is empty; exported action will use fallback copy.',
          suggestedValue: spec.defaultValue,
          fixLabel: 'Restore',
        ),
      );
      continue;
    }

    if (_primaryContentKeys.contains(spec.key)) {
      issues.add(
        WebsiteBuilderComponentContentIssue(
          severity: WebsiteBuilderComponentContentIssueSeverity.info,
          key: spec.key,
          message:
              '${spec.label} is empty; exported section will use fallback copy.',
          suggestedValue: spec.defaultValue,
          fixLabel: 'Restore',
        ),
      );
    }
  }

  final href = component.properties['href'];
  if (_isUnsafeWebsiteBuilderUrl(href)) {
    issues.add(
      WebsiteBuilderComponentContentIssue(
        severity: WebsiteBuilderComponentContentIssueSeverity.warning,
        key: 'href',
        message: 'Unsafe link will be replaced during export.',
        suggestedValue:
            websiteBuilderDefaultPropertyValueFor(component.kindKey, 'href') ??
            '#',
        fixLabel: 'Use safe link',
      ),
    );
  } else if (href != null && href.trim().isEmpty) {
    issues.add(
      WebsiteBuilderComponentContentIssue(
        severity: WebsiteBuilderComponentContentIssueSeverity.info,
        key: 'href',
        message: 'Link is empty; exported link will use #.',
        suggestedValue:
            websiteBuilderDefaultPropertyValueFor(component.kindKey, 'href') ??
            '#',
        fixLabel: 'Use default',
      ),
    );
  }

  final imageUrl = component.properties['imageUrl'];
  if (_isUnsafeWebsiteBuilderUrl(imageUrl)) {
    issues.add(
      WebsiteBuilderComponentContentIssue(
        severity: WebsiteBuilderComponentContentIssueSeverity.warning,
        key: 'imageUrl',
        message: 'Unsafe image URL will export as a placeholder.',
        suggestedValue:
            websiteBuilderDefaultPropertyValueFor(
              component.kindKey,
              'imageUrl',
            ) ??
            '',
        fixLabel: 'Use safe image',
      ),
    );
  } else if (component.kindKey == 'image' &&
      imageUrl != null &&
      imageUrl.trim().isEmpty) {
    issues.add(
      WebsiteBuilderComponentContentIssue(
        severity: WebsiteBuilderComponentContentIssueSeverity.info,
        key: 'imageUrl',
        message: 'Image URL is empty; exported image will use a placeholder.',
        suggestedValue:
            websiteBuilderDefaultPropertyValueFor(
              component.kindKey,
              'imageUrl',
            ) ??
            '',
        fixLabel: 'Use default',
      ),
    );
  }

  return List.unmodifiable(issues);
}

String? websiteBuilderPrimaryPropertyValue(BuilderComponentGeometry component) {
  for (final key in [
    'headline',
    'title',
    'label',
    'productName',
    'leftTitle',
  ]) {
    final value = component.properties[key]?.trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

bool _isUnsafeWebsiteBuilderUrl(String? value) {
  return value?.trim().toLowerCase().startsWith('javascript:') ?? false;
}
