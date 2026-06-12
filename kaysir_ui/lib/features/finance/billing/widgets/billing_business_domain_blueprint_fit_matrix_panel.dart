import 'package:flutter/material.dart';

import '../utils/billing_business_domain_blueprint_fit_matrix.dart';
import 'billing_business_domain_blueprint_fit_matrix_components.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_empty_state.dart';

class BillingBusinessDomainBlueprintFitMatrixPanel extends StatelessWidget {
  final BillingBusinessDomainBlueprintFitMatrix matrix;

  const BillingBusinessDomainBlueprintFitMatrixPanel({
    super.key,
    required this.matrix,
  });

  @override
  Widget build(BuildContext context) {
    return BillingReadinessPanelScaffold(
      title: 'Blueprint fit matrix',
      summary:
          'Compare which product behaviors each reusable billing domain supports.',
      icon: Icons.grid_on_outlined,
      iconColor: const Color(0xFF7C3AED),
      iconBackgroundColor: const Color(0xFFF5F3FF),
      metrics: [
        BillingReadinessMetric(
          label: 'Domains',
          value: '${matrix.domainCount}',
          icon: Icons.business_center_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Signals',
          value: '${matrix.signalCount}',
          icon: Icons.tune_outlined,
          color: const Color(0xFF7C3AED),
        ),
        BillingReadinessMetric(
          label: 'Fits',
          value: '${matrix.supportedCellCount}',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF059669),
        ),
      ],
      child:
          matrix.isEmpty
              ? const _MatrixEmptyState()
              : LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 840) {
                    return BillingBlueprintWideFitMatrix(matrix: matrix);
                  }
                  return BillingBlueprintCompactFitMatrix(matrix: matrix);
                },
              ),
    );
  }
}

class _MatrixEmptyState extends StatelessWidget {
  const _MatrixEmptyState();

  @override
  Widget build(BuildContext context) {
    return const BillingEmptyState(
      message: 'No billing blueprint fit signals are available yet.',
    );
  }
}
