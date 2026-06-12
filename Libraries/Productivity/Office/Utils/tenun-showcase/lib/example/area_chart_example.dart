import 'package:flutter/material.dart';

import 'area_chart_variants.dart';

export 'area_chart_data.dart';
export 'area_chart_interactive_knob.dart';
export 'area_chart_variants.dart';

class AreaChartExample extends StatelessWidget {
  const AreaChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AreaVariantSection(
            title: '1. JSON: Smooth Multi-Series',
            chart: AreaSmoothVariantExample(),
          ),
          AreaVariantSection(
            title: '2. JSON: Straight Line, Solid Fill, No Dots',
            chart: AreaStraightVariantExample(),
          ),
          AreaVariantSection(
            title: '3. JSON: Positive + Negative Values',
            chart: AreaPositiveNegativeVariantExample(),
          ),
          AreaVariantSection(
            title: '4. JSON: Dense Daily Data',
            chart: AreaDenseVariantExample(),
          ),
          AreaVariantSection(
            title: '5. Config Object: Equivalent API',
            chart: AreaConfigVariantExample(),
          ),
        ],
      ),
    );
  }
}
