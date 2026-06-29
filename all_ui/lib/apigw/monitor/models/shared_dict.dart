class SharedDictMetric {
  final String name;
  final int capacityBytes;
  final int freeSpaceBytes;

  SharedDictMetric({
    required this.name,
    required this.capacityBytes,
    required this.freeSpaceBytes,
  });

  double get usagePercentage {
    return (capacityBytes - freeSpaceBytes) / capacityBytes * 100;
  }

  factory SharedDictMetric.fromJson(Map<String, dynamic> json) {
    return SharedDictMetric(
      name: json['name'],
      capacityBytes: json['capacity_bytes'],
      freeSpaceBytes: json['free_space_bytes'],
    );
  }
}
