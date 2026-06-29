import 'package:flutter/material.dart';

class Numpad extends StatelessWidget {
  final VoidCallback? onEnter;
  final Function(int)? onTap;
  final VoidCallback? onClear;
  final Decoration? decoration;
  final double width;
  final double height;
  const Numpad(
      {super.key,
      this.onEnter,
      this.onTap,
      this.onClear,
      this.decoration,
      this.width = 320,
      this.height = 320});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration,
      width: width,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: const EdgeInsets.all(16.0),
        children: [
          ...List.generate(9, (index) {
            return ElevatedButton(
              onPressed: () => onTap!(index + 1),
              child: Text('${index + 1}'),
            );
          }),
          ElevatedButton(
            onPressed: onClear,
            child: const Text('C'),
          ),
          ElevatedButton(
            onPressed: () => onTap!(0),
            child: const Text('0'),
          ),
          ElevatedButton(
            onPressed: onEnter,
            child: const Text('Enter'),
          ),
        ],
      ),
    );
  }
}
