import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_org_models.dart';
import '../../states/employee_org_provider.dart';
import 'employee_org_relationship_form.dart';
import 'employee_org_tiles.dart';

class EmployeeOrgCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeOrgCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeOrgCenterPanel> createState() =>
      _EmployeeOrgCenterPanelState();
}

class _EmployeeOrgCenterPanelState
    extends ConsumerState<EmployeeOrgCenterPanel> {
  final _relatedController = TextEditingController();
  final _ownerController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _relatedController.dispose();
    _ownerController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeOrgProfileProvider(employeeId));
    final draft = ref.watch(employeeOrgRelationshipDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_relatedController, draft.relatedEmployeeName);
    _sync(_ownerController, draft.owner);
    _sync(_reasonController, draft.reason);

    final relationships = [...profile.relationships]..sort((a, b) {
      final statusCompare = _relationshipRank(
        a.status,
      ).compareTo(_relationshipRank(b.status));
      if (statusCompare != 0) return statusCompare;
      return b.createdAt.compareTo(a.createdAt);
    });

    return HrisSectionPanel(
      icon: Icons.account_tree_outlined,
      title: 'Organization and reporting',
      subtitle: profile.nextAction,
      children: [
        EmployeeOrgSummaryStrip(profile: profile),
        EmployeeOrgManagerCard(profile: profile),
        EmployeeOrgPeopleCard(
          title: 'Direct reports',
          people: profile.directReports,
          emptyMessage: 'No direct reports in this workspace.',
        ),
        EmployeeOrgPeopleCard(
          title: 'Peers',
          people: profile.peers,
          emptyMessage: 'No peers share this manager.',
        ),
        EmployeeOrgRelationshipForm(
          draft: draft,
          relatedController: _relatedController,
          ownerController: _ownerController,
          reasonController: _reasonController,
          onTypeChanged:
              ref
                  .read(
                    employeeOrgRelationshipDraftProvider(employeeId).notifier,
                  )
                  .setType,
          onRelatedChanged:
              ref
                  .read(
                    employeeOrgRelationshipDraftProvider(employeeId).notifier,
                  )
                  .setRelatedEmployeeName,
          onOwnerChanged:
              ref
                  .read(
                    employeeOrgRelationshipDraftProvider(employeeId).notifier,
                  )
                  .setOwner,
          onReasonChanged:
              ref
                  .read(
                    employeeOrgRelationshipDraftProvider(employeeId).notifier,
                  )
                  .setReason,
          onAdd: () => _addRelationship(draft),
        ),
        if (profile.risks.isEmpty)
          const HrisListSurface(child: Text('No organization risk signals.'))
        else
          ...profile.risks.map(
            (risk) => EmployeeOrgRiskTile(
              risk: risk,
              onAcknowledge:
                  () => ref
                      .read(employeeOrgProfileProvider(employeeId).notifier)
                      .acknowledgeRisk(risk.id),
            ),
          ),
        if (relationships.isEmpty)
          const HrisListSurface(
            child: Text('No dotted-line or support relationships recorded.'),
          )
        else
          ...relationships.map(
            (relationship) => EmployeeOrgRelationshipTile(
              relationship: relationship,
              onActivate:
                  () => ref
                      .read(employeeOrgProfileProvider(employeeId).notifier)
                      .activateRelationship(relationship.id),
              onArchive:
                  () => ref
                      .read(employeeOrgProfileProvider(employeeId).notifier)
                      .archiveRelationship(relationship.id),
            ),
          ),
      ],
    );
  }

  void _addRelationship(EmployeeOrgRelationshipDraft draft) {
    try {
      final relationship = ref
          .read(employeeOrgProfileProvider(draft.employeeId).notifier)
          .addDraft(draft);
      ref
          .read(employeeOrgRelationshipDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${relationship.id} added for ${draft.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  int _relationshipRank(EmployeeOrgRelationshipStatus status) {
    return switch (status) {
      EmployeeOrgRelationshipStatus.pending => 0,
      EmployeeOrgRelationshipStatus.active => 1,
      EmployeeOrgRelationshipStatus.archived => 2,
    };
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
