import 'package:flutter/material.dart';

IconData billingProductCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'subscription':
      return Icons.sync_alt;
    case 'service':
      return Icons.support_agent;
    case 'hosting':
      return Icons.dns;
    case 'domain':
      return Icons.language;
    case 'add-on':
      return Icons.extension;
    default:
      return Icons.shop;
  }
}
