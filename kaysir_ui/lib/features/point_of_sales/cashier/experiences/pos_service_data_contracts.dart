import 'pos_data_contract_model.dart';
import 'pos_data_trait.dart';

abstract final class POSServiceDataContracts {
  static const modifierGroups = POSDataTraitContract(
    traitKey: POSDataTraitKeys.modifierGroups,
    requiredFields: [
      POSDataContractField('group_id', 'Group id'),
      POSDataContractField('option_id', 'Option id'),
      POSDataContractField('price_delta', 'Price delta'),
    ],
  );

  static const tableService = POSDataTraitContract(
    traitKey: POSDataTraitKeys.tableService,
    requiredFields: [
      POSDataContractField('table_id', 'Table id'),
      POSDataContractField('guest_count', 'Guest count'),
      POSDataContractField('service_status', 'Service status'),
    ],
  );

  static const appointments = POSDataTraitContract(
    traitKey: POSDataTraitKeys.appointments,
    requiredFields: [
      POSDataContractField('appointment_id', 'Appointment id'),
      POSDataContractField('scheduled_start', 'Scheduled start'),
      POSDataContractField('assigned_staff_id', 'Assigned staff id'),
    ],
  );

  static const deposits = POSDataTraitContract(
    traitKey: POSDataTraitKeys.deposits,
    requiredFields: [
      POSDataContractField('deposit_amount', 'Deposit amount'),
      POSDataContractField('balance_due', 'Balance due'),
    ],
  );

  static const ageRestricted = POSDataTraitContract(
    traitKey: POSDataTraitKeys.ageRestricted,
    requiredFields: [
      POSDataContractField('minimum_age', 'Minimum age'),
      POSDataContractField('verification_status', 'Verification status'),
    ],
  );

  static const serviceTickets = POSDataTraitContract(
    traitKey: POSDataTraitKeys.serviceTickets,
    requiredFields: [
      POSDataContractField('ticket_id', 'Ticket id'),
      POSDataContractField('service_status', 'Service status'),
      POSDataContractField('intake_notes', 'Intake notes'),
    ],
  );

  static const all = [
    modifierGroups,
    tableService,
    appointments,
    deposits,
    ageRestricted,
    serviceTickets,
  ];
}
