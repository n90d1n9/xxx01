import 'package:queue_ui/signature/signature.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import 'financial_closing/closing_report.dart';
import 'financial_closing/syirkah.dart';
import 'table/ky_table_app.dart';

final widgets = [
  // Features
  Story(
    name: 'Widget/Signature',
    description: 'Showing siganture',
    builder: (context) => TrendySignaturePad(),
  ),
  Story(
    name: 'Widget/Syirkah closing',
    description: 'Showing siganture',
    builder: (context) => SyirkahClosingReportScreen(),
  ),
  Story(
    name: 'Widget/Syirkah Report',
    description: '',
    builder: (context) => SyirkahReportForm(),
  ),
  Story(
    name: 'Table/Ky Table',
    description: '',
    builder: (context) => KyTableApp(),
  ),
];
