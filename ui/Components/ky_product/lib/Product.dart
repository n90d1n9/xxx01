import 'package:flutter/foundation.dart';

class Product {
  String? name, price, image;
  bool? userLiked;
  double? discount;

  Product({@required this.name,@required  this.price, this.discount,@required  this.image, this.userLiked});
}
