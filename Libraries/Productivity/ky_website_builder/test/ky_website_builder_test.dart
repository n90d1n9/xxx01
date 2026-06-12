import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_website_builder/ky_website_builder.dart';

import 'website_builder_test_fixtures.dart';

void main() {
  test('controller adds, selects, duplicates, and exports components', () {
    final controller = websiteBuilderTestController(
      projectId: 'site-1',
      projectName: 'Storefront',
    );

    final createdId = addWebsiteBuilderTestComponent(controller, 'hero');

    expect(createdId, 'component_1');
    expect(controller.componentCount, 1);
    expect(controller.selectedComponentKind?.key, 'hero');
    expect(
      controller.selectedComponent?.properties['headline'],
      'Launch a better storefront',
    );

    controller.updateSelectedComponentProperty('headline', 'Summer Launch');

    expect(
      controller.selectedComponent?.properties['headline'],
      'Summer Launch',
    );

    controller.duplicateSelected();

    expect(controller.componentCount, 2);
    expect(controller.selectedComponentId, 'component_2');
    expect(controller.toJson()['components'], hasLength(2));

    final snapshot = controller.toSharedSnapshot();
    final snapshotJson = jsonDecode(controller.toPrettySharedSnapshotJson());

    expect(snapshot.id, 'site-1');
    expect(snapshot.name, 'Storefront');
    expect(snapshot.componentCount, 2);
    expect(snapshot.components.first.properties['headline'], 'Summer Launch');
    expect(snapshotJson['schema'], BuilderSharedSnapshot.schemaId);
  });

  test('controller exports static HTML from visible components', () {
    final controller = websiteBuilderTestController(projectName: 'Storefront');

    final heroId = addWebsiteBuilderTestComponent(controller, 'hero');
    controller.updateComponentProperty(heroId, 'headline', '<Summer & Sale>');
    controller.updateComponentProperty(
      heroId,
      'subheadline',
      'Launch with safe copy.',
    );
    final buttonId = addWebsiteBuilderTestComponent(controller, 'button');
    controller.updateComponentProperty(buttonId, 'href', 'javascript:alert(1)');
    controller.updateComponentProperty(buttonId, 'label', '');
    controller.toggleComponentVisibility(buttonId);

    final readiness = controller.inspectHtmlExport();

    expect(readiness.visibleComponentCount, 1);
    expect(readiness.hiddenComponentCount, 1);
    expect(readiness.exportedComponentCount, 1);
    expect(
      readiness.issues.map((issue) => issue.message),
      contains('1 hidden component will be skipped.'),
    );

    final readinessWithHidden = controller.inspectHtmlExport(
      options: const WebsiteBuilderHtmlExportOptions(
        includeHiddenComponents: true,
      ),
    );

    expect(readinessWithHidden.exportedComponentCount, 2);
    expect(readinessWithHidden.hasWarnings, isTrue);
    expect(
      readinessWithHidden.issues.map((issue) => issue.message),
      contains('Unsafe link on Button will be replaced with #.'),
    );
    expect(
      readinessWithHidden.issues.map((issue) => issue.message),
      contains(
        'Button: Label is empty; exported action will use fallback copy.',
      ),
    );

    final html = controller.toHtml(
      options: const WebsiteBuilderHtmlExportOptions(
        documentTitle: '<Campaign>',
        languageCode: 'id',
      ),
    );

    expect(html, contains('<!doctype html>'));
    expect(html, contains('<html lang="id">'));
    expect(html, contains('<title>&lt;Campaign&gt;</title>'));
    expect(html, contains('&lt;Summer &amp; Sale&gt;'));
    expect(html, contains('class="wb-component wb-hero"'));
    expect(html, isNot(contains('javascript:alert')));
    expect(html, isNot(contains('Learn more')));

    final htmlWithHidden = controller.toHtml(
      options: const WebsiteBuilderHtmlExportOptions(
        includeHiddenComponents: true,
      ),
    );

    expect(htmlWithHidden, contains('hidden'));
    expect(htmlWithHidden, contains('href="#"'));
    expect(htmlWithHidden, contains('Button'));
    expect(htmlWithHidden, isNot(contains('Learn more')));
  });

  test('controller undoes and redoes component mutations', () {
    final controller = websiteBuilderTestController();

    expect(controller.canUndo, isFalse);
    expect(controller.canRedo, isFalse);

    final heroId = addWebsiteBuilderTestComponent(controller, 'hero');
    controller.updateSelectedComponentProperty('headline', 'Campaign hero');

    expect(controller.componentCount, 1);
    expect(
      _component(controller, heroId).properties['headline'],
      'Campaign hero',
    );
    expect(controller.canUndo, isTrue);
    expect(controller.canRedo, isFalse);

    controller.undo();

    expect(
      _component(controller, heroId).properties['headline'],
      'Launch a better storefront',
    );
    expect(controller.canRedo, isTrue);

    controller.undo();

    expect(controller.componentCount, 0);
    expect(controller.selectedComponentId, isNull);

    controller.redo();

    expect(controller.componentCount, 1);
    expect(controller.selectedComponentId, heroId);
    expect(
      _component(controller, heroId).properties['headline'],
      'Launch a better storefront',
    );

    controller.redo();

    expect(
      _component(controller, heroId).properties['headline'],
      'Campaign hero',
    );
    expect(controller.canRedo, isFalse);
  });

  test('controller inserts new components near the selected component', () {
    final controller = websiteBuilderTestController();
    final heroId = addWebsiteBuilderTestComponent(controller, 'hero');
    final buttonId = addWebsiteBuilderTestComponent(controller, 'button');

    final hero = _component(controller, heroId);
    final button = _component(controller, buttonId);

    expect(button.position.dx, hero.position.dx);
    expect(button.position.dy, greaterThan(hero.position.dy));
    expect(button.position.dy, greaterThanOrEqualTo(hero.rect.bottom));

    controller.selectComponent(heroId);

    final sectionId = addWebsiteBuilderTestComponent(controller, 'section');
    final section = _component(controller, sectionId);

    expect(
      section.position.dx >= button.rect.right ||
          section.position.dy >= button.rect.bottom,
      isTrue,
    );
    expect(section.rect.overlaps(button.rect), isFalse);
    expect(section.rect.overlaps(hero.rect), isFalse);
  });

  test('controller inserts beside the anchor when below does not fit', () {
    final controller = websiteBuilderTestController(
      canvasConfig: const BuilderCanvasConfig(canvasHeight: 420),
    );
    final heroId = addWebsiteBuilderTestComponent(controller, 'hero');
    final buttonId = addWebsiteBuilderTestComponent(controller, 'button');

    final hero = _component(controller, heroId);
    final button = _component(controller, buttonId);

    expect(button.position.dx, greaterThanOrEqualTo(hero.rect.right));
    expect(button.position.dy, hero.position.dy);
    expect(
      button.rect.right,
      lessThanOrEqualTo(controller.canvasConfig.canvasWidth),
    );
    expect(
      button.rect.bottom,
      lessThanOrEqualTo(controller.canvasConfig.canvasHeight),
    );
  });

  test('controller duplicates into open nearby positions', () {
    final controller = websiteBuilderTestController();
    final buttonId = addWebsiteBuilderTestComponent(controller, 'button');

    final firstDuplicateId = controller.duplicateSelected();
    final secondDuplicateId = controller.duplicateSelected();

    expect(firstDuplicateId, isNotNull);
    expect(secondDuplicateId, isNotNull);
    expect(controller.componentCount, 3);
    expect(controller.selectedComponentId, secondDuplicateId);

    final original = _component(controller, buttonId);
    final firstDuplicate = _component(controller, firstDuplicateId!);
    final secondDuplicate = _component(controller, secondDuplicateId!);

    expect(firstDuplicate.isLocked, isFalse);
    expect(firstDuplicate.properties, original.properties);
    expect(firstDuplicate.rect.overlaps(original.rect), isFalse);
    expect(secondDuplicate.rect.overlaps(original.rect), isFalse);
    expect(secondDuplicate.rect.overlaps(firstDuplicate.rect), isFalse);
  });

  test('controller resets content properties to defaults', () {
    final controller = websiteBuilderTestController();
    final heroId = addWebsiteBuilderTestComponent(controller, 'hero');

    controller.updateComponentProperty(heroId, 'headline', 'Campaign hero');
    controller.updateComponentProperty(heroId, 'analyticsKey', 'hero-main');

    expect(
      _component(controller, heroId).properties['headline'],
      'Campaign hero',
    );

    controller.resetSelectedComponentProperties();

    expect(
      _component(controller, heroId).properties['headline'],
      'Launch a better storefront',
    );
    expect(
      _component(controller, heroId).properties['analyticsKey'],
      'hero-main',
    );

    controller.undo();

    expect(
      _component(controller, heroId).properties['headline'],
      'Campaign hero',
    );

    controller.redo();

    expect(
      _component(controller, heroId).properties['headline'],
      'Launch a better storefront',
    );
  });

  test('controller applies content presets through history', () {
    final controller = websiteBuilderTestController();
    final heroId = addWebsiteBuilderTestComponent(controller, 'hero');

    controller.updateComponentProperty(heroId, 'headline', 'Campaign hero');
    controller.updateComponentProperty(heroId, 'analyticsKey', 'hero-main');

    final preset = websiteBuilderPresetById('hero', 'hero_product_launch')!;
    controller.applySelectedComponentPreset(preset);

    expect(
      _component(controller, heroId).properties['headline'],
      'Launch your next product',
    );
    expect(
      _component(controller, heroId).properties['subheadline'],
      'Turn early demand into a polished campaign page that is ready to share.',
    );
    expect(
      _component(controller, heroId).properties['ctaLabel'],
      'Explore the launch',
    );
    expect(
      _component(controller, heroId).properties['analyticsKey'],
      'hero-main',
    );

    controller.undo();

    expect(
      _component(controller, heroId).properties['headline'],
      'Campaign hero',
    );
    expect(
      _component(controller, heroId).properties['analyticsKey'],
      'hero-main',
    );

    controller.redo();

    expect(
      _component(controller, heroId).properties['headline'],
      'Launch your next product',
    );

    final wrongKindPreset = websiteBuilderPresetById('button', 'button_demo')!;
    controller.applyComponentPreset(heroId, wrongKindPreset);

    expect(
      _component(controller, heroId).properties['headline'],
      'Launch your next product',
    );
  });

  test('controller adds components with content presets', () {
    final controller = websiteBuilderTestController();
    final preset = websiteBuilderPresetById('button', 'button_demo')!;
    final buttonId = addWebsiteBuilderTestComponent(
      controller,
      'button',
      contentPreset: preset,
    );

    expect(controller.componentCount, 1);
    expect(controller.selectedComponentId, buttonId);
    expect(_component(controller, buttonId).properties['label'], 'Book a demo');
    expect(_component(controller, buttonId).properties['href'], '/demo');

    controller.undo();

    expect(controller.componentCount, 0);

    controller.redo();

    expect(controller.componentCount, 1);
    expect(controller.selectedComponentId, buttonId);
    expect(_component(controller, buttonId).properties['label'], 'Book a demo');
  });

  test('controller saves custom content presets through history and json', () {
    final controller = WebsiteBuilderController();
    final buttonKind = websiteBuilderCatalog.byKey('button')!;
    final buttonId = controller.addComponent(buttonKind);

    controller.updateComponentProperty(buttonId, 'label', 'Request quote');
    controller.updateComponentProperty(buttonId, 'href', '/quote');

    final preset = controller.saveSelectedComponentContentPreset();

    expect(preset, isNotNull);
    expect(preset?.kindKey, 'button');
    expect(preset?.label, 'Request quote');
    expect(preset?.properties, containsPair('href', '/quote'));
    expect(preset?.isCustom, isTrue);
    expect(
      websiteBuilderPresetById('button', 'button_demo')?.isCustom,
      isFalse,
    );
    expect(controller.customContentPresets, hasLength(1));
    expect(
      controller.presetsMatching('button', 'quote').map((preset) => preset.id),
      contains(preset?.id),
    );

    final json = controller.toJson();
    expect(json['customContentPresets'], hasLength(1));
    expect(json['customContentPresets'].single['isCustom'], isTrue);

    controller.undo();

    expect(controller.customContentPresets, isEmpty);

    controller.redo();

    expect(controller.customContentPresets.single.label, 'Request quote');

    final loaded = WebsiteBuilderController.fromJson(json);
    final loadedPreset = loaded.presetsMatching('button', 'quote').first;
    final newButtonId = loaded.addComponent(
      buttonKind,
      contentPreset: loadedPreset,
    );

    expect(loaded.customContentPresets.single.label, 'Request quote');
    expect(loaded.customContentPresets.single.isCustom, isTrue);
    expect(
      _component(loaded, newButtonId).properties['label'],
      'Request quote',
    );
    expect(_component(loaded, newButtonId).properties['href'], '/quote');
  });

  test('controller deletes custom content presets through history', () {
    final controller = websiteBuilderTestController();
    final buttonId = addWebsiteBuilderTestComponent(controller, 'button');

    controller.updateComponentProperty(buttonId, 'label', 'Request quote');
    final preset = controller.saveSelectedComponentContentPreset();

    expect(preset, isNotNull);
    expect(controller.customContentPresets, hasLength(1));

    expect(controller.deleteCustomContentPreset(preset!.id), isTrue);
    expect(controller.customContentPresets, isEmpty);
    expect(controller.presetsMatching('button', 'quote'), isEmpty);

    controller.undo();

    expect(controller.customContentPresets.single.id, preset.id);

    controller.redo();

    expect(controller.customContentPresets, isEmpty);
    expect(controller.deleteCustomContentPreset('missing-preset'), isFalse);
  });

  test('controller renames custom content presets through history', () {
    final controller = websiteBuilderTestController();
    final buttonId = addWebsiteBuilderTestComponent(controller, 'button');

    controller.updateComponentProperty(buttonId, 'label', 'Request quote');
    final preset = controller.saveSelectedComponentContentPreset();

    expect(preset, isNotNull);
    expect(
      controller.renameCustomContentPreset(preset!.id, 'Quote CTA'),
      isTrue,
    );
    expect(controller.customContentPresets.single.label, 'Quote CTA');
    expect(controller.presetsMatching('button', 'Quote CTA'), hasLength(1));
    expect(
      controller.presetsMatching('button', 'Request quote').single.label,
      'Quote CTA',
    );

    controller.undo();

    expect(controller.customContentPresets.single.label, 'Request quote');

    controller.redo();

    expect(controller.customContentPresets.single.label, 'Quote CTA');
    expect(controller.renameCustomContentPreset(preset.id, '   '), isFalse);
    expect(
      controller.renameCustomContentPreset('missing-preset', 'Name'),
      isFalse,
    );
  });

  test('controller updates custom content presets through history', () {
    final controller = websiteBuilderTestController();
    final buttonId = addWebsiteBuilderTestComponent(controller, 'button');

    controller.updateComponentProperty(buttonId, 'label', 'Request quote');
    controller.updateComponentProperty(buttonId, 'href', '/quote');
    final preset = controller.saveSelectedComponentContentPreset();

    expect(preset, isNotNull);

    controller.updateComponentProperty(buttonId, 'label', 'Apply now');
    controller.updateComponentProperty(buttonId, 'href', '/apply');

    expect(
      controller.updateCustomContentPresetFromComponent(preset!.id, buttonId),
      isTrue,
    );
    expect(
      controller.customContentPresets.single.properties,
      containsPair('label', 'Apply now'),
    );
    expect(
      controller.customContentPresets.single.properties,
      containsPair('href', '/apply'),
    );

    controller.undo();

    expect(
      controller.customContentPresets.single.properties,
      containsPair('label', 'Request quote'),
    );
    expect(
      controller.customContentPresets.single.properties,
      containsPair('href', '/quote'),
    );

    controller.redo();

    expect(
      controller.customContentPresets.single.properties,
      containsPair('label', 'Apply now'),
    );
    expect(
      controller.updateCustomContentPresetFromComponent(preset.id, buttonId),
      isFalse,
    );
    expect(
      controller.updateCustomContentPresetFromComponent(
        'missing-preset',
        buttonId,
      ),
      isFalse,
    );
  });

  test('controller exports custom content preset libraries by kind', () {
    final controller = websiteBuilderTestController();
    final buttonId = addWebsiteBuilderTestComponent(controller, 'button');

    controller.updateComponentProperty(buttonId, 'label', 'Request quote');
    controller.updateComponentProperty(buttonId, 'href', '/quote');
    controller.saveSelectedComponentContentPreset();

    final heroId = addWebsiteBuilderTestComponent(controller, 'hero');
    controller.updateComponentProperty(heroId, 'headline', 'Launch offer');
    controller.saveSelectedComponentContentPreset();

    final exported =
        jsonDecode(
              controller.toPrettyCustomContentPresetLibraryJson(
                'button',
                kindLabel: 'Button',
              ),
            )
            as Map<String, dynamic>;

    expect(exported['schema'], WebsiteBuilderContentPresetLibrary.schemaId);
    expect(exported['kindKey'], 'button');
    expect(exported['kindLabel'], 'Button');
    expect(exported['presets'], hasLength(1));
    expect(exported['presets'].single['label'], 'Request quote');
    expect(exported['presets'].single['isCustom'], isTrue);

    final library = WebsiteBuilderContentPresetLibrary.fromJson(exported);

    expect(library.presetCount, 1);
    expect(library.presets.single.kindKey, 'button');
    expect(library.presets.single.properties, containsPair('href', '/quote'));
    expect(library.presets.single.isCustom, isTrue);
  });

  test(
    'controller imports custom content preset libraries through history',
    () {
      final controller = websiteBuilderTestController();
      final library = WebsiteBuilderContentPresetLibrary(
        kindKey: 'button',
        kindLabel: 'Button',
        presets: [websiteBuilderQuoteButtonPreset(label: 'Request quote')],
      );

      final preview = controller.previewCustomContentPresetLibrary(
        library,
        kindKey: 'button',
      );

      expect(preview.addedCount, 1);
      expect(preview.updatedCount, 0);
      expect(preview.skippedCount, 0);
      expect(controller.customContentPresets, isEmpty);

      final result = controller.importCustomContentPresetLibrary(
        library,
        kindKey: 'button',
      );

      expect(result.addedCount, 1);
      expect(result.updatedCount, 0);
      expect(result.didChange, isTrue);
      expect(controller.customContentPresets, hasLength(1));
      expect(controller.customContentPresets.single.id, 'custom_button_quote');

      controller.undo();

      expect(controller.customContentPresets, isEmpty);

      controller.redo();

      expect(controller.customContentPresets.single.label, 'Request quote');

      final updatedLibrary = WebsiteBuilderContentPresetLibrary(
        kindKey: 'button',
        kindLabel: 'Button',
        presets: [
          websiteBuilderQuoteButtonPreset(
            label: 'Request quote',
            properties: const {'label': 'Apply now', 'href': '/apply'},
          ),
        ],
      );
      final updatedPreview = controller.previewCustomContentPresetLibrary(
        updatedLibrary,
        kindKey: 'button',
      );

      expect(updatedPreview.addedCount, 0);
      expect(updatedPreview.updatedCount, 1);
      expect(
        controller.customContentPresets.single.properties,
        containsPair('label', 'Request quote'),
      );

      final updatedResult = controller.importCustomContentPresetLibrary(
        updatedLibrary,
        kindKey: 'button',
      );

      expect(updatedResult.addedCount, 0);
      expect(updatedResult.updatedCount, 1);
      expect(
        controller.customContentPresets.single.properties,
        containsPair('label', 'Apply now'),
      );

      final mismatch = controller.importCustomContentPresetLibrary(
        library,
        kindKey: 'hero',
      );

      expect(mismatch.kindMismatch, isTrue);
      expect(mismatch.didChange, isFalse);
    },
  );

  test('component presets support content search', () {
    expect(
      websiteBuilderPresetsMatching(
        'button',
        'demo',
      ).map((preset) => preset.id),
      ['button_demo'],
    );
    expect(websiteBuilderKindHasPresetMatch('pricing', 'starter'), isTrue);
    expect(websiteBuilderKindHasPresetMatch('button', 'enterprise'), isFalse);
  });

  test('component content issues flag unsafe and empty fields', () {
    final buttonIssues = websiteBuilderContentIssuesFor(
      websiteBuilderUnsafeButtonFixture,
    );
    final imageIssues = websiteBuilderContentIssuesFor(
      websiteBuilderEmptyImageFixture,
    );

    expect(
      buttonIssues.map((issue) => issue.message),
      containsAll([
        'Label is empty; exported action will use fallback copy.',
        'Unsafe link will be replaced during export.',
      ]),
    );
    expect(buttonIssues.every((issue) => issue.isWarning), isTrue);
    expect(
      buttonIssues.singleWhere((issue) => issue.key == 'href').suggestedValue,
      '/learn-more',
    );
    expect(
      websiteBuilderComponentWithContentIssueFixes(
        websiteBuilderUnsafeButtonFixture,
      ).properties,
      containsPair('label', 'Learn more'),
    );
    expect(
      websiteBuilderComponentWithContentIssueFixes(
        websiteBuilderUnsafeButtonFixture,
      ).properties,
      containsPair('href', '/learn-more'),
    );
    expect(
      imageIssues.map((issue) => issue.message),
      containsAll([
        'Alt text is empty; exported image will use generic copy.',
        'Image URL is empty; exported image will use a placeholder.',
      ]),
    );
  });

  test('controller applies content issue fixes through history', () {
    final controller = WebsiteBuilderController();
    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );

    controller.updateComponentProperty(buttonId, 'label', '');
    controller.updateComponentProperty(buttonId, 'href', 'javascript:alert(1)');

    controller.applyContentIssueFixes(buttonId);

    expect(_component(controller, buttonId).properties['label'], 'Learn more');
    expect(_component(controller, buttonId).properties['href'], '/learn-more');

    controller.undo();

    expect(_component(controller, buttonId).properties['label'], '');
    expect(
      _component(controller, buttonId).properties['href'],
      'javascript:alert(1)',
    );

    controller.redo();

    expect(_component(controller, buttonId).properties['label'], 'Learn more');
    expect(_component(controller, buttonId).properties['href'], '/learn-more');
  });

  test('controller applies all content issue fixes in one history entry', () {
    final controller = WebsiteBuilderController();
    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );
    final imageId = controller.addComponent(
      websiteBuilderCatalog.byKey('image')!,
    );

    controller.updateComponentProperty(buttonId, 'label', '');
    controller.updateComponentProperty(buttonId, 'href', 'javascript:alert(1)');
    controller.updateComponentProperty(imageId, 'imageUrl', '');
    controller.updateComponentProperty(imageId, 'altText', '');
    controller.toggleComponentLock(imageId);

    expect(controller.contentIssueCount, 4);
    expect(controller.hasFixableContentIssues, isTrue);

    final changedCount = controller.applyAllContentIssueFixes();

    expect(changedCount, 1);
    expect(_component(controller, buttonId).properties['label'], 'Learn more');
    expect(_component(controller, buttonId).properties['href'], '/learn-more');
    expect(_component(controller, imageId).properties['altText'], '');
    expect(controller.contentIssueCount, 2);
    expect(controller.hasFixableContentIssues, isFalse);

    controller.undo();

    expect(_component(controller, buttonId).properties['label'], '');
    expect(
      _component(controller, buttonId).properties['href'],
      'javascript:alert(1)',
    );
    expect(_component(controller, imageId).properties['altText'], '');
    expect(controller.contentIssueCount, 4);

    controller.redo();

    expect(_component(controller, buttonId).properties['label'], 'Learn more');
    expect(_component(controller, buttonId).properties['href'], '/learn-more');
    expect(_component(controller, imageId).properties['altText'], '');
    expect(controller.contentIssueCount, 2);
  });

  test('controller navigates content issue components by layer', () {
    final controller = WebsiteBuilderController();
    final heroId = controller.addComponent(
      websiteBuilderCatalog.byKey('hero')!,
    );
    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );
    final imageId = controller.addComponent(
      websiteBuilderCatalog.byKey('image')!,
    );

    controller.updateComponentProperty(heroId, 'headline', '');
    controller.updateComponentProperty(buttonId, 'href', 'javascript:alert(1)');
    controller.selectComponent(imageId);

    expect(controller.hasContentIssueComponents, isTrue);
    expect(controller.selectNextComponentWithContentIssues(), buttonId);
    expect(controller.selectedComponentId, buttonId);
    expect(controller.selectNextComponentWithContentIssues(), heroId);
    expect(controller.selectedComponentId, heroId);
    expect(controller.selectPreviousComponentWithContentIssues(), buttonId);
    expect(controller.selectedComponentId, buttonId);

    controller.applyAllContentIssueFixes();

    expect(controller.hasContentIssueComponents, isFalse);
    expect(controller.selectNextComponentWithContentIssues(), isNull);
  });

  test('controller reorders the selected layer', () {
    final controller = WebsiteBuilderController();

    final heroId = controller.addComponent(
      websiteBuilderCatalog.byKey('hero')!,
    );
    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );

    expect(_componentZIndex(controller, heroId), 0);
    expect(_componentZIndex(controller, buttonId), 1);

    controller.selectComponent(heroId);
    controller.bringSelectedForward();

    expect(_componentZIndex(controller, heroId), 1);
    expect(_componentZIndex(controller, buttonId), 0);

    controller.sendSelectedToBack();

    expect(_componentZIndex(controller, heroId), 0);
    expect(_componentZIndex(controller, buttonId), 1);

    controller.bringSelectedToFront();

    expect(_componentZIndex(controller, heroId), 1);
    expect(_componentZIndex(controller, buttonId), 0);
  });

  test('controller toggles layer visibility and lock state', () {
    final controller = WebsiteBuilderController();
    final heroId = controller.addComponent(
      websiteBuilderCatalog.byKey('hero')!,
    );
    final originalPosition = _component(controller, heroId).position;
    final originalSize = _component(controller, heroId).size;

    controller.toggleComponentVisibility(heroId);

    expect(_component(controller, heroId).isVisible, isFalse);
    expect(controller.toSharedSnapshot().components.single.isVisible, isFalse);

    controller.toggleComponentLock(heroId);

    expect(_component(controller, heroId).isLocked, isTrue);

    controller.moveComponent(heroId, const Offset(200, 220));
    controller.resizeComponent(heroId, const Size(120, 80));

    expect(_component(controller, heroId).position, originalPosition);
    expect(_component(controller, heroId).size, originalSize);
    expect(controller.duplicateSelected(), isNull);

    controller.removeSelected();

    expect(controller.componentCount, 1);

    controller.toggleComponentVisibility(heroId);
    controller.toggleComponentLock(heroId);

    expect(_component(controller, heroId).isVisible, isTrue);
    expect(_component(controller, heroId).isLocked, isFalse);

    controller.removeSelected();

    expect(controller.componentCount, 0);
  });

  test('controller imports shared snapshots and maps layout builder kinds', () {
    final controller = WebsiteBuilderController();
    const snapshot = BuilderSharedSnapshot(
      id: 'layout-1',
      name: 'Register Layout',
      canvasConfig: BuilderCanvasConfig(
        layoutMechanism: BuilderLayoutMechanism.tabularColumns,
      ),
      selectedComponentId: 'button_1',
      components: [
        BuilderComponentGeometry(
          id: 'button_1',
          kindKey: 'custom_button',
          position: Offset(24, 24),
          size: Size(160, 56),
        ),
        BuilderComponentGeometry(
          id: 'legacy_1',
          kindKey: 'legacy_widget',
          position: Offset(240, 24),
          size: Size(160, 120),
        ),
      ],
    );

    final preview = controller.previewSharedSnapshot(snapshot);

    expect(preview.componentCount, 2);
    expect(preview.mappedCount, 1);
    expect(preview.unknownCount, 1);
    expect(preview.mappedKindLabels, ['custom_button to button']);
    expect(preview.unknownKindKeys, ['legacy_widget']);
    expect(preview.importedCount(includeUnknownComponents: false), 1);
    final replaceImpact = preview.impact(
      existingComponentCount: 3,
      options: const WebsiteBuilderSnapshotImportOptions(
        includeUnknownComponents: false,
      ),
    );
    final appendImpact = preview.impact(
      existingComponentCount: 3,
      options: const WebsiteBuilderSnapshotImportOptions(
        includeUnknownComponents: false,
        mode: WebsiteBuilderSnapshotImportMode.append,
      ),
    );

    expect(replaceImpact.resultComponentCount, 1);
    expect(replaceImpact.skippedComponentCount, 1);
    expect(replaceImpact.replacesExistingComponents, isTrue);
    expect(appendImpact.resultComponentCount, 4);
    expect(appendImpact.replacesExistingComponents, isFalse);

    controller.loadSharedSnapshot(snapshot);

    expect(controller.projectName, 'Register Layout');
    expect(
      controller.canvasConfig.layoutMechanism,
      BuilderLayoutMechanism.tabularColumns,
    );
    expect(controller.componentCount, 2);
    expect(controller.selectedComponentId, 'button_1');
    expect(controller.components.map((component) => component.kindKey), [
      'button',
      'legacy_widget',
    ]);

    controller.duplicateSelected();

    expect(
      controller.components.map((component) => component.id),
      unorderedEquals(['button_1', 'button_2', 'legacy_1']),
    );

    final filteredController = WebsiteBuilderController();
    filteredController.loadSharedSnapshot(
      snapshot,
      includeUnknownComponents: false,
    );

    expect(filteredController.componentCount, 1);
    expect(filteredController.components.single.kindKey, 'button');

    final appendController = WebsiteBuilderController(
      projectName: 'Existing Site',
    );
    appendController.addComponent(websiteBuilderCatalog.byKey('button')!);
    appendController.loadSharedSnapshot(
      snapshot,
      includeUnknownComponents: false,
      mode: WebsiteBuilderSnapshotImportMode.append,
    );

    expect(appendController.projectName, 'Existing Site');
    expect(appendController.componentCount, 2);
    expect(appendController.selectedComponentId, 'button_1_2');
    expect(
      appendController.components.map((component) => component.id),
      unorderedEquals(['button_1', 'button_1_2']),
    );
  });

  test('website templates load through shared snapshots', () {
    final template = websiteBuilderTemplates.first;
    final snapshot = template.toSharedSnapshot();
    final controller = WebsiteBuilderController();

    controller.loadSharedSnapshot(snapshot, includeUnknownComponents: false);

    expect(snapshot.id, template.id);
    expect(snapshot.name, template.name);
    expect(snapshot.componentCount, template.componentCount);
    expect(controller.projectName, template.name);
    expect(controller.componentCount, template.componentCount);
    expect(controller.selectedComponentId, template.selectedComponentId);
    expect(
      controller.components.map((component) => component.kindKey),
      everyElement(isIn(websiteBuilderCatalog.kinds.map((kind) => kind.key))),
    );
  });

  test('website template library searches by category and content', () {
    final library = websiteBuilderTemplateLibrary;

    expect(library.categories, ['Marketing', 'Commerce', 'Operations']);
    expect(library.byId('template_product_page')?.name, 'Product Page');
    expect(
      library.search(category: 'Commerce').map((template) => template.name),
      ['Product Page'],
    );
    expect(
      library
          .search(query: 'response promise')
          .map((template) => template.name),
      ['Contact Page'],
    );
    expect(library.search(query: 'missing-template'), isEmpty);
  });

  testWidgets('screen renders the builder palette and canvas', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WebsiteBuilderScreen()));

    expect(find.text('Website Builder'), findsOneWidget);
    expect(find.text('Components'), findsOneWidget);
    expect(find.text('Layers'), findsOneWidget);
    expect(find.text('Hero Section'), findsOneWidget);

    await tester.tap(find.text('Hero Section'));
    await tester.pump();

    expect(find.text('1'), findsWidgets);
    expect(find.text('Inspector'), findsOneWidget);
  });

  testWidgets('palette quick inserts preset components', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.tap(
      find.byKey(const ValueKey('website-builder-palette-presets-button')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey('website-builder-preset-source-button-button_demo'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        const ValueKey('website-builder-palette-preset-button-button_demo'),
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.componentCount, 1);
    expect(controller.selectedComponentKind?.key, 'button');
    expect(controller.selectedComponent?.properties['label'], 'Book a demo');
    expect(controller.selectedComponent?.properties['href'], '/demo');
    expect(find.text('Book a demo'), findsWidgets);
  });

  testWidgets('palette sorts components and reports result count', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    final buttonTile = find.byKey(
      const ValueKey('website-builder-palette-tile-button'),
    );
    final sectionTile = find.byKey(
      const ValueKey('website-builder-palette-tile-section'),
    );

    expect(find.text('10 of 10 components'), findsOneWidget);
    expect(
      tester.getTopLeft(sectionTile).dy,
      lessThan(tester.getTopLeft(buttonTile).dy),
    );

    await tester.tap(
      find.byKey(const ValueKey('website-builder-palette-category-Layout')),
    );
    await tester.pump();

    expect(find.text('2 of 10 components'), findsOneWidget);
    expect(find.text('Button'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('website-builder-palette-category-All')),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const ValueKey('website-builder-palette-sort')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('website-builder-palette-sort-name')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Name A-Z'), findsOneWidget);
    expect(
      tester.getTopLeft(buttonTile).dy,
      lessThan(tester.getTopLeft(sectionTile).dy),
    );

    await tester.enterText(
      find.byKey(const ValueKey('website-builder-palette-search')),
      'demo',
    );
    await tester.pump();

    expect(find.text('1 of 10 components'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('website-builder-palette-search-clear')),
    );
    await tester.pump();

    expect(find.text('10 of 10 components'), findsOneWidget);
  });

  testWidgets('palette search finds preset content', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.enterText(
      find.byKey(const ValueKey('website-builder-palette-search')),
      'demo',
    );
    await tester.pump();

    expect(find.text('Hero Section'), findsNothing);
    expect(find.text('Button'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('website-builder-palette-match-button-button_demo'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('website-builder-preset-source-button-button_demo'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('website-builder-palette-presets-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Book a demo'), findsWidgets);
    expect(find.text('Start checkout'), findsNothing);

    await tester.tap(
      find.byKey(
        const ValueKey('website-builder-palette-preset-button-button_demo'),
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.componentCount, 1);
    expect(controller.selectedComponentKind?.key, 'button');
    expect(controller.selectedComponent?.properties['label'], 'Book a demo');
  });

  testWidgets('palette search submits the best preset match', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.enterText(
      find.byKey(const ValueKey('website-builder-palette-search')),
      'demo',
    );
    await tester.pump();

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(controller.componentCount, 1);
    expect(controller.selectedComponentKind?.key, 'button');
    expect(controller.selectedComponent?.properties['label'], 'Book a demo');
    expect(controller.selectedComponent?.properties['href'], '/demo');
  });

  testWidgets('palette search row taps the single preset match', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.enterText(
      find.byKey(const ValueKey('website-builder-palette-search')),
      'demo',
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const ValueKey('website-builder-palette-tile-button')),
    );
    await tester.pumpAndSettle();

    expect(controller.componentCount, 1);
    expect(controller.selectedComponentKind?.key, 'button');
    expect(controller.selectedComponent?.properties['label'], 'Book a demo');
    expect(controller.selectedComponent?.properties['href'], '/demo');
  });

  testWidgets('palette search row keeps default tap for component matches', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.enterText(
      find.byKey(const ValueKey('website-builder-palette-search')),
      'button',
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const ValueKey('website-builder-palette-tile-button')),
    );
    await tester.pumpAndSettle();

    expect(controller.componentCount, 1);
    expect(controller.selectedComponentKind?.key, 'button');
    expect(controller.selectedComponent?.properties['label'], 'Learn more');
    expect(controller.selectedComponent?.properties['href'], '/learn-more');
  });

  testWidgets('palette search finds saved custom presets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    final sourceButtonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );
    controller.updateComponentProperty(
      sourceButtonId,
      'label',
      'Request quote',
    );
    controller.updateComponentProperty(sourceButtonId, 'href', '/quote');
    controller.saveSelectedComponentContentPreset();

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.enterText(
      find.byKey(const ValueKey('website-builder-palette-search')),
      'quote',
    );
    await tester.pump();

    expect(
      find.byKey(
        ValueKey(
          'website-builder-palette-match-button-${controller.customContentPresets.single.id}',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        ValueKey(
          'website-builder-preset-source-button-${controller.customContentPresets.single.id}',
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('website-builder-palette-tile-button')),
    );
    await tester.pumpAndSettle();

    expect(controller.componentCount, 2);
    expect(controller.selectedComponent?.properties['label'], 'Request quote');
    expect(controller.selectedComponent?.properties['href'], '/quote');
  });

  testWidgets('component preview renders website content properties', (
    tester,
  ) async {
    const component = BuilderComponentGeometry(
      id: 'button-1',
      kindKey: 'button',
      position: Offset.zero,
      size: Size(260, 160),
      properties: {'label': 'Buy now', 'href': '/checkout'},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 260,
            height: 160,
            child: WebsiteBuilderComponentPreview(
              component: component,
              kind: websiteBuilderCatalog.byKey('button'),
              isSelected: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Buy now'), findsOneWidget);
    expect(find.text('/checkout'), findsOneWidget);
  });

  testWidgets('screen undoes and redoes toolbar actions', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.tap(find.text('Hero Section'));
    await tester.pump();

    expect(controller.componentCount, 1);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pump();

    expect(controller.componentCount, 0);

    await tester.tap(find.byTooltip('Redo'));
    await tester.pump();

    expect(controller.componentCount, 1);
  });

  testWidgets('screen handles canvas keyboard shortcuts', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    final heroId = controller.addComponent(
      websiteBuilderCatalog.byKey('hero')!,
    );

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );
    await tester.pump();

    final originalPosition = _component(controller, heroId).position;

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(
      _component(controller, heroId).position,
      originalPosition + const Offset(20, 0),
    );

    await _sendControlShortcut(tester, LogicalKeyboardKey.keyD);

    expect(controller.componentCount, 2);

    await _sendControlShortcut(tester, LogicalKeyboardKey.keyZ);

    expect(controller.componentCount, 1);
    expect(controller.selectedComponentId, heroId);

    await _sendControlShiftShortcut(tester, LogicalKeyboardKey.keyZ);

    expect(controller.componentCount, 2);

    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pump();

    expect(controller.componentCount, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    expect(controller.selectedComponentId, isNull);

    controller.selectComponent(heroId);
    await tester.pump();

    await tester.enterText(
      find.byKey(ValueKey('website-builder-property-$heroId-headline')),
      'Draft headline',
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    expect(controller.componentCount, 1);
  });

  testWidgets('screen confirms clear canvas and can undo it', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);
    controller.addComponent(websiteBuilderCatalog.byKey('hero')!);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.tap(find.byTooltip('Clear canvas'));
    await tester.pump();

    expect(find.text('Clear canvas'), findsOneWidget);
    expect(
      find.text('This will remove 1 component from the current canvas.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pump();

    expect(controller.componentCount, 1);

    await tester.tap(find.byTooltip('Clear canvas'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(controller.componentCount, 0);
    expect(find.text('Canvas cleared (1 component removed)'), findsOneWidget);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pump();

    expect(controller.componentCount, 1);
  });

  testWidgets('screen selects and reorders components from layers', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    final heroId = controller.addComponent(
      websiteBuilderCatalog.byKey('hero')!,
    );
    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );
    controller.updateComponentProperty(buttonId, 'label', '');
    controller.updateComponentProperty(buttonId, 'href', 'javascript:alert(1)');

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    expect(controller.selectedComponentId, buttonId);
    expect(find.text('2 on canvas | 2 issues'), findsOneWidget);
    expect(
      find.byKey(ValueKey('website-builder-layer-health-$buttonId')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('website-builder-layer-health-$heroId')),
      findsNothing,
    );

    await _selectLayerFilter(tester, 'Has issues');

    expect(find.text('2 on canvas | 2 issues | Has issues: 1'), findsOneWidget);
    expect(
      find.byKey(ValueKey('website-builder-layer-$buttonId')),
      findsOneWidget,
    );
    expect(find.byKey(ValueKey('website-builder-layer-$heroId')), findsNothing);

    await _selectLayerFilter(tester, 'All');

    expect(
      find.byKey(ValueKey('website-builder-layer-$heroId')),
      findsOneWidget,
    );

    await _selectLayerFilter(tester, 'Hidden');

    expect(find.text('No matching layers'), findsOneWidget);

    await _selectLayerFilter(tester, 'All');

    await _selectContentIssueAction(tester, 'Fix all issues');

    expect(
      find.byKey(ValueKey('website-builder-layer-health-$buttonId')),
      findsNothing,
    );
    expect(find.text('2 on canvas'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('website-builder-layer-$heroId')));
    await tester.pump();

    expect(controller.selectedComponentId, heroId);

    await tester.tap(find.byTooltip('Bring forward'));
    await tester.pump();

    expect(
      _componentZIndex(controller, heroId),
      greaterThan(_componentZIndex(controller, buttonId)),
    );

    await tester.tap(
      find.byKey(ValueKey('website-builder-layer-visibility-$heroId')),
    );
    await tester.pump();

    expect(_component(controller, heroId).isVisible, isFalse);

    await _selectLayerFilter(tester, 'Hidden');

    expect(
      find.byKey(ValueKey('website-builder-layer-$heroId')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('website-builder-layer-$buttonId')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(ValueKey('website-builder-layer-lock-$heroId')),
    );
    await tester.pump();

    expect(_component(controller, heroId).isLocked, isTrue);
    expect(find.text('2 on canvas | Hidden: 1'), findsOneWidget);

    await _selectLayerFilter(tester, 'Locked');

    expect(
      find.byKey(ValueKey('website-builder-layer-$heroId')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('website-builder-layer-$buttonId')),
      findsNothing,
    );

    final heroZIndex = _componentZIndex(controller, heroId);
    final sendBackwardButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.vertical_align_bottom_outlined),
    );

    expect(sendBackwardButton.onPressed, isNull);
    expect(_componentZIndex(controller, heroId), heroZIndex);
  });

  testWidgets('layers issue navigation jumps between content problems', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    final heroId = controller.addComponent(
      websiteBuilderCatalog.byKey('hero')!,
    );
    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );

    controller.updateComponentProperty(heroId, 'headline', '');
    controller.updateComponentProperty(buttonId, 'href', 'javascript:alert(1)');

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    expect(controller.selectedComponentId, buttonId);

    await _selectIssueNavigation(tester, 'Next issue');

    expect(controller.selectedComponentId, heroId);

    await _selectIssueNavigation(tester, 'Previous issue');

    expect(controller.selectedComponentId, buttonId);

    controller.applyAllContentIssueFixes();
    await tester.pump();

    expect(
      tester
          .widget<PopupMenuButton<dynamic>>(
            find.byKey(
              const ValueKey('website-builder-layers-content-issues-menu'),
            ),
          )
          .enabled,
      isFalse,
    );
  });

  testWidgets('screen toggles selected component state from inspector', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    final heroId = controller.addComponent(
      websiteBuilderCatalog.byKey('hero')!,
    );

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.enterText(
      find.byKey(ValueKey('website-builder-property-$heroId-headline')),
      'Campaign hero',
    );
    await tester.pump();

    expect(
      _component(controller, heroId).properties['headline'],
      'Campaign hero',
    );
    expect(find.text('Campaign hero'), findsWidgets);

    final resetContentButton = find.byKey(
      const ValueKey('website-builder-inspector-reset-content'),
    );

    expect(tester.widget<TextButton>(resetContentButton).onPressed, isNotNull);

    await tester.tap(resetContentButton);
    await tester.pump();

    expect(
      _component(controller, heroId).properties['headline'],
      'Launch a better storefront',
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(ValueKey('website-builder-property-$heroId-headline')),
          )
          .controller
          ?.text,
      'Launch a better storefront',
    );
    expect(tester.widget<TextButton>(resetContentButton).onPressed, isNull);

    final visibleControl = find.byKey(
      const ValueKey('website-builder-inspector-visible-control'),
    );
    final lockControl = find.byKey(
      const ValueKey('website-builder-inspector-lock-control'),
    );

    await tester.tap(
      find.descendant(of: visibleControl, matching: find.byType(Switch)),
    );
    await tester.pump();

    expect(_component(controller, heroId).isVisible, isFalse);
    expect(find.text('Hidden from canvas'), findsOneWidget);

    await tester.tap(
      find.descendant(of: lockControl, matching: find.byType(Switch)),
    );
    await tester.pump();

    expect(_component(controller, heroId).isLocked, isTrue);
    expect(find.text('Locked from editing'), findsOneWidget);
    expect(tester.widget<TextButton>(resetContentButton).onPressed, isNull);

    expect(
      tester
          .widget<TextFormField>(
            find.byKey(ValueKey('website-builder-property-$heroId-headline')),
          )
          .enabled,
      isFalse,
    );

    final moveUpButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.keyboard_arrow_up),
    );

    final duplicateButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Duplicate'),
    );

    expect(moveUpButton.onPressed, isNull);
    expect(duplicateButton.onPressed, isNull);
  });

  testWidgets('inspector applies content presets while editing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.tap(
      find.byKey(const ValueKey('website-builder-inspector-presets')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey('website-builder-preset-source-button-button_demo'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        const ValueKey('website-builder-inspector-preset-button_demo'),
      ),
    );
    await tester.pumpAndSettle();

    expect(_component(controller, buttonId).properties['label'], 'Book a demo');
    expect(_component(controller, buttonId).properties['href'], '/demo');
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(ValueKey('website-builder-property-$buttonId-label')),
          )
          .controller
          ?.text,
      'Book a demo',
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(ValueKey('website-builder-property-$buttonId-href')),
          )
          .controller
          ?.text,
      '/demo',
    );

    controller.toggleComponentLock(buttonId);
    await tester.pump();

    expect(
      tester
          .widget<PopupMenuButton<WebsiteBuilderComponentPreset>>(
            find.byKey(const ValueKey('website-builder-inspector-presets')),
          )
          .enabled,
      isFalse,
    );
  });

  testWidgets('inspector saves and reapplies custom content presets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.enterText(
      find.byKey(ValueKey('website-builder-property-$buttonId-label')),
      'Request quote',
    );
    await tester.pump();
    await tester.enterText(
      find.byKey(ValueKey('website-builder-property-$buttonId-href')),
      '/quote',
    );
    await tester.pump();

    await tester.tap(
      find.byKey(
        const ValueKey('website-builder-inspector-save-content-preset'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Save content preset'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('website-builder-content-preset-name')),
          )
          .controller
          ?.text,
      'Request quote',
    );

    await tester.enterText(
      find.byKey(const ValueKey('website-builder-content-preset-name')),
      'Quote CTA',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save preset'));
    await tester.pumpAndSettle();

    expect(controller.customContentPresets, hasLength(1));
    final preset = controller.customContentPresets.single;
    expect(preset.label, 'Quote CTA');

    await tester.enterText(
      find.byKey(ValueKey('website-builder-property-$buttonId-label')),
      'Learn more',
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const ValueKey('website-builder-inspector-presets')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(ValueKey('website-builder-preset-source-button-${preset.id}')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(ValueKey('website-builder-inspector-preset-${preset.id}')),
    );
    await tester.pumpAndSettle();

    expect(
      _component(controller, buttonId).properties['label'],
      'Request quote',
    );
    expect(_component(controller, buttonId).properties['href'], '/quote');
  });

  testWidgets('content preset dialog requires a name', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    controller.addComponent(websiteBuilderCatalog.byKey('button')!);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.tap(
      find.byKey(
        const ValueKey('website-builder-inspector-save-content-preset'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('website-builder-content-preset-name')),
      '',
    );
    await tester.pump();

    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save preset'),
    );

    expect(saveButton.onPressed, isNull);
  });

  testWidgets('inspector manages and deletes custom content presets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );
    controller.updateComponentProperty(buttonId, 'label', 'Request quote');
    final preset = controller.saveSelectedComponentContentPreset();

    expect(preset, isNotNull);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    final manageButton = find.byKey(
      const ValueKey('website-builder-inspector-manage-content-presets'),
    );
    expect(tester.widget<IconButton>(manageButton).onPressed, isNotNull);

    await tester.tap(manageButton);
    await tester.pumpAndSettle();

    expect(find.text('Manage content presets'), findsOneWidget);
    expect(
      find.byKey(ValueKey('website-builder-content-preset-row-${preset!.id}')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(
        ValueKey('website-builder-content-preset-delete-${preset.id}'),
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.customContentPresets, isEmpty);
    expect(tester.widget<IconButton>(manageButton).onPressed, isNotNull);

    await tester.tap(manageButton);
    await tester.pumpAndSettle();

    expect(find.text('No saved content presets yet.'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('website-builder-content-preset-export')),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('website-builder-content-preset-import')),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('content preset manager filters saved presets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );
    controller.updateComponentProperty(buttonId, 'label', 'Request quote');
    controller.updateComponentProperty(buttonId, 'href', '/quote');
    final quotePreset = controller.saveSelectedComponentContentPreset(
      label: 'Quote CTA',
    );

    controller.updateComponentProperty(buttonId, 'label', 'Book audit');
    controller.updateComponentProperty(buttonId, 'href', '/audit');
    final auditPreset = controller.saveSelectedComponentContentPreset(
      label: 'Audit CTA',
    );

    expect(quotePreset, isNotNull);
    expect(auditPreset, isNotNull);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.tap(
      find.byKey(
        const ValueKey('website-builder-inspector-manage-content-presets'),
      ),
    );
    await tester.pumpAndSettle();

    final quoteRow = find.byKey(
      ValueKey('website-builder-content-preset-row-${quotePreset!.id}'),
    );
    final auditRow = find.byKey(
      ValueKey('website-builder-content-preset-row-${auditPreset!.id}'),
    );
    final searchField = find.byKey(
      const ValueKey('website-builder-content-preset-manager-search'),
    );

    expect(searchField, findsOneWidget);
    expect(quoteRow, findsOneWidget);
    expect(auditRow, findsOneWidget);
    expect(find.text('2 of 2 presets'), findsOneWidget);

    await tester.enterText(searchField, 'audit');
    await tester.pumpAndSettle();

    expect(quoteRow, findsNothing);
    expect(auditRow, findsOneWidget);
    expect(find.text('1 of 2 presets'), findsOneWidget);

    await tester.enterText(searchField, '/quote');
    await tester.pumpAndSettle();

    expect(quoteRow, findsOneWidget);
    expect(auditRow, findsNothing);

    await tester.enterText(searchField, 'missing preset');
    await tester.pumpAndSettle();

    expect(quoteRow, findsNothing);
    expect(auditRow, findsNothing);
    expect(find.text('No matching content presets.'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('website-builder-content-preset-export')),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('content preset manager sorts saved presets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController(
      customContentPresets: const [
        WebsiteBuilderComponentPreset(
          id: 'alpha_cta',
          kindKey: 'button',
          label: 'Alpha CTA',
          description: 'Short preset.',
          properties: {'label': 'Alpha'},
        ),
        WebsiteBuilderComponentPreset(
          id: 'beta_cta',
          kindKey: 'button',
          label: 'Beta CTA',
          description: 'Full preset.',
          properties: {'label': 'Beta', 'href': '/beta'},
        ),
      ],
    );
    addTearDown(controller.dispose);

    controller.addComponent(websiteBuilderCatalog.byKey('button')!);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.tap(
      find.byKey(
        const ValueKey('website-builder-inspector-manage-content-presets'),
      ),
    );
    await tester.pumpAndSettle();

    final alphaRow = find.byKey(
      const ValueKey('website-builder-content-preset-row-alpha_cta'),
    );
    final betaRow = find.byKey(
      const ValueKey('website-builder-content-preset-row-beta_cta'),
    );
    final sortButton = find.byKey(
      const ValueKey('website-builder-content-preset-manager-sort'),
    );

    expect(find.text('Recently saved'), findsOneWidget);
    expect(
      tester.getTopLeft(betaRow).dy,
      lessThan(tester.getTopLeft(alphaRow).dy),
    );

    await tester.tap(sortButton);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('website-builder-content-preset-sort-name')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Name A-Z'), findsOneWidget);
    expect(
      tester.getTopLeft(alphaRow).dy,
      lessThan(tester.getTopLeft(betaRow).dy),
    );

    await tester.tap(sortButton);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('website-builder-content-preset-sort-fields')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Most fields'), findsOneWidget);
    expect(
      tester.getTopLeft(betaRow).dy,
      lessThan(tester.getTopLeft(alphaRow).dy),
    );
  });

  testWidgets('inspector copies custom content preset library JSON', (
    tester,
  ) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    String? copiedText;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiedText = (call.arguments as Map?)?['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );
    controller.updateComponentProperty(buttonId, 'label', 'Request quote');
    controller.updateComponentProperty(buttonId, 'href', '/quote');
    controller.saveSelectedComponentContentPreset();

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.tap(
      find.byKey(
        const ValueKey('website-builder-inspector-manage-content-presets'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('website-builder-content-preset-export')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final copiedJson = jsonDecode(copiedText!) as Map<String, dynamic>;

    expect(copiedJson['schema'], WebsiteBuilderContentPresetLibrary.schemaId);
    expect(copiedJson['kindKey'], 'button');
    expect(copiedJson['kindLabel'], 'Button');
    expect(copiedJson['presets'], hasLength(1));
    expect(copiedJson['presets'].single['label'], 'Request quote');
    expect(find.text('Content presets copied (1 preset)'), findsOneWidget);
  });

  testWidgets('inspector imports custom content preset library JSON', (
    tester,
  ) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    final library = WebsiteBuilderContentPresetLibrary(
      kindKey: 'button',
      kindLabel: 'Button',
      presets: const [
        WebsiteBuilderComponentPreset(
          id: 'custom_button_quote',
          kindKey: 'button',
          label: 'Request quote',
          description: 'Imported CTA.',
          properties: {'label': 'Request quote', 'href': '/quote'},
          isCustom: true,
        ),
      ],
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') {
          return {'text': library.toPrettyJson()};
        }
        return null;
      },
    );
    addTearDown(
      () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.tap(
      find.byKey(
        const ValueKey('website-builder-inspector-manage-content-presets'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No saved content presets yet.'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('website-builder-content-preset-import')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Import content presets'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('new'), findsOneWidget);
    expect(find.text('updated'), findsOneWidget);
    expect(find.text('skipped'), findsOneWidget);
    expect(controller.customContentPresets, isEmpty);

    await tester.tap(
      find.byKey(
        const ValueKey('website-builder-content-preset-import-confirm'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(controller.customContentPresets, hasLength(1));
    expect(controller.customContentPresets.single.label, 'Request quote');
    expect(find.text('Content presets imported (1 preset)'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('website-builder-inspector-presets')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey('website-builder-inspector-preset-custom_button_quote'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      _component(controller, buttonId).properties['label'],
      'Request quote',
    );
    expect(_component(controller, buttonId).properties['href'], '/quote');
  });

  testWidgets('inspector updates custom content presets from selection', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );
    controller.updateComponentProperty(buttonId, 'label', 'Request quote');
    controller.updateComponentProperty(buttonId, 'href', '/quote');
    final preset = controller.saveSelectedComponentContentPreset();

    expect(preset, isNotNull);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.enterText(
      find.byKey(ValueKey('website-builder-property-$buttonId-label')),
      'Apply now',
    );
    await tester.pump();
    await tester.enterText(
      find.byKey(ValueKey('website-builder-property-$buttonId-href')),
      '/apply',
    );
    await tester.pump();

    await tester.tap(
      find.byKey(
        const ValueKey('website-builder-inspector-manage-content-presets'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        ValueKey('website-builder-content-preset-update-${preset!.id}'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      controller.customContentPresets.single.properties,
      containsPair('label', 'Apply now'),
    );
    expect(
      controller.customContentPresets.single.properties,
      containsPair('href', '/apply'),
    );

    await tester.enterText(
      find.byKey(ValueKey('website-builder-property-$buttonId-label')),
      'Temporary label',
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const ValueKey('website-builder-inspector-presets')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(ValueKey('website-builder-inspector-preset-${preset.id}')),
    );
    await tester.pumpAndSettle();

    expect(_component(controller, buttonId).properties['label'], 'Apply now');
    expect(_component(controller, buttonId).properties['href'], '/apply');
  });

  testWidgets('inspector renames custom content presets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );
    controller.updateComponentProperty(buttonId, 'label', 'Request quote');
    final preset = controller.saveSelectedComponentContentPreset();

    expect(preset, isNotNull);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.tap(
      find.byKey(
        const ValueKey('website-builder-inspector-manage-content-presets'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        ValueKey('website-builder-content-preset-rename-${preset!.id}'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rename content preset'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('website-builder-content-preset-name')),
          )
          .controller
          ?.text,
      'Request quote',
    );

    await tester.enterText(
      find.byKey(const ValueKey('website-builder-content-preset-name')),
      'Quote CTA',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Rename'));
    await tester.pumpAndSettle();

    expect(controller.customContentPresets.single.label, 'Quote CTA');
    expect(controller.presetsMatching('button', 'Quote CTA'), hasLength(1));
    expect(
      controller.presetsMatching('button', 'Request quote').single.label,
      'Quote CTA',
    );
  });

  testWidgets('inspector surfaces content health while editing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);

    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    expect(
      find.byKey(const ValueKey('website-builder-content-issues')),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(ValueKey('website-builder-property-$buttonId-href')),
      'javascript:alert(1)',
    );
    await tester.pump();
    await tester.enterText(
      find.byKey(ValueKey('website-builder-property-$buttonId-label')),
      '',
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('website-builder-content-issues')),
      findsOneWidget,
    );
    expect(find.text('Content health'), findsOneWidget);
    expect(
      find.text('Unsafe link will be replaced during export.'),
      findsOneWidget,
    );
    expect(
      find.text('Label is empty; exported action will use fallback copy.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey('website-builder-content-fix-all')),
          )
          .onPressed,
      isNotNull,
    );

    await tester.tap(
      find.byKey(const ValueKey('website-builder-content-fix-href')),
    );
    await tester.pump();

    expect(_component(controller, buttonId).properties['href'], '/learn-more');
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(ValueKey('website-builder-property-$buttonId-href')),
          )
          .controller
          ?.text,
      '/learn-more',
    );
    expect(
      find.text('Unsafe link will be replaced during export.'),
      findsNothing,
    );
    expect(
      find.text('Label is empty; exported action will use fallback copy.'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('website-builder-content-fix-all')),
    );
    await tester.pump();

    expect(_component(controller, buttonId).properties['label'], 'Learn more');
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(ValueKey('website-builder-property-$buttonId-label')),
          )
          .controller
          ?.text,
      'Learn more',
    );
    expect(
      find.byKey(const ValueKey('website-builder-content-issues')),
      findsNothing,
    );
  });

  testWidgets('screen edits project details from the app bar', (tester) async {
    final controller = WebsiteBuilderController(
      projectId: 'site-1',
      projectName: 'Storefront',
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.tap(find.byTooltip('Edit project details'));
    await tester.pump();

    expect(find.text('Project details'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Project name'),
      'Campaign Site',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Project id'),
      'campaign-site',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(controller.projectName, 'Campaign Site');
    expect(controller.projectId, 'campaign-site');
    expect(controller.toSharedSnapshot().name, 'Campaign Site');
    expect(controller.toSharedSnapshot().id, 'campaign-site');
    expect(find.text('Project details updated'), findsOneWidget);
  });

  testWidgets('screen applies starter template from the app bar', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WebsiteBuilderController(projectName: 'Existing Site');
    addTearDown(controller.dispose);
    controller.addComponent(websiteBuilderCatalog.byKey('hero')!);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );

    await tester.tap(find.byTooltip('Open templates'));
    await tester.pump();

    expect(find.text('Templates'), findsOneWidget);
    expect(find.text('Landing Page'), findsWidgets);
    expect(find.text('Product Page'), findsOneWidget);
    expect(find.text('Contact Page'), findsOneWidget);
    expect(find.text('3 of 3 templates'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey(
          'website-builder-template-preview-template_landing_page',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Recommended'), findsOneWidget);
    expect(
      tester
          .getTopLeft(
            find.byKey(
              const ValueKey(
                'website-builder-template-tile-template_landing_page',
              ),
            ),
          )
          .dy,
      lessThan(
        tester
            .getTopLeft(
              find.byKey(
                const ValueKey(
                  'website-builder-template-tile-template_product_page',
                ),
              ),
            )
            .dy,
      ),
    );
    await tester.tap(
      find.byKey(const ValueKey('website-builder-template-sort')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('website-builder-template-sort-name')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Name A-Z'), findsOneWidget);
    expect(
      tester
          .getTopLeft(
            find.byKey(
              const ValueKey(
                'website-builder-template-tile-template_contact_page',
              ),
            ),
          )
          .dy,
      lessThan(
        tester
            .getTopLeft(
              find.byKey(
                const ValueKey(
                  'website-builder-template-tile-template_landing_page',
                ),
              ),
            )
            .dy,
      ),
    );
    expect(
      find.text('Replace will clear 1 component from the current canvas.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('website-builder-template-search')),
      'missing-template',
    );
    await tester.pump();

    expect(find.text('0 of 3 templates'), findsOneWidget);
    expect(
      find.text('No templates match the current filters.'),
      findsOneWidget,
    );
    expect(find.text('Select a template to inspect it.'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('website-builder-template-search-clear')),
    );
    await tester.pump();

    expect(find.text('3 of 3 templates'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('website-builder-template-search')),
      'signature product',
    );
    await tester.pump();

    expect(find.text('1 of 3 templates'), findsOneWidget);
    expect(find.text('Product Page'), findsWidgets);
    expect(find.text('Contact Page'), findsNothing);
    expect(
      find.byKey(
        const ValueKey(
          'website-builder-template-preview-template_product_page',
        ),
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('website-builder-template-search')),
      '',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(
        const ValueKey('website-builder-template-category-Operations'),
      ),
    );
    await tester.pump();

    expect(find.text('1 of 3 templates'), findsOneWidget);
    expect(find.text('Contact Page'), findsWidgets);
    expect(find.text('Product Page'), findsNothing);
    expect(
      find.byKey(
        const ValueKey(
          'website-builder-template-preview-template_contact_page',
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Contact Page').first);
    await tester.pump();
    await tester.tap(find.text('Append'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final contactTemplate = websiteBuilderTemplates.singleWhere(
      (template) => template.id == 'template_contact_page',
    );

    expect(controller.projectName, 'Existing Site');
    expect(controller.componentCount, 1 + contactTemplate.componentCount);
    expect(controller.selectedComponentId, contactTemplate.selectedComponentId);
    expect(
      find.text('Applied template: Contact Page (5 components)'),
      findsOneWidget,
    );
  });

  testWidgets('screen copies shared snapshot to clipboard', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    String? copiedText;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiedText = (call.arguments as Map?)?['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    final controller = WebsiteBuilderController(
      projectId: 'site-1',
      projectName: 'Storefront',
    );
    addTearDown(controller.dispose);
    controller.addComponent(websiteBuilderCatalog.byKey('hero')!);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );
    await tester.tap(find.byTooltip('Copy shared snapshot'));
    await tester.pump();

    final copiedJson = jsonDecode(copiedText!) as Map<String, dynamic>;
    expect(copiedJson['schema'], BuilderSharedSnapshot.schemaId);
    expect(copiedJson['id'], 'site-1');
    expect(copiedJson['components'], hasLength(1));
    expect(find.text('Shared snapshot copied (1 component)'), findsOneWidget);
  });

  testWidgets('screen copies static HTML to clipboard', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    String? copiedText;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiedText = (call.arguments as Map?)?['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    final controller = WebsiteBuilderController(projectName: 'Storefront');
    addTearDown(controller.dispose);
    controller.addComponent(websiteBuilderCatalog.byKey('hero')!);
    final buttonId = controller.addComponent(
      websiteBuilderCatalog.byKey('button')!,
    );
    controller.updateComponentProperty(buttonId, 'href', 'javascript:alert(1)');
    controller.updateComponentProperty(buttonId, 'label', '');
    controller.toggleComponentVisibility(buttonId);

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );
    await tester.tap(find.byTooltip('Copy HTML'));
    await tester.pump();

    expect(find.text('Copy HTML'), findsOneWidget);
    expect(find.text('Options'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('Include hidden components'), findsOneWidget);
    expect(find.text('1 hidden component will be skipped.'), findsOneWidget);

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    final initialPreview = tester.widget<SelectableText>(
      find.byKey(const ValueKey('website-builder-html-export-preview-source')),
    );

    expect(initialPreview.data, contains('<title>Storefront</title>'));
    expect(initialPreview.data, isNot(contains('Learn more')));

    await tester.tap(find.text('Options'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Document title'),
      'Campaign Page',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Language code'),
      'id',
    );
    await tester.tap(find.text('Include hidden components'));
    await tester.pump();

    expect(
      find.text('Unsafe link on Button will be replaced with #.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Button: Label is empty; exported action will use fallback copy.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    final updatedPreview = tester.widget<SelectableText>(
      find.byKey(const ValueKey('website-builder-html-export-preview-source')),
    );

    expect(updatedPreview.data, contains('<title>Campaign Page</title>'));
    expect(updatedPreview.data, contains('Button'));
    expect(updatedPreview.data, contains('href="#"'));
    expect(updatedPreview.data, isNot(contains('javascript:alert')));

    await tester.tap(find.widgetWithText(FilledButton, 'Copy'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(copiedText, contains('<!doctype html>'));
    expect(copiedText, contains('<html lang="id">'));
    expect(copiedText, contains('<title>Campaign Page</title>'));
    expect(copiedText, contains('Launch a better storefront'));
    expect(copiedText, contains('hidden'));
    expect(copiedText, contains('Button'));
    expect(copiedText, contains('href="#"'));
    expect(copiedText, isNot(contains('javascript:alert')));
    expect(find.text('Website HTML copied (2 components)'), findsOneWidget);
  });

  testWidgets('screen imports shared snapshot from clipboard', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    final clipboardText = jsonEncode(
      websiteBuilderLegacySharedSnapshotFixture.toJson(),
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') {
          return {'text': clipboardText};
        }
        return null;
      },
    );
    addTearDown(
      () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    final controller = WebsiteBuilderController();
    addTearDown(controller.dispose);
    addWebsiteBuilderTestComponent(controller, 'hero');

    await tester.pumpWidget(
      MaterialApp(home: WebsiteBuilderScreen(controller: controller)),
    );
    await tester.tap(find.byTooltip('Paste shared snapshot'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Import shared snapshot'), findsOneWidget);
    expect(find.text('Replace'), findsOneWidget);
    expect(find.text('Append'), findsOneWidget);
    expect(
      find.text('Replace will clear 1 component from the current canvas.'),
      findsOneWidget,
    );
    expect(find.text('Mapped kinds'), findsOneWidget);
    expect(find.text('image_holder to image'), findsOneWidget);
    expect(find.text('Unknown kinds'), findsOneWidget);
    expect(find.text('legacy_widget'), findsOneWidget);
    expect(find.text('Include unknown kinds'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Import'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Register Layout'), findsOneWidget);
    expect(
      find.text('Imported shared snapshot (2 components)'),
      findsOneWidget,
    );
    expect(find.text('Image'), findsWidgets);
  });
}

int _componentZIndex(WebsiteBuilderController controller, String id) {
  return websiteBuilderTestComponentZIndex(controller, id);
}

BuilderComponentGeometry _component(
  WebsiteBuilderController controller,
  String id,
) {
  return websiteBuilderTestComponent(controller, id);
}

Future<void> _sendControlShortcut(
  WidgetTester tester,
  LogicalKeyboardKey key,
) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pump();
}

Future<void> _sendControlShiftShortcut(
  WidgetTester tester,
  LogicalKeyboardKey key,
) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pump();
}

Future<void> _selectLayerFilter(WidgetTester tester, String label) async {
  final keySuffix = switch (label) {
    'All' => 'all',
    'Visible' => 'visible',
    'Hidden' => 'hidden',
    'Locked' => 'locked',
    'Has issues' => 'issues',
    _ => throw ArgumentError('Unknown layer filter: $label'),
  };
  await tester.tap(
    find.byKey(const ValueKey('website-builder-layers-filter-menu')),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.byKey(ValueKey('website-builder-layers-filter-$keySuffix')),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectIssueNavigation(WidgetTester tester, String label) async {
  await _selectContentIssueAction(tester, label);
}

Future<void> _selectContentIssueAction(
  WidgetTester tester,
  String label,
) async {
  final keySuffix = switch (label) {
    'Previous issue' => 'previous',
    'Next issue' => 'next',
    'Fix all issues' => 'fixAll',
    _ => throw ArgumentError('Unknown issue navigation action: $label'),
  };
  await tester.tap(
    find.byKey(const ValueKey('website-builder-layers-content-issues-menu')),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.byKey(ValueKey('website-builder-layers-content-action-$keySuffix')),
  );
  await tester.pumpAndSettle();
}
