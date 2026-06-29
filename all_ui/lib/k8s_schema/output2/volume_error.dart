class VolumeError {
  final DateTime? time;
  final String? message;
  VolumeError({this.time, this.message});
  factory VolumeError.fromJson(Map<String, dynamic> json) {
    return VolumeError(
      time: json['time'] != null ? DateTime.parse(json['time']) : null,
      message: json['message'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (time != null) 'time': time!.toIso8601String(),
      if (message != null) 'message': message,
    };
  }
}
