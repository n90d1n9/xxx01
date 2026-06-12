enum EmployeeAddressType {
  home('Home'),
  mailing('Mailing'),
  work('Work');

  final String label;

  const EmployeeAddressType(this.label);
}

enum EmployeePersonalRecordStatus {
  verified('Verified'),
  pending('Pending'),
  reviewDue('Review due'),
  missing('Missing');

  final String label;

  const EmployeePersonalRecordStatus(this.label);
}

enum EmployeeEmergencyContactRelationship {
  spouse('Spouse'),
  partner('Partner'),
  parent('Parent'),
  sibling('Sibling'),
  friend('Friend'),
  guardian('Guardian');

  final String label;

  const EmployeeEmergencyContactRelationship(this.label);
}

class EmployeeAddressRecord {
  final String id;
  final String employeeId;
  final EmployeeAddressType type;
  final String label;
  final String line1;
  final String city;
  final String region;
  final String country;
  final String postalCode;
  final DateTime lastVerifiedAt;
  final EmployeePersonalRecordStatus status;

  const EmployeeAddressRecord({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.label,
    required this.line1,
    required this.city,
    required this.region,
    required this.country,
    required this.postalCode,
    required this.lastVerifiedAt,
    required this.status,
  });

  bool needsAttention(DateTime asOfDate) {
    if (status != EmployeePersonalRecordStatus.verified) {
      return true;
    }
    return lastVerifiedAt.isBefore(
      _dateOnly(asOfDate).subtract(const Duration(days: 365)),
    );
  }

  String get singleLine {
    return '$line1, $city, $region $postalCode';
  }

  EmployeeAddressRecord copyWith({
    DateTime? lastVerifiedAt,
    EmployeePersonalRecordStatus? status,
  }) {
    return EmployeeAddressRecord(
      id: id,
      employeeId: employeeId,
      type: type,
      label: label,
      line1: line1,
      city: city,
      region: region,
      country: country,
      postalCode: postalCode,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      status: status ?? this.status,
    );
  }
}

class EmployeeEmergencyContactRecord {
  final String id;
  final String employeeId;
  final String fullName;
  final EmployeeEmergencyContactRelationship relationship;
  final String phone;
  final String email;
  final int priority;
  final DateTime lastVerifiedAt;
  final EmployeePersonalRecordStatus status;

  const EmployeeEmergencyContactRecord({
    required this.id,
    required this.employeeId,
    required this.fullName,
    required this.relationship,
    required this.phone,
    required this.email,
    required this.priority,
    required this.lastVerifiedAt,
    required this.status,
  });

  bool get isPrimary => priority == 1;

  bool needsAttention(DateTime asOfDate) {
    if (status != EmployeePersonalRecordStatus.verified) {
      return true;
    }
    return lastVerifiedAt.isBefore(
      _dateOnly(asOfDate).subtract(const Duration(days: 365)),
    );
  }

  EmployeeEmergencyContactRecord copyWith({
    int? priority,
    DateTime? lastVerifiedAt,
    EmployeePersonalRecordStatus? status,
  }) {
    return EmployeeEmergencyContactRecord(
      id: id,
      employeeId: employeeId,
      fullName: fullName,
      relationship: relationship,
      phone: phone,
      email: email,
      priority: (priority ?? this.priority).clamp(1, 9).toInt(),
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      status: status ?? this.status,
    );
  }
}

class EmployeePersonalRecordsProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeAddressRecord> addresses;
  final List<EmployeeEmergencyContactRecord> emergencyContacts;

  const EmployeePersonalRecordsProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.addresses,
    required this.emergencyContacts,
  });

  EmployeePersonalRecordsProfile copyWith({
    List<EmployeeAddressRecord>? addresses,
    List<EmployeeEmergencyContactRecord>? emergencyContacts,
  }) {
    return EmployeePersonalRecordsProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      addresses: addresses ?? this.addresses,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }

  int get addressAttentionCount {
    return addresses
        .where((address) => address.needsAttention(asOfDate))
        .length;
  }

  int get contactAttentionCount {
    return emergencyContacts
        .where((contact) => contact.needsAttention(asOfDate))
        .length;
  }

  int get verifiedAddressCount {
    return addresses
        .where(
          (address) => address.status == EmployeePersonalRecordStatus.verified,
        )
        .length;
  }

  int get verifiedContactCount {
    return emergencyContacts
        .where(
          (contact) => contact.status == EmployeePersonalRecordStatus.verified,
        )
        .length;
  }

  int get totalAttentionCount => addressAttentionCount + contactAttentionCount;

  EmployeeEmergencyContactRecord? get primaryContact {
    if (emergencyContacts.isEmpty) return null;
    final sorted = [...emergencyContacts]
      ..sort((a, b) => a.priority.compareTo(b.priority));
    return sorted.first;
  }

  String get nextAction {
    if (addressAttentionCount > 0) {
      return 'Verify $addressAttentionCount address record${addressAttentionCount == 1 ? '' : 's'}.';
    }
    if (contactAttentionCount > 0) {
      return 'Verify $contactAttentionCount emergency contact${contactAttentionCount == 1 ? '' : 's'}.';
    }
    if (emergencyContacts.isEmpty) {
      return 'Add an emergency contact.';
    }
    return 'Personal records are current.';
  }
}

class EmployeeEmergencyContactDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String fullName;
  final EmployeeEmergencyContactRelationship relationship;
  final String phone;
  final String email;
  final bool primary;

  const EmployeeEmergencyContactDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.fullName,
    required this.relationship,
    required this.phone,
    required this.email,
    required this.primary,
  });

  EmployeeEmergencyContactDraft copyWith({
    String? fullName,
    EmployeeEmergencyContactRelationship? relationship,
    String? phone,
    String? email,
    bool? primary,
  }) {
    return EmployeeEmergencyContactDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      fullName: fullName ?? this.fullName,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      primary: primary ?? this.primary,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (fullName.trim().length < 3) {
      errors.add('Contact name must be at least 3 characters');
    }
    if (phone.trim().length < 7) {
      errors.add('Contact phone is required');
    }
    if (email.trim().isNotEmpty && !email.trim().contains('@')) {
      errors.add('Contact email must be valid');
    }
    return errors;
  }

  bool get isReadyToAdd => validationErrors.isEmpty;

  double get completionRatio {
    var complete = 0;
    if (fullName.trim().length >= 3) complete++;
    if (phone.trim().length >= 7) complete++;
    if (email.trim().isEmpty || email.trim().contains('@')) complete++;
    return complete / 3;
  }

  EmployeeEmergencyContactRecord toContact({
    required String id,
    required int priority,
  }) {
    if (!isReadyToAdd) {
      throw StateError(validationErrors.first);
    }

    return EmployeeEmergencyContactRecord(
      id: id,
      employeeId: employeeId,
      fullName: fullName.trim(),
      relationship: relationship,
      phone: phone.trim(),
      email: email.trim(),
      priority: priority,
      lastVerifiedAt: asOfDate,
      status: EmployeePersonalRecordStatus.pending,
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
