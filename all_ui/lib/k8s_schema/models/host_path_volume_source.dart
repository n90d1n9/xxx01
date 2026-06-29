
class HostPathVolumeSource {final String path; final String? type; HostPathVolumeSource({required this.path, this.type}); factory HostPathVolumeSource.fromJson(Map<String, dynamic> json) {return HostPathVolumeSource(path: json['path'], type: json['type']);} Map<String, dynamic> toJson() {return {'path' : path, if (type != null) 'type' : type};}}
