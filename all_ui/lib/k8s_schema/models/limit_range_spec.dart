
class LimitRangeSpec {final List<LimitRangeItem> limits; LimitRangeSpec({required this.limits}); factory LimitRangeSpec.fromJson(Map<String, dynamic> json) {return LimitRangeSpec(limits: (json['limits'] as List).map((e) => LimitRangeItem.fromJson(e)).toList());} Map<String, dynamic> toJson() {return {'limits' : limits.map((e) => e.toJson()).toList()};}}
