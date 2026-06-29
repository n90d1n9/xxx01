class ListMeta {
  final String? selfLink;
  final String? resourceVersion;
  final String? continueToken;
  final int? remainingItemCount;
  ListMeta({
    this.selfLink,
    this.resourceVersion,
    this.continueToken,
    this.remainingItemCount,
  });
  factory ListMeta.fromJson(Map<String, dynamic> json) {
    return ListMeta(
      selfLink: json['selfLink'],
      resourceVersion: json['resourceVersion'],
      continueToken: json['continue'],
      remainingItemCount: json['remainingItemCount'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (selfLink != null) 'selfLink': selfLink,
      if (resourceVersion != null) 'resourceVersion': resourceVersion,
      if (continueToken != null) 'continue': continueToken,
      if (remainingItemCount != null) 'remainingItemCount': remainingItemCount,
    };
  }
}
