import 'dart:async';

import 'package:all_in_apps/model/product.dart';
import 'package:all_in_apps/widgets/common_scaffold.dart';
import 'package:all_in_apps/widgets/login_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uikit/inherited/product_provider.dart';

import 'shopping_details/shopping_widget.dart';


class ShoppingDetailsPage extends StatelessWidget {
  final _scaffoldState = GlobalKey<ScaffoldState>();

  Stream<List<Product>> productItems;

  var productBloc;

  Widget bodyData(Stream<List<Product>> products) =>
      StreamBuilder<List<Product>>(
          stream: products,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      LoginBackground(
                        showIcon: false,
                        image: snapshot.data[0].image,
                      ),
                      ShoppingWidgets(product: snapshot.data[0]),
                    ],
                  )
                : Center(child: CircularProgressIndicator());
          });

  @override
  Widget build(BuildContext context) {
  
    return ProductProvider(
      productBloc: productBloc,
      child: CommonScaffold(
        backGroundColor: Colors.grey.shade100,
        actionFirstIcon: null,
        appTitle: "Product Detail",
        showFAB: true,
        scaffoldKey: _scaffoldState,
        showDrawer: false,
        centerDocked: true,
        floatingIcon: Icons.add_shopping_cart,
        bodyData: bodyData(productItems),
        showBottomNav: true,
      ),
    );
  }
}
