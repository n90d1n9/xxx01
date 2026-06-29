import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/hadith_provider.dart';

class SearchBar extends ConsumerWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterType = ref.watch(filterTypeProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: tr(ref, 'search_hint'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<FilterType>(
            value: filterType,
            items: [
              DropdownMenuItem(
                value: FilterType.all,
                child: Text(tr(ref, 'filter_all')),
              ),
              DropdownMenuItem(
                value: FilterType.book,
                child: Text(tr(ref, 'filter_book')),
              ),
              DropdownMenuItem(
                value: FilterType.topic,
                child: Text(tr(ref, 'filter_topic')),
              ),
              DropdownMenuItem(
                value: FilterType.rawi,
                child: Text(tr(ref, 'filter_rawi')),
              ),
              DropdownMenuItem(
                value: FilterType.grade,
                child: Text(tr(ref, 'filter_grade')),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(filterTypeProvider.notifier).state = value;
              }
            },
          ),
        ],
      ),
    );
  }
}
