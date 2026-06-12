import 'package:flutter/material.dart';

import '../models/search_result.dart';

class GlobalSearch extends StatefulWidget {
  const GlobalSearch({super.key});

  @override
  State<GlobalSearch> createState() => _GlobalSearchState();
}

class _GlobalSearchState extends State<GlobalSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _results = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search components, pages, or actions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _performSearch,
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _results.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Type to search',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final result = _results[index];
                          return ListTile(
                            leading: Icon(result.icon),
                            title: Text(result.title),
                            subtitle: Text(result.subtitle),
                            trailing: Text(
                              result.type,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context, result);
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    // Simulate search
    setState(() {
      _results =
          [
                SearchResult(
                  title: 'Hero Section',
                  subtitle: 'Add a hero section to your page',
                  type: 'Component',
                  icon: Icons.panorama,
                ),
                SearchResult(
                  title: 'Button Component',
                  subtitle: 'Add a button',
                  type: 'Component',
                  icon: Icons.smart_button,
                ),
                SearchResult(
                  title: 'Export Website',
                  subtitle: 'Export your website as HTML',
                  type: 'Action',
                  icon: Icons.download,
                ),
                SearchResult(
                  title: 'Home Page',
                  subtitle: 'Navigate to home page',
                  type: 'Page',
                  icon: Icons.home,
                ),
              ]
              .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
