import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/utils/helper.dart';

void main() {
  test('getIconData falls back for unknown icon keys', () {
    expect(getIconData('missing-icon'), Icons.circle_outlined);
  });

  test('getIconData exposes profile menu icons', () {
    expect(getIconData('person'), Icons.person_outline);
    expect(getIconData('logout'), Icons.logout);
  });

  test('getIconData exposes commerce menu icons', () {
    expect(getIconData('commerce'), Icons.hub_rounded);
    expect(getIconData('commerce-profiles'), Icons.tune_rounded);
    expect(getIconData('ecommerce-pos'), Icons.point_of_sale_rounded);
    expect(getIconData('ecommerce-orders'), Icons.receipt_long_rounded);
    expect(getIconData('marketplace-orders'), Icons.storefront_rounded);
    expect(getIconData('delivery-orders'), Icons.local_shipping_rounded);
    expect(getIconData('wholesale-orders'), Icons.warehouse_rounded);
  });

  test('getIconData exposes restaurant menu icons', () {
    expect(getIconData('restaurant'), Icons.restaurant_rounded);
    expect(getIconData('restaurant-floor'), Icons.table_restaurant_rounded);
    expect(getIconData('restaurant-menu'), Icons.restaurant_menu_rounded);
    expect(getIconData('restaurant-kitchen'), Icons.soup_kitchen_rounded);
  });
}
