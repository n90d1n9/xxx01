import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/surah.dart';

class BookmarkService {
  static const String _bookmarksKey = 'bookmarks';
  static const String _lastReadKey = 'last_read_position';

  Future<List<Bookmark>> getBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
      return bookmarksJson
          .map((json) => Bookmark.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      throw Exception('Failed to load bookmarks: $e');
    }
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = await getBookmarks();

      // Check if already bookmarked
      if (!bookmarks.any(
        (b) =>
            b.surahNumber == bookmark.surahNumber &&
            b.ayahNumber == bookmark.ayahNumber,
      )) {
        bookmarks.add(bookmark);
        await _saveBookmarks(prefs, bookmarks);
      }
    } catch (e) {
      throw Exception('Failed to add bookmark: $e');
    }
  }

  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = await getBookmarks();
      bookmarks.removeWhere(
        (b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber,
      );
      await _saveBookmarks(prefs, bookmarks);
    } catch (e) {
      throw Exception('Failed to remove bookmark: $e');
    }
  }

  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any(
      (b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber,
    );
  }

  Future<void> saveLastReadPosition(
    int surahNumber,
    int ayahNumber,
    int pageNumber,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _lastReadKey,
        jsonEncode({
          'surahNumber': surahNumber,
          'ayahNumber': ayahNumber,
          'pageNumber': pageNumber,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      throw Exception('Failed to save last position: $e');
    }
  }

  Future<Map<String, dynamic>?> getLastReadPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_lastReadKey);
      return json != null ? jsonDecode(json) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAllBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookmarksKey);
  }

  Future<void> _saveBookmarks(
    SharedPreferences prefs,
    List<Bookmark> bookmarks,
  ) async {
    final bookmarksJson = bookmarks.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList(_bookmarksKey, bookmarksJson);
  }

  /* 
  Future<List<Bookmark>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? bookmarksJson = prefs.getString(_bookmarksKey);
    if (bookmarksJson == null) return [];

    final List decoded = json.decode(bookmarksJson);
    return decoded.map((b) => Bookmark.fromJson(b)).toList();
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) =>
        b.surahNumber == bookmark.surahNumber &&
        b.ayahNumber == bookmark.ayahNumber);
    bookmarks.insert(0, bookmark);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _bookmarksKey, json.encode(bookmarks.map((b) => b.toJson()).toList()));
  }

  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) =>
        b.surahNumber == surahNumber && b.ayahNumber == ayahNumber);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _bookmarksKey, json.encode(bookmarks.map((b) => b.toJson()).toList()));
  }

  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    final bookmarks = await getBookmarks();
    return bookmarks
        .any((b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber);
  }

  Future<void> saveLastReadPosition(int surahNumber, int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastReadKey,
        json.encode({'surahNumber': surahNumber, 'ayahNumber': ayahNumber}));
  }

  Future<Map<String, int>?> getLastReadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final String? positionJson = prefs.getString(_lastReadKey);
    if (positionJson == null) return null;

    final decoded = json.decode(positionJson);
    return {
      'surahNumber': decoded['surahNumber'],
      'ayahNumber': decoded['ayahNumber']
    };
  } */
}
