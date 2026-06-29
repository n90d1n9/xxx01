import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syirkah/modules/main/main_module.dart';


import '../../../utils/config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SplashScreen());
  }

  @override
  State<StatefulWidget> createState() => _Splashpagestate();
}

class _Splashpagestate extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print('----------------init------------------------');
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    print('----------------------------------------');
    return Material(
      child: Center(child: Image.asset(imageSplash)),
    );
  }

  startTimer() {
    var _duration = const Duration(milliseconds: 300);
    return Timer(_duration, navigate);
  }

  navigate() async {
   // Navigator.of(context).pushReplacementNamed(MainModule.about);
   context.go('/');
   print('<><><><><>');
  }
}
