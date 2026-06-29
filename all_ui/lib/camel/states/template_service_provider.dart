// providers/template_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/template.dart';
import '../services/template_service.dart';

final templateServiceProvider = Provider<TemplateService>((ref) {
  return TemplateService();
});

// Or if you need to maintain state:
final templateStateProvider =
    StateNotifierProvider<TemplateNotifier, List<Template>>((ref) {
      return TemplateNotifier();
    });

class TemplateNotifier extends StateNotifier<List<Template>> {
  TemplateNotifier() : super([]);

  void addTemplate(Template template) {
    state = [...state, template];
  }

  void updateTemplate(String id, Template updatedTemplate) {
    state =
        state
            .map((template) => template.id == id ? updatedTemplate : template)
            .toList();
  }

  void deleteTemplate(String id) {
    state = state.where((template) => template.id != id).toList();
  }
}
