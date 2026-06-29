import 'package:flutter/material.dart';

class PlusMinusButton extends StatelessWidget {
  final int value;
  final Function() onPressedMinus;
  final Function() onPressedPlus;

  const PlusMinusButton(
      {super.key,
      this.value = 0,
      required this.onPressedMinus,
      required this.onPressedPlus});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10)
      ),
      child: 
    Row(
      children: [
        IconButton(
          onPressed: onPressedMinus,
          icon: const Icon(Icons.delete_rounded),
        ),
        const SizedBox(width: 8),
        Text('$value'),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onPressedPlus,
          icon: const Icon(Icons.add),
        )
      ],
    ));
  }
}
