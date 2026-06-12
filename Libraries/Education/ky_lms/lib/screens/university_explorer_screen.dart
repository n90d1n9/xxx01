import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'university_card.dart';

class UniversityExplorerScreen extends ConsumerWidget {
  const UniversityExplorerScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universities = ref.watch(universitiesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksplorasi Universitas'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: universities.length,
        itemBuilder: (context, index) {
          return UniversityCard(university: universities[index]);
        },
      ),
    );
  }
}
