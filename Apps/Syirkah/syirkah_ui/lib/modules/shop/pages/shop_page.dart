import 'package:flutter/material.dart';
import 'package:syirkah/modules/shop/models/grid_item.dart';
import 'package:syirkah/modules/shop/widgets/home_widget.dart';

import '../shop_module.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  @override
  Widget build(BuildContext context) {
    List<GridItem> items = [
      GridItem(
          id: 1,
          title: 'Toko',
          path: ShopModule.shop,
          imagePath: 'assets/icons/toko.png'),
      GridItem(
          id: 2,
          title: 'Kasir',
          path: '/pos',
          imagePath: 'assets/icons/kasir.png'),
      GridItem(
          id: 3,
          title: 'Akuntasi',
          path: '',
          imagePath: 'assets/icons/akuntansi.png'),
      GridItem(
          id: 1,
          title: 'Toko',
          path: ShopModule.shop,
          imagePath: 'assets/icons/toko.png'),
      GridItem(
          id: 2,
          title: 'Kasir',
          path: '/pos',
          imagePath: 'assets/icons/kasir.png'),
    ];
    return Material(child: HomeWidget(items: items));
  }
}
