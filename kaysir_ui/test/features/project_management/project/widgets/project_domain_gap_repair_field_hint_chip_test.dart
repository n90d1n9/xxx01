import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_field_hint_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_repair_field_hint_chip.dart';

void main() {
  testWidgets('repair field hint chip renders type guidance', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairFieldHintChip(
            hint: ProjectDomainGapRepairFieldHint(
              type: ProjectCustomAttributeType.url,
              label: 'URL value',
              detail: 'Add the link or source of truth for Repository.',
            ),
          ),
        ),
      ),
    );

    expect(find.text('URL value'), findsOneWidget);
    expect(find.byIcon(Icons.link_outlined), findsOneWidget);
  });
}
