import 'package:flutter/material.dart';

class Rating extends StatelessWidget {
  final int rate;
  const Rating({super.key, this.rate = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        rate,
        (i) => const Icon(Icons.star, size: 16, color: Colors.amber),
      ),
    );
  }
}
