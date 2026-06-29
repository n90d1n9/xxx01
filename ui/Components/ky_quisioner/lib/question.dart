import 'package:flutter/material.dart';
import '../widgets/question_widget.dart';
import '../widgets/answer_widget.dart';

class QuestionPage extends StatefulWidget {
  QuestionPage({Key? key}) : super(key: key);

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
        body:  Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        QuestionWidget(
          text: 'pertanyaan',
        ),
        AnswerOptionWidget(
          onPressed: _onPressed,
          options: ['aku', 'bee', 'ceee', 'deee'],
        )
      ]),
    );
  }

  _onPressed(value) {
    print('>>>>>' + value.toString());
    return value;
  }
}
