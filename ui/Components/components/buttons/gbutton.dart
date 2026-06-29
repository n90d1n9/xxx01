import 'package:flutter/material.dart';

class GButton extends StatelessWidget {
  const GButton(
      {super.key,
      required this.icon,
      this.label,
      this.spaceSize = 0.0,
      this.fontSize = 10.0,
      this.shape = const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      required this.onPressed,
      this.iconColor = Colors.black26,
      this.height,
      this.labelPosition = GLabelPosition.bottom,
      this.width});
  final IconData icon;
  final Color iconColor;
  final String? label;
  final Function() onPressed;
  final GLabelPosition labelPosition;
  final double fontSize;
  final ShapeBorder shape;
  final double? height;
  final double? width;
  final double spaceSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: MaterialButton(
          shape: shape,
          onPressed: onPressed,
          child: switch (labelPosition) {
            GLabelPosition.bottom => Column(
                children: <Widget>[iconWidget(), SizedBox(height: spaceSize,),labelWidget()],
              ),
            GLabelPosition.left => Column(
                children: <Widget>[
                  labelWidget(),
                  SizedBox(height: spaceSize,),
                  iconWidget(),
                ],
              ),
            GLabelPosition.right => Row(
                children: <Widget>[iconWidget(),SizedBox(width: spaceSize,), labelWidget()],
              ),
            GLabelPosition.top => Row(
                children: <Widget>[
                  labelWidget(),
                  SizedBox(width: spaceSize,),
                  iconWidget(),
                ],
              )
          }),
    );
  }

  Widget iconWidget() => Icon(
        icon,
        color: iconColor,
      );
  Widget labelWidget() => label != null
      ? Text(
          label!,
          style: TextStyle(color: Colors.black, fontSize: fontSize),
        )
      : const SizedBox();
}

enum GLabelPosition { bottom, top, left, right }
