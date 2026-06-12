import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_availability_rule_authoring_session.dart';

class ProductAvailabilityRuleAuthoringSessionStrip extends StatelessWidget {
  const ProductAvailabilityRuleAuthoringSessionStrip({
    super.key,
    required this.summary,
    required this.onReset,
    this.persistence =
        ProductAvailabilityRuleAuthoringSessionPersistenceState.idle,
  });

  final ProductAvailabilityRuleAuthoringSessionSummary summary;
  final ProductAvailabilityRuleAuthoringSessionPersistenceState persistence;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContentPanel(
      title: 'Authoring session',
      subtitle: '${summary.templateLabel} | ${summary.targetLabel}',
      leadingIcon: Icons.tune_rounded,
      trailing: AppActionButton(
        label: 'Reset',
        icon: Icons.restart_alt_rounded,
        variant: AppActionButtonVariant.secondary,
        compact: true,
        height: 36,
        onPressed: summary.isDefault ? null : onReset,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppStatusPill(
            label: persistence.label,
            color: _persistenceColor(persistence),
            icon: _persistenceIcon(persistence),
            maxWidth: 190,
          ),
          AppStatusPill(
            label: summary.sessionLabel,
            color:
                summary.isDefault
                    ? Colors.teal.shade700
                    : Colors.indigo.shade700,
            icon:
                summary.isDefault ? Icons.verified_rounded : Icons.tune_rounded,
            maxWidth: 150,
          ),
          AppStatusPill(
            label: 'Source: ${summary.sourceDisplayLabel}',
            color: colorScheme.primary,
            icon: Icons.extension_rounded,
            maxWidth: 250,
          ),
          AppStatusPill(
            label: 'Template: ${summary.templateLabel}',
            color: Colors.deepOrange.shade700,
            icon: Icons.rule_rounded,
            maxWidth: 250,
          ),
          AppStatusPill(
            label: 'Target: ${summary.targetLabel}',
            color: Colors.blue.shade700,
            icon: Icons.filter_alt_rounded,
            maxWidth: 220,
          ),
          AppStatusPill(
            label: summary.availableTemplateCountLabel,
            color: Colors.blueGrey.shade700,
            icon: Icons.library_books_rounded,
            maxWidth: 180,
          ),
          AppStatusPill(
            label: summary.totalTemplateCountLabel,
            color: Colors.purple.shade700,
            showDot: true,
            maxWidth: 160,
          ),
        ],
      ),
    );
  }
}

Color _persistenceColor(
  ProductAvailabilityRuleAuthoringSessionPersistenceState persistence,
) {
  switch (persistence.phase) {
    case ProductAvailabilityRuleAuthoringSessionPersistencePhase.idle:
      return Colors.blueGrey.shade700;
    case ProductAvailabilityRuleAuthoringSessionPersistencePhase.hydrating:
      return Colors.indigo.shade700;
    case ProductAvailabilityRuleAuthoringSessionPersistencePhase.saving:
      return Colors.amber.shade800;
    case ProductAvailabilityRuleAuthoringSessionPersistencePhase.saved:
      return Colors.teal.shade700;
    case ProductAvailabilityRuleAuthoringSessionPersistencePhase.failed:
      return Colors.red.shade700;
  }
}

IconData _persistenceIcon(
  ProductAvailabilityRuleAuthoringSessionPersistenceState persistence,
) {
  switch (persistence.phase) {
    case ProductAvailabilityRuleAuthoringSessionPersistencePhase.idle:
      return Icons.cloud_done_rounded;
    case ProductAvailabilityRuleAuthoringSessionPersistencePhase.hydrating:
      return Icons.cloud_download_rounded;
    case ProductAvailabilityRuleAuthoringSessionPersistencePhase.saving:
      return Icons.sync_rounded;
    case ProductAvailabilityRuleAuthoringSessionPersistencePhase.saved:
      return Icons.verified_rounded;
    case ProductAvailabilityRuleAuthoringSessionPersistencePhase.failed:
      return Icons.cloud_off_rounded;
  }
}
