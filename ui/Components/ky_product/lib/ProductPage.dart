import 'package:flutter/material.dart';
import 'package:kays_rating/kays_rating.dart';
import 'Product.dart';



import 'product_item.dart';

class ProductPage extends StatefulWidget {
  final String? pageTitle;
  final Product? productData;
  final Color? bgColor;
  final Color? darkText;
  final TextStyle? appBarStyle;

  ProductPage({Key? key, this.pageTitle, @required this.productData, this.bgColor, this.darkText, this.appBarStyle}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  double _rating = 4;
  int _quantity = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: widget.bgColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: widget.bgColor,
          centerTitle: true,
          leading: BackButton(
            color: widget.darkText,
          ),
          title: Text(widget.productData!.name!, style: widget.appBarStyle),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Center(
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                      margin: EdgeInsets.only(top: 100, bottom: 100),
                      padding: EdgeInsets.only(top: 100, bottom: 50),
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(widget.productData!.name!, style: widget.appBarStyle),
                          Text(widget.productData!.price!, style: widget.appBarStyle),
                          Container(
                            margin: EdgeInsets.only(top: 5, bottom: 20),
                            child: Rating(
                              //direction: Axis.vertical,
                              onRate: (v) {
                                setState(() {
                                  _rating = v;
                                });
                                print(v);
                              },
                    
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10, bottom: 25),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Text('Quantity'),
                                  margin: EdgeInsets.only(bottom: 15),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 55,
                                      height: 55,
                                      child: OutlineButton(
                                        onPressed: () {
                                          setState(() {
                                            _quantity += 1;
                                          });
                                        },
                                        child: Icon(Icons.add),
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 20, right: 20),
                                      child: Text(_quantity.toString()),
                                    ),
                                    Container(
                                      width: 55,
                                      height: 55,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                           if(_quantity == 1) return;
                                             _quantity -= 1; 
                                          });
                                        },
                                        child: Icon(Icons.remove),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: 180,
                            child: OutlinedButton(child:Text('Buy Now'), onPressed:() {}),
                          ),
                          Container(
                            width: 180,
                            child: TextButton(child:Text('Add to Cart'), onPressed:() {}),
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 15,
                                spreadRadius: 5,
                                color: Color.fromRGBO(0, 0, 0, .05))
                          ]),
                    ),
                    ),
                    Align(
                        alignment: Alignment.center,
                      child: SizedBox(
                        width: 200,
                        height: 160,
                        child: ProductItem(product:widget.productData,
                           isProductPage: true,
                            onTapped: () {},
                            imgWidth: 250,
                            onLike: () {}),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
