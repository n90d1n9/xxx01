import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_field_group.dart';
import 'package:kaysir/features/product/models/management_pack_field_group_progress.dart';
import 'package:kaysir/features/product/models/product_editor_section_navigator_view_state.dart';
import 'package:kaysir/features/product/models/product_form_section.dart';
import 'package:kaysir/features/product/models/product_form_section_progress.dart';

void main() {
  test('product editor section navigator mixes sections and pack groups', () {
    final overview = _overview();
    final progress = _progressFor(overview, const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'description': 'Leafy greens',
    });
    final viewState = ProductEditorSectionNavigatorViewState.from(
      progress: progress,
      groupProgress: _groupProgressFor(const {
        'name': 'Spinach',
        'sku': 'SP-001',
        'category': 'Fresh',
        'description': 'Leafy greens',
      }),
    );

    expect(viewState.items, hasLength(8));
    expect(viewState.statusLabel, '4 required missing');
    expect(viewState.isReady, isFalse);

    final identity = viewState.items[0];
    expect(identity.title, 'Identity');
    expect(identity.statusLabel, 'Ready');
    expect(identity.progressLabel, '4/4 required');
    expect(identity.canLaunch, isTrue);
    expect(identity.canReview, isFalse);
    expect(identity.actionLabel, 'Open');
    expect(identity.primaryAttribute?.id, 'name');

    final commercial = viewState.items[1];
    expect(commercial.title, 'Commercial');
    expect(commercial.statusLabel, '2 missing required');
    expect(commercial.progressLabel, '0/2 required');
    expect(commercial.canLaunch, isTrue);
    expect(commercial.actionLabel, 'Review Price');
    expect(commercial.primaryAttribute?.id, 'price');
    expect(commercial.reviewLabel, 'Review Price');
    expect(commercial.nextMissingAttribute?.fieldId, 'price');

    final expiry = viewState.items.firstWhere(
      (item) => item.title == 'Expiry tracking',
    );
    expect(expiry.statusLabel, '1 missing required');
    expect(expiry.reviewLabel, 'Review Expiry date');
    expect(expiry.nextMissingAttribute?.fieldId, 'expiry_date');
  });

  test('product editor section navigator reports ready state', () {
    final overview = _overview();
    final progress = _progressFor(overview, const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'price': '12',
      'initial_stock': '8',
      'description': 'Leafy greens',
      'expiry_date': '2026-07-01',
      'batch_number': 'B-01',
    });
    final viewState = ProductEditorSectionNavigatorViewState.from(
      progress: progress,
      groupProgress: _groupProgressFor(const {
        'expiry_date': '2026-07-01',
        'batch_number': 'B-01',
      }),
    );

    expect(viewState.statusLabel, 'All ready');
    expect(viewState.isReady, isTrue);
    expect(viewState.items.where((item) => item.canReview), isEmpty);
    expect(viewState.items.every((item) => item.canLaunch), isTrue);
  });

  test('product editor section navigator reviews invalid pack groups', () {
    final overview = _overview();
    final progress = _progressFor(overview, const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh',
      'price': '12',
      'initial_stock': '8',
      'description': 'Leafy greens',
      'expiry_date': 'soon',
      'batch_number': 'B-01',
    });
    final viewState = ProductEditorSectionNavigatorViewState.from(
      progress: progress,
      groupProgress: _groupProgressFor(const {
        'expiry_date': 'soon',
        'batch_number': 'B-01',
      }),
    );

    expect(viewState.statusLabel, '1 invalid');
    expect(viewState.isReady, isFalse);

    final expiry = viewState.items.firstWhere(
      (item) => item.title == 'Expiry tracking',
    );
    expect(expiry.statusLabel, '1 invalid');
    expect(expiry.canReview, isTrue);
    expect(expiry.actionLabel, 'Review Expiry date');
    expect(expiry.nextMissingAttribute, isNull);
    expect(expiry.reviewAttribute?.fieldId, 'expiry_date');
    expect(expiry.primaryAttribute?.id, 'expiry_date');
  });
}

ProductFormSectionOverview _overview() {
  return buildProductFormSectionOverview(
    pack: groceryFreshGoodsProductManagementPack,
    isEditing: false,
  );
}

ProductFormSectionProgressOverview _progressFor(
  ProductFormSectionOverview overview,
  Map<String, String> values,
) {
  return buildProductFormSectionProgressOverview(
    overview: overview,
    values: values,
  );
}

ProductManagementPackFieldGroupProgressOverview _groupProgressFor(
  Map<String, String> values,
) {
  return buildProductManagementPackFieldGroupProgressOverview(
    groups: buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    ),
    values: values,
  );
}
