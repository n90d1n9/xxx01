import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyView extends StatelessWidget {
  final String? locale;
  final double? value;
  final String? currencyLabel;
  final int? decimalDigit;
  final TextStyle? style;
  const CurrencyView(
      {super.key,
      this.value,
      this.locale,
      this.currencyLabel = '',
      this.decimalDigit = 0,
      this.style = const TextStyle(fontSize: 50, color: Colors.white)});

  @override
  Widget build(BuildContext context) {
    return Text(
      NumberFormat.currency(
              locale: locale,
              name: '$currencyLabel ',
              decimalDigits: decimalDigit)
          .format(value),
      style: style,
    );
  }
}
