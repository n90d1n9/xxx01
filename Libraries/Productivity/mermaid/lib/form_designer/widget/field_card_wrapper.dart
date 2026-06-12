import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/field_config.dart';
import 'container_field_card.dart';
import 'field_card.dart';

class FieldCardWrapper extends ConsumerWidget {
  final FieldConfig field;
  final int index;
  final String? parentId;
  final int depth;

  const FieldCardWrapper({
    super.key,
    required this.field,
    required this.index,
    this.parentId,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (field.isContainer) {
      return ContainerFieldCard(field: field, depth: depth);
    }
    return FieldCard(field: field, index: index, depth: depth);
  }
}
