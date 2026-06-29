import 'package:flutter/material.dart';
import 'package:kayys_components/components/checkout/btn_add_plus.dart';
import 'package:kayys_components/utils/helper.dart';

import '../text/wrap_text.dart';

class ProductItemController extends ChangeNotifier {
  int totalItem = 0;
  bool isChecked = false;

  addItem(int value) {
    totalItem += value;
    notifyListeners();
  }

  removeItem(int value) {
    if (totalItem != 0) {
      totalItem -= 1;
    }
    notifyListeners();
  }

  checkItem(bool check) {
    isChecked = check;
    notifyListeners();
  }
}

class ProductItem extends StatefulWidget {
  final String? imageURL;
  final String? title;
  final String? descripton;
  final double? price;
  final int totalItem;
  final Function() onPressedMinus;
  final Function() onPressedPlus;
  final Function() onPressedFavorite;
  final Function() onPressedComment;
  final Color favoriteColor;
  final Function(bool?) onChangedCheck;
  final bool isChecked;
  final ProductItemController controller;

  const ProductItem({
    super.key,
    this.title,
    required this.imageURL,
    required this.descripton,
    required this.price,
    this.totalItem = 0,
    required this.onPressedMinus,
    required this.onPressedPlus,
    required this.onPressedFavorite,
    required this.onPressedComment,
    this.favoriteColor = Colors.black12,
    required this.onChangedCheck,
    required this.isChecked,
    required this.controller,
  });

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  int totalItem = 0;
  bool isChecked = false;
  @override
  void initState() {
    widget.controller.addListener(() {
      setState(() {
        totalItem = widget.controller.totalItem;
        isChecked = widget.controller.isChecked;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    totalItem = widget.totalItem;
    isChecked = widget.isChecked;
    return SizedBox(
        height: 130,
        child: Row(children: [
          productCheck(),
          FutureBuilder<Widget>(
              future:
                  productImage(), // a previously-obtained Future<String> or null
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return Image.asset('assets/bag_1.png');
              }),
          productDescription()
        ]));
  }

  Future<Widget> productImage() async {
    Widget image; 
    if (await hasInternet()) {
      image = Image.network(
        widget.imageURL!,
        width: 80,
        height: 80,
      );
    } else {
      image = Image.asset('assets/bag_1.png');
    }
    return image;
  }

  productCheck() => Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
      child: Checkbox(
        value: isChecked,
        onChanged: widget.onChangedCheck,
      ));

  productDescription() => Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          WrapLongText(widget.descripton!), // maxLinesToShow: 1,),
          const SizedBox(height: 4),
          Text(
            numberFormatCurrency(widget.price!),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: widget.onPressedFavorite,
                icon: const Icon(Icons.favorite),
                color: widget.favoriteColor,
              ),
              IconButton(
                onPressed: widget.onPressedComment,
                icon: const Icon(Icons.comment_rounded),
              ),
              const Spacer(
                flex: 2,
              ),
              PlusMinusButton(
                value: totalItem,
                onPressedMinus: widget.onPressedMinus,
                onPressedPlus: widget.onPressedPlus,
              )
            ],
          )
        ],
      ));
}
