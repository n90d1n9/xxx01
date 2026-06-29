// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
    var duration = const Duration(milliseconds: 300);
    return Timer(duration, navigate);
  }

  navigate() async {
   // Navigator.of(context).pushReplacementNamed(MainModule.about);
   context.go('/');
   print('<><><><><>');
  }
}
