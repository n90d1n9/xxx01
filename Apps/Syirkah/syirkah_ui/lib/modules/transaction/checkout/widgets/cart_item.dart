import 'package:flutter/material.dart';

class CartItemController extends ChangeNotifier {
  bool isStoreChecked = false;

  checkItem(bool check) {
    isStoreChecked = check;
    notifyListeners();
  }
}

class CartItem extends StatefulWidget {
  final String storeName;
  final List<Widget>? productsItem;
  final Function(bool?) onChangedStoreCheck;
  final bool isStoreChecked;
  final CartItemController controller;
  const CartItem(
      {super.key,
      required this.storeName,
      this.productsItem,
      required this.isStoreChecked,
      required this.onChangedStoreCheck,
      required this.controller});

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  bool isStoreChecked = false;

  @override
  void initState() {
    widget.controller.addListener(() {
      setState(() {
        isStoreChecked = widget.controller.isStoreChecked;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isStoreChecked = widget.isStoreChecked;
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
        child: Column(
          children: [
            SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: isStoreChecked,
                      onChanged: widget.onChangedStoreCheck,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      widget.storeName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                )),
            ...widget.productsItem!
          ],
        ));
  }
}
