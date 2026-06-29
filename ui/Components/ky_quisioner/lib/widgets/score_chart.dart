import 'package:flutter/material.dart';
import '../model/score.dart';

class ScoreBar extends StatelessWidget {
  final double width;
  final List<Score>? list;
  const ScoreBar({Key? key, this.width = 50, this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _chart(list);
  }

  Widget _chart(list) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(list.length, (index) => _bar(index)),
    );
  }

  Widget _bar(index) {
    return Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: [
          Icon(
            Icons.person,size: 35,
            color: Colors.blue,
          ),
          Container(
            color: Colors.amber,
            margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
            width: width,
            height: list![index].score!,
            child: Text(
              list![index].title!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          )
        ]);
  }
}
