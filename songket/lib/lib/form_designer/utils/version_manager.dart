import 'package:flutter_riverpod/legacy.dart';

import '../model/field_config.dart';
import '../model/form_version.dart';

class VersionManager extends StateNotifier<List<FormVersion>> {
  VersionManager() : super([]);

  void createVersion(
    List<FieldConfig> fields,
    String title,
    String? changeLog,
  ) {
    final version = FormVersion(
      id: 'v_${DateTime.now().millisecondsSinceEpoch}',
      versionNumber: state.length + 1,
      title: title,
      fields: fields,
      createdAt: DateTime.now(),
      createdBy: 'current_user',
      changeLog: changeLog,
    );
    state = [...state, version];
  }

  void publishVersion(String versionId) {
    state = state.map((v) {
      if (v.id == versionId) {
        return FormVersion(
          id: v.id,
          versionNumber: v.versionNumber,
          title: v.title,
          fields: v.fields,
          createdAt: v.createdAt,
          createdBy: v.createdBy,
          changeLog: v.changeLog,
          diff: v.diff,
          isPublished: true,
          publishedAt: DateTime.now().toIso8601String(),
        );
      }
      return v;
    }).toList();
  }

  FormVersion? getVersion(String id) {
    try {
      return state.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  FormVersion? getLatestPublished() {
    final published = state.where((v) => v.isPublished).toList();
    if (published.isEmpty) return null;
    return published.last;
  }
}
