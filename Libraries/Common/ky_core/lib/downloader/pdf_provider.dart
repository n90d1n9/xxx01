// Providers
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../rest/dio_provider.dart';
import '../local_database/local_storage_service.dart';
import 'download_progress.dart';
import 'file_book.dart';

final pdfBooksProvider =
    StateNotifierProvider<FileBooksNotifier, AsyncValue<List<FileBook>>>((ref) {
      return FileBooksNotifier(ref.read(dioProvider));
    });

final pdfDownloadProgressProvider =
    StateNotifierProvider<DownloadNotifier, Map<String, PdfDownloadProgress>>((
      ref,
    ) {
      return DownloadNotifier(ref.read(dioProvider));
    });

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Notifiers
class FileBooksNotifier extends StateNotifier<AsyncValue<List<FileBook>>> {
  final Dio dio;

  FileBooksNotifier(this.dio) : super(const AsyncValue.loading()) {
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      // state = AsyncValue.data(books);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void refresh() => fetchBooks();
}

class DownloadNotifier extends StateNotifier<Map<String, PdfDownloadProgress>> {
  final Dio dio;
  static const _downloadNamespace = 'pdf_downloads';
  static const _downloadMetaNamespace = 'pdf_downloads_meta';
  static const _downloadErrorNamespace = 'pdf_downloads_error';
  static const int _defaultMaxConcurrent = 2;
  final List<_QueuedDownload> _queue = [];
  int _activeCount = 0;

  DownloadNotifier(this.dio) : super({});

  int get activeCount => _activeCount;
  int get queuedCount => _queue.length;
  List<String> get queuedIds =>
      _queue.map((item) => item.id).toList(growable: false);

  bool isQueued(String id) => _queue.any((item) => item.id == id);

  bool cancelQueued(String id) {
    final index = _queue.indexWhere((item) => item.id == id);
    if (index == -1) return false;
    _queue.removeAt(index);
    return true;
  }

  Future<void> loadPersistedDownloads() async {
    final entries = await LocalDBService.getCacheRecords();
    final restored = <String, PdfDownloadProgress>{};
    for (final record in entries) {
      final value = record.value;
      final namespace = value['namespace']?.toString() ?? 'default';
      if (namespace != _downloadNamespace) continue;
      final id = value['key']?.toString();
      final localPath = value['value']?.toString();
      if (id != null && localPath != null && localPath.isNotEmpty) {
        restored[id] = PdfDownloadProgress(
          bookId: id,
          isCompleted: true,
          localPath: localPath,
        );
      }
    }
    if (restored.isNotEmpty) {
      state = {...state, ...restored};
    }
  }

  Future<void> loadInProgressDownloads() async {
    final entries = await LocalDBService.getCacheRecords();
    final restored = <String, PdfDownloadProgress>{};
    for (final record in entries) {
      final value = record.value;
      final namespace = value['namespace']?.toString() ?? 'default';
      if (namespace != _downloadMetaNamespace) continue;
      final payload = value['value']?.toString();
      if (payload == null || payload.isEmpty) continue;
      try {
        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        final id = decoded['id']?.toString();
        if (id == null || id.isEmpty) continue;
        final received = decoded['receivedBytes'] as int? ?? 0;
        final total = decoded['totalBytes'] as int? ?? 0;
        final progress = total > 0
            ? (received / total).clamp(0, 1).toDouble()
            : 0.0;
        restored[id] = PdfDownloadProgress(
          bookId: id,
          isDownloading: false,
          isCompleted: false,
          progress: progress,
          receivedBytes: received,
          totalBytes: total,
        );
      } catch (_) {}
    }
    if (restored.isNotEmpty) {
      state = {...state, ...restored};
    }
  }

  Future<void> resumePendingDownloads() async {
    final entries = await LocalDBService.getCacheRecords();
    for (final record in entries) {
      final value = record.value;
      final namespace = value['namespace']?.toString() ?? 'default';
      if (namespace != _downloadMetaNamespace) continue;
      final payload = value['value']?.toString();
      if (payload == null || payload.isEmpty) continue;
      try {
        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        final id = decoded['id']?.toString();
        final url = decoded['url']?.toString();
        final title = decoded['title']?.toString() ?? id ?? 'download';
        if (id == null || url == null) continue;
        final book = FileBook(
          id: id,
          title: title,
          author: 'unknown',
          thumbnailUrl: '',
          downloadUrl: url,
          pages: 0,
          size: 0,
          category: 'unknown',
        );
        await downloadBook(book, resume: true);
      } catch (_) {}
    }
  }

  Future<void> downloadBook(
    FileBook book, {
    bool resume = true,
    String? expectedSha256,
    int maxConcurrent = _defaultMaxConcurrent,
  }) async {
    if (state[book.id]?.isDownloading == true) return;

    state = {
      ...state,
      book.id: PdfDownloadProgress(bookId: book.id, isDownloading: true),
    };

    await LocalDBService.cacheJson(
      key: _downloadMetaNamespace + book.id,
      value: {
        'id': book.id,
        'url': book.downloadUrl,
        'title': book.title,
        'receivedBytes': 0,
        'totalBytes': 0,
        'resume': resume,
      },
      namespace: _downloadMetaNamespace,
      schemaVersion: 1,
    );

    Future<void> task() async {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/${book.title.replaceAll(' ', '_')}.pdf';

        int existingBytes = 0;
        if (resume) {
          final file = File(filePath);
          if (await file.exists()) {
            existingBytes = await file.length();
          }
        }

        final options = Options(
          headers: existingBytes > 0
              ? {'Range': 'bytes=$existingBytes-'}
              : null,
          responseType: ResponseType.stream,
        );

        await dio.download(
          book.downloadUrl,
          filePath,
          options: options,
          deleteOnError: !resume,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final adjustedTotal = existingBytes > 0
                  ? existingBytes + total
                  : total;
              final adjustedReceived = existingBytes > 0
                  ? existingBytes + received
                  : received;
              final progress = adjustedReceived / adjustedTotal;
              state = {
                ...state,
                book.id: state[book.id]!.copyWith(
                  progress: progress,
                  receivedBytes: adjustedReceived,
                  totalBytes: adjustedTotal,
                ),
              };
              LocalDBService.cacheJson(
                key: _downloadMetaNamespace + book.id,
                value: {
                  'id': book.id,
                  'url': book.downloadUrl,
                  'title': book.title,
                  'receivedBytes': adjustedReceived,
                  'totalBytes': adjustedTotal,
                  'resume': resume,
                },
                namespace: _downloadMetaNamespace,
                schemaVersion: 1,
              );
            }
          },
        );

        state = {
          ...state,
          book.id: state[book.id]!.copyWith(
            isDownloading: false,
            isCompleted: true,
            localPath: filePath,
          ),
        };

        if (expectedSha256 != null && expectedSha256.isNotEmpty) {
          final actual = await _hashFileSha256(filePath);
          if (actual.toLowerCase() != expectedSha256.toLowerCase()) {
            state = {...state, book.id: PdfDownloadProgress(bookId: book.id)};
            try {
              await File(filePath).delete();
            } catch (_) {}
            return;
          }
        }

        await LocalDBService.cacheData(
          key: book.id,
          value: filePath,
          namespace: _downloadNamespace,
          schemaVersion: 1,
          pinned: true,
        );

        await LocalDBService.clearCache(key: _downloadMetaNamespace + book.id);
      } catch (e) {
        state = {...state, book.id: PdfDownloadProgress(bookId: book.id)};
        await LocalDBService.cacheJson(
          key: _downloadErrorNamespace + book.id,
          value: {
            'id': book.id,
            'error': e.toString(),
            'ts': DateTime.now().toIso8601String(),
          },
          namespace: _downloadErrorNamespace,
          schemaVersion: 1,
        );
        await LocalDBService.clearCache(key: _downloadMetaNamespace + book.id);
        rethrow;
      }
    }

    await _enqueue(book.id, task, maxConcurrent);
  }

  bool isBookDownloaded(String bookId) {
    return state[bookId]?.isCompleted == true;
  }

  String? getLocalPath(String bookId) {
    return state[bookId]?.localPath;
  }

  Future<Map<String, dynamic>?> getDownloadError(String bookId) async {
    final key = _downloadErrorNamespace + bookId;
    return LocalDBService.getCachedJson(
      key: key,
      namespace: _downloadErrorNamespace,
      parser: (json) => Map<String, dynamic>.from(json as Map),
      cleanupExpired: false,
    );
  }

  Future<List<Map<String, dynamic>>> getDownloadErrors() async {
    final records = await LocalDBService.getCacheRecordsByNamespace(
      _downloadErrorNamespace,
    );
    final errors = <Map<String, dynamic>>[];
    for (final record in records) {
      final raw = record.value['value'];
      if (raw == null) continue;
      try {
        final decoded = raw is String
            ? jsonDecode(raw)
            : raw as Map<String, dynamic>;
        errors.add(Map<String, dynamic>.from(decoded as Map));
      } catch (_) {}
    }
    return errors;
  }

  Future<void> clearDownloadError(String bookId) async {
    await LocalDBService.clearCache(key: _downloadErrorNamespace + bookId);
  }

  Future<String> _hashFileSha256(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _enqueue(
    String id,
    Future<void> Function() task,
    int maxConcurrent,
  ) async {
    _queue.add(_QueuedDownload(id: id, task: task));
    _processQueue(maxConcurrent);
  }

  void _processQueue(int maxConcurrent) {
    while (_activeCount < maxConcurrent && _queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      _activeCount += 1;
      next.task().whenComplete(() {
        _activeCount -= 1;
        _processQueue(maxConcurrent);
      });
    }
  }
}

class _QueuedDownload {
  final String id;
  final Future<void> Function() task;

  const _QueuedDownload({required this.id, required this.task});
}
