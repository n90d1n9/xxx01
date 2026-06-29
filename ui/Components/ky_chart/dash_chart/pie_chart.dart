import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/* 
class ChartDataProvider with ChangeNotifier {
  List<PieChartData> _data = [
    PieChartData('Category A', 30, Colors.blue),
    PieChartData('Category B', 25, Colors.red),
    PieChartData('Category C', 20, Colors.green),
    PieChartData('Category D', 15, Colors.yellow),
    PieChartData('Category E', 10, Colors.purple),
  ];

  List<PieChartData> get data => _data;

  void updateValue(int index, double newValue) {
    if (index >= 0 && index < _data.length) {
      _data[index] = _data[index].copyWith(value: newValue);
      notifyListeners();
    }
  }

  void addCategory(String title, double value, Color color) {
    _data.add(PieChartData(title, value, color));
    notifyListeners();
  }

  void removeCategory(int index) {
    if (index >= 0 && index < _data.length) {
      _data.removeAt(index);
      notifyListeners();
    }
  }
} */

class PieChartModel {
  final String title;
  final double value;
  final Color color;

  PieChartModel(this.title, this.value, this.color);

  PieChartModel copyWith({
    String? title,
    double? value,
    Color? color,
  }) {
    return PieChartModel(
      title ?? this.title,
      value ?? this.value,
      color ?? this.color,
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final List<PieChartModel> data;
  const PieChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: data.map((item) {
                return PieChartSectionData(
                  value: item.value,
                  color: item.color,
                  title: '${item.value}%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: data.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value;
            return _buildLegendItem(
              context,
              value,
              index,
              data,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    PieChartModel data,
    int index,
    List<PieChartModel> item,
  ) {
    return GestureDetector(
      onTap: () => _showUpdateDialog(
        context,
        data,
        index,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${data.title}: ${data.value}%',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(
    BuildContext context,
    PieChartModel data,
    int index,
    //ChartDataProvider provider,
  ) {
    final controller = TextEditingController(text: data.value.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${data.title}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'New value',
            suffixText: '%',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text);
              if (newValue != null) {
                // provider.updateValue(index, newValue);
              }
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

/* 

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Interactive Pie Chart'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: PieChartWidget(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final provider = context.read<ChartDataProvider>();
            provider.addCategory(
              'New Category',
              10,
              Colors.orange,
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
} */