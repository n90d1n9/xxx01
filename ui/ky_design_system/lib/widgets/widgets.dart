import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

final widgets = [
  // Features
  Story(
    name: 'Widgets/Text',
    description: 'Simple text widget.',
    builder: (context) => const Center(child: Text('Simple text')),
  ),
];
