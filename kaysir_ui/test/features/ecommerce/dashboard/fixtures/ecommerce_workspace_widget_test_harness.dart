import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHost extends StatelessWidget {
  const TestHost({
    required this.child,
    this.width,
    this.height,
    this.scrollable = false,
    this.theme,
    super.key,
  });

  final Widget child;
  final double? width;
  final double? height;
  final bool scrollable;
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    Widget body = child;

    if (width != null || height != null) {
      body = SizedBox(width: width, height: height, child: body);
    }

    if (scrollable) {
      body = SingleChildScrollView(child: body);
    }

    return MaterialApp(theme: theme, home: Scaffold(body: body));
  }
}

extension EcommerceWorkspaceWidgetTester on WidgetTester {
  Future<void> pumpWorkspaceWidget(
    Widget child, {
    double? width,
    double? height,
    bool scrollable = false,
    ThemeData? theme,
  }) {
    return pumpWidget(
      TestHost(
        width: width,
        height: height,
        scrollable: scrollable,
        theme: theme,
        child: child,
      ),
    );
  }
}
