import 'package:flutter/material.dart';
import 'package:ky_chart/utils/legend_widget.dart';

import '../model/chart_model.dart';
import '../utils/fl_chart_helper.dart';

class TenunChart extends StatefulWidget {
  final ChartConfig config;
  const TenunChart({super.key, required this.config});

  @override
  State<TenunChart> createState() => _TenunChartState();
}

class _TenunChartState extends State<TenunChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 600,
        height: 600,
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  widget.config.title != null ? widget.config.title!.text! : '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                //_buildControls(),
                //const SizedBox(height: 20),
                LegendWidget(config: widget.config),
                const SizedBox(height: 20),
                Expanded(
                  child: flChart(widget.config.type!, widget.config),
                ),
              ],
            ),
          ),
        ));
  }
}
