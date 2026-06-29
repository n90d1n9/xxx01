import 'token_request.dart';

class CSIDriverSpec {
  final bool? attachRequired;
  final bool? podInfoOnMount;
  final List<String>? volumeLifecycleModes;
  final bool? storageCapacity;
  final bool? fsGroupPolicy;
  final List<TokenRequest>? tokenRequests;
  final bool? requiresRepublish;
  final String? seLinuxMount;
  CSIDriverSpec({
    this.attachRequired,
    this.podInfoOnMount,
    this.volumeLifecycleModes,
    this.storageCapacity,
    this.fsGroupPolicy,
    this.tokenRequests,
    this.requiresRepublish,
    this.seLinuxMount,
  });
  factory CSIDriverSpec.fromJson(Map<String, dynamic> json) {
    return CSIDriverSpec(
      attachRequired: json['attachRequired'],
      podInfoOnMount: json['podInfoOnMount'],
      volumeLifecycleModes:
          json['volumeLifecycleModes'] != null
              ? List<String>.from(json['volumeLifecycleModes'])
              : null,
      storageCapacity: json['storageCapacity'],
      fsGroupPolicy: json['fsGroupPolicy'],
      tokenRequests:
          json['tokenRequests'] != null
              ? (json['tokenRequests'] as List)
                  .map((e) => TokenRequest.fromJson(e))
                  .toList()
              : null,
      requiresRepublish: json['requiresRepublish'],
      seLinuxMount: json['seLinuxMount'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (attachRequired != null) 'attachRequired': attachRequired,
      if (podInfoOnMount != null) 'podInfoOnMount': podInfoOnMount,
      if (volumeLifecycleModes != null)
        'volumeLifecycleModes': volumeLifecycleModes,
      if (storageCapacity != null) 'storageCapacity': storageCapacity,
      if (fsGroupPolicy != null) 'fsGroupPolicy': fsGroupPolicy,
      if (tokenRequests != null)
        'tokenRequests': tokenRequests!.map((e) => e.toJson()).toList(),
      if (requiresRepublish != null) 'requiresRepublish': requiresRepublish,
      if (seLinuxMount != null) 'seLinuxMount': seLinuxMount,
    };
  }
}
