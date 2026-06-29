import 'package:flutter/material.dart';

import 'field_type_definition.dart';

enum AdvancedLayoutType { tabs, stepper, accordion, wizard, splitPane }

const advancedLayoutFieldTypes = [
  FieldTypeDefinition(
    type: 'tabs',
    label: 'Tabs Layout',
    icon: Icons.tab,
    category: 'Advanced',
  ),
  FieldTypeDefinition(
    type: 'stepper',
    label: 'Stepper/Wizard',
    icon: Icons.stairs,
    category: 'Advanced',
  ),
  FieldTypeDefinition(
    type: 'accordion',
    label: 'Accordion',
    icon: Icons.expand_more,
    category: 'Advanced',
  ),
  FieldTypeDefinition(
    type: 'split',
    label: 'Split Pane',
    icon: Icons.vertical_split,
    category: 'Advanced',
  ),
];
