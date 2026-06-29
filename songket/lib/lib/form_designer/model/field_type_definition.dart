import 'package:flutter/material.dart';

class FieldTypeDefinition {
  final String type;
  final String label;
  final IconData icon;
  final String category;

  const FieldTypeDefinition({
    required this.type,
    required this.label,
    required this.icon,
    required this.category,
  });
}

const fieldTypes = [
  // Layout Containers
  FieldTypeDefinition(
    type: 'container',
    label: 'Container',
    icon: Icons.crop_square,
    category: 'Layout',
  ),
  FieldTypeDefinition(
    type: 'row',
    label: 'Row Layout',
    icon: Icons.view_week,
    category: 'Layout',
  ),
  FieldTypeDefinition(
    type: 'column',
    label: 'Column Layout',
    icon: Icons.view_agenda,
    category: 'Layout',
  ),
  FieldTypeDefinition(
    type: 'card',
    label: 'Card',
    icon: Icons.credit_card,
    category: 'Layout',
  ),
  FieldTypeDefinition(
    type: 'grid',
    label: 'Grid Layout',
    icon: Icons.grid_on,
    category: 'Layout',
  ),
  FieldTypeDefinition(
    type: 'section',
    label: 'Section Header',
    icon: Icons.title,
    category: 'Layout',
  ),
  FieldTypeDefinition(
    type: 'divider',
    label: 'Divider',
    icon: Icons.horizontal_rule,
    category: 'Layout',
  ),
  FieldTypeDefinition(
    type: 'html',
    label: 'HTML/Text',
    icon: Icons.text_snippet,
    category: 'Layout',
  ),

  // Input Fields
  FieldTypeDefinition(
    type: 'text',
    label: 'Text Input',
    icon: Icons.text_fields,
    category: 'Input',
  ),
  FieldTypeDefinition(
    type: 'email',
    label: 'Email',
    icon: Icons.email,
    category: 'Input',
  ),
  FieldTypeDefinition(
    type: 'password',
    label: 'Password',
    icon: Icons.lock,
    category: 'Input',
  ),
  FieldTypeDefinition(
    type: 'number',
    label: 'Number',
    icon: Icons.numbers,
    category: 'Input',
  ),
  FieldTypeDefinition(
    type: 'tel',
    label: 'Phone',
    icon: Icons.phone,
    category: 'Input',
  ),
  FieldTypeDefinition(
    type: 'url',
    label: 'URL',
    icon: Icons.link,
    category: 'Input',
  ),
  FieldTypeDefinition(
    type: 'textarea',
    label: 'Text Area',
    icon: Icons.notes,
    category: 'Input',
  ),

  // Selection Fields
  FieldTypeDefinition(
    type: 'select',
    label: 'Dropdown',
    icon: Icons.arrow_drop_down_circle,
    category: 'Selection',
  ),
  FieldTypeDefinition(
    type: 'radio',
    label: 'Radio Group',
    icon: Icons.radio_button_checked,
    category: 'Selection',
  ),
  FieldTypeDefinition(
    type: 'checkbox',
    label: 'Checkbox',
    icon: Icons.check_box,
    category: 'Selection',
  ),
  FieldTypeDefinition(
    type: 'switch',
    label: 'Switch',
    icon: Icons.toggle_on,
    category: 'Selection',
  ),
  FieldTypeDefinition(
    type: 'chips',
    label: 'Chips',
    icon: Icons.label,
    category: 'Selection',
  ),
  FieldTypeDefinition(
    type: 'slider',
    label: 'Slider',
    icon: Icons.linear_scale,
    category: 'Input',
  ),

  // DateTime
  FieldTypeDefinition(
    type: 'date',
    label: 'Date',
    icon: Icons.calendar_today,
    category: 'DateTime',
  ),
  FieldTypeDefinition(
    type: 'time',
    label: 'Time',
    icon: Icons.access_time,
    category: 'DateTime',
  ),

  // Special
  FieldTypeDefinition(
    type: 'rating',
    label: 'Rating',
    icon: Icons.star,
    category: 'Special',
  ),
  FieldTypeDefinition(
    type: 'tags',
    label: 'Tags',
    icon: Icons.local_offer,
    category: 'Special',
  ),
];
