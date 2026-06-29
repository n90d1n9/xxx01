import 'package:flutter/material.dart';

class GBox extends StatelessWidget {
     const GBox(
      {Key? key,
      this.width = 100,
      this.height = 50,
      this.label,
      this.value,
      this.border =  const Border(),
      this.margin = const EdgeInsets.fromLTRB(10, 10, 10, 10),
      this.backgroundColor = const Color.fromARGB(255, 237, 236, 236),
      this.labelStyle = const TextStyle(
        fontSize: 12
      ),
      this.valueStyle = const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      )})
      : super(key: key);
  final double width;
  final double height;
  final String? label;
  final double? value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final EdgeInsetsGeometry margin;
  final BoxBorder border;
  final Color backgroundColor;
  @override
  Widget build(BuildContext context) {
    return Container( 
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: border
      ),
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$value', style: valueStyle),
          Text(label!, style: labelStyle)
        ],
      ),
    );
  }
}
