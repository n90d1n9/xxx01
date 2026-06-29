import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/teacher.dart';
import '../states/teacher/teacher_provider.dart';
import '../widgets/teacher_card.dart';
import 'teacher_detail_screen.dart';

class TeachersScreen extends ConsumerWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context, ref);
            },
          ),
        ],
      ),
      body: Column(children: [_buildSearchBar(ref), _buildTeachersList(ref)]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add teacher screen
          // Navigator.push(context, MaterialPageRoute(builder: (_) => AddTeacherScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged:
            (value) => ref.read(searchQueryProvider.notifier).state = value,
        decoration: InputDecoration(
          hintText: 'Search teachers...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildTeachersList(WidgetRef ref) {
    final teachers = ref.watch(teachersProvider);
    final isActiveFilterEnabled = ref.watch(activeFilterProvider);

    if (teachers.isEmpty) {
      return const Expanded(child: Center(child: Text('No teachers found')));
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: teachers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          Teacher teacher = teachers[index];
          return TeacherCard(
            teacher: teacher,
            onTap: () {
              /* ref.read(selectedTeacherProvider.notifier).state = teacher;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TeacherDetailScreen(teacherId: teacher,)),
              ); */
            },
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final isActiveFilterEnabled = ref.watch(activeFilterProvider);

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Show only active teachers'),
                    value: isActiveFilterEnabled,
                    onChanged: (value) {
                      ref.read(activeFilterProvider.notifier).state = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Reset all filters
                      ref.read(activeFilterProvider.notifier).state = false;
                      ref.read(searchQueryProvider.notifier).state = '';
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Reset Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
