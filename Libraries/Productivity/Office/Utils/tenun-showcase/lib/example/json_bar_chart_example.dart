import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

/// Example demonstrating JSON-driven bar chart configuration
///
/// This example shows how to create bar charts using pure JSON configuration
/// without manually creating config objects in Dart code.
class JsonBarChartExample extends StatelessWidget {
  const JsonBarChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JSON-Driven Bar Chart'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Simple Bar Chart from JSON',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: TenunChartFromJson(
                jsonConfig: _simpleBarChartJson,
                padding: const EdgeInsets.all(8),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '2. Multi-Series Bar Chart from JSON',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 350,
              child: TenunChartFromJson(
                jsonConfig: _multiSeriesBarChartJson,
                padding: const EdgeInsets.all(8),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '3. Stacked Bar Chart from JSON',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 350,
              child: TenunChartFromJson(
                jsonConfig: _stackedBarChartJson,
                padding: const EdgeInsets.all(8),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '4. Using TenunChart with Config Object',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: TenunChart(
                config: _createConfigObject(),
                padding: const EdgeInsets.all(8),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '5. Dynamic JSON from API/Database',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can load chart configuration from JSON files, APIs, or databases:\n\n'
              '```dart\n'
              '// From JSON file\n'
              'final jsonString = await rootBundle.loadString(\'assets/chart.json\');\n'
              'final chartJson = jsonDecode(jsonString);\n'
              '\n'
              '// From API\n'
              'final response = await http.get(Uri.parse(\'/api/chart-data\'));\n'
              'final chartJson = jsonDecode(response.body);\n'
              '\n'
              '// Render chart\n'
              'return TenunChartFromJson(jsonConfig: chartJson);\n'
              '```',
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Simple bar chart configuration
  static final Map<String, dynamic> _simpleBarChartJson = {
    'type': 'bar',
    'title': {
      'text': 'Monthly Sales',
      'subtext': '2024 Performance',
      'fontSize': 16,
      'fontWeight': 'bold',
    },
    'tooltip': {
      'show': true,
      'textColor': '#FFFFFF',
      'backgroundColor': '#333333',
    },
    'legend': {'show': true, 'textColor': '#000000', 'fontSize': 12},
    'xAxis': {
      'show': true,
      'data': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
      'fontSize': 10,
      'color': '#666666',
    },
    'yAxis': {
      'show': true,
      'name': 'Revenue (\$)',
      'fontSize': 10,
      'color': '#666666',
      'nameColor': '#333333',
    },
    'grid': {
      'show': true,
      'showHorizontalLines': true,
      'showVerticalLines': false,
      'horizontalColor': '#E0E0E0',
      'horizontalWidth': 0.5,
    },
    'series': [
      {
        'name': 'Sales',
        'data': [120, 200, 150, 80, 70, 110],
        'color': '#5470C6',
      },
    ],
    'barWidth': 20,
    'barBorderRadius': 4,
    'alignment': 'center',
  };

  /// Multi-series bar chart configuration
  static final Map<String, dynamic> _multiSeriesBarChartJson = {
    'type': 'bar',
    'title': {
      'text': 'Quarterly Sales by Product',
      'subtext': 'Product Comparison Q1-Q4',
      'fontSize': 16,
    },
    'tooltip': {
      'show': true,
      'textColor': '#FFFFFF',
      'backgroundColor': '#333333',
      'formatter': '{c} units',
    },
    'legend': {
      'show': true,
      'data': ['Product A', 'Product B', 'Product C'],
      'textColor': '#000000',
    },
    'xAxis': {
      'show': true,
      'data': ['Q1', 'Q2', 'Q3', 'Q4'],
      'fontSize': 11,
    },
    'yAxis': {'show': true, 'name': 'Units Sold', 'fontSize': 10},
    'grid': {
      'show': true,
      'showHorizontalLines': true,
      'showVerticalLines': false,
    },
    'series': [
      {
        'name': 'Product A',
        'data': [120, 132, 101, 134],
        'color': '#5470C6',
      },
      {
        'name': 'Product B',
        'data': [220, 182, 191, 234],
        'color': '#91CC75',
      },
      {
        'name': 'Product C',
        'data': [150, 232, 201, 154],
        'color': '#FAC858',
      },
    ],
    'barWidth': 14,
    'barBorderRadius': 2,
    'alignment': 'spaceAround',
    'maxY': 300,
  };

  /// Stacked bar chart configuration
  static final Map<String, dynamic> _stackedBarChartJson = {
    'type': 'bar',
    'isStacked': true,
    'title': {'text': 'Revenue by Region', 'subtext': 'Stacked View'},
    'tooltip': {'show': true},
    'legend': {
      'show': true,
      'data': ['North', 'South', 'East', 'West'],
    },
    'xAxis': {
      'data': ['2021', '2022', '2023', '2024'],
    },
    'yAxis': {'name': 'Revenue (M)'},
    'grid': {'show': true},
    'series': [
      {
        'name': 'North',
        'data': [120, 132, 101, 134],
        'color': '#5470C6',
      },
      {
        'name': 'South',
        'data': [220, 182, 191, 234],
        'color': '#91CC75',
      },
      {
        'name': 'East',
        'data': [150, 232, 201, 154],
        'color': '#FAC858',
      },
      {
        'name': 'West',
        'data': [98, 79, 101, 94],
        'color': '#EE6666',
      },
    ],
    'barWidth': 16,
    'barBorderRadius': 0,
    'alignment': 'center',
    'maxY': 700,
  };

  /// Example of creating chart using config object (alternative to JSON)
  BaseChartConfig _createConfigObject() {
    return BarChartConfig(
      title: TitlesData(
        text: 'Config Object Example',
        subtext: 'Built without raw JSON',
      ),
      tooltip: ChartTooltip(show: true),
      legend: ChartLegend(show: true),
      grid: GridData(show: true, showHorizontalLines: true),
      xAxis: XYAxis(data: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
      series: [
        Series(
          type: ChartType.bar,
          name: 'Orders',
          data: const [120, 180, 150, 200, 170],
          color: const Color(0xFF5470C6),
        ),
      ],
      barWidth: 18,
      barBorderRadiusValue: 4,
      alignment: BarChartAlignment.center,
    );
  }
}

/// Example showing how to load chart config from external JSON file
class ExternalJsonChartExample extends StatelessWidget {
  const ExternalJsonChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('External JSON Chart')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadChartJson(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: TenunChartFromJson(jsonConfig: snapshot.data!),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadChartJson() async {
    // Example: Load from assets
    // final jsonString = await rootBundle.loadString('assets/charts/bar_chart.json');
    // return jsonDecode(jsonString);

    // Example: Load from API
    // final response = await http.get(Uri.parse('https://api.example.com/chart-data'));
    // return jsonDecode(response.body);

    // For demo, return inline JSON
    return {
      'type': 'bar',
      'title': {'text': 'Loaded from JSON'},
      'xAxis': {
        'data': ['A', 'B', 'C', 'D'],
      },
      'series': [
        {
          'name': 'Series 1',
          'data': [10, 20, 15, 25],
        },
      ],
    };
  }
}
