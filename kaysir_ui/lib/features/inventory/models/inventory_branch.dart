enum InventoryBranchStatus { active, planning, paused }

enum InventoryBranchType {
  headquarters,
  branchOffice,
  retailOutlet,
  fulfillmentHub,
  partner,
}

enum InventoryBranchComplianceTier { standard, monitored, restricted }

class InventoryBranch {
  const InventoryBranch({
    required this.id,
    required this.name,
    required this.city,
    required this.managerName,
    required this.contact,
    this.code = '',
    this.region = '',
    this.legalEntity = '',
    this.type = InventoryBranchType.branchOffice,
    this.complianceTier = InventoryBranchComplianceTier.standard,
    this.employeeCount = 0,
    this.status = InventoryBranchStatus.active,
    this.notes,
  });

  final String id;
  final String name;
  final String city;
  final String managerName;
  final String contact;
  final String code;
  final String region;
  final String legalEntity;
  final InventoryBranchType type;
  final InventoryBranchComplianceTier complianceTier;
  final int employeeCount;
  final InventoryBranchStatus status;
  final String? notes;

  String get nameLabel => _labelOrFallback(name, 'Unnamed branch');

  String get codeLabel => _labelOrFallback(code, 'No code');

  String get cityLabel => _labelOrFallback(city, 'No city');

  String get regionLabel => _labelOrFallback(region, 'No region');

  String get legalEntityLabel => _labelOrFallback(legalEntity, 'No entity');

  String get managerLabel => _labelOrFallback(managerName, 'No manager');

  String get contactLabel => _labelOrFallback(contact, 'No contact');

  bool get hasCompanyGovernance {
    return code.trim().isNotEmpty &&
        region.trim().isNotEmpty &&
        legalEntity.trim().isNotEmpty &&
        managerName.trim().isNotEmpty &&
        contact.trim().isNotEmpty;
  }

  InventoryBranch copyWith({
    String? id,
    String? name,
    String? city,
    String? managerName,
    String? contact,
    String? code,
    String? region,
    String? legalEntity,
    InventoryBranchType? type,
    InventoryBranchComplianceTier? complianceTier,
    int? employeeCount,
    InventoryBranchStatus? status,
    String? notes,
  }) {
    return InventoryBranch(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      managerName: managerName ?? this.managerName,
      contact: contact ?? this.contact,
      code: code ?? this.code,
      region: region ?? this.region,
      legalEntity: legalEntity ?? this.legalEntity,
      type: type ?? this.type,
      complianceTier: complianceTier ?? this.complianceTier,
      employeeCount: employeeCount ?? this.employeeCount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'InventoryBranch(id: $id, name: $name, city: $city, managerName: $managerName, contact: $contact, code: $code, region: $region, legalEntity: $legalEntity, type: $type, complianceTier: $complianceTier, employeeCount: $employeeCount, status: $status, notes: $notes)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'managerName': managerName,
      'contact': contact,
      'code': code,
      'region': region,
      'legalEntity': legalEntity,
      'type': type.name,
      'complianceTier': complianceTier.name,
      'employeeCount': employeeCount,
      'status': status.name,
      'notes': notes,
    };
  }

  factory InventoryBranch.fromJson(Map<String, dynamic> json) {
    return InventoryBranch(
      id: json['id'],
      name: json['name'],
      city: json['city'] ?? '',
      managerName: json['managerName'] ?? '',
      contact: json['contact'] ?? '',
      code: json['code'] ?? '',
      region: json['region'] ?? '',
      legalEntity: json['legalEntity'] ?? '',
      type: inventoryBranchTypeFromName(json['type']),
      complianceTier: inventoryBranchComplianceTierFromName(
        json['complianceTier'],
      ),
      employeeCount: _intFromJson(json['employeeCount']),
      status: inventoryBranchStatusFromName(json['status']),
      notes: json['notes'],
    );
  }
}

String inventoryBranchStatusLabel(InventoryBranchStatus status) {
  switch (status) {
    case InventoryBranchStatus.active:
      return 'Active';
    case InventoryBranchStatus.planning:
      return 'Planning';
    case InventoryBranchStatus.paused:
      return 'Paused';
  }
}

String inventoryBranchTypeLabel(InventoryBranchType type) {
  switch (type) {
    case InventoryBranchType.headquarters:
      return 'Headquarters';
    case InventoryBranchType.branchOffice:
      return 'Branch office';
    case InventoryBranchType.retailOutlet:
      return 'Retail outlet';
    case InventoryBranchType.fulfillmentHub:
      return 'Fulfillment hub';
    case InventoryBranchType.partner:
      return 'Partner';
  }
}

String inventoryBranchComplianceTierLabel(InventoryBranchComplianceTier tier) {
  switch (tier) {
    case InventoryBranchComplianceTier.standard:
      return 'Standard';
    case InventoryBranchComplianceTier.monitored:
      return 'Monitored';
    case InventoryBranchComplianceTier.restricted:
      return 'Restricted';
  }
}

InventoryBranchStatus inventoryBranchStatusFromName(Object? value) {
  final name = value?.toString();
  for (final status in InventoryBranchStatus.values) {
    if (status.name == name) return status;
  }
  return InventoryBranchStatus.active;
}

InventoryBranchType inventoryBranchTypeFromName(Object? value) {
  final name = value?.toString();
  for (final type in InventoryBranchType.values) {
    if (type.name == name) return type;
  }
  return InventoryBranchType.branchOffice;
}

InventoryBranchComplianceTier inventoryBranchComplianceTierFromName(
  Object? value,
) {
  final name = value?.toString();
  for (final tier in InventoryBranchComplianceTier.values) {
    if (tier.name == name) return tier;
  }
  return InventoryBranchComplianceTier.standard;
}

String _labelOrFallback(String value, String fallback) {
  final normalized = value.trim();
  return normalized.isEmpty ? fallback : normalized;
}

int _intFromJson(Object? value) {
  if (value is int) return value < 0 ? 0 : value;
  if (value is num) return value < 0 ? 0 : value.toInt();
  final parsed = int.tryParse(value?.toString() ?? '');
  if (parsed == null || parsed < 0) return 0;
  return parsed;
}
