import 'package:adaptive_screen/index.dart';
import 'package:flutter/material.dart';

class PosLayout extends StatelessWidget {
  final Widget header;
  final Widget order;
  final Widget subtotal;
  final Widget detailForm;
  final Widget button;
  final Widget numericKeyboard;
  final Widget footer;

  const PosLayout(
      {super.key,
      required this.header,
      required this.order,
      required this.subtotal,
      required this.detailForm,
      required this.button,
      required this.numericKeyboard,
      required this.footer});

  String get struckNo => 'null';

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      // If fit large screen (Desktop)
      largeScreen: largeScreen(
          order, subtotal, footer, detailForm, button, numericKeyboard),
      mediumScreen: mediumScreen(
          order, subtotal, footer, detailForm, button, numericKeyboard),
      phone: phoneScreen(
          order, subtotal, footer, detailForm, button, numericKeyboard),
    );
  }

  Widget largeScreen(
          order, subtotal, footer, detailForm, button, numericKeyboard) =>
          Scaffold(body: 
      Column(
        children: [
          header,
          Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [detailForm, numericKeyboard],
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [info(), order, radioPPN(), Row(children: [
                          button,
                          numericKeyboard
                        ],)],
                      )),
                ],
              ))
        ],
      ));

  Widget info() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [const Text('No Struck : '), Text(struckNo)]),
        subtotal
      ],
    );
  }

  Widget radioPPN() {
    const textStyle = TextStyle(fontSize: 12);
    const groupValue = null;
    return Row(
      children: [
        Row(children: [
          Radio(value: true, groupValue: groupValue, onChanged: (val) => {}),
          const Text(
            'Non PPN',
            style: textStyle,
          )
        ]),
        Row(children: [
          Radio(value: true, groupValue: groupValue, onChanged: (val) => {}),
          const Text(
            'Include PPN',
            style: textStyle,
          )
        ]),
        Row(children: [
          Radio(value: true, groupValue: groupValue, onChanged: (val) => {}),
          const Text(
            'Exclude PPN',
            style: textStyle,
          )
        ]),
      ],
    );
  }

  Widget mediumScreen(
          order, subtotal, footer, detailForm, button, numericKeyboard) =>
      const Text('medium');
  Widget phoneScreen(
          order, subtotal, footer, detailForm, button, numericKeyboard) =>
      const Text('phone');
}
