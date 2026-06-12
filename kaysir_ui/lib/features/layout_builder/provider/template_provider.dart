import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/template.dart';

const _templateStorageKey = 'layout_builder.templates.v1';

final templateRepositoryProvider = Provider<LayoutTemplateRepository>((ref) {
  return LayoutTemplateRepository();
});

final templateProvider = FutureProvider<List<Template>>((ref) async {
  return ref.watch(templateRepositoryProvider).loadTemplates();
});

class LayoutTemplateRepository {
  Future<List<Template>> loadTemplates() async {
    await _ensureDatabase();

    final stored = await LocalDBService.getPreference(key: _templateStorageKey);
    final rawTemplates = stored is List ? stored : const [];

    final templates =
        rawTemplates
            .whereType<Map>()
            .map((item) => Template.fromJson(Map<String, dynamic>.from(item)))
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return templates;
  }

  Future<void> saveTemplate(Template template) async {
    final templates = await loadTemplates();
    final now = DateTime.now();
    final nextTemplate = template.copyWith(updatedAt: now);
    final nextTemplates = [
      nextTemplate,
      ...templates.where((item) => item.id != template.id),
    ];

    await _saveTemplates(nextTemplates);
  }

  Future<void> deleteTemplate(String templateId) async {
    final templates = await loadTemplates();
    await _saveTemplates(
      templates.where((template) => template.id != templateId).toList(),
    );
  }

  Future<void> _saveTemplates(List<Template> templates) async {
    await _ensureDatabase();
    await LocalDBService.savePreference(
      key: _templateStorageKey,
      value: templates.map((template) => template.toJson()).toList(),
    );
  }

  Future<void> _ensureDatabase() async {
    await LocalDBService.initialize(encryptionPassword: 'your-secure-password');
  }
}
