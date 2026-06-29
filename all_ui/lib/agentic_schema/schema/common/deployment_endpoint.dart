class DeploymentEndpoint {
  final String type;
  final String? url;
  final Map<String, dynamic>? authentication;

  DeploymentEndpoint({required this.type, this.url, this.authentication});

  factory DeploymentEndpoint.fromJson(Map<String, dynamic> json) {
    return DeploymentEndpoint(
      type: json['type'] as String,
      url: json['url'] as String?,
      authentication: json['authentication'] != null
          ? Map<String, dynamic>.from(json['authentication'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (url != null) 'url': url,
      if (authentication != null) 'authentication': authentication,
    };
  }
}
