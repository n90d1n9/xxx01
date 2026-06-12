import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'model/content_type_schema.dart';
import '../services/cms_repository.dart';
import '../states/cms_repository_provider.dart';

final contentTypesProvider =
    StateNotifierProvider<
      ContentTypesNotifier,
      AsyncValue<List<ContentTypeSchema>>
    >((ref) {
      return ContentTypesNotifier(ref.watch(cmsRepositoryProvider));
    });

class ContentTypesNotifier
    extends StateNotifier<AsyncValue<List<ContentTypeSchema>>> {
  final CMSRepository _repository;

  ContentTypesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadContentTypes();
  }

  Future<void> _loadContentTypes() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getContentTypes());
  }

  Future<void> create(ContentTypeSchema contentType) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createContentType(contentType);
      return _repository.getContentTypes();
    });
  }

  Future<void> update(ContentTypeSchema contentType) async {
    state = await AsyncValue.guard(() async {
      await _repository.updateContentType(contentType);
      return _repository.getContentTypes();
    });
  }

  Future<void> delete(String id) async {
    state = await AsyncValue.guard(() async {
      await _repository.deleteContentType(id);
      return _repository.getContentTypes();
    });
  }

  void refresh() => _loadContentTypes();
}
