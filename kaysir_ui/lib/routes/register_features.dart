import 'package:kaysir/features/finance/accounting/accounting_features.dart';
import 'package:kaysir/features/finance/billing/billing_features.dart';
import 'package:kaysir/features/hris/hris_features.dart';
import 'package:kaysir/features/inventory/inventory_features.dart';
import 'package:kaysir/features/restaurant/restaurant_features.dart';

import 'package:kaysir/features/product/product_feature.dart';

import '../core/features/features_base.dart';

List<FeaturesBase> registerFeatures() {
  return [
    AccountingFeatures(),
    BillingFeatures(),
    HrisFeatures(),
    InventoryFeatures(),
    ProductFeature(),
    RestaurantFeatures(),
  ];
}
