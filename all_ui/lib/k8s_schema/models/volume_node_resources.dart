
class VolumeNodeResources {final int? count; VolumeNodeResources({this.count}); factory VolumeNodeResources.fromJson(Map<String, dynamic> json) {return VolumeNodeResources(count: json['count']);} Map<String, dynamic> toJson() {return {if (count != null) 'count' : count};}}
