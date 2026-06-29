import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'customer.dart';

final customersProvider = FutureProvider<List<Customer>>((ref) async {
  // Simulate API call
  await Future.delayed(Duration(seconds: 1));
  return [
    Customer(
      id: '1',
      name: 'Acme Corp',
      email: 'accounts@acme.com',
      phone: '555-123-4567',
    ),
    Customer(
      id: '2',
      name: 'Wayne Enterprises',
      email: 'finance@wayne.com',
      phone: '555-987-6543',
    ),
    Customer(
      id: '3',
      name: 'Stark Industries',
      email: 'ar@stark.com',
      phone: '555-789-0123',
    ),
    Customer(
      id: '4',
      name: 'Umbrella Corp',
      email: 'billing@umbrella.com',
      phone: '555-456-7890',
    ),
  ];
});
