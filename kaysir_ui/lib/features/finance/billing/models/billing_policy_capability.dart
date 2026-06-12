/// Configurable capabilities that can be enabled per billing workspace.
enum BillingPolicyCapabilityId {
  splitBilling,
  multiPayer,
  milestoneBilling,
  partialCollection,
  exceptionEvents,
  forceMajeureRelief,
  dueDatePause,
  dunningPause,
  lateFeeWaiver,
  paymentReschedule,
  manualAdjustment,
  approvalWorkflow,
}

/// Functional grouping for billing policy capabilities.
enum BillingPolicyCapabilityGroup {
  allocation,
  exceptionHandling,
  collectionControl,
  governance,
}

/// Metadata for one configurable billing policy capability.
class BillingPolicyCapability {
  final BillingPolicyCapabilityId id;
  final BillingPolicyCapabilityGroup group;
  final String label;
  final String description;

  const BillingPolicyCapability({
    required this.id,
    required this.group,
    required this.label,
    required this.description,
  });
}

/// Labels and descriptions for billing policy capability groups.
extension BillingPolicyCapabilityGroupLabels on BillingPolicyCapabilityGroup {
  String get label {
    return switch (this) {
      BillingPolicyCapabilityGroup.allocation => 'Allocation',
      BillingPolicyCapabilityGroup.exceptionHandling => 'Exception handling',
      BillingPolicyCapabilityGroup.collectionControl => 'Collection control',
      BillingPolicyCapabilityGroup.governance => 'Governance',
    };
  }
}

/// Labels and descriptions for billing policy capability identifiers.
extension BillingPolicyCapabilityIdLabels on BillingPolicyCapabilityId {
  String get label {
    return switch (this) {
      BillingPolicyCapabilityId.splitBilling => 'Split billing',
      BillingPolicyCapabilityId.multiPayer => 'Multi-payer billing',
      BillingPolicyCapabilityId.milestoneBilling => 'Milestone billing',
      BillingPolicyCapabilityId.partialCollection => 'Partial collection',
      BillingPolicyCapabilityId.exceptionEvents => 'Exception events',
      BillingPolicyCapabilityId.forceMajeureRelief => 'Force majeure relief',
      BillingPolicyCapabilityId.dueDatePause => 'Due date pause',
      BillingPolicyCapabilityId.dunningPause => 'Dunning pause',
      BillingPolicyCapabilityId.lateFeeWaiver => 'Late fee waiver',
      BillingPolicyCapabilityId.paymentReschedule => 'Payment reschedule',
      BillingPolicyCapabilityId.manualAdjustment => 'Manual adjustment',
      BillingPolicyCapabilityId.approvalWorkflow => 'Approval workflow',
    };
  }

  String get description {
    return switch (this) {
      BillingPolicyCapabilityId.splitBilling =>
        'Allow one payable amount to be allocated across configured recipients.',
      BillingPolicyCapabilityId.multiPayer =>
        'Track invoices where several parties share payment responsibility.',
      BillingPolicyCapabilityId.milestoneBilling =>
        'Issue or allocate billing by project, delivery, or subscription milestone.',
      BillingPolicyCapabilityId.partialCollection =>
        'Collect and reconcile accepted partial payments against open balances.',
      BillingPolicyCapabilityId.exceptionEvents =>
        'Register operational, legal, dispute, outage, and relief events.',
      BillingPolicyCapabilityId.forceMajeureRelief =>
        'Apply configured relief when extraordinary conditions affect payment.',
      BillingPolicyCapabilityId.dueDatePause =>
        'Pause or extend due dates while an approved exception is active.',
      BillingPolicyCapabilityId.dunningPause =>
        'Suspend reminder and collection escalation while relief is active.',
      BillingPolicyCapabilityId.lateFeeWaiver =>
        'Waive or suppress late fees according to policy approval.',
      BillingPolicyCapabilityId.paymentReschedule =>
        'Move open balances into an approved payment schedule.',
      BillingPolicyCapabilityId.manualAdjustment =>
        'Permit controlled manual invoice and balance adjustments.',
      BillingPolicyCapabilityId.approvalWorkflow =>
        'Require approval and evidence before sensitive billing changes apply.',
    };
  }

  BillingPolicyCapabilityGroup get group {
    return switch (this) {
      BillingPolicyCapabilityId.splitBilling ||
      BillingPolicyCapabilityId.multiPayer ||
      BillingPolicyCapabilityId
          .milestoneBilling => BillingPolicyCapabilityGroup.allocation,
      BillingPolicyCapabilityId.exceptionEvents ||
      BillingPolicyCapabilityId
          .forceMajeureRelief => BillingPolicyCapabilityGroup.exceptionHandling,
      BillingPolicyCapabilityId.partialCollection ||
      BillingPolicyCapabilityId.dueDatePause ||
      BillingPolicyCapabilityId.dunningPause ||
      BillingPolicyCapabilityId.lateFeeWaiver ||
      BillingPolicyCapabilityId
          .paymentReschedule => BillingPolicyCapabilityGroup.collectionControl,
      BillingPolicyCapabilityId.manualAdjustment ||
      BillingPolicyCapabilityId
          .approvalWorkflow => BillingPolicyCapabilityGroup.governance,
    };
  }

  BillingPolicyCapability get capability {
    return BillingPolicyCapability(
      id: this,
      group: group,
      label: label,
      description: description,
    );
  }
}
