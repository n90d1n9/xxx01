import 'package:flutter/material.dart';

import 'Product.dart';

class ProductItem extends StatelessWidget {
  final Product? product;
  final double? imgWidth;
  final VoidCallback? onLike;
  final VoidCallback? onTapped;
  final bool? isProductPage;
  const ProductItem(
      {Key? key, this.product, this.imgWidth, this.onLike, this.onTapped, this.isProductPage=false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      // color: Colors.red,
      margin: EdgeInsets.only(left: 20),
      child: Stack(
        children: <Widget>[
          Container(
              width: 180,
              height: 180,
              child: ElevatedButton(
                  onPressed: onTapped,
                  child: Hero(
                      transitionOnUserGestures: true,
                      tag: product!.name!,
                      child: Image.asset(product!.image!,
                          width: (imgWidth != null) ? imgWidth : 100)))),
          Positioned(
            bottom: (isProductPage!) ? 10 : 70,
            right: 0,
            child: FlatButton(
              padding: EdgeInsets.all(20),
              shape: CircleBorder(),
              onPressed: onLike,
              child: Icon(
                (product!.userLiked!) ? Icons.favorite : Icons.favorite_border,
                size: 30,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: (isProductPage! )
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        product!.name!,
                      ),
                      Text(
                        product!.price!,
                      ),
                    ],
                  )
                : Text(' '),
          ),
          Positioned(
              top: 10,
              left: 10,
              child: (product!.discount != null)
                  ? Container(
                      padding: EdgeInsets.only(
                          top: 5, left: 10, right: 10, bottom: 5),
                      decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(50)),
                      child: Text('-' + product!.discount.toString() + '%',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    )
                  : SizedBox(width: 0))
        ],
      ),
    );
  }
}
