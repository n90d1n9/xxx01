import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_catalog_quality.dart';
import 'package:kaysir/features/product/models/product_catalog_quality_panel_state.dart';

void main() {
  test('catalog quality panel state describes empty catalogs', () {
    final viewState = ProductCatalogQualityPanelViewState.fromSummary(
      const ProductCatalogQualitySummary(
        productCount: 0,
        completeProductCount: 0,
        issueProductCount: 0,
        totalIssueCount: 0,
        issues: [],
      ),
    );

    expect(viewState.title, 'Catalog quality');
    expect(viewState.subtitle, '0/0 ready, no products to review');
    expect(viewState.completionLabel, '0% complete');
    expect(viewState.progressValue, 0);
    expect(viewState.isEmpty, isTrue);
  });

  test('catalog quality panel state describes ready catalogs', () {
    final viewState = ProductCatalogQualityPanelViewState.fromSummary(
      const ProductCatalogQualitySummary(
        productCount: 3,
        completeProductCount: 3,
        issueProductCount: 0,
        totalIssueCount: 0,
        issues: [],
      ),
    );

    expect(viewState.subtitle, '3/3 ready, all products ready');
    expect(viewState.completionLabel, '100% complete');
    expect(viewState.progressValue, 1);
    expect(viewState.isEmpty, isFalse);
  });

  test('catalog quality panel state describes singular setup work', () {
    final viewState = ProductCatalogQualityPanelViewState.fromSummary(
      const ProductCatalogQualitySummary(
        productCount: 2,
        completeProductCount: 1,
        issueProductCount: 1,
        totalIssueCount: 2,
        issues: [],
      ),
    );

    expect(viewState.subtitle, '1/2 ready, 1 product needs setup');
    expect(viewState.completionLabel, '50% complete');
    expect(viewState.progressValue, 0.5);
  });

  test('catalog quality panel state describes plural setup work', () {
    final viewState = ProductCatalogQualityPanelViewState.fromSummary(
      const ProductCatalogQualitySummary(
        productCount: 4,
        completeProductCount: 1,
        issueProductCount: 3,
        totalIssueCount: 6,
        issues: [],
      ),
    );

    expect(viewState.subtitle, '1/4 ready, 3 products need setup');
    expect(viewState.completionLabel, '25% complete');
    expect(viewState.progressValue, 0.25);
  });
}
