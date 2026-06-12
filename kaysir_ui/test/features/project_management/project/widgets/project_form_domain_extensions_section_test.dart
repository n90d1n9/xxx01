import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_custom_attribute_templates.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_domain_extensions_section.dart';

void main() {
  testWidgets('project form domain extensions section forwards value edits', (
    tester,
  ) async {
    List<ProjectCustomAttribute>? changedAttributes;

    await tester.pumpWidget(
      _DomainExtensionsHarness(
        attributes: defaultProjectCustomAttributesForDomain(
          'Software Development',
        ),
        onChanged: (attributes) => changedAttributes = attributes,
      ),
    );

    final valueField = find.byKey(
      const ValueKey('project-custom-attribute-value-repository'),
    );
    await tester.enterText(
      find.descendant(of: valueField, matching: find.byType(TextField)),
      'https://example.test/kaysir',
    );

    expect(
      changedAttributes
          ?.firstWhere((attribute) => attribute.key == 'repository')
          .value,
      'https://example.test/kaysir',
    );
  });

  testWidgets('project form domain extensions section forwards focus target', (
    tester,
  ) async {
    await tester.pumpWidget(
      _DomainExtensionsHarness(
        attributes: defaultProjectCustomAttributesForDomain(
          'Software Development',
        ),
        focusedAttributeKey: 'Repository',
        onChanged: (_) {},
      ),
    );
    await tester.pumpAndSettle();

    final row = find.byKey(
      const ValueKey('project-custom-attribute-row-repository'),
    );
    final valueField = find.byKey(
      const ValueKey('project-custom-attribute-value-repository'),
    );
    final textField = tester.widget<TextField>(
      find.descendant(of: valueField, matching: find.byType(TextField)),
    );

    expect(row, findsOneWidget);
    expect(textField.autofocus, isTrue);
    expect(textField.focusNode?.hasFocus, isTrue);
  });
}

class _DomainExtensionsHarness extends StatelessWidget {
  const _DomainExtensionsHarness({
    required this.attributes,
    required this.onChanged,
    this.focusedAttributeKey,
  });

  final List<ProjectCustomAttribute> attributes;
  final ValueChanged<List<ProjectCustomAttribute>> onChanged;
  final String? focusedAttributeKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 960,
          height: 640,
          child: SingleChildScrollView(
            child: ProjectFormDomainExtensionsSection(
              businessDomain: 'Software Development',
              attributes: attributes,
              focusedAttributeKey: focusedAttributeKey,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}
