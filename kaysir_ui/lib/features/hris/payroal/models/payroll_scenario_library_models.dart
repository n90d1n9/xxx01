import 'payroll_input_change_models.dart';
import 'payroll_simulation_models.dart';

enum PayrollScenarioStatus {
  saved('Saved'),
  approved('Approved'),
  converted('Converted');

  final String label;

  const PayrollScenarioStatus(this.label);
}

class PayrollScenarioRecord {
  final String id;
  final String label;
  final String notes;
  final DateTime createdAt;
  final PayrollScenarioStatus status;
  final double grossDelta;
  final double netDelta;
  final double projectedGross;
  final double projectedNet;
  final List<PayrollInputChangeRequest> proposedInputs;

  const PayrollScenarioRecord({
    required this.id,
    required this.label,
    required this.notes,
    required this.createdAt,
    required this.status,
    required this.grossDelta,
    required this.netDelta,
    required this.projectedGross,
    required this.projectedNet,
    required this.proposedInputs,
  });

  factory PayrollScenarioRecord.fromSimulation({
    required String id,
    required String label,
    required String notes,
    required DateTime createdAt,
    required PayrollSimulationSummary simulation,
  }) {
    return PayrollScenarioRecord(
      id: id,
      label: label.trim().isEmpty ? 'Payroll scenario $id' : label.trim(),
      notes: notes.trim(),
      createdAt: createdAt,
      status: PayrollScenarioStatus.saved,
      grossDelta: simulation.grossDelta,
      netDelta: simulation.netDelta,
      projectedGross: simulation.projectedGross,
      projectedNet: simulation.projectedNet,
      proposedInputs:
          simulation.inputChanges.lines
              .where((line) => !line.hasBlockers && !line.isApplied)
              .map((line) => line.request)
              .toList(),
    );
  }

  bool get canApprove => status == PayrollScenarioStatus.saved;

  bool get canConvert => status == PayrollScenarioStatus.approved;

  PayrollScenarioRecord copyWith({PayrollScenarioStatus? status}) {
    return PayrollScenarioRecord(
      id: id,
      label: label,
      notes: notes,
      createdAt: createdAt,
      status: status ?? this.status,
      grossDelta: grossDelta,
      netDelta: netDelta,
      projectedGross: projectedGross,
      projectedNet: projectedNet,
      proposedInputs: proposedInputs,
    );
  }

  List<PayrollInputChangeRequest> toInputChanges() {
    return proposedInputs.map((request) {
      return PayrollInputChangeRequest(
        id: '$id-${request.id}',
        employeeId: request.employeeId,
        type: request.type,
        currentAmount: request.currentAmount,
        proposedAmount: request.proposedAmount,
        effectiveDate: request.effectiveDate,
        sourceLabel: label,
        reason: 'Scenario conversion: ${request.reason}',
        hasApprovalOwner: true,
        hasSupportingDocument: true,
      );
    }).toList();
  }
}

class PayrollScenarioLibrarySummary {
  final List<PayrollScenarioRecord> scenarios;
  final String draftLabel;
  final String draftNotes;

  const PayrollScenarioLibrarySummary({
    required this.scenarios,
    required this.draftLabel,
    required this.draftNotes,
  });

  int get savedCount => _count(PayrollScenarioStatus.saved);

  int get approvedCount => _count(PayrollScenarioStatus.approved);

  int get convertedCount => _count(PayrollScenarioStatus.converted);

  double get bestNetDelta {
    if (scenarios.isEmpty) return 0;
    return scenarios
        .map((scenario) => scenario.netDelta)
        .reduce((best, value) => value > best ? value : best);
  }

  PayrollScenarioRecord? get nextScenario {
    for (final scenario in scenarios) {
      if (scenario.status != PayrollScenarioStatus.converted) {
        return scenario;
      }
    }
    return null;
  }

  String get nextAction {
    if (savedCount > 0) return 'Approve $savedCount saved payroll scenarios.';
    if (approvedCount > 0) {
      return 'Convert $approvedCount approved scenarios into payroll inputs.';
    }
    if (scenarios.isEmpty) return 'Save the current simulation as a scenario.';
    return 'All approved payroll scenarios are converted.';
  }

  int _count(PayrollScenarioStatus status) {
    return scenarios.where((scenario) => scenario.status == status).length;
  }
}
