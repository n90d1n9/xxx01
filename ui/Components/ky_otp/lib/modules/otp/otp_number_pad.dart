import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kays_otp/modules/otp/otp_button.dart';

class OtpPage extends StatelessWidget{
  final Function? onDeleted;
  final Function? onPressedNumber;
  final Function? onPressedOk;
  OtpPage({this.onDeleted, this.onPressedNumber, this.onPressedOk})
  
  @override
  Widget build(BuildContext context) {
    return Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  row([1, 2, 3]),
                  row([4, 5, 6]),
                  row([7, 8, 9]),
                  rowWidget([
                    MaterialButton(
                        onPressed: () {
                          onDeleted;
                        },
                        child: Text('<')),
                    OtpBtn(
                      label: "0",
                      onPressed: () {
                     //   inputTextToField("0");
                      },
                    ),
                    MaterialButton(
                        onPressed: () {
                        //  matchOtp();
                        },
                        child: Text(">"))
                  ]),
                ],
              ),
              flex: 90,
            );
  }

  Widget row(List<int> labels) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(
            left: 8.0, top: 16.0, right: 8.0, bottom: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: button(labels),
        ),
      ),
    );
  }

  Widget col(Widget child) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(
            left: 8.0, top: 16.0, right: 8.0, bottom: 0.0),
        child: child,
      ),
    );
  }

  Widget rowWidget(List<Widget> children) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(
            left: 8.0, top: 16.0, right: 8.0, bottom: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  List<Widget> button(List<int> labels) {
    var temp = <Widget>[];
    for (var item in labels) {
      temp.add(OtpBtn(
          label: item.toString(),
          onPressed: onPressedNumber
          ));
    }
    return temp;
  }

}
