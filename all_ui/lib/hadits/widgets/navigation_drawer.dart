import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/browse_by_book_screen.dart';
import '../screens/browse_by_grade_screen.dart';
import '../screens/browse_by_rawi_screen.dart';
import '../screens/browse_by_topic_screen.dart';
import '../states/hadith_provider.dart';

class MyNavigationDrawer extends ConsumerWidget {
  const MyNavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.teal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.book, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  tr(ref, 'app_title'),
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: Text(tr(ref, 'browse_by_book')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrowseByBookScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.topic),
            title: Text(tr(ref, 'browse_by_topic')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrowseByTopicScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: Text(tr(ref, 'browse_by_rawi')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrowseByRawiScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: Text(tr(ref, 'browse_by_grade')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrowseByGradeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
