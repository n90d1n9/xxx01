import 'package:flutter/material.dart';
import 'package:kays_quiz/model/score.dart';
import 'package:kays_quiz/widgets/score_chart.dart';

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Quiz'),
        ),
        body: Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScoreBar(
                  list: [
                    Score(title: 'satu', score: 200),
                    Score(title: 'dua', score: 170),
                    Score(title: 'tiga', score: 130)
                  ],
                )
              ]),
        ));
  }
}
