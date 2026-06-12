// download_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../rest/dio_provider.dart';
import '../rest/rest_error_util.dart';
import '../local_database/local_storage_service.dart';
import 'download_state.dart';

final downloadProvider =
    StateNotifierProvider<DownloadNotifier, Map<String, DownloadState>>((ref) {
      return DownloadNotifier(ref.read(dioProvider));
    });

class DownloadNotifier extends StateNotifier<Map<String, DownloadState>> {
  final Dio dio;
  final Map<String, CancelToken> _cancelTokens = {};
  final List<_QueuedDownload> _queue = [];
  int _activeCount = 0;

  static const _downloadNamespace = 'downloads';
  static const _downloadMetaNamespace = 'downloads_meta';
  static const _downloadErrorNamespace = 'downloads_error';
  static const int _defaultMaxConcurrent = 2;

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
    final restored = <String, DownloadState>{};
    for (final record in entries) {
      final value = record.value;
      final namespace = value['namespace']?.toString() ?? 'default';
      if (namespace != _downloadNamespace) continue;
      final id = value['key']?.toString();
      final localPath = value['value']?.toString();
      if (id != null && localPath != null && localPath.isNotEmpty) {
        restored[id] = DownloadState(
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
    final restored = <String, DownloadState>{};
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
        final progress =
            total > 0 ? (received / total).clamp(0, 1).toDouble() : 0.0;
        restored[id] = DownloadState(
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
        final localDir = decoded['localDir']?.toString();
        final title = decoded['title']?.toString() ?? 'download';
        if (id == null || url == null || localDir == null) continue;
        await downloadAlwaie(id, title, url, localDir, resume: true);
      } catch (_) {}
    }
  }

  Future<void> downloadAlwaie(
    String id,
    String title,
    String url,
    String localDir, {
    int maxRetries = 0,
    bool resume = true,
    String? expectedSha256,
    int maxConcurrent = _defaultMaxConcurrent,
  }) async {
    // If already downloading or completed, return
    if (state[id]?.isDownloading == true || state[id]?.isCompleted == true) {
      return;
    }

    // Create cancel token
    final cancelToken = CancelToken();
    _cancelTokens[id] = cancelToken;

    // Set initial state
    state = {
      ...state,
      id: const DownloadState(isDownloading: true, progress: 0),
    };

    await LocalDBService.cacheJson(
      key: _downloadMetaNamespace + id,
      value: {
        'id': id,
        'url': url,
        'localDir': localDir,
        'title': title,
        'resume': resume,
        'receivedBytes': 0,
        'totalBytes': 0,
      },
      namespace: _downloadMetaNamespace,
      schemaVersion: 1,
    );

    Future<void> task() async {
      var attempts = 0;
      while (true) {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final fileName =
              '${id}_${title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf';
          final filePath = '${directory.path}/$localDir/$fileName';

          // Create directory if it doesn't exist
          await Directory('${directory.path}/$localDir').create(recursive: true);

          int existingBytes = 0;
          if (resume) {
            final file = File(filePath);
            if (await file.exists()) {
              existingBytes = await file.length();
            }
          }

          final options = Options(
            headers:
                existingBytes > 0 ? {'Range': 'bytes=$existingBytes-'} : null,
            responseType: ResponseType.stream,
          );

          await dio.download(
            url,
            filePath,
            cancelToken: cancelToken,
            options: options,
            deleteOnError: !resume,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final adjustedTotal =
                    existingBytes > 0 ? existingBytes + total : total;
                final adjustedReceived =
                    existingBytes > 0 ? existingBytes + received : received;
                final progress = adjustedReceived / adjustedTotal;
                // Only update state if progress changes significantly.
                if (progress - (state[id]?.progress ?? 0) > 0.01 ||
                    progress == 1.0) {
                  state = {
                    ...state,
                    id: state[id]!.copyWith(
                      progress: progress,
                      receivedBytes: adjustedReceived,
                      totalBytes: adjustedTotal,
                    ),
                  };
                  LocalDBService.cacheJson(
                    key: _downloadMetaNamespace + id,
                    value: {
                      'id': id,
                      'url': url,
                      'localDir': localDir,
                      'title': title,
                      'resume': resume,
                      'receivedBytes': adjustedReceived,
                      'totalBytes': adjustedTotal,
                    },
                    namespace: _downloadMetaNamespace,
                    schemaVersion: 1,
                  );
                }
              }
            },
          );

          state = {
            ...state,
            id: state[id]!.copyWith(
              isDownloading: false,
              isCompleted: true,
              localPath: filePath,
            ),
          };

          if (expectedSha256 != null && expectedSha256.isNotEmpty) {
            final actual = await _hashFileSha256(filePath);
            if (actual.toLowerCase() != expectedSha256.toLowerCase()) {
              state = {
                ...state,
                id: DownloadState(error: 'File integrity check failed'),
              };
              try {
                await File(filePath).delete();
              } catch (_) {}
              _cancelTokens.remove(id);
              break;
            }
          }

          await LocalDBService.cacheData(
            key: id,
            value: filePath,
            namespace: _downloadNamespace,
            schemaVersion: 1,
            pinned: true,
          );

          await LocalDBService.clearCache(
            key: _downloadMetaNamespace + id,
          );

          // Remove cancel token
          _cancelTokens.remove(id);
          break;
        } catch (e) {
          if (e is DioException && e.type == DioExceptionType.cancel) {
            // Download was cancelled, remove the file if it was partially downloaded
            final currentState = state[id];
            if (currentState?.localPath != null) {
              try {
                await File(currentState!.localPath!).delete();
              } catch (_) {}
            }
            state = {...state};
            state.remove(id);
            _cancelTokens.remove(id);
            await LocalDBService.clearCache(key: _downloadMetaNamespace + id);
            break;
          } else if (e is DioException &&
              attempts < maxRetries &&
              _shouldRetryDownload(e)) {
            attempts += 1;
            await Future.delayed(Duration(milliseconds: 250 * (1 << attempts)));
            continue;
          } else {
            final errorMessage = e is DioException
                ? DioErrorUtil.handleError(e)
                : e.toString();
            state = {...state, id: DownloadState(error: errorMessage)};
            await LocalDBService.cacheJson(
              key: _downloadErrorNamespace + id,
              value: {
                'id': id,
                'error': errorMessage,
                'ts': DateTime.now().toIso8601String(),
              },
              namespace: _downloadErrorNamespace,
              schemaVersion: 1,
            );
            _cancelTokens.remove(id);
            await LocalDBService.clearCache(key: _downloadMetaNamespace + id);
            break;
          }
        }
      }
    }

    await _enqueue(id, task, maxConcurrent);
  }

  void removeDownload(String id) {
    // Cancel ongoing download if any
    _cancelTokens[id]?.cancel('User cancelled');
    _cancelTokens.remove(id);

    // Delete the file if it exists
    final currentState = state[id];
    if (currentState?.localPath != null) {
      try {
        File(currentState!.localPath!).delete();
      } catch (_) {}
    }

    // Remove from state
    state = {...state};
    state.remove(id);
  }

  bool isDownloaded(String id) {
    return state[id]?.isCompleted == true;
  }

  String? getLocalPath(String id) {
    return state[id]?.localPath;
  }

  Future<Map<String, dynamic>?> getDownloadError(String id) async {
    final key = _downloadErrorNamespace + id;
    return LocalDBService.getCachedJson(
      key: key,
      namespace: _downloadErrorNamespace,
      parser: (json) => Map<String, dynamic>.from(json as Map),
      cleanupExpired: false,
    );
  }

  Future<List<Map<String, dynamic>>> getDownloadErrors() async {
    final records =
        await LocalDBService.getCacheRecordsByNamespace(_downloadErrorNamespace);
    final errors = <Map<String, dynamic>>[];
    for (final record in records) {
      final raw = record.value['value'];
      if (raw == null) continue;
      try {
        final decoded =
            raw is String ? jsonDecode(raw) : raw as Map<String, dynamic>;
        errors.add(Map<String, dynamic>.from(decoded as Map));
      } catch (_) {}
    }
    return errors;
  }

  Future<void> clearDownloadError(String id) async {
    await LocalDBService.clearCache(key: _downloadErrorNamespace + id);
  }

  bool _shouldRetryDownload(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return true;
    }
    final status = e.response?.statusCode ?? 0;
    return status >= 500;
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
