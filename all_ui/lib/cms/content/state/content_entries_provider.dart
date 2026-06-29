import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/content_entry.dart';
import '../../services/cms_repository.dart';
import '../../states/cms_repository_provider.dart';

final contentEntriesProvider = StateNotifierProvider.family<
  ContentEntriesNotifier,
  AsyncValue<List<ContentEntry>>,
  String
>((ref, contentTypeId) {
  return ContentEntriesNotifier(
    ref.watch(cmsRepositoryProvider),
    contentTypeId,
  );
});

class ContentEntriesNotifier
    extends StateNotifier<AsyncValue<List<ContentEntry>>> {
  final CMSRepository _repository;
  final String contentTypeId;

  ContentEntriesNotifier(this._repository, this.contentTypeId)
    : super(const AsyncValue.loading()) {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getEntries(contentTypeId));
  }

  Future<void> create(ContentEntry entry) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createEntry(entry);
      return _repository.getEntries(contentTypeId);
    });
  }

  Future<void> update(ContentEntry entry) async {
    state = await AsyncValue.guard(() async {
      await _repository.updateEntry(entry);
      return _repository.getEntries(contentTypeId);
    });
  }

  Future<void> delete(String entryId) async {
    state = await AsyncValue.guard(() async {
      await _repository.deleteEntry(contentTypeId, entryId);
      return _repository.getEntries(contentTypeId);
    });
  }

  void refresh() => _loadEntries();
}
