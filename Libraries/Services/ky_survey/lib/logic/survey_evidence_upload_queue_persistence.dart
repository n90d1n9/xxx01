import 'dart:convert';

import 'survey_evidence_upload_queue.dart';
import 'survey_evidence_upload_queue_coordinator.dart';
import 'survey_evidence_upload_service.dart';

const int surveyEvidenceUploadQueueSnapshotVersion = 1;

DateTime _defaultEvidenceUploadQueueSnapshotClock() => DateTime.now();

typedef SurveyEvidenceUploadQueueJsonReader = Future<String?> Function();
typedef SurveyEvidenceUploadQueueJsonWriter =
    Future<void> Function(String json);
typedef SurveyEvidenceUploadQueueDecodeErrorHandler =
    void Function(Object error, StackTrace stackTrace);

class SurveyEvidenceUploadQueueSnapshot {
  final int schemaVersion;
  final SurveyEvidenceUploadQueue queue;
  final DateTime savedAt;
  final Map<String, dynamic> metadata;

  const SurveyEvidenceUploadQueueSnapshot({
    required this.queue,
    required this.savedAt,
    this.schemaVersion = surveyEvidenceUploadQueueSnapshotVersion,
    this.metadata = const {},
  });

  factory SurveyEvidenceUploadQueueSnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    return SurveyEvidenceUploadQueueSnapshot(
      schemaVersion: _intFromJson(json['schemaVersion']),
      queue: _queueFromJson(json),
      savedAt:
          _dateTimeFromJson(json['savedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }

  bool get isCurrentSchema {
    return schemaVersion == surveyEvidenceUploadQueueSnapshotVersion;
  }

  bool get isNewerSchema {
    return schemaVersion > surveyEvidenceUploadQueueSnapshotVersion;
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'savedAt': savedAt.toIso8601String(),
      'queue': queue.toJson(),
      'metadata': metadata,
    };
  }

  static int _intFromJson(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  static DateTime? _dateTimeFromJson(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static SurveyEvidenceUploadQueue _queueFromJson(Map<String, dynamic> json) {
    final queueJson = json['queue'];
    if (queueJson is Map) {
      return SurveyEvidenceUploadQueue.fromJson(
        Map<String, dynamic>.from(queueJson),
      );
    }

    // Legacy snapshots stored the queue object directly at the top level.
    return SurveyEvidenceUploadQueue.fromJson(json);
  }
}

class SurveyEvidenceUploadQueueSnapshotCodec {
  const SurveyEvidenceUploadQueueSnapshotCodec();

  SurveyEvidenceUploadQueueSnapshot decodeJson(Map<String, dynamic> json) {
    return SurveyEvidenceUploadQueueSnapshot.fromJson(json);
  }

  SurveyEvidenceUploadQueueSnapshot decodeString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map) {
      throw const FormatException(
        'Evidence upload queue snapshot must decode to a JSON object.',
      );
    }

    return decodeJson(Map<String, dynamic>.from(decoded));
  }

  Map<String, dynamic> encodeJson(SurveyEvidenceUploadQueueSnapshot snapshot) {
    return snapshot.toJson();
  }

  String encodeString(SurveyEvidenceUploadQueueSnapshot snapshot) {
    return jsonEncode(encodeJson(snapshot));
  }
}

class SurveyEvidenceUploadJsonQueueStore
    implements SurveyEvidenceUploadQueueStore {
  final SurveyEvidenceUploadQueueJsonReader readJson;
  final SurveyEvidenceUploadQueueJsonWriter writeJson;
  final SurveyEvidenceUploadQueueSnapshotCodec codec;
  final SurveyEvidenceUploadClock clock;
  final SurveyEvidenceUploadQueue fallbackQueue;
  final Map<String, dynamic> metadata;
  final bool resetOnDecodeError;
  final SurveyEvidenceUploadQueueDecodeErrorHandler? onDecodeError;

  const SurveyEvidenceUploadJsonQueueStore({
    required this.readJson,
    required this.writeJson,
    this.codec = const SurveyEvidenceUploadQueueSnapshotCodec(),
    this.clock = _defaultEvidenceUploadQueueSnapshotClock,
    this.fallbackQueue = const SurveyEvidenceUploadQueue(),
    this.metadata = const {},
    this.resetOnDecodeError = false,
    this.onDecodeError,
  });

  @override
  Future<SurveyEvidenceUploadQueue> load() async {
    final jsonString = await readJson();
    if (jsonString == null || jsonString.trim().isEmpty) {
      return fallbackQueue;
    }

    try {
      return codec.decodeString(jsonString).queue;
    } catch (error, stackTrace) {
      onDecodeError?.call(error, stackTrace);
      if (resetOnDecodeError) {
        return fallbackQueue;
      }
      rethrow;
    }
  }

  @override
  Future<void> save(SurveyEvidenceUploadQueue queue) async {
    final snapshot = SurveyEvidenceUploadQueueSnapshot(
      queue: queue,
      savedAt: clock(),
      metadata: metadata,
    );

    await writeJson(codec.encodeString(snapshot));
  }
}

class SurveyEvidenceUploadMemoryJsonStorage {
  String? _json;

  SurveyEvidenceUploadMemoryJsonStorage({String? initialJson})
    : _json = initialJson;

  String? get json => _json;

  Future<String?> read() async => _json;

  Future<void> write(String json) async {
    _json = json;
  }
}
