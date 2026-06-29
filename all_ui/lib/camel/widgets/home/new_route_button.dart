import 'package:flutter/material.dart';

class NewRouteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NewRouteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: onPressed,
      tooltip: 'New Route',
    );
  }
}
