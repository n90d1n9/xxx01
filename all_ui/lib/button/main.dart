import 'package:flutter/material.dart';

import 'google.dart';
import 'google_basic.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GoogleSignInButton(
            onPressed: () {
              print('----');
            },
          ),
          AnimatedGoogleSignInButton(
            onPressed: () {
              print('----');
            },
          ),
        ],
      ),
    );
  }
}

void main(List<String> args) {
  runApp(MaterialApp(home: MyWidget()));
}
