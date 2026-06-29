import 'package:flutter/material.dart';
import 'dart:async';

class DigiClock extends StatefulWidget {
  const DigiClock({super.key});

  @override
  DigiClockState createState() => DigiClockState();
}

class DigiClockState extends State<DigiClock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Timer _timer;
  late DateTime _time;

  @override
  void initState() {
    super.initState();
    _time = DateTime.now();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _time = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return /* Scaffold(
      backgroundColor: Colors.black,
      body:  */
        Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 + _animation.value * 0.1,
            child: ClockText(time: _time),
          );
        },
      ),
      // ),
    );
  }
}

class ClockText extends StatelessWidget {
  final DateTime time;

  const ClockText({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
    return Text(
      formattedTime,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 60,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
