import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/config.dart';

final layoutDataBindingProvider = FutureProvider<LayoutDataBindingValues>((
  ref,
) async {
  try {
    final source = await rootBundle.loadString(demoProfileAsset);
    final decoded = jsonDecode(source);
    if (decoded is! Map) return LayoutDataBindingValues.fallback();

    final values = <String, String>{};
    _flattenJson(Map<String, dynamic>.from(decoded), values);
    values.addAll(_derivedValues(values));

    return LayoutDataBindingValues(values);
  } catch (_) {
    return LayoutDataBindingValues.fallback();
  }
});

class LayoutDataBindingValues {
  final Map<String, String> values;

  const LayoutDataBindingValues(this.values);

  factory LayoutDataBindingValues.fallback() {
    return const LayoutDataBindingValues({
      'app.name': appName,
      'store.name': 'Kaysir Demo Outlet',
      'store.code': 'KDO-01',
      'store.terminal': 'POS-01',
      'store.currency': 'IDR',
      'shift.cashierName': 'Demo Cashier',
      'user.fullName': 'Demo Cashier',
      'user.firstName': 'Demo',
      'user.lastName': 'Cashier',
      'user.login': 'demo.admin',
      'user.role': 'admin',
      'cart.subtotal': 'Rp 124.000',
      'cart.tax': 'Rp 13.640',
      'cart.total': 'Rp 137.640',
      'cart.items.0.name': 'Americano',
      'cart.items.0.quantity': '2',
      'cart.items.0.total': 'Rp 48.000',
      'cart.items.1.name': 'Chicken Rice',
      'cart.items.1.quantity': '1',
      'cart.items.1.total': 'Rp 76.000',
      'products.0.name': 'Americano',
      'products.0.price': 'Rp 24.000',
      'products.1.name': 'Chicken Rice',
      'products.1.price': 'Rp 76.000',
      'products.2.name': 'Mineral Water',
      'products.2.price': 'Rp 8.000',
    });
  }

  List<LayoutProductPreview> get products {
    final products = <LayoutProductPreview>[];

    for (var index = 0; ; index++) {
      final name = values['products.$index.name'];
      if (name == null) break;

      products.add(
        LayoutProductPreview(
          name: name,
          price: values['products.$index.price'] ?? '',
        ),
      );
    }

    return products.isEmpty ? LayoutProductPreview.fallbackItems : products;
  }

  List<LayoutCartItemPreview> get cartItems {
    final items = <LayoutCartItemPreview>[];

    for (var index = 0; ; index++) {
      final name = values['cart.items.$index.name'];
      if (name == null) break;

      items.add(
        LayoutCartItemPreview(
          name: name,
          quantity: values['cart.items.$index.quantity'] ?? '1',
          total: values['cart.items.$index.total'] ?? '',
        ),
      );
    }

    return items.isEmpty ? LayoutCartItemPreview.fallbackItems : items;
  }

  String get cartSubtotal => values['cart.subtotal'] ?? '';

  String get cartTax => values['cart.tax'] ?? '';

  String get cartTotal => values['cart.total'] ?? 'Rp 137.640';

  String? valueFor(String key) => values[key];

  bool hasBinding(String key) => values.containsKey(key);

  List<LayoutBindingPreview> get bindingPreviews {
    final keys =
        values.keys.where(_isBindableKey).toList()..sort(_compareBindingKeys);

    return [
      for (final key in keys)
        LayoutBindingPreview(
          key: key,
          token: '{{$key}}',
          value: values[key] ?? '',
        ),
    ];
  }

  String resolve(String template) {
    return template.replaceAllMapped(RegExp(r'\{\{\s*([\w\.\-]+)\s*\}\}'), (
      match,
    ) {
      final key = match.group(1);
      if (key == null) return match.group(0) ?? '';
      return values[key] ?? match.group(0) ?? '';
    });
  }
}

class LayoutBindingPreview {
  final String key;
  final String token;
  final String value;

  const LayoutBindingPreview({
    required this.key,
    required this.token,
    required this.value,
  });
}

class LayoutProductPreview {
  final String name;
  final String price;

  const LayoutProductPreview({required this.name, required this.price});

  static const fallbackItems = [
    LayoutProductPreview(name: 'Americano', price: 'Rp 24.000'),
    LayoutProductPreview(name: 'Chicken Rice', price: 'Rp 76.000'),
    LayoutProductPreview(name: 'Mineral Water', price: 'Rp 8.000'),
  ];
}

class LayoutCartItemPreview {
  final String name;
  final String quantity;
  final String total;

  const LayoutCartItemPreview({
    required this.name,
    required this.quantity,
    required this.total,
  });

  static const fallbackItems = [
    LayoutCartItemPreview(name: 'Americano', quantity: '2', total: 'Rp 48.000'),
    LayoutCartItemPreview(
      name: 'Chicken Rice',
      quantity: '1',
      total: 'Rp 76.000',
    ),
  ];
}

void _flattenJson(
  Map<String, dynamic> source,
  Map<String, String> values, [
  String prefix = '',
]) {
  for (final entry in source.entries) {
    final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
    final value = entry.value;

    if (value == null) continue;

    if (value is Map) {
      _flattenJson(Map<String, dynamic>.from(value), values, key);
      continue;
    }

    if (value is List) {
      values[key] = value.join(', ');
      for (var index = 0; index < value.length; index++) {
        final item = value[index];
        if (item is Map) {
          _flattenJson(Map<String, dynamic>.from(item), values, '$key.$index');
        } else {
          values['$key.$index'] = '$item';
        }
      }
      continue;
    }

    values[key] = '$value';
  }
}

Map<String, String> _derivedValues(Map<String, String> values) {
  final firstName = values['user.firstName'];
  final lastName = values['user.lastName'];
  final derived = <String, String>{'app.name': appName};

  if (firstName != null || lastName != null) {
    derived['user.fullName'] = [
      if (firstName != null) firstName,
      if (lastName != null) lastName,
    ].join(' ');
  }

  return derived;
}

const _preferredBindingKeys = [
  'app.name',
  'store.name',
  'store.code',
  'store.terminal',
  'store.currency',
  'shift.cashierName',
  'shift.openedAt',
  'user.fullName',
  'user.login',
  'user.role',
  'user.email',
  'cart.subtotal',
  'cart.tax',
  'cart.total',
];

bool _isBindableKey(String key) {
  final lowerKey = key.toLowerCase();
  if (lowerKey.contains('token')) return false;

  if (_preferredBindingKeys.contains(key)) return true;
  if (RegExp(r'^products\.\d+\.(name|price)$').hasMatch(key)) return true;
  if (RegExp(r'^cart\.items\.\d+\.(name|quantity|total)$').hasMatch(key)) {
    return true;
  }

  return false;
}

int _compareBindingKeys(String left, String right) {
  final leftRank = _bindingRank(left);
  final rightRank = _bindingRank(right);
  if (leftRank != rightRank) return leftRank.compareTo(rightRank);
  return left.compareTo(right);
}

int _bindingRank(String key) {
  final preferredIndex = _preferredBindingKeys.indexOf(key);
  if (preferredIndex >= 0) return preferredIndex;
  if (key.startsWith('products.')) return 100 + _indexedBindingRank(key);
  if (key.startsWith('cart.items.')) return 200 + _indexedBindingRank(key);
  return 1000;
}

int _indexedBindingRank(String key) {
  final index =
      int.tryParse(
        key
            .split('.')
            .firstWhere(
              (part) => int.tryParse(part) != null,
              orElse: () => '0',
            ),
      ) ??
      0;
  final field = key.split('.').last;
  final fieldRank = switch (field) {
    'name' => 0,
    'price' => 1,
    'quantity' => 1,
    'total' => 2,
    _ => 9,
  };

  return (index * 10) + fieldRank;
}
