// ignore_for_file: unused_local_variable, avoid_print

import 'package:flutter/material.dart';

import '../widgets/cart_item.dart';
import '../widgets/product_item.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, this.title = ''});

  final String title;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late CartModel cartChecked = cartdata;
  
  int totalChecked = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '${cartChecked.getTotalProduct} produk terpilih',
        ),
        const SizedBox(height: 16),
        ...items(cartChecked)
      ],
    ));
  }

  List<Widget> items(CartModel cart) {
    List<Widget> list = [];
    CartItemController cartController = CartItemController();
    // put cart by store
    StoreModel newStore;
    for (var store in cart.stores) {
      newStore = StoreModel(id: store.id);
      // Put product to cart items
      List<Widget> proditems = [];
      ProductModel newProduct;
      for (var item in store.products!) {
        ProductItemController productController = ProductItemController();
         
        proditems.add(ProductItem(
          title: item.title,
          isChecked: item.isChecked,
          totalItem: item.totalItem,
          imageURL: item.imageURL!,
          descripton: item.descripton!,
          favoriteColor: item.isInWhishlist
              ? const Color.fromARGB(255, 249, 112, 102)
              : Colors.black12,
          price: item.price!,
          onPressedMinus: () {
            productController.removeItem(1);
            setState(() {
              if (item.totalItem != 0) {
                item.totalItem = item.totalItem - 1;
              }
              
            });
            
            /* print(productController.isChecked);
            print(productController.totalItem); */
          },
          onPressedPlus: () {
            productController.addItem(1);
            setState(() {
              item.totalItem = item.totalItem + 1;
              
            });
          },
          onPressedFavorite: () {
            setState(() {
              item.isInWhishlist = item.isInWhishlist ? false : true;
            });
          },
          onPressedComment: () {
            //print('bukan komen');
          },
          onChangedCheck: (value) {
            setState(() {
              item.isChecked = item.isChecked ? false : true;

              if (item.isChecked) {
                totalChecked -= 1;
              } else if (totalChecked == 0) {
                store.isStoreChecked = false;
              } else {
                totalChecked += 1;
              }
            });

            print(cartChecked.toString());
            print(productController.isChecked);
          },
          controller: productController,
        ));

        //newProduct = item;
        //newStore.products = [...ProductModel(id: 20)];
      }

      list.add(CartItem(
        storeName: store.storeName!,
        isStoreChecked: store.isStoreChecked,
        productsItem: proditems,
        onChangedStoreCheck: (value) {
          setState(() {
            store.isStoreChecked = store.isStoreChecked ? false : true;

            if (store.isStoreChecked) {
              for (var str in store.products!) {
                str.isChecked = true;
              }
            } else {
              for (var str in store.products!) {
                str.isChecked = false;
              }
            }
          });
        },
        controller: cartController,
      ));
    }
    return list;
  }
}

class CartModel {
  final double? id;
  int totalProduct;
  double totalAmount;
  List<StoreModel> stores;

  CartModel(
      {this.id,
      this.totalProduct = 0,
      this.totalAmount = 0.0,
      required this.stores});

  get getTotalProduct {
    for (var el in stores) {
      totalProduct += el.totalChecked;
      print(el.totalChecked);
    }
    return totalProduct;
  }

  get getTotalAmount {
    for (var el in stores) {
      totalAmount += el.totalAmount;
    }
    return totalAmount;
  }

  @override
  String toString() {
    return 'totalProduct: $totalProduct, totalAmount: $totalAmount, stores: $stores';
  }
}

class StoreModel {
  final double id;
  final String? storeName;
  int totalItems;
  double totalAmount;
  bool isStoreChecked;
  int totalChecked;
  List<ProductModel>? products;

  StoreModel(
      { required this.id,
       this.storeName,
      this.totalItems = 0,
      this.totalAmount = 0,
      this.totalChecked = 0,
      this.isStoreChecked = false,
      this.products});

  @override
  String toString() => 'storeName: $storeName, products: $products';
}

class ProductModel {
  final double? id;
  final String? title;
  final double? price;
  final String? imageURL;
  final String? descripton;
  bool isInWhishlist;
  bool isChecked;
  int totalItem;

  ProductModel(
      {required this.id,
      this.isInWhishlist = false,
      this.title,
      this.price,
      this.imageURL,
      this.totalItem = 0,
      this.descripton,
      this.isChecked = false});
 @override
  String toString() => 'id: $id, title: $title, price: $price, totalItem: $totalItem, isChecked: $isChecked';
  
}

var _products1 = [
  ProductModel(
      id: 1,
      isChecked: false,
      isInWhishlist: false,
      imageURL:
          'https://static.bmdstatic.com/pk/product/medium/60a22c7d9e063.jpg',
      descripton: '1 Ini adalah deskripsi dari produk yang ada di cart',
      totalItem: 3,
      title: '1 Laptop yang mahal',
      price: 97777)
];
var _products2 = [
  ProductModel(
      id: 2,
      isChecked: true,
      isInWhishlist: false,
      imageURL:
          'https://static.bmdstatic.com/pk/product/medium/60a22c7d9e063.jpg',
      descripton: '2 Ini adalah deskripsi dari produk yang ada di cart',
      totalItem: 2,
      title: '02 Laptop yang mahal buanget',
      price: 1000),
  ProductModel(
      id: 3,
      isChecked: false,
      isInWhishlist: true,
      imageURL:
          'https://static.bmdstatic.com/pk/product/medium/60a22c7d9e063.jpg',
      descripton: '3 Ini adalah deskripsi dari produk yang ada di cart',
      totalItem: 5,
      title: '3 Laptop yang mahal sekali',
      price: 5656)
];
var _products3 = [
  ProductModel(
      id: 4,
      isChecked: false,
      isInWhishlist: false,
      imageURL:
          'https://static.bmdstatic.com/pk/product/medium/60a22c7d9e063.jpg',
      descripton: '4 Ini adalah deskripsi dari produk yang ada di cart',
      totalItem: 2,
      title: '4 Laptop yang mahal buanget',
      price: 1000),
  ProductModel(
      id: 5,
      isChecked: false,
      isInWhishlist: true,
      imageURL:
          'https://static.bmdstatic.com/pk/product/medium/60a22c7d9e063.jpg',
      descripton: '5 Ini adalah deskripsi dari produk yang ada di cart',
      totalItem: 5,
      title: '5 Laptop yang mahal sekali',
      price: 5656)
];

var cartdata = CartModel(stores: [
  StoreModel(id: 11, storeName: 'Berani jaya', products: _products1),
  StoreModel(id: 12, storeName: 'Gunajaya', products: _products2),
  StoreModel(id: 13, storeName: 'Suryajaya', products: _products3)
]);
