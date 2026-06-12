import 'package:flutter/material.dart';

IconData paymentMethodIcon(String method) {
  switch (method) {
    case 'Cash':
      return Icons.payments_outlined;
    case 'Debit Card':
      return Icons.credit_card;
    case 'Mobile Payment':
      return Icons.phone_android;
    case 'Bank Transfer':
      return Icons.account_balance_outlined;
    default:
      return Icons.payment;
  }
}
