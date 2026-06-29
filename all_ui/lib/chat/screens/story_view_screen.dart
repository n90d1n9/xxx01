import 'package:flutter/material.dart';

import '../models/story.dart';

class StoryViewScreen extends StatelessWidget {
  final Story story;

  const StoryViewScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Story')),
      body: Center(child: Text('Story View Screen')),
    );
  }
}
