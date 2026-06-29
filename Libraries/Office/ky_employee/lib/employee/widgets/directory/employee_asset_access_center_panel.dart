import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_assets_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_assets_provider.dart';
import 'employee_asset_assignment_form.dart';
import 'employee_assets_tiles.dart';

class EmployeeAssetAccessCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeAssetAccessCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeAssetAccessCenterPanel> createState() =>
      _EmployeeAssetAccessCenterPanelState();
}

class _EmployeeAssetAccessCenterPanelState
    extends ConsumerState<EmployeeAssetAccessCenterPanel> {
  final _labelController = TextEditingController();
  final _tagController = TextEditingController();
  final _ownerController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _tagController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeAssetAccessProfileProvider(employeeId));
    final draft = ref.watch(employeeAssetAssignmentDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_labelController, draft.label);
    _sync(_tagController, draft.assetTag);
    _sync(_ownerController, draft.owner);

    final assets = [...profile.assets]..sort((a, b) {
      final aAttention = a.needsAttention(profile.asOfDate);
      final bAttention = b.needsAttention(profile.asOfDate);
      if (aAttention != bAttention) return aAttention ? -1 : 1;
      return a.type.index.compareTo(b.type.index);
    });
    final accessGrants = [...profile.accessGrants]..sort((a, b) {
      final aReview = a.needsReview(profile.asOfDate);
      final bReview = b.needsReview(profile.asOfDate);
      if (aReview != bReview) return aReview ? -1 : 1;
      return a.scope.index.compareTo(b.scope.index);
    });

    return HrisSectionPanel(
      icon: Icons.admin_panel_settings_outlined,
      title: 'Assets and access',
      subtitle: profile.nextAction,
      children: [
        EmployeeAssetAccessSummaryStrip(profile: profile),
        EmployeeAssetAssignmentForm(
          draft: draft,
          labelController: _labelController,
          tagController: _tagController,
          ownerController: _ownerController,
          onTypeChanged:
              ref
                  .read(
                    employeeAssetAssignmentDraftProvider(employeeId).notifier,
                  )
                  .setType,
          onLabelChanged:
              ref
                  .read(
                    employeeAssetAssignmentDraftProvider(employeeId).notifier,
                  )
                  .setLabel,
          onTagChanged:
              ref
                  .read(
                    employeeAssetAssignmentDraftProvider(employeeId).notifier,
                  )
                  .setAssetTag,
          onOwnerChanged:
              ref
                  .read(
                    employeeAssetAssignmentDraftProvider(employeeId).notifier,
                  )
                  .setOwner,
          onAdd: () => _addAsset(draft),
        ),
        ...assets.map(
          (asset) => EmployeeAssetRecordTile(
            asset: asset,
            asOfDate: profile.asOfDate,
            onCompleteProvisioning:
                () => ref
                    .read(
                      employeeAssetAccessProfileProvider(employeeId).notifier,
                    )
                    .completeProvisioning(asset.id),
            onReturn:
                () => ref
                    .read(
                      employeeAssetAccessProfileProvider(employeeId).notifier,
                    )
                    .markAssetReturned(asset.id),
          ),
        ),
        if (accessGrants.isEmpty)
          const HrisListSurface(child: Text('No system access recorded yet.'))
        else
          ...accessGrants.map(
            (grant) => EmployeeAccessGrantTile(
              grant: grant,
              asOfDate: profile.asOfDate,
              onApprove:
                  () => ref
                      .read(
                        employeeAssetAccessProfileProvider(employeeId).notifier,
                      )
                      .approveAccess(grant.id),
              onRevoke:
                  () => ref
                      .read(
                        employeeAssetAccessProfileProvider(employeeId).notifier,
                      )
                      .revokeAccess(grant.id),
            ),
          ),
      ],
    );
  }

  void _addAsset(EmployeeAssetAssignmentDraft draft) {
    try {
      final asset = ref
          .read(employeeAssetAccessProfileProvider(draft.employeeId).notifier)
          .addAsset(draft);
      ref
          .read(employeeAssetAssignmentDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${asset.label} queued for ${draft.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}
