
class ContainerImage {final List<String> names; final int? sizeBytes; ContainerImage({required this.names, this.sizeBytes}); factory ContainerImage.fromJson(Map<String, dynamic> json) {return ContainerImage(names: List<String>.from(json['names']), sizeBytes: json['sizeBytes']);} Map<String, dynamic> toJson() {return {'names' : names, if (sizeBytes != null) 'sizeBytes' : sizeBytes};}}
