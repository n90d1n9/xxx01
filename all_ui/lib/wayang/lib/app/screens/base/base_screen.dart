// base_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/base/screen_provider.dart';

abstract class BaseScreen extends ConsumerWidget {
  final String screenName;

  const BaseScreen({super.key, required this.screenName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(screenProvider.notifier).setScreen(screenName);
    return buildScreen(context, ref);
  }

  Widget buildScreen(BuildContext context, WidgetRef ref);
}
