// ignore_for_file: avoid_print

import 'package:flutter/material.dart';


class PosNumericKey extends StatelessWidget {
  final ValueChanged<String> onTapBtn;
  const PosNumericKey({super.key, required this.onTapBtn});

  @override
  Widget build(BuildContext context) {
    const btnStyle = TextStyle(fontSize: 18, color: Colors.black);

    //const btnList = [{'name': 'delete', ''}];

    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [numeric(btnStyle), btnRight(btnStyle)]);
  }

  Widget btnRight(btnStyle) {
    return Column(
      children: [
        // Row(children: [
        ElevatedButton.icon(
            onPressed: () => print(''),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Delete')),
        ElevatedButton.icon(
            onPressed: () => print(''),
            icon: const Icon(Icons.close),
            label: const Text('Clear')),
        ElevatedButton.icon(
            style: ButtonStyle(
                minimumSize: const WidgetStatePropertyAll(Size(50, 150)),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                   // side: const BorderSide(color: Colors.red)
                    ))),
            onPressed: () => print(''),
            icon: const Icon(Icons.arrow_drop_down),
            label: const Text('Enter')),
        //]),
      ],
    );
  }

  Widget numeric(btnStyle) {
    var list = <Widget>[];
    list.add(btn2('1', btnStyle));
    list.add(btn2('2', btnStyle));
    list.add(btn2('3', btnStyle));
    list.add(btn2('4', btnStyle));
    list.add(btn2('5', btnStyle));
    list.add(btn2('6', btnStyle));
    list.add(btn2('7', btnStyle));
    list.add(btn2('8', btnStyle));
    list.add(btn2('9', btnStyle));
    list.add(btn2('0', btnStyle));
    list.add(btn2('00', btnStyle));
    list.add(btn2('000', btnStyle));

    return Container(
        constraints: const BoxConstraints(
          minHeight: 130.0,
          minWidth: 130.0,
        ),
        width: 150,
        height: 200,
        child: GridView.count(
            restorationId: 'grid_button',
            crossAxisCount: 3,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
            padding: const EdgeInsets.all(1),
            childAspectRatio: 1,
            children: list));
  }

  Widget btn(label, btnStyle, [double height = 65, double width = 65]) =>
      GestureDetector(
          onTap: () => onTapBtn(label),
          child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 178, 182, 178),
                boxShadow: [BoxShadow(color: Colors.lightGreen)]),
            width: height,
            height: width,
            child: Text(
              '$label',
              style: btnStyle,
            ),
          ));

  Widget btn3(label, btnStyle, [double height = 35, double width = 35]) =>
      ElevatedButton(
        onPressed: () => onTapBtn(label),
        style: ElevatedButton.styleFrom(
          fixedSize: Size(height, width),
          padding: const EdgeInsets.all(0),
          backgroundColor: Colors.black12,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero)),
          elevation: 0,
        ),
        child: Text(
          '$label',
          style: btnStyle,
        ),
      );

  Widget btn2(label, btnStyle, [double height = 35, double width = 35]) =>
      ElevatedButton(
        onPressed: () => onTapBtn(label),
        style: ElevatedButton.styleFrom(
          //fixedSize: Size(height, width),
          padding: const EdgeInsets.all(0),
          //backgroundColor: Colors.black12,
          /*  shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(100))),
          */
          elevation: 5,
        ),
        child: Text(
          '$label',
          style: btnStyle,
        ),
      );
}
