import '../models/employee_compensation_models.dart';
import '../models/employee_directory_models.dart';

List<EmployeeCompensationPackage> buildEmployeeCompensationPackages({
  required List<EmployeeDirectoryMember> members,
  required DateTime asOfDate,
}) {
  return members
      .map((member) => buildEmployeeCompensationPackage(member, asOfDate))
      .toList();
}

EmployeeCompensationPackage buildEmployeeCompensationPackage(
  EmployeeDirectoryMember member,
  DateTime asOfDate,
) {
  final profile = _profileFor(member);
  final lastReviewDate = DateTime(
    asOfDate.year - 1,
    member.joiningDate.month,
    1,
  );

  return EmployeeCompensationPackage(
    employeeId: member.id,
    employeeName: member.name,
    currencyCode: profile.currencyCode,
    baseSalary: profile.baseSalary,
    bandMin: profile.bandMin,
    bandMid: profile.bandMid,
    bandMax: profile.bandMax,
    payCycle: profile.payCycle,
    lastReviewDate: lastReviewDate,
    nextReviewDate: DateTime(asOfDate.year, member.joiningDate.month, 1),
  );
}

_CompensationProfile _profileFor(EmployeeDirectoryMember member) {
  return switch (member.id) {
    '1' => const _CompensationProfile(
      currencyCode: 'IDR',
      baseSalary: 284000000,
      bandMin: 240000000,
      bandMid: 300000000,
      bandMax: 360000000,
      payCycle: 'Monthly',
    ),
    '2' => const _CompensationProfile(
      currencyCode: 'SGD',
      baseSalary: 132000,
      bandMin: 118000,
      bandMid: 138000,
      bandMax: 166000,
      payCycle: 'Monthly',
    ),
    '3' => const _CompensationProfile(
      currencyCode: 'IDR',
      baseSalary: 318000000,
      bandMin: 285000000,
      bandMid: 340000000,
      bandMax: 405000000,
      payCycle: 'Monthly',
    ),
    '4' => const _CompensationProfile(
      currencyCode: 'IDR',
      baseSalary: 336000000,
      bandMin: 300000000,
      bandMid: 370000000,
      bandMax: 450000000,
      payCycle: 'Monthly',
    ),
    '5' => const _CompensationProfile(
      currencyCode: 'IDR',
      baseSalary: 188000000,
      bandMin: 175000000,
      bandMid: 220000000,
      bandMax: 280000000,
      payCycle: 'Monthly',
    ),
    _ => _fallbackProfile(member),
  };
}

_CompensationProfile _fallbackProfile(EmployeeDirectoryMember member) {
  final base = switch (member.department) {
    'Engineering' => 300000000,
    'Product' => 310000000,
    'Human Resources' => 260000000,
    'Design' => 245000000,
    _ => 220000000,
  };

  return _CompensationProfile(
    currencyCode: member.location == 'Singapore' ? 'SGD' : 'IDR',
    baseSalary: base.toDouble(),
    bandMin: (base * 0.82).roundToDouble(),
    bandMid: base.toDouble(),
    bandMax: (base * 1.25).roundToDouble(),
    payCycle: 'Monthly',
  );
}

class _CompensationProfile {
  final String currencyCode;
  final double baseSalary;
  final double bandMin;
  final double bandMid;
  final double bandMax;
  final String payCycle;

  const _CompensationProfile({
    required this.currencyCode,
    required this.baseSalary,
    required this.bandMin,
    required this.bandMid,
    required this.bandMax,
    required this.payCycle,
  });
}
