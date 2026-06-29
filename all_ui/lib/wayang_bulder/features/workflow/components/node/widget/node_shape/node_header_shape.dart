import 'package:flutter/material.dart';

class NodeHeaderShape extends StatelessWidget {
  final String title;
  final String subtitle;
  final double height;
  const NodeHeaderShape({
    super.key,
    required this.title,
    required this.subtitle,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            IconData(0xe800, fontFamily: 'CustomIcons'),
            size: 16,
            color: Colors.grey,
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 12,
              color: Color(0xFF5C5B5B),
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 8,
                color: Color(0xFF5C5B5B),
              ),
            ),
        ],
      ),
    );
  }
}
