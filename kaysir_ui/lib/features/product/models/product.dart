import 'dart:convert';

import 'package:uuid/uuid.dart';

class Product {
  final String id;
  final String name;
  final String? description;
  final String? sku;
  final String? image;
  final String? category;
  final double price;
  final String? unit;
  final bool? isliked;
  final bool? isSelected;
  final String? barcode;
  final int? stockQuantity;
  final String shortcutKey;
  final int? quantity;
  final int? actualStock;
  final int currentStock;
  final int systemStock;
  final String? notes;
  final DateTime? lastChecked;
  final Map<String, String> customAttributes;

  Product({
    String? id,
    required this.name,
    this.description,
    this.sku,
    this.image,
    this.category,
    this.price = 0,
    this.unit,
    this.isliked,
    this.isSelected,
    this.barcode,
    this.stockQuantity,
    this.shortcutKey = '',
    this.quantity = 1,
    this.actualStock,
    this.currentStock = 0,
    this.systemStock = 0,
    this.notes,
    this.lastChecked,
    Map<String, String> customAttributes = const {},
  }) : id = id ?? const Uuid().v4(),
       customAttributes = Map.unmodifiable(customAttributes);

  double get total => price * (quantity ?? 0);
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id']?.toString(),
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString(),
    sku: json['sku']?.toString(),
    image: json['image']?.toString(),
    category: json['category']?.toString(),
    price: _doubleFromJson(json['price']),
    unit: json['unit']?.toString(),
    quantity: _intFromJson(json['quantity']) ?? 1,
    barcode: json['barcode']?.toString(),
    stockQuantity: _intFromJson(json['stockQuantity']),
    actualStock: _intFromJson(json['actualStock']),
    currentStock: _intFromJson(json['currentStock']) ?? 0,
    systemStock: _intFromJson(json['systemStock']) ?? 0,
    customAttributes: _customAttributesFromJson(
      json['customAttributes'] ?? json['attributes'],
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "sku": sku,
    "image": image,
    "category": category,
    "price": price,
    "unit": unit,
    "quantity": quantity,
    "customAttributes": customAttributes,
  };

  static List<Product> listFromString(String str) =>
      List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

  static List<Product> listFromJson(List<dynamic> data) {
    return data.map((post) => Product.fromJson(post)).toList();
  }

  static String listProductToJson(List<Product> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? sku,
    String? image,
    String? category,
    double? price,
    String? unit,
    bool? isliked,
    bool? isSelected,
    String? barcode,
    int? stockQuantity,
    String? shortcutKey,
    int? quantity,
    int? actualStock,
    int? currentStock,
    int? systemStock,
    String? notes,
    DateTime? lastChecked,
    Map<String, String>? customAttributes,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      image: image ?? this.image,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      isliked: isliked ?? this.isliked,
      isSelected: isSelected ?? this.isSelected,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      shortcutKey: shortcutKey ?? this.shortcutKey,
      quantity: quantity ?? this.quantity,
      actualStock: actualStock ?? this.actualStock,
      currentStock: currentStock ?? this.currentStock,
      systemStock: systemStock ?? this.systemStock,
      notes: notes ?? this.notes,
      lastChecked: lastChecked ?? this.lastChecked,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }
}

Map<String, String> _customAttributesFromJson(Object? value) {
  if (value is! Map) return const {};

  return Map.unmodifiable({
    for (final entry in value.entries)
      if (entry.key != null && entry.value != null)
        entry.key.toString(): entry.value.toString(),
  });
}

double _doubleFromJson(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;

  return 0;
}

int? _intFromJson(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());

  return null;
}

class ProductList {
  final List<Product>? products;

  ProductList({this.products});

  factory ProductList.fromJson(List<dynamic> json) {
    List<Product> products = [];
    products = json.map((post) => Product.fromJson(post)).toList();

    return ProductList(products: products);
  }
}
