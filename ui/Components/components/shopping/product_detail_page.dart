import 'dart:async';

import 'package:all_in_apps/model/product.dart';
import 'package:all_in_apps/widgets/login_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uikit/inherited/product_provider.dart';

import 'shopping_two/product_detail_widgets.dart';


class ProductDetailPage extends StatelessWidget {
  var productBloc;

  Widget productScaffold(Stream<List<Product>> products) => new Scaffold(
      backgroundColor: new Color(0xffeeeeee),
      body: StreamBuilder<List<Product>>(
          stream: products,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      LoginBackground(
                        showIcon: false,
                      ),
                      ProductDetailWidgets(product:snapshot.data[0]),
                    ],
                  )
                : Center(child: CircularProgressIndicator());
          }));
  @override
  Widget build(BuildContext context) {
    return ProductProvider(
        productBloc: productBloc,
        child: productScaffold(productBloc.productItems));
  }
}
