class CertificateSigningRequestSpec {
  final String request;
  final String? signerName;
  final int? expirationSeconds;
  final List<String>? usages;
  final String? username;
  final String? uid;
  final List<String>? groups;
  final Map<String, List<String>>? extra;
  CertificateSigningRequestSpec({
    required this.request,
    this.signerName,
    this.expirationSeconds,
    this.usages,
    this.username,
    this.uid,
    this.groups,
    this.extra,
  });
  factory CertificateSigningRequestSpec.fromJson(Map<String, dynamic> json) {
    return CertificateSigningRequestSpec(
      request: json['request'],
      signerName: json['signerName'],
      expirationSeconds: json['expirationSeconds'],
      usages: json['usages'] != null ? List<String>.from(json['usages']) : null,
      username: json['username'],
      uid: json['uid'],
      groups: json['groups'] != null ? List<String>.from(json['groups']) : null,
      extra:
          json['extra'] != null
              ? (json['extra'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, List<String>.from(value)),
              )
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'request': request,
      if (signerName != null) 'signerName': signerName,
      if (expirationSeconds != null) 'expirationSeconds': expirationSeconds,
      if (usages != null) 'usages': usages,
      if (username != null) 'username': username,
      if (uid != null) 'uid': uid,
      if (groups != null) 'groups': groups,
      if (extra != null) 'extra': extra,
    };
  }
}
