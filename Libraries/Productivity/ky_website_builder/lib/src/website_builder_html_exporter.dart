import 'dart:convert';

import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_component_properties.dart';

class WebsiteBuilderHtmlExportOptions {
  final String languageCode;
  final String? documentTitle;
  final bool includeHiddenComponents;

  const WebsiteBuilderHtmlExportOptions({
    this.languageCode = 'en',
    this.documentTitle,
    this.includeHiddenComponents = false,
  });
}

enum WebsiteBuilderHtmlExportIssueSeverity { info, warning }

class WebsiteBuilderHtmlExportIssue {
  final WebsiteBuilderHtmlExportIssueSeverity severity;
  final String message;
  final String? componentId;
  final String? componentKindKey;

  const WebsiteBuilderHtmlExportIssue({
    required this.severity,
    required this.message,
    this.componentId,
    this.componentKindKey,
  });
}

class WebsiteBuilderHtmlExportReadiness {
  final int componentCount;
  final int visibleComponentCount;
  final int hiddenComponentCount;
  final int exportedComponentCount;
  final String normalizedLanguageCode;
  final List<WebsiteBuilderHtmlExportIssue> issues;

  const WebsiteBuilderHtmlExportReadiness({
    required this.componentCount,
    required this.visibleComponentCount,
    required this.hiddenComponentCount,
    required this.exportedComponentCount,
    required this.normalizedLanguageCode,
    this.issues = const [],
  });

  bool get hasWarnings => issues.any(
    (issue) => issue.severity == WebsiteBuilderHtmlExportIssueSeverity.warning,
  );
}

class WebsiteBuilderHtmlExporter {
  final BuilderComponentCatalog catalog;

  const WebsiteBuilderHtmlExporter({this.catalog = websiteBuilderCatalog});

  WebsiteBuilderHtmlExportReadiness inspect({
    required List<BuilderComponentGeometry> components,
    WebsiteBuilderHtmlExportOptions options =
        const WebsiteBuilderHtmlExportOptions(),
  }) {
    final normalizedComponents = [
      for (final component in components)
        websiteBuilderComponentWithDefaultProperties(component),
    ];
    final exportedComponents = [
      for (final component in normalizedComponents)
        if (options.includeHiddenComponents || component.isVisible) component,
    ];
    final visibleComponentCount =
        normalizedComponents.where((component) => component.isVisible).length;
    final hiddenComponentCount =
        normalizedComponents.length - visibleComponentCount;
    final normalizedLanguageCode = _safeLanguage(options.languageCode);
    final issues = <WebsiteBuilderHtmlExportIssue>[];

    if (normalizedComponents.isEmpty) {
      issues.add(
        const WebsiteBuilderHtmlExportIssue(
          severity: WebsiteBuilderHtmlExportIssueSeverity.warning,
          message:
              'Canvas is empty. The copied HTML will only include a shell.',
        ),
      );
    } else if (exportedComponents.isEmpty) {
      issues.add(
        const WebsiteBuilderHtmlExportIssue(
          severity: WebsiteBuilderHtmlExportIssueSeverity.warning,
          message: 'No visible components will be exported.',
        ),
      );
    }

    if (!options.includeHiddenComponents && hiddenComponentCount > 0) {
      issues.add(
        WebsiteBuilderHtmlExportIssue(
          severity: WebsiteBuilderHtmlExportIssueSeverity.info,
          message:
              '${_componentCountLabel(hiddenComponentCount)} will be skipped.',
        ),
      );
    }

    if (normalizedLanguageCode != options.languageCode.trim()) {
      issues.add(
        const WebsiteBuilderHtmlExportIssue(
          severity: WebsiteBuilderHtmlExportIssueSeverity.warning,
          message: 'Language code will fall back to en.',
        ),
      );
    }

    for (final component in exportedComponents) {
      final kindLabel =
          catalog.byKey(component.kindKey)?.label ?? component.kindKey;
      issues.addAll(
        websiteBuilderContentIssuesFor(component).map(
          (issue) => _contentIssueToExportIssue(
            component: component,
            kindLabel: kindLabel,
            issue: issue,
          ),
        ),
      );
    }

    return WebsiteBuilderHtmlExportReadiness(
      componentCount: normalizedComponents.length,
      visibleComponentCount: visibleComponentCount,
      hiddenComponentCount: hiddenComponentCount,
      exportedComponentCount: exportedComponents.length,
      normalizedLanguageCode: normalizedLanguageCode,
      issues: List.unmodifiable(issues),
    );
  }

  String exportDocument({
    required String projectName,
    required BuilderCanvasConfig canvasConfig,
    required List<BuilderComponentGeometry> components,
    WebsiteBuilderHtmlExportOptions options =
        const WebsiteBuilderHtmlExportOptions(),
  }) {
    final title =
        options.documentTitle?.trim().isNotEmpty == true
            ? options.documentTitle!.trim()
            : projectName.trim().isEmpty
            ? 'Website'
            : projectName.trim();
    final visibleComponents = [
      for (final component in components)
        if (options.includeHiddenComponents || component.isVisible)
          websiteBuilderComponentWithDefaultProperties(component),
    ]..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    final buffer =
        StringBuffer()
          ..writeln('<!doctype html>')
          ..writeln(
            '<html lang="${_escapeAttribute(_safeLanguage(options.languageCode))}">',
          )
          ..writeln('<head>')
          ..writeln('  <meta charset="utf-8">')
          ..writeln(
            '  <meta name="viewport" content="width=device-width, initial-scale=1">',
          )
          ..writeln('  <title>${_escapeText(title)}</title>')
          ..writeln('  <style>')
          ..write(_baseCss(canvasConfig))
          ..writeln('  </style>')
          ..writeln('</head>')
          ..writeln('<body>')
          ..writeln('  <main class="website-builder-page" aria-label="Page">');

    for (final component in visibleComponents) {
      buffer.write(_componentHtml(component, canvasConfig));
    }

    buffer
      ..writeln('  </main>')
      ..writeln('</body>')
      ..writeln('</html>');

    return buffer.toString();
  }

  String _componentHtml(
    BuilderComponentGeometry component,
    BuilderCanvasConfig canvasConfig,
  ) {
    final kind = catalog.byKey(component.kindKey);
    final kindLabel = kind?.label ?? component.kindKey;
    final componentClass = _slug(component.kindKey);
    final content = _componentContent(component, kindLabel);
    final hiddenAttributes = component.isVisible ? '' : ' hidden';

    return '''
    <section id="component-${_escapeAttribute(_slug(component.id))}" class="wb-component wb-$componentClass" data-kind="${_escapeAttribute(component.kindKey)}" style="${_componentStyle(component, canvasConfig)}"$hiddenAttributes>
$content
    </section>
''';
  }

  String _componentContent(
    BuilderComponentGeometry component,
    String kindLabel,
  ) {
    return switch (component.kindKey) {
      'hero' => _heroHtml(component),
      'section' => _sectionHtml(component),
      'two_column' => _twoColumnHtml(component),
      'text_block' => _textBlockHtml(component),
      'image' => _imageHtml(component),
      'gallery' => _galleryHtml(component),
      'button' => _buttonHtml(component),
      'form' => _formHtml(component),
      'pricing' => _pricingHtml(component),
      'product_card' => _productCardHtml(component),
      _ => _genericHtml(component, kindLabel),
    };
  }
}

WebsiteBuilderHtmlExportIssue _contentIssueToExportIssue({
  required BuilderComponentGeometry component,
  required String kindLabel,
  required WebsiteBuilderComponentContentIssue issue,
}) {
  return WebsiteBuilderHtmlExportIssue(
    severity: _exportIssueSeverityFor(issue.severity),
    message: _contentIssueExportMessage(
      component: component,
      kindLabel: kindLabel,
      issue: issue,
    ),
    componentId: component.id,
    componentKindKey: component.kindKey,
  );
}

WebsiteBuilderHtmlExportIssueSeverity _exportIssueSeverityFor(
  WebsiteBuilderComponentContentIssueSeverity severity,
) {
  return switch (severity) {
    WebsiteBuilderComponentContentIssueSeverity.info =>
      WebsiteBuilderHtmlExportIssueSeverity.info,
    WebsiteBuilderComponentContentIssueSeverity.warning =>
      WebsiteBuilderHtmlExportIssueSeverity.warning,
  };
}

String _contentIssueExportMessage({
  required BuilderComponentGeometry component,
  required String kindLabel,
  required WebsiteBuilderComponentContentIssue issue,
}) {
  if (issue.key == 'href' && _isUnsafeUrl(component.properties['href'])) {
    return 'Unsafe link on $kindLabel will be replaced with #.';
  }
  if (issue.key == 'imageUrl' &&
      _isUnsafeUrl(component.properties['imageUrl'])) {
    return 'Unsafe image URL on $kindLabel will be exported as a placeholder.';
  }
  return '$kindLabel: ${issue.message}';
}

String _heroHtml(BuilderComponentGeometry component) {
  final headline = _property(component, 'headline', 'Hero headline');
  final subheadline = _property(component, 'subheadline', 'Supporting copy');
  final ctaLabel = _property(component, 'ctaLabel', 'Call to action');
  return '''
      <div class="wb-card wb-hero-card">
        <p class="wb-kicker">Featured</p>
        <h1>${_escapeText(headline)}</h1>
        <p>${_escapeText(subheadline)}</p>
        <a class="wb-button" href="#">${_escapeText(ctaLabel)}</a>
      </div>
''';
}

String _sectionHtml(BuilderComponentGeometry component) {
  return '''
      <div class="wb-card">
        <h2>${_escapeText(_property(component, 'title', 'Section title'))}</h2>
        <p>${_escapeText(_property(component, 'body', 'Section body'))}</p>
      </div>
''';
}

String _twoColumnHtml(BuilderComponentGeometry component) {
  return '''
      <div class="wb-columns">
        <article class="wb-card">
          <h2>${_escapeText(_property(component, 'leftTitle', 'Left'))}</h2>
          <p>${_escapeText(_property(component, 'leftBody', 'Left body'))}</p>
        </article>
        <article class="wb-card">
          <h2>${_escapeText(_property(component, 'rightTitle', 'Right'))}</h2>
          <p>${_escapeText(_property(component, 'rightBody', 'Right body'))}</p>
        </article>
      </div>
''';
}

String _textBlockHtml(BuilderComponentGeometry component) {
  return '''
      <article class="wb-card wb-text-block">
        <h2>${_escapeText(_property(component, 'title', 'Text block'))}</h2>
        <p>${_escapeText(_property(component, 'body', 'Text body'))}</p>
      </article>
''';
}

String _imageHtml(BuilderComponentGeometry component) {
  final imageUrl = _safeImageUrl(_property(component, 'imageUrl', ''));
  final altText = _property(component, 'altText', 'Image');
  final imageMarkup =
      imageUrl.isEmpty
          ? '<div class="wb-image-placeholder" role="img" aria-label="${_escapeAttribute(altText)}"></div>'
          : '<img src="${_escapeAttribute(imageUrl)}" alt="${_escapeAttribute(altText)}" loading="lazy">';
  return '''
      <figure class="wb-media">
        $imageMarkup
        <figcaption>${_escapeText(altText)}</figcaption>
      </figure>
''';
}

String _galleryHtml(BuilderComponentGeometry component) {
  return '''
      <section class="wb-card wb-gallery">
        <div class="wb-gallery-grid" aria-hidden="true">
          <span></span><span></span><span></span><span></span>
        </div>
        <h2>${_escapeText(_property(component, 'title', 'Gallery'))}</h2>
        <p>${_escapeText(_property(component, 'caption', 'Gallery caption'))}</p>
      </section>
''';
}

String _buttonHtml(BuilderComponentGeometry component) {
  final href = _safeHref(_property(component, 'href', '#'));
  return '''
      <a class="wb-button wb-button-standalone" href="${_escapeAttribute(href)}">${_escapeText(_property(component, 'label', 'Button'))}</a>
''';
}

String _formHtml(BuilderComponentGeometry component) {
  return '''
      <form class="wb-card wb-form">
        <h2>${_escapeText(_property(component, 'title', 'Contact us'))}</h2>
        <label>
          <span>Name</span>
          <input type="text" name="name">
        </label>
        <label>
          <span>Email</span>
          <input type="email" name="email">
        </label>
        <button type="submit">${_escapeText(_property(component, 'submitLabel', 'Submit'))}</button>
      </form>
''';
}

String _pricingHtml(BuilderComponentGeometry component) {
  return '''
      <article class="wb-card wb-pricing">
        <h2>${_escapeText(_property(component, 'title', 'Plan'))}</h2>
        <p class="wb-price">${_escapeText(_property(component, 'price', r'$0'))}</p>
        <ul>
          <li>Included feature</li>
          <li>Priority support</li>
        </ul>
        <a class="wb-button" href="#">${_escapeText(_property(component, 'ctaLabel', 'Choose plan'))}</a>
      </article>
''';
}

String _productCardHtml(BuilderComponentGeometry component) {
  return '''
      <article class="wb-card wb-product">
        <div class="wb-product-media" aria-hidden="true"></div>
        <h2>${_escapeText(_property(component, 'productName', 'Product'))}</h2>
        <p class="wb-price">${_escapeText(_property(component, 'price', r'$0'))}</p>
        <button type="button">${_escapeText(_property(component, 'ctaLabel', 'Add to cart'))}</button>
      </article>
''';
}

String _genericHtml(BuilderComponentGeometry component, String kindLabel) {
  return '''
      <article class="wb-card">
        <h2>${_escapeText(websiteBuilderPrimaryPropertyValue(component) ?? kindLabel)}</h2>
        <p>${_escapeText(component.kindKey)}</p>
      </article>
''';
}

String _baseCss(BuilderCanvasConfig canvasConfig) {
  final width = canvasConfig.canvasWidth.round();
  final height = canvasConfig.canvasHeight.round();
  return '''
    :root {
      color-scheme: light;
      font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: #f4f7fb;
      color: #172033;
    }

    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      padding: 32px;
      background: #f4f7fb;
    }

    .website-builder-page {
      position: relative;
      width: min(100%, ${width}px);
      aspect-ratio: $width / $height;
      margin: 0 auto;
      overflow: hidden;
      background: #ffffff;
      border: 1px solid #d9e2ef;
      border-radius: 8px;
      box-shadow: 0 24px 80px rgba(15, 23, 42, 0.12);
    }

    .wb-component {
      position: absolute;
      overflow: hidden;
      container-type: size;
    }

    .wb-card,
    .wb-media,
    .wb-form {
      width: 100%;
      height: 100%;
      padding: clamp(12px, 4cqw, 32px);
      border: 1px solid #d8e2ee;
      border-radius: 8px;
      background: #ffffff;
    }

    .wb-hero-card {
      display: flex;
      flex-direction: column;
      align-items: flex-start;
      justify-content: center;
      gap: clamp(8px, 2cqw, 18px);
      background: #eef6ff;
    }

    h1,
    h2,
    p {
      margin: 0;
    }

    h1 {
      max-width: 14ch;
      font-size: clamp(28px, 9cqw, 72px);
      line-height: 0.98;
      font-weight: 900;
    }

    h2 {
      font-size: clamp(18px, 5cqw, 36px);
      line-height: 1.05;
      font-weight: 850;
    }

    p {
      max-width: 62ch;
      color: #526179;
      font-size: clamp(13px, 2.6cqw, 18px);
      line-height: 1.48;
    }

    .wb-kicker {
      color: #0f67b1;
      font-size: 12px;
      font-weight: 800;
      letter-spacing: 0;
      text-transform: uppercase;
    }

    .wb-button,
    button {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      min-height: 40px;
      padding: 10px 16px;
      border: 0;
      border-radius: 8px;
      background: #0f67b1;
      color: #ffffff;
      font: inherit;
      font-weight: 800;
      text-decoration: none;
      cursor: pointer;
    }

    .wb-button-standalone {
      width: 100%;
      height: 100%;
    }

    .wb-columns {
      display: grid;
      grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
      gap: 12px;
      width: 100%;
      height: 100%;
    }

    .wb-media {
      display: grid;
      grid-template-rows: minmax(0, 1fr) auto;
      gap: 8px;
      margin: 0;
    }

    .wb-media img,
    .wb-image-placeholder,
    .wb-product-media {
      width: 100%;
      height: 100%;
      min-height: 0;
      object-fit: cover;
      border-radius: 8px;
      background: linear-gradient(135deg, #dbeafe, #dcfce7);
    }

    figcaption {
      color: #526179;
      font-size: 13px;
    }

    .wb-gallery {
      display: grid;
      grid-template-rows: minmax(0, 1fr) auto auto;
      gap: 8px;
    }

    .wb-gallery-grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 8px;
      min-height: 0;
    }

    .wb-gallery-grid span {
      border-radius: 8px;
      background: linear-gradient(135deg, #e0f2fe, #fef3c7);
    }

    .wb-form {
      display: grid;
      gap: 10px;
      align-content: start;
    }

    label {
      display: grid;
      gap: 4px;
      color: #526179;
      font-size: 13px;
      font-weight: 700;
    }

    input {
      width: 100%;
      min-height: 38px;
      border: 1px solid #cad7e6;
      border-radius: 8px;
      padding: 8px 10px;
      font: inherit;
    }

    .wb-pricing,
    .wb-product,
    .wb-text-block {
      display: flex;
      flex-direction: column;
      align-items: flex-start;
      gap: 10px;
    }

    .wb-price {
      color: #047857;
      font-size: clamp(20px, 6cqw, 44px);
      font-weight: 900;
    }

    ul {
      margin: 0;
      padding-left: 18px;
      color: #526179;
      line-height: 1.6;
    }

    @media (max-width: 720px) {
      body {
        padding: 12px;
      }
    }
''';
}

String _componentStyle(
  BuilderComponentGeometry component,
  BuilderCanvasConfig canvasConfig,
) {
  final width = canvasConfig.canvasWidth <= 0 ? 1.0 : canvasConfig.canvasWidth;
  final height =
      canvasConfig.canvasHeight <= 0 ? 1.0 : canvasConfig.canvasHeight;
  return [
    'left: ${_percent(component.position.dx / width)}',
    'top: ${_percent(component.position.dy / height)}',
    'width: ${_percent(component.size.width / width)}',
    'height: ${_percent(component.size.height / height)}',
    'z-index: ${component.zIndex}',
  ].join('; ');
}

String _property(
  BuilderComponentGeometry component,
  String key,
  String fallback,
) {
  final value = component.properties[key]?.trim();
  return value == null || value.isEmpty ? fallback : value;
}

String _percent(double value) {
  final percent = (value * 100).clamp(0.0, 100.0).toStringAsFixed(4);
  return '${percent.replaceFirst(RegExp(r'\.?0+$'), '')}%';
}

String _safeHref(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '#';
  if (_isUnsafeUrl(trimmed)) return '#';
  return trimmed;
}

String _safeImageUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';
  if (_isUnsafeUrl(trimmed)) return '';
  return trimmed;
}

bool _isUnsafeUrl(String? value) {
  return value?.trim().toLowerCase().startsWith('javascript:') ?? false;
}

String _componentCountLabel(int count) {
  return count == 1 ? '1 hidden component' : '$count hidden components';
}

String _safeLanguage(String value) {
  final normalized = value.trim();
  if (RegExp(r'^[a-zA-Z]{2,3}(-[a-zA-Z0-9]{2,8})?$').hasMatch(normalized)) {
    return normalized;
  }
  return 'en';
}

String _slug(String value) {
  final normalized = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return normalized.isEmpty ? 'component' : normalized;
}

String _escapeText(String value) {
  return const HtmlEscape(HtmlEscapeMode.element).convert(value);
}

String _escapeAttribute(String value) {
  return const HtmlEscape(HtmlEscapeMode.attribute).convert(value);
}
