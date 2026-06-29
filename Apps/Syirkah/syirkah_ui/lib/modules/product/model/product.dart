import 'dart:convert';
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int? id;
  final String? name;
  final String? description;
  final String? sku;
  final String? image;
  final String? category;
  final String? price;
  final String? unit;
  final bool? isliked;
  final bool? isSelected;

  const Product({
    this.id,
    this.name,
    this.description,
    this.sku,
    this.image,
    this.category,
    this.price,
    this.unit,
    this.isliked,
    this.isSelected,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        sku: json['sku'],
        image: json['image'],
        category: json['category'],
        price: json['price'],
        unit: json['unit'],
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
      };

  static List<Product> listFromString(String str) =>
      List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

  static List<Product> listFromJson(List<dynamic> data) {
    return data.map((post) => Product.fromJson(post)).toList();
  }

  static String listProductToJson(List<Product> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

  @override
  List<Object> get props => [
        id!,
        name!,
        description!,
        sku!,
        image!,
        category!,
        price!,
        unit!,
      ];
}

class ProductList {
  final List<Product>? products;

  ProductList({
    this.products,
  });

  factory ProductList.fromJson(List<dynamic> json) {
    List<Product> products = [];
    products = json.map((post) => Product.fromJson(post)).toList();

    return ProductList(
      products: products,
    );
  }
}
