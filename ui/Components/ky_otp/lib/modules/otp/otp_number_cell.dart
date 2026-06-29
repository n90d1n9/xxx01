import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberPad extends StatelessWidget {
  final List<Widget>? children;
  final TextEditingController? controller1;
  final TextEditingController? controller2;
   final TextEditingController? controller3;
   final TextEditingController? controller4;
   final TextEditingController? controller5;
   final TextEditingController? controller6;

  /*  TextEditingController? controller1 = new TextEditingController();
  TextEditingController? controller2 = new TextEditingController();
  TextEditingController? controller3 = new TextEditingController();
  TextEditingController? controller4 = new TextEditingController();
  TextEditingController? controller5 = new TextEditingController();
  TextEditingController? controller6 = new TextEditingController();

  TextEditingController currController = new TextEditingController();
 */
  NumberPad({Key? key, this.children,
  this.controller1,
  this.controller2,
   this.controller3,
   this.controller4,
   this.controller5,
   this.controller6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GridView.count(
                crossAxisCount: 8,
                mainAxisSpacing: 10.0,
                shrinkWrap: true,
                primary: false,
                scrollDirection: Axis.vertical,
                children: List<Container>.generate(
                    8, (int index) => Container(child: widgetList[index]))),
          ]),
      flex: 20,
    );
  }

  List<Widget> widgetList = [
      Padding(
        padding: EdgeInsets.only(left: 0.0, right: 2.0),
        child: new Container(
          color: Colors.transparent,
        ),
      ),
      /* cell(controller1!),
      cell(controller2),
      cell(controller3),
      cell(controller4),
      cell(controller5),
      cell(controller6), */
      Padding(
        padding: EdgeInsets.only(left: 2.0, right: 0.0),
        child: new Container(
          color: Colors.transparent,
        ),
      ),
    ];

    Widget cell(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(right: 2.0, left: 2.0),
      child: new Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              border: new Border.all(
                  width: 1.0, color: Color.fromRGBO(0, 0, 0, 0.1)),
              borderRadius: new BorderRadius.circular(4.0)),
          child: new TextField(
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
            ],
            enabled: false,
            controller: controller,
            autofocus: false,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24.0, color: Colors.black),
          )),
    );
}
}