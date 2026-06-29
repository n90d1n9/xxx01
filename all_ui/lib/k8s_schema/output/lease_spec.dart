class LeaseSpec {
  final String? holderIdentity;
  final int? leaseDurationSeconds;
  final DateTime? acquireTime;
  final DateTime? renewTime;
  final int? leaseTransitions;
  LeaseSpec({
    this.holderIdentity,
    this.leaseDurationSeconds,
    this.acquireTime,
    this.renewTime,
    this.leaseTransitions,
  });
  factory LeaseSpec.fromJson(Map<String, dynamic> json) {
    return LeaseSpec(
      holderIdentity: json['holderIdentity'],
      leaseDurationSeconds: json['leaseDurationSeconds'],
      acquireTime:
          json['acquireTime'] != null
              ? DateTime.parse(json['acquireTime'])
              : null,
      renewTime:
          json['renewTime'] != null ? DateTime.parse(json['renewTime']) : null,
      leaseTransitions: json['leaseTransitions'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (holderIdentity != null) 'holderIdentity': holderIdentity,
      if (leaseDurationSeconds != null)
        'leaseDurationSeconds': leaseDurationSeconds,
      if (acquireTime != null) 'acquireTime': acquireTime!.toIso8601String(),
      if (renewTime != null) 'renewTime': renewTime!.toIso8601String(),
      if (leaseTransitions != null) 'leaseTransitions': leaseTransitions,
    };
  }
}
