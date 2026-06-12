import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/widgets/project_custom_attribute_type_ui.dart';

void main() {
  test('custom attribute type ui maps icons, keyboards, and hints', () {
    final lightScheme = ColorScheme.fromSeed(seedColor: Colors.blue);

    expect(ProjectCustomAttributeType.text.icon, Icons.short_text_outlined);
    expect(ProjectCustomAttributeType.number.icon, Icons.pin_outlined);
    expect(ProjectCustomAttributeType.date.icon, Icons.event_outlined);
    expect(ProjectCustomAttributeType.url.icon, Icons.link_outlined);
    expect(ProjectCustomAttributeType.choice.icon, Icons.tune_outlined);
    expect(ProjectCustomAttributeType.boolean.icon, Icons.toggle_on_outlined);

    expect(
      ProjectCustomAttributeType.number.keyboardType,
      const TextInputType.numberWithOptions(decimal: true),
    );
    expect(
      ProjectCustomAttributeType.date.keyboardType,
      TextInputType.datetime,
    );
    expect(ProjectCustomAttributeType.url.keyboardType, TextInputType.url);
    expect(ProjectCustomAttributeType.text.keyboardType, TextInputType.text);

    expect(ProjectCustomAttributeType.date.valueHint, 'YYYY-MM-DD');
    expect(ProjectCustomAttributeType.boolean.valueHint, isNull);
    expect(
      ProjectCustomAttributeType.url.accentColor(lightScheme),
      Colors.blue.shade700,
    );
  });
}
