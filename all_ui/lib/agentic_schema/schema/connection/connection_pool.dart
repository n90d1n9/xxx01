class ConnectionPool {
  final int? minSize;
  final int? maxSize;
  final int? maxIdleTime;

  ConnectionPool({
    this.minSize = 1,
    this.maxSize = 10,
    this.maxIdleTime = 30000,
  });

  factory ConnectionPool.fromJson(Map<String, dynamic> json) {
    return ConnectionPool(
      minSize: json['minSize'] as int?,
      maxSize: json['maxSize'] as int?,
      maxIdleTime: json['maxIdleTime'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (minSize != null) 'minSize': minSize,
      if (maxSize != null) 'maxSize': maxSize,
      if (maxIdleTime != null) 'maxIdleTime': maxIdleTime,
    };
  }
}
