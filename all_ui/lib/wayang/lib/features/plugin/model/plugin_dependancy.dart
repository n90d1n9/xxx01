class PluginDependency {
  final String pluginId;
  final String versionConstraint;

  PluginDependency({required this.pluginId, required this.versionConstraint});

  Map<String, dynamic> toJson() => {
    'pluginId': pluginId,
    'versionConstraint': versionConstraint,
  };

  factory PluginDependency.fromJson(Map<String, dynamic> json) =>
      PluginDependency(
        pluginId: json['pluginId'],
        versionConstraint: json['versionConstraint'],
      );
}
