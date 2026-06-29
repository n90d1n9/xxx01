// Search templates
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/execution_log_entry.dart';
import '../models/template.dart';
import 'template_provider.dart';
// providers/template_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Template list provider
final templatesProvider =
    StateNotifierProvider<TemplateNotifier, List<Template>>((ref) {
      return TemplateNotifier();
    });

// Template search provider
final templateSearchProvider = StateProvider<String>((ref) => '');

// Filtered templates provider
final filteredTemplatesProvider = Provider<List<Template>>((ref) {
  final query = ref.watch(templateSearchProvider).toLowerCase();
  final templates = ref.watch(templatesProvider);

  if (query.isEmpty) return templates;

  return templates.where((template) {
    return template.name.toLowerCase().contains(query) ||
        template.description.toLowerCase().contains(query) ||
        template.category.toLowerCase().contains(query) ||
        template.tags.any((tag) => tag.toLowerCase().contains(query)) ||
        template.fields.any(
          (field) =>
              field.label.toLowerCase().contains(query) ||
              field.key.toLowerCase().contains(query),
        );
  }).toList();
});

// Selected template provider
final selectedTemplateProvider = StateProvider<Template?>((ref) => null);

// Template categories provider
final templateCategoriesProvider = Provider<List<String>>((ref) {
  final templates = ref.watch(templatesProvider);
  final categories = templates.map((t) => t.category).toSet().toList();
  categories.sort();
  return categories;
});

// Templates by category provider
final templatesByCategoryProvider = Provider.family<List<Template>, String>((
  ref,
  category,
) {
  final templates = ref.watch(filteredTemplatesProvider);
  return templates.where((template) => template.category == category).toList();
});

// Template execution history provider
final templateExecutionHistoryProvider =
    StateNotifierProvider<TemplateHistoryNotifier, List<ExecutionLogEntry>>((
      ref,
    ) {
      return TemplateHistoryNotifier();
    });

class TemplateNotifier extends StateNotifier<List<Template>> {
  TemplateNotifier() : super(_defaultTemplates);

  static final List<Template> _defaultTemplates = [
    Template(
      id: '1',
      name: 'User Profile',
      description: 'Template for user profile pages',
      icon: Icons.person,
      category: 'Profiles',
      defaultContext: {
        'name': 'John Doe',
        'email': 'john@example.com',
        'age': 30,
        'isActive': true,
      },
      fields: [
        TemplateField(
          key: 'name',
          label: 'Full Name',
          type: FieldType.text,
          required: true,
        ),
        TemplateField(
          key: 'email',
          label: 'Email Address',
          type: FieldType.email,
          required: true,
        ),
        TemplateField(key: 'age', label: 'Age', type: FieldType.number),
        TemplateField(
          key: 'isActive',
          label: 'Active Status',
          type: FieldType.boolean,
          defaultValue: true,
        ),
      ],
      tags: ['user', 'profile', 'personal'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Template(
      id: '2',
      name: 'Product Catalog',
      description: 'E-commerce product listing template',
      icon: Icons.shopping_cart,
      category: 'E-commerce',
      defaultContext: {
        'products': [
          {'name': 'Product 1', 'price': 29.99},
          {'name': 'Product 2', 'price': 39.99},
        ],
      },
      fields: [
        TemplateField(
          key: 'category',
          label: 'Product Category',
          type: FieldType.text,
          required: true,
        ),
        TemplateField(
          key: 'showPrices',
          label: 'Show Prices',
          type: FieldType.boolean,
          defaultValue: true,
        ),
      ],
      tags: ['products', 'catalog', 'ecommerce'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Template(
      id: '3',
      name: 'Invoice Template',
      description: 'Professional invoice template',
      icon: Icons.receipt,
      category: 'Business',
      defaultContext: {
        'invoiceNumber': 'INV-001',
        'date': '2024-01-15',
        'items': [
          {'description': 'Service 1', 'amount': 100.00},
        ],
      },
      fields: [
        TemplateField(
          key: 'companyName',
          label: 'Company Name',
          type: FieldType.text,
          required: true,
        ),
        TemplateField(
          key: 'customerName',
          label: 'Customer Name',
          type: FieldType.text,
          required: true,
        ),
      ],
      tags: ['invoice', 'business', 'billing'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

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

  Template? getTemplateById(String id) {
    try {
      return state.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Template> getTemplatesByCategory(String category) {
    return state.where((template) => template.category == category).toList();
  }

  List<Template> searchTemplates(String query) {
    if (query.isEmpty) return state;

    final lowerQuery = query.toLowerCase();
    return state
        .where(
          (template) =>
              template.name.toLowerCase().contains(lowerQuery) ||
              template.description.toLowerCase().contains(lowerQuery) ||
              template.category.toLowerCase().contains(lowerQuery) ||
              template.tags.any(
                (tag) => tag.toLowerCase().contains(lowerQuery),
              ),
        )
        .toList(); // Add .toList() here to convert Iterable to List
  }
}

class TemplateHistoryNotifier extends StateNotifier<List<ExecutionLogEntry>> {
  TemplateHistoryNotifier() : super([]);

  void addLogEntry(ExecutionLogEntry entry) {
    state = [entry, ...state].take(100).toList(); // Keep only last 100 entries
  }

  void clearHistory() {
    state = [];
  }

  List<ExecutionLogEntry> getEntriesForTemplate(String templateId) {
    return state.where((entry) => entry.templateId == templateId).toList();
  }

  List<ExecutionLogEntry> getRecentEntries(int count) {
    return state.take(count).toList();
  }
}
