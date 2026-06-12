// Category Model
import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;

  Category({required this.name, required this.icon, required this.color});
}

// Predefined Categories
final categories = [
  Category(name: 'Work', icon: Icons.work_outline, color: Colors.blue),
  Category(name: 'Personal', icon: Icons.person_outline, color: Colors.purple),
  Category(name: 'Health', icon: Icons.favorite_outline, color: Colors.red),
  Category(name: 'Study', icon: Icons.school_outlined, color: Colors.green),
  Category(name: 'Meeting', icon: Icons.groups_outlined, color: Colors.orange),
  Category(name: 'Travel', icon: Icons.flight_outlined, color: Colors.teal),
  Category(
    name: 'Finance',
    icon: Icons.account_balance_wallet_outlined,
    color: Colors.amber,
  ),
  Category(name: 'Other', icon: Icons.more_horiz, color: Colors.grey),
];
