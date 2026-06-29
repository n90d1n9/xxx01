import 'package:flutter/material.dart';

class Winner{
  String? name;
  int? score;
}

class WinnerWidget extends StatelessWidget {
  final List<Winner>? winners;
  const WinnerWidget({Key? key, this.winners}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: List.generate(winners!.length, (index) => _barWinner(index)),),
    );
  }

  Widget _barWinner(index){
    return Container(
      
    );
  }
}