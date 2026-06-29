import 'dart:async';

import 'package:flutter/material.dart';

import 'PreloginScreen.dart';

class TransportSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => PreloginScreen()));
    });

    return Scaffold(
      body: Center(
        child: Text(
          "reJEK¡",
          style: TextStyle(
              color: Colors.green, fontSize: 50, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
