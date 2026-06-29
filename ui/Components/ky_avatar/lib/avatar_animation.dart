import 'package:flutter/material.dart';


class AvatarAnimation extends StatefulWidget {
  const AvatarAnimation({super.key});

 @override
  State<AvatarAnimation> createState() => _AvatarAnimationState();
}

class _AvatarAnimationState extends State<AvatarAnimation> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: AnimatedBuilder(
          animation: _animation!,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation!.value,
              child: child,
            );
          },
          child: const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://robohash.org/satu'),//AssetImage('assets/avatar.jpg'), // Add your avatar image here
          ),
        ),
      
    );
  }
}