import 'certificate_signing_request_condition.dart';

class CertificateSigningRequestStatus {
  final List<CertificateSigningRequestCondition>? conditions;
  final String? certificate;
  CertificateSigningRequestStatus({this.conditions, this.certificate});
  factory CertificateSigningRequestStatus.fromJson(Map<String, dynamic> json) {
    return CertificateSigningRequestStatus(
      conditions:
          json['conditions'] != null
              ? (json['conditions'] as List)
                  .map((e) => CertificateSigningRequestCondition.fromJson(e))
                  .toList()
              : null,
      certificate: json['certificate'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (conditions != null)
        'conditions': conditions!.map((e) => e.toJson()).toList(),
      if (certificate != null) 'certificate': certificate,
    };
  }
}
