import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SyirkahPage extends ConsumerStatefulWidget {
  const SyirkahPage({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  @override
  ConsumerState<SyirkahPage> createState() => _SyirkahPageState();
}

class _SyirkahPageState extends ConsumerState<SyirkahPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('syirkah'),
    );
    
  }
}