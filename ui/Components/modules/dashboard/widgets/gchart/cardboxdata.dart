import 'package:flutter/material.dart';

class CardBoxData extends StatelessWidget {
  final Color? color;
  final String? title;
  final String? subtitle;
  final double? value;
  final double? leftValue;
  final double? rightValue;
  final bool isIncrease;
  const CardBoxData(
      {super.key,
      this.color = Colors.white,
      this.title,
      this.subtitle,
      this.value,
      this.leftValue,
      this.rightValue,
      this.isIncrease = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 4,
        shadowColor: Colors.black38,
        color: color!,
        child:  Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$subtitle',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '$leftValue',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '$title',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
               Row(
                children: [
                  //Text('Y-1'),
                  //SizedBox(width: 8.0),
                  Text('$value'),
                  const SizedBox(width: 16.0),
                  const Icon(Icons.arrow_upward, color: Colors.green),
                  const SizedBox(width: 8.0),
                  Text('$rightValue'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
