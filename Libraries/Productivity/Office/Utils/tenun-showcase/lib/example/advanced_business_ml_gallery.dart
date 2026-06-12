import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

class AdvancedBusinessMLGallery extends StatelessWidget {
  const AdvancedBusinessMLGallery({super.key});

  @override
  Widget build(BuildContext context) {
    registerTenunProBusinessAiMlCharts();
    registerTenunProAdvancedPieRadialCharts(includeCore: false);
    registerTenunProAdvancedCartesianCharts(includeCore: false);
    registerTenunProHierarchyFlowGraphCharts(includeCore: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Business & AI/ML Gallery')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('1. Confusion Matrix (AI/ML)', _confusionMatrix, 320),
          _section('2. ROC Curve (AI/ML)', _rocCurve, 320),
          _section('3. S-Curve (Project)', _sCurve, 320),
          _section('4. Pareto Chart (Business)', _pareto, 350),
          _section('5. KPI Indicators (Dashboard)', _indicators(), 150),
          _section('6. Bullet Chart (KPIs)', _bullet, 300),
          _section('7. Slope Chart (Comparison)', _slope, 300),
          _section('8. Sunburst (Hierarchy)', _sunburst, 400),
        ],
      ),
    );
  }

  Widget _section(String title, dynamic content, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: height,
          child: content is Map<String, dynamic>
              ? TenunChartJson(jsonConfig: content)
              : content as Widget,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  static const Map<String, dynamic> _confusionMatrix = {
    'type': 'confusionMatrix',
    'title': {'text': 'Model Accuracy'},
    'labels': ['Class A', 'Class B', 'Class C'],
    'data': [
      [45, 2, 3],
      [5, 38, 7],
      [2, 8, 40],
    ],
    'baseColor': '#673AB7',
  };

  static const Map<String, dynamic> _rocCurve = {
    'type': 'rocCurve',
    'title': {'text': 'Binary Classifier ROC'},
    'series': [
      {
        'name': 'Model X',
        'color': '#FF5722',
        'data': [
          [0, 0],
          [0.1, 0.5],
          [0.3, 0.8],
          [0.6, 0.95],
          [1, 1],
        ],
      },
    ],
  };

  static const Map<String, dynamic> _sCurve = {
    'type': 'sCurve',
    'title': {'text': 'Project Burn-up'},
    'series': [
      {
        'name': 'Target',
        'data': [10, 20, 30, 20, 15, 5],
        'color': '#9E9E9E',
      },
      {
        'name': 'Actual',
        'data': [8, 22, 28, 25],
        'color': '#009688',
      },
    ],
  };

  static const Map<String, dynamic> _pareto = {
    'type': 'pareto',
    'title': {'text': 'Defect Sources'},
    'xAxis': {
      'data': ['Code', 'Docs', 'Test', 'UI', 'API'],
    },
    'series': [
      {
        'name': 'Count',
        'data': [150, 40, 80, 20, 10],
      },
    ],
    'lineIndicatorColor': '#E91E63',
  };

  Widget _indicators() {
    return Row(
      children: [
        Expanded(
          child: TenunChartJson(
            jsonConfig: {
              'type': 'indicator',
              'label': 'Growth',
              'value': 24.5,
              'previousValue': 18.2,
              'unit': '%',
              'precision': 1,
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TenunChartJson(
            jsonConfig: {
              'type': 'indicator',
              'label': 'Uptime',
              'value': 99.98,
              'unit': '%',
              'precision': 2,
            },
          ),
        ),
      ],
    );
  }

  static const Map<String, dynamic> _bullet = {
    'type': 'bullet',
    'title': {'text': 'Sales vs Quota'},
    'series': [
      {
        'data': [
          {
            'label': 'Region West',
            'value': 85,
            'target': 90,
            'max': 100,
            'bands': [
              {'to': 60, 'color': '#FFCDD2'},
              {'to': 80, 'color': '#FFF9C4'},
              {'to': 100, 'color': '#C8E6C9'},
            ],
          },
        ],
      },
    ],
  };

  static const Map<String, dynamic> _slope = {
    'type': 'slope',
    'title': {'text': 'Employee Satisfaction'},
    'columnLabels': ['2023', '2024'],
    'series': [
      {
        'name': 'Engineering',
        'data': [65, 88],
      },
      {
        'name': 'Marketing',
        'data': [82, 79],
      },
      {
        'name': 'Sales',
        'data': [45, 72],
      },
      {
        'name': 'HR',
        'data': [78, 75],
      },
    ],
  };

  static const Map<String, dynamic> _sunburst = {
    'type': 'sunburst',
    'centerText': 'Expenses',
    'series': [
      {
        'data': [
          {
            'name': 'Fixed',
            'value': 60,
            'children': [
              {'name': 'Rent', 'value': 40},
              {'name': 'Salaries', 'value': 20},
            ],
          },
          {
            'name': 'Variable',
            'value': 40,
            'children': [
              {'name': 'Marketing', 'value': 25},
              {'name': 'Cloud', 'value': 15},
            ],
          },
        ],
      },
    ],
  };
}
