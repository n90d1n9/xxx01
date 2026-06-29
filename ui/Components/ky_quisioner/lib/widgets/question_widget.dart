import 'package:flutter/material.dart';

class QuestionWidget extends StatelessWidget {
  final String? text;
  const QuestionWidget({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: TextStyle(color: Colors.cyanAccent, fontSize: 30),
            text: text!));
  }
}
