import 'package:flutter/material.dart';

class GSearchBar extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? fillColor;
  final double? fontSize;
  final String? hintText;
  final double? hintFontSize;
  final double borderRadius;
  final TextEditingController? controller;
  const GSearchBar(
      {super.key,
      this.controller,
      this.width,
      this.height,
      this.fillColor,
      this.fontSize,
      this.hintText,
      this.hintFontSize,
      this.borderRadius = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          hintText: hintText,
          hintStyle:  TextStyle(fontSize: hintFontSize),
          prefixIcon: const Icon(Icons.search),
          prefixIconColor: Colors.black45,
        ),
      ),
    );
  }
}
