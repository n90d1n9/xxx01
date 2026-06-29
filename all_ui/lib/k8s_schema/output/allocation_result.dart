import 'resource_handle.dart';

class AllocationResult {
  final ResourceHandle? resourceHandle;
  final String? availableOnNodes;
  final bool? shareable;
  AllocationResult({
    this.resourceHandle,
    this.availableOnNodes,
    this.shareable,
  });
  factory AllocationResult.fromJson(Map<String, dynamic> json) {
    return AllocationResult(
      resourceHandle:
          json['resourceHandle'] != null
              ? ResourceHandle.fromJson(json['resourceHandle'])
              : null,
      availableOnNodes: json['availableOnNodes'],
      shareable: json['shareable'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (resourceHandle != null) 'resourceHandle': resourceHandle!.toJson(),
      if (availableOnNodes != null) 'availableOnNodes': availableOnNodes,
      if (shareable != null) 'shareable': shareable,
    };
  }
}
