// download_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

//import '../../../../services/downloader/pdf_provider.dart';
import '../../features/miku/alwaie/models/alwaie.dart';
import '../rest/dio_provider.dart';
import 'download_state.dart';

final downloadProvider =
    StateNotifierProvider<AlwaieDownloadNotifier, Map<String, DownloadState>>(
        (ref) {
  return AlwaieDownloadNotifier(ref.read(dioProvider));
});

class AlwaieDownloadNotifier extends StateNotifier<Map<String, DownloadState>> {
  final Dio dio;
  final Map<String, CancelToken> _cancelTokens = {};

  AlwaieDownloadNotifier(this.dio) : super({});

  Future<void> downloadAlwaie(Alwaie alwaie) async {
    final alwaieId = alwaie.id;

    // If already downloading or completed, return
    if (state[alwaieId]?.isDownloading == true ||
        state[alwaieId]?.isCompleted == true) {
      return;
    }

    // Create cancel token
    final cancelToken = CancelToken();
    _cancelTokens[alwaieId] = cancelToken;

    // Set initial state
    state = {
      ...state,
      alwaieId: const DownloadState(isDownloading: true, progress: 0),
    };

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${alwaie.id}_${alwaie.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf';
      final filePath = '${directory.path}/alwaie/$fileName';

      // Create directory if it doesn't exist
      await Directory('${directory.path}/alwaie').create(recursive: true);

      await dio.download(
        alwaie.pdfUrl,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            // Only update state if progress changes significantly (to avoid too many rebuilds)
            if (progress - (state[alwaieId]?.progress ?? 0) > 0.01 ||
                progress == 1.0) {
              state = {
                ...state,
                alwaieId: state[alwaieId]!.copyWith(progress: progress),
              };
            }
          }
        },
      );

      state = {
        ...state,
        alwaieId: state[alwaieId]!.copyWith(
          isDownloading: false,
          isCompleted: true,
          localPath: filePath,
        ),
      };

      // Remove cancel token
      _cancelTokens.remove(alwaieId);
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // Download was cancelled, remove the file if it was partially downloaded
        final currentState = state[alwaieId];
        if (currentState?.localPath != null) {
          try {
            await File(currentState!.localPath!).delete();
          } catch (_) {}
        }
        state = {...state};
        state.remove(alwaieId);
      } else {
        state = {
          ...state,
          alwaieId: DownloadState(error: e.toString()),
        };
      }
      _cancelTokens.remove(alwaieId);
    }
  }

  void removeDownload(String alwaieId) {
    // Cancel ongoing download if any
    _cancelTokens[alwaieId]?.cancel('User cancelled');
    _cancelTokens.remove(alwaieId);

    // Delete the file if it exists
    final currentState = state[alwaieId];
    if (currentState?.localPath != null) {
      try {
        File(currentState!.localPath!).delete();
      } catch (_) {}
    }

    // Remove from state
    state = {...state};
    state.remove(alwaieId);
  }

  bool isDownloaded(String alwaieId) {
    return state[alwaieId]?.isCompleted == true;
  }

  String? getLocalPath(String alwaieId) {
    return state[alwaieId]?.localPath;
  }
}
