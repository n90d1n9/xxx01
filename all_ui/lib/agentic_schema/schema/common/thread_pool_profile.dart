class ThreadPoolProfile {
  final int? poolSize;
  final int? maxPoolSize;
  final int? keepAliveTime;
  final int? maxQueueSize;

  ThreadPoolProfile({
    this.poolSize = 10,
    this.maxPoolSize = 20,
    this.keepAliveTime = 60,
    this.maxQueueSize = 1000,
  });

  factory ThreadPoolProfile.fromJson(Map<String, dynamic> json) {
    return ThreadPoolProfile(
      poolSize: json['poolSize'] as int?,
      maxPoolSize: json['maxPoolSize'] as int?,
      keepAliveTime: json['keepAliveTime'] as int?,
      maxQueueSize: json['maxQueueSize'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (poolSize != null) 'poolSize': poolSize,
      if (maxPoolSize != null) 'maxPoolSize': maxPoolSize,
      if (keepAliveTime != null) 'keepAliveTime': keepAliveTime,
      if (maxQueueSize != null) 'maxQueueSize': maxQueueSize,
    };
  }
}
