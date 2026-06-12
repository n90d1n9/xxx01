import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_touch_layout_profiles.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_touch_layout_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_touch_layout_profile_catalog.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';

void main() {
  test('default touch layout profile catalog validates cleanly', () {
    expect(defaultPOSTouchLayoutProfileCatalog.validate(), isEmpty);
    expect(defaultPOSTouchLayoutProfileCatalog.throwIfInvalid, returnsNormally);
    expect(
      defaultPOSTouchLayoutProfileCatalog.profileIds,
      containsAll([
        'core_counter_touch',
        'grocery_scanner_touch',
        'coffee_counter_touch',
        'restaurant_service_touch',
        'retail_assisted_touch',
        'kiosk_self_service_touch',
      ]),
    );
  });

  test('touch layout catalog resolves fallback profile details', () {
    final resolution = defaultPOSTouchLayoutProfileCatalog.resolveDetailed(
      'missing_profile',
    );

    expect(resolution.usedFallback, isTrue);
    expect(resolution.profile.id, 'core_counter_touch');
    expect(resolution.fallbackReason, contains('not registered'));
  });

  test('touch layout catalog recommends product-line specific profiles', () {
    final grocery = defaultPOSTouchLayoutProfileCatalog.recommendFor(
      productLine: 'Grocery',
      formFactor: POSExperienceFormFactor.desktop,
      preferredLayout: POSLayoutPreference.counter,
      traits: ['scanner-first', 'fresh-goods'],
    );
    final kiosk = defaultPOSTouchLayoutProfileCatalog.recommendFor(
      productLine: 'Kiosk',
      formFactor: POSExperienceFormFactor.kiosk,
      preferredLayout: POSLayoutPreference.checkout,
      traits: ['self-service', 'large-touch'],
    );

    expect(grocery.id, 'grocery_scanner_touch');
    expect(kiosk.id, 'kiosk_self_service_touch');
  });

  test('touch layout profile filters visible quick buttons by context', () {
    final grocery = defaultPOSTouchLayoutProfileCatalog.profileForId(
      'grocery_scanner_touch',
    );

    final buttons = grocery.visibleButtonsFor(
      surface: POSQuickButtonSurface.primaryGrid,
      formFactor: POSExperienceFormFactor.tablet,
      layoutPreference: POSLayoutPreference.counter,
    );

    expect(buttons.map((button) => button.id), contains('grocery_weigh_item'));
    expect(buttons.map((button) => button.id), contains('grocery_markdown'));
  });

  test('touch layout catalog reports invalid profile metadata', () {
    const brokenButton = POSQuickButton(
      id: '',
      label: '',
      description: 'Broken button.',
      intent: POSQuickButtonIntent.product(''),
      surface: POSQuickButtonSurface.primaryGrid,
    );
    const duplicatedButton = POSQuickButton(
      id: 'dup_button',
      label: 'Duplicate',
      description: 'Duplicate button.',
      intent: POSQuickButtonIntent.category('duplicate'),
      surface: POSQuickButtonSurface.primaryGrid,
    );
    const brokenProfile = POSTouchLayoutProfile(
      id: '',
      label: '',
      description: '',
      productLine: 'Broken',
      preferredLayout: POSLayoutPreference.auto,
      density: POSTouchLayoutDensity.compact,
      orderPanelPlacement: POSTouchOrderPanelPlacement.right,
      catalogEmphasis: POSTouchCatalogEmphasis.categoryFirst,
      groups: [
        POSQuickButtonGroup(
          id: '',
          label: '',
          description: 'Broken group.',
          surface: POSQuickButtonSurface.primaryGrid,
          buttons: [brokenButton, duplicatedButton, duplicatedButton],
        ),
      ],
    );
    const catalog = POSTouchLayoutProfileCatalog(
      defaultProfileId: 'missing',
      profiles: [brokenProfile, brokenProfile],
    );

    final issueTypes = catalog.validate().map((issue) => issue.type);

    expect(
      issueTypes,
      containsAll([
        POSTouchLayoutProfileCatalogIssueType.missingDefaultProfile,
        POSTouchLayoutProfileCatalogIssueType.blankProfileId,
        POSTouchLayoutProfileCatalogIssueType.blankProfileLabel,
        POSTouchLayoutProfileCatalogIssueType.blankProfileDescription,
        POSTouchLayoutProfileCatalogIssueType.blankGroupId,
        POSTouchLayoutProfileCatalogIssueType.blankGroupLabel,
        POSTouchLayoutProfileCatalogIssueType.blankButtonId,
        POSTouchLayoutProfileCatalogIssueType.blankButtonLabel,
        POSTouchLayoutProfileCatalogIssueType.duplicateButtonId,
        POSTouchLayoutProfileCatalogIssueType.incompleteButtonIntent,
      ]),
    );
    expect(catalog.throwIfInvalid, throwsStateError);
  });
}
