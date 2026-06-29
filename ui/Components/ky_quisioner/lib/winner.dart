import 'package:flutter/material.dart';
import '../widgets/winner_widget.dart';

class WinnerPage extends StatelessWidget {
  const WinnerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Column(children: [_header(), _winnerBoard()]),
    ]));
  }

  _header() {
    return Container();
  }

  _winnerBoard() {
    return WinnerWidget();
  }
}
