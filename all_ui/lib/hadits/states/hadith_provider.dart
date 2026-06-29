// State Management
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../config/data.dart';
import '../config/translation.dart';
import '../models/book.dart';
import '../models/hadith.dart';
import '../models/rawi.dart';

final localeProvider = StateProvider<String>((ref) => 'id');
final bookListProvider = StateProvider<List<Book>>((ref) => sampleBooks);
final rawiListProvider = StateProvider<List<Rawi>>((ref) => sampleRawis);
final hadithListProvider = StateProvider<List<Hadith>>((ref) => sampleHadiths);

final selectedHadithProvider = StateProvider<Hadith?>((ref) => null);
final selectedRawiProvider = StateProvider<Rawi?>((ref) => null);

final scaleGestureProvider = StateProvider<bool>((ref) => false);

enum ViewMode { graph, list, grid, network }

final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.graph);

// Network graph state
final networkZoomProvider = StateProvider<double>((ref) => 1.0);
final networkOffsetProvider = StateProvider<Offset>((ref) => Offset.zero);
final collapsedNodesProvider = StateProvider<Set<String>>((ref) => {});
final selectedNodeProvider = StateProvider<String?>((ref) => null);

enum FilterType { all, book, topic, rawi, grade }

final filterTypeProvider = StateProvider<FilterType>((ref) => FilterType.all);
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredHadithsProvider = Provider<List<Hadith>>((ref) {
  final hadiths = ref.watch(hadithListProvider);
  final filterType = ref.watch(filterTypeProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final locale = ref.watch(localeProvider);

  if (query.isEmpty) return hadiths;

  return hadiths.where((h) {
    switch (filterType) {
      case FilterType.book:
        final books = ref.read(bookListProvider);
        final book = books.firstWhereOrNull((b) => b.id == h.bookId);
        return book?.name.get(locale).toLowerCase().contains(query) ?? false;
      case FilterType.topic:
        return h.topics.any((t) => t.toLowerCase().contains(query));
      case FilterType.grade:
        return h.grade.toLowerCase().contains(query);
      case FilterType.rawi:
        final rawis = ref.read(rawiListProvider);
        return h.sanad.any((rawiId) {
          final rawi = rawis.firstWhereOrNull((r) => r.id == rawiId);
          return rawi?.name.get(locale).toLowerCase().contains(query) ?? false;
        });
      case FilterType.all:
        return h.translation.get(locale).toLowerCase().contains(query) ||
            h.arabicText.toLowerCase().contains(query) ||
            h.topics.any((t) => t.toLowerCase().contains(query));
    }
  }).toList();
});

// Translation helper
String tr(WidgetRef ref, String key) {
  final locale = ref.watch(localeProvider);
  return translations[locale]?[key] ?? key;
}
