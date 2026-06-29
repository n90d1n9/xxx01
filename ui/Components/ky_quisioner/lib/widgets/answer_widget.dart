import 'package:flutter/material.dart';

typedef IntValue = Function(int);

class AnswerOptionWidget extends StatefulWidget {
  final List<String>? options;
  final IntValue? onPressed;
  const AnswerOptionWidget({Key? key, this.options, this.onPressed})
      : super(key: key);

  @override
  _AnswerOptionWidgetState createState() => _AnswerOptionWidgetState();
}

class _AnswerOptionWidgetState extends State<AnswerOptionWidget> {
  int _currentMenu = 0;

  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: 1,
        child: Container(
            width: 400,
            height: 400,
            child: GridView.count(
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              crossAxisCount: 2,
              children: List.generate(widget.options!.length,
                  (index) => _optionBtn(widget.options![index], index)),
            )));
  }

  _optionBtn(label, index) {
    return InkWell(
        onTap: () => _onTapMenu(index),
        child: Container(
            padding: EdgeInsets.all(20),
            color: Colors.amber,
            width: 50,
            height: 50,
            child: Text(label!, style: TextStyle(
              fontSize:20,
            ),)));
  }

  _onTapMenu(value) {
    setState(() {
      _currentMenu = value;
      print(_currentMenu);
      widget.onPressed!(_currentMenu);
    });
  }
}
