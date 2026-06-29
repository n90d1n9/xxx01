import 'package:flutter/material.dart';

class OtpBtn extends StatelessWidget {
  final Function? onPressed;
  final String? label;
  const OtpBtn({Key? key, this.label, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: pressed,
      child: Text(label!,
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center),
    );
  }

  pressed(){
    onPressed!();
  }
}
