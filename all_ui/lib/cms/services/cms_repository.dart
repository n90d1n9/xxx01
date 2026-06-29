import 'dart:convert';
//main
import '../content/model/content_entry.dart';
import '../content/model/content_type_schema.dart';
import '../code_generator/code_generation_engine.dart';

class CMSRepository {
  final Map<String, ContentTypeSchema> _contentTypes = {};
  final Map<String, List<ContentEntry>> _entries = {};
  int _idCounter = 1;

  String _generateId() =>
      'id_${_idCounter++}_${DateTime.now().millisecondsSinceEpoch}';

  Future<List<ContentTypeSchema>> getContentTypes() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _contentTypes.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<ContentTypeSchema?> getContentType(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _contentTypes[id];
  }

  Future<ContentTypeSchema> createContentType(
    ContentTypeSchema contentType,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _contentTypes[contentType.id] = contentType;
    _entries[contentType.id] = [];
    return contentType;
  }

  Future<ContentTypeSchema> updateContentType(
    ContentTypeSchema contentType,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final updated = contentType.copyWith(
      version: contentType.version + 1,
      updatedAt: DateTime.now(),
    );
    _contentTypes[contentType.id] = updated;
    return updated;
  }

  Future<void> deleteContentType(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _contentTypes.remove(id);
    _entries.remove(id);
  }

  Future<List<ContentEntry>> getEntries(String contentTypeId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _entries[contentTypeId] ?? [];
  }

  Future<ContentEntry> createEntry(ContentEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _entries[entry.contentTypeId] = [
      ..._entries[entry.contentTypeId] ?? [],
      entry,
    ];
    return entry;
  }

  Future<ContentEntry> updateEntry(ContentEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final entries = List<ContentEntry>.from(
      _entries[entry.contentTypeId] ?? [],
    );
    final idx = entries.indexWhere((e) => e.id == entry.id);
    if (idx != -1) {
      entries[idx] = entry.copyWith(version: entry.version + 1);
      _entries[entry.contentTypeId] = entries;
    }
    return entry;
  }

  Future<void> deleteEntry(String contentTypeId, String entryId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _entries[contentTypeId] =
        (_entries[contentTypeId] ?? []).where((e) => e.id != entryId).toList();
  }

  /// Export schema as SQL
  String exportSchemaAsSQL(String contentTypeId) {
    final contentType = _contentTypes[contentTypeId];
    if (contentType == null) return '';
    return contentType.toCreateTableSQL();
  }

  /// Export schema as JSON
  String exportSchemaAsJSON(String contentTypeId) {
    final contentType = _contentTypes[contentTypeId];
    if (contentType == null) return '';
    return const JsonEncoder.withIndent('  ').convert(contentType.toJson());
  }

  /// Generate Quarkus project
  Map<String, String> generateQuarkusProject() {
    final schemas = _contentTypes.values.toList();
    final engine = CodeGenerationEngine();
    return engine.generateQuarkusProject(schemas);
  }
}
