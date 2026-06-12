import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart';

import 'story/storybook.dart';

void main() {
  registerTenunProCharts(includeCore: true);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MikuStorybook());
  }
}

class MikuStorybook extends StatelessWidget {
  const MikuStorybook({super.key});

  @override
  Widget build(BuildContext context) => storybook;
}
