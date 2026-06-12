import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute_value.dart';

void main() {
  test('custom attribute value parser normalizes boolean values', () {
    expect(parseProjectCustomAttributeBool('Yes'), isTrue);
    expect(parseProjectCustomAttributeBool('enabled'), isTrue);
    expect(parseProjectCustomAttributeBool('No'), isFalse);
    expect(parseProjectCustomAttributeBool('disabled'), isFalse);
    expect(parseProjectCustomAttributeBool('maybe'), isNull);
    expect(projectCustomAttributeBooleanDisplayValue('enabled'), 'Yes');
    expect(projectCustomAttributeBooleanDisplayValue('disabled'), 'No');
    expect(projectCustomAttributeBooleanEditValue('1'), 'Yes');
    expect(projectCustomAttributeBooleanEditValue('maybe'), '');
  });

  test('custom attribute value parser handles typed values', () {
    expect(parseProjectCustomAttributeNumber('1,200.5'), 1200.5);
    expect(parseProjectCustomAttributeNumber('NaN'), isNull);
    expect(parseProjectCustomAttributeNumber('many'), isNull);

    expect(parseProjectCustomAttributeIsoDate('2026-06-12'), isNotNull);
    expect(parseProjectCustomAttributeIsoDate('2026-02-31'), isNull);
    expect(parseProjectCustomAttributeIsoDate('12/06/2026'), isNull);

    expect(parseProjectCustomAttributeWebUrl('https://example.com'), isNotNull);
    expect(parseProjectCustomAttributeWebUrl('http://example.com'), isNotNull);
    expect(parseProjectCustomAttributeWebUrl('example.com'), isNull);
  });
}
