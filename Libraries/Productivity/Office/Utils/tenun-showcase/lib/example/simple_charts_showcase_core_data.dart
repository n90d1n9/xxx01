import 'package:tenun/tenun_core.dart' hide FontWeight;

abstract final class SimpleChartsShowcaseCoreData {
  static const regionalGrowth = [
    SimpleBarChartData(label: 'Retail', value: 22),
    SimpleBarChartData(label: 'Health', value: 31),
    SimpleBarChartData(label: 'Finance', value: 18),
    SimpleBarChartData(label: 'Public', value: -6),
    SimpleBarChartData(label: 'Energy', value: 27),
    SimpleBarChartData(label: 'SaaS', value: 36),
  ];

  static const courseOutcomes = [
    SimpleBarChartData(label: 'Reading', value: 78),
    SimpleBarChartData(label: 'Writing', value: 72),
    SimpleBarChartData(label: 'Science', value: 84),
    SimpleBarChartData(label: 'Math', value: 88),
    SimpleBarChartData(label: 'Arts', value: 69),
  ];
}
