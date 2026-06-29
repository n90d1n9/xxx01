import 'package:flutter/material.dart';

class StockDisplay extends StatelessWidget {
  const StockDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.grey
      ),
      height: 200,
      width: 700,
      child: const Text('Display Stock'),
    );
  }
}