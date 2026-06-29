import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ky_chart/model/chart_model.dart';
import 'package:ky_chart/model/pie_series.dart';
import 'package:ky_chart/utils/helper.dart';

class KPie extends StatelessWidget {
  final ChartConfig config;
  const KPie({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    List<PieSeries> pieData = [];

    if (config.series[0].data!.isNotEmpty &&
        config.series[0].data![0].value != null) {
      pieData = config.series[0].data!
          .map(((e) => PieSeries(value: e.value, name: e.name)))
          .toList();
      return _buildPieChart(context, pieData);
    } else {
      return const Center(child: Text('Data not relevant for Pie Chart'));
    }
  }

  _buildPieChart(BuildContext context, List<PieSeries> pieData) => PieChart(
        PieChartData(
          sections: config.series[0].data!.map((item) {
            return PieChartSectionData(
              value: item.value,
              color: item.color ?? getRandomColor(),
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

        /* const SizedBox(height: 20),
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
       */
      );
/* 
  Widget _buildLegendItem(
    BuildContext context,
    int index,
    //List<PieChartModel> item,
  ) {
    
    return GestureDetector(
      onTap: () => _showUpdateDialog(
        context
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
            '${pieData[index].title}: ${data.value}%',
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
  } */
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
          child: KPie(),
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
