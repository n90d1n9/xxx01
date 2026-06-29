import 'package:flutter/material.dart';

import 'currency_view.dart';

class Subtotal extends StatelessWidget {
  final double? subtotal;
  final double? tax;
  const Subtotal({super.key, this.subtotal, this.tax});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: Colors.black);
    return Container(
      alignment: Alignment.centerRight,
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(children: [
            const Text('Subtotal : '),
            CurrencyView(
              value: subtotal,
              currencyLabel: 'Rp',
              style: style,
            )
          ]),
          Row(children: [
            const Text('Tax : '),
            CurrencyView(
              value: tax,
              currencyLabel: 'Rp',
              style: style,
            )
          ])
        ],
      ),
    );
  }
}
