import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_empty_state.dart';
import '../models/management_pack_field_visibility_mode.dart';

/// Empty state shown when a management pack field visibility mode hides every group.
class ProductManagementPackFieldEmptyState extends StatelessWidget {
  const ProductManagementPackFieldEmptyState({
    super.key,
    required this.visibilityMode,
    this.onShowAllFields,
  });

  final ProductManagementPackFieldVisibilityMode visibilityMode;
  final VoidCallback? onShowAllFields;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: _icon,
      title: _title,
      message: _message,
      action:
          onShowAllFields == null
              ? null
              : OutlinedButton.icon(
                onPressed: onShowAllFields,
                icon: const Icon(Icons.view_list_rounded),
                label: const Text('Show all fields'),
              ),
    );
  }

  IconData get _icon {
    return switch (visibilityMode) {
      ProductManagementPackFieldVisibilityMode.all =>
        Icons.dynamic_form_rounded,
      ProductManagementPackFieldVisibilityMode.requiredOnly =>
        Icons.rule_rounded,
    };
  }

  String get _title {
    return switch (visibilityMode) {
      ProductManagementPackFieldVisibilityMode.all =>
        'No pack fields available',
      ProductManagementPackFieldVisibilityMode.requiredOnly =>
        'No required pack fields',
    };
  }

  String get _message {
    return switch (visibilityMode) {
      ProductManagementPackFieldVisibilityMode.all =>
        'This management pack does not add editable product fields.',
      ProductManagementPackFieldVisibilityMode.requiredOnly =>
        'This pack only adds optional product attributes. Switch back to all fields to review them.',
    };
  }
}

@Preview(name: 'Management pack field empty state')
Widget productManagementPackFieldEmptyStatePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ProductManagementPackFieldEmptyState(
          visibilityMode: ProductManagementPackFieldVisibilityMode.requiredOnly,
          onShowAllFields: () {},
        ),
      ),
    ),
  );
}
