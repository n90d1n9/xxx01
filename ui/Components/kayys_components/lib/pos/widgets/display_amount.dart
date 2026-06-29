import 'package:flutter/material.dart';

import 'currency_view.dart';

class DisplayAmount extends StatelessWidget {
  final double amount;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry borderRadius;

  const DisplayAmount(
      {super.key,
      this.amount = 0,
      this.width = 100,
      this.height = 50,
      this.borderRadius = const BorderRadius.all(Radius.circular(10.0)),
      this.padding = const EdgeInsets.fromLTRB(0, 0, 10, 0),
      this.margin = const EdgeInsets.fromLTRB(10, 0, 0, 0)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.black45,
      ),
      alignment: Alignment.centerRight,
      margin: margin,
      width: width,
      height: height,
      child: CurrencyView(value: amount),
    );
  }
}
