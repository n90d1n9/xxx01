import 'package:flutter/material.dart';

import '../../../../widgets/ui/app_surface.dart';
import '../helper/format_currency.dart';
import '../models/financial_report_pack.dart';

class FinancialReportPackMetricGrid extends StatelessWidget {
  const FinancialReportPackMetricGrid({
    required this.metrics,
    required this.isDarkMode,
    super.key,
  });

  final List<FinancialReportMetric> metrics;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns =
            width >= 900
                ? 4
                : width >= 560
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio:
                columns == 1
                    ? 2.8
                    : columns == 2
                    ? 1.7
                    : 1.55,
          ),
          itemBuilder: (context, index) {
            return FinancialReportMetricCard(
              metric: metrics[index],
              isDarkMode: isDarkMode,
            );
          },
        );
      },
    );
  }
}

class FinancialReportMetricCard extends StatelessWidget {
  const FinancialReportMetricCard({
    required this.metric,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportMetric metric;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final amountColor = financialReportMetricAmountColor(
      metric.amount,
      isDarkMode,
    );

    return AppSurface(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDarkMode ? const Color(0xFF2C2C44) : Colors.white,
      borderColor: isDarkMode ? Colors.white12 : Colors.grey.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: mutedColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatCurrency(metric.amount),
              style: TextStyle(
                color: amountColor,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metric.helperText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textColor.withValues(alpha: 0.72)),
          ),
          if (metric.comparativeAmount != null) ...[
            const SizedBox(height: 6),
            FinancialReportMetricVarianceText(
              variance: metric.variance ?? 0,
              isDarkMode: isDarkMode,
            ),
          ],
        ],
      ),
    );
  }
}

class FinancialReportMetricVarianceText extends StatelessWidget {
  const FinancialReportMetricVarianceText({
    required this.variance,
    required this.isDarkMode,
    super.key,
  });

  final double variance;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color = financialReportMetricVarianceColor(variance, isDarkMode);
    final prefix = variance > 0 ? '+' : '';

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(
        '$prefix${formatCurrency(variance)}',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Color financialReportMetricAmountColor(double value, bool isDarkMode) {
  if (value >= 0) {
    return isDarkMode ? const Color(0xFF4ECCA3) : Colors.green.shade700;
  }
  return isDarkMode ? const Color(0xFFFF6B6B) : Colors.red.shade700;
}

Color financialReportMetricVarianceColor(double value, bool isDarkMode) {
  if (value > 0) {
    return isDarkMode ? const Color(0xFF4ECCA3) : Colors.green.shade700;
  }
  if (value < 0) {
    return isDarkMode ? const Color(0xFFFF6B6B) : Colors.red.shade700;
  }
  return isDarkMode ? Colors.grey.shade400 : Colors.blueGrey.shade600;
}
