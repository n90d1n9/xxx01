import 'package:flutter/material.dart';

import 'anim/screen/3d.dart';

void main() {
  runApp(const SvgStudio3DApp());
}

class SvgStudio3DApp extends StatelessWidget {
  const SvgStudio3DApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SVG Studio - 3D Transforms',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const Studio3DHome(),
    );
  }
}
