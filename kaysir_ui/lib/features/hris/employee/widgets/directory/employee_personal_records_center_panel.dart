import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_personal_records_models.dart';
import '../../states/employee_personal_records_provider.dart';
import 'employee_emergency_contact_form.dart';
import 'employee_personal_records_tiles.dart';

class EmployeePersonalRecordsCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeePersonalRecordsCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeePersonalRecordsCenterPanel> createState() =>
      _EmployeePersonalRecordsCenterPanelState();
}

class _EmployeePersonalRecordsCenterPanelState
    extends ConsumerState<EmployeePersonalRecordsCenterPanel> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(
      employeePersonalRecordsProfileProvider(employeeId),
    );
    final draft = ref.watch(employeeEmergencyContactDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_nameController, draft.fullName);
    _sync(_phoneController, draft.phone);
    _sync(_emailController, draft.email);

    final addresses = [...profile.addresses]..sort((a, b) {
      final aAttention = a.needsAttention(profile.asOfDate);
      final bAttention = b.needsAttention(profile.asOfDate);
      if (aAttention != bAttention) return aAttention ? -1 : 1;
      return a.type.index.compareTo(b.type.index);
    });
    final contacts = [...profile.emergencyContacts]..sort((a, b) {
      if (a.isPrimary != b.isPrimary) return a.isPrimary ? -1 : 1;
      final aAttention = a.needsAttention(profile.asOfDate);
      final bAttention = b.needsAttention(profile.asOfDate);
      if (aAttention != bAttention) return aAttention ? -1 : 1;
      return a.priority.compareTo(b.priority);
    });

    return HrisSectionPanel(
      icon: Icons.contact_emergency_outlined,
      title: 'Personal records',
      subtitle: profile.nextAction,
      children: [
        EmployeePersonalRecordsSummaryStrip(profile: profile),
        EmployeeEmergencyContactForm(
          draft: draft,
          nameController: _nameController,
          phoneController: _phoneController,
          emailController: _emailController,
          onNameChanged:
              ref
                  .read(
                    employeeEmergencyContactDraftProvider(employeeId).notifier,
                  )
                  .setFullName,
          onRelationshipChanged:
              ref
                  .read(
                    employeeEmergencyContactDraftProvider(employeeId).notifier,
                  )
                  .setRelationship,
          onPhoneChanged:
              ref
                  .read(
                    employeeEmergencyContactDraftProvider(employeeId).notifier,
                  )
                  .setPhone,
          onEmailChanged:
              ref
                  .read(
                    employeeEmergencyContactDraftProvider(employeeId).notifier,
                  )
                  .setEmail,
          onPrimaryChanged:
              ref
                  .read(
                    employeeEmergencyContactDraftProvider(employeeId).notifier,
                  )
                  .setPrimary,
          onAdd: () => _addContact(draft),
        ),
        ...addresses.map(
          (address) => EmployeeAddressRecordTile(
            address: address,
            asOfDate: profile.asOfDate,
            onVerify:
                () => ref
                    .read(
                      employeePersonalRecordsProfileProvider(
                        employeeId,
                      ).notifier,
                    )
                    .verifyAddress(address.id),
          ),
        ),
        if (contacts.isEmpty)
          const HrisListSurface(child: Text('No emergency contacts yet.'))
        else
          ...contacts.map(
            (contact) => EmployeeEmergencyContactTile(
              contact: contact,
              asOfDate: profile.asOfDate,
              onVerify:
                  () => ref
                      .read(
                        employeePersonalRecordsProfileProvider(
                          employeeId,
                        ).notifier,
                      )
                      .verifyContact(contact.id),
              onMakePrimary:
                  () => ref
                      .read(
                        employeePersonalRecordsProfileProvider(
                          employeeId,
                        ).notifier,
                      )
                      .makePrimaryContact(contact.id),
            ),
          ),
      ],
    );
  }

  void _addContact(EmployeeEmergencyContactDraft draft) {
    try {
      final contact = ref
          .read(
            employeePersonalRecordsProfileProvider(draft.employeeId).notifier,
          )
          .addContact(draft);
      ref
          .read(
            employeeEmergencyContactDraftProvider(draft.employeeId).notifier,
          )
          .reset();
      _showMessage('${contact.fullName} added to ${draft.employeeName}');
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
