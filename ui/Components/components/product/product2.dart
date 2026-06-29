import 'package:flutter/material.dart';
import 'package:kays_product/Product.dart';
import 'package:kays_product/ProductPage.dart' as p;

class ProductPage extends StatelessWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var productData=Product(name: 'ini product', 
    discount: 20, userLiked: true,
    price: '20000', image: 'images/1001.jpg');

    return p.ProductPage(productData: productData);
  }
}